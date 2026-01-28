{
  pkgs,
  nvimWrapped,
}: let
  packLockfileSourcePath = nvimWrapped.configuration.packLockfileSourcePath;

  mkTest = {
    name,
    setup ? "",
    test,
  }: let
    setupFile =
      pkgs.writeText "setup-${name}.lua"
      # lua
      ''
        ${setup}
      '';

    testFile =
      pkgs.writeText "test-${name}.lua"
      # lua
      ''
        local ok, err = xpcall(function()
          -- Wait for scheduled callbacks to run
          vim.wait(100, function() return false end)

          ${test}
        end, debug.traceback)

        if not ok then
          io.stderr:write("\n\nTEST FAILED\n\n" .. tostring(err) .. "\n\n")
          vim.cmd("cq!")  -- quit with error code
        else
          vim.cmd("qa!")  -- quit successfully
        end
      '';
  in
    pkgs.runCommand "test-${name}" {
      nativeBuildInputs = [nvimWrapped pkgs.cacert];
      inherit packLockfileSourcePath;

      # SSL certificates for git/curl (used by vim.pack)
      SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    } ''
      export HOME=$TMPDIR/home
      mkdir -p $HOME
      export XDG_CONFIG_HOME="$HOME/.config"

      nvim --headless \
        --cmd "luafile ${setupFile}" \
        -c "luafile ${testFile}"

      touch $out
    '';

  dir = builtins.readDir ./tests;
  testFiles =
    builtins.filter
    (name: builtins.match ".*\\.nix" name != null)
    (builtins.attrNames dir);

  importTestFile = filename: let
    testDefs = import (./tests + "/${filename}") {};
  in
    pkgs.lib.mapAttrs' (name: testDef: {
      name = "test-${name}";
      value = mkTest ({name = name;} // testDef);
    })
    testDefs;
in
  builtins.foldl' (acc: file: acc // importTestFile file) {} testFiles
