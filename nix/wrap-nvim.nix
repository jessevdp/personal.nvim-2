{wrappers, ...}:
wrappers.lib.wrapModule ({
  config,
  lib,
  ...
}: let
  mkNvimConfigSource = import ./mk-nvim-config-source.nix {
    inherit (config) pkgs;
  };

  configSource = mkNvimConfigSource {
    root = config.configRoot;
  };

  wrappedInit =
    config.pkgs.writeText "${config.name}-init.lua"
    # lua
    ''
      dofile([[${./nvim-pack-lock-install.lua}]]).run({
        source_path = [[${configSource}/nvim-pack-lock.json]],
        wants_symlink = false,
      })

      dofile([[${configSource}/init.lua]])
    '';

  # XDG_CONFIG_DIRS expects <dir>/<appname>/.
  xdgConfigDir =
    config.pkgs.runCommand "xdg-config-${config.name}" {}
    # sh
    ''
      mkdir -p "$out/${config.name}"
      for f in ${configSource}/*; do
        [ "$(basename "$f")" = "init.lua" ] && continue
        ln -s "$f" "$out/${config.name}/"
      done
      ln -s ${wrappedInit} "$out/${config.name}/init.lua"
    '';
in {
  options = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "NVIM_APPNAME";
    };

    configRoot = lib.mkOption {
      type = lib.types.path;
      description = "Path to your '~/.config/nvim'-like tree.";
    };

    gitPackage = lib.mkOption {
      type = lib.types.package;
      default = config.pkgs.git;
    };

    ripgrepPackage = lib.mkOption {
      type = lib.types.package;
      default = config.pkgs.ripgrep;
    };
  };
  config = {
    package = config.pkgs.neovim;
    env = {
      NVIM_APPNAME = "\${NVIM_APPNAME:-${config.name}}";
      XDG_CONFIG_DIRS = "${xdgConfigDir}\${XDG_CONFIG_DIRS:+:\$XDG_CONFIG_DIRS}";
    };
    extraPackages = [
      config.ripgrepPackage
      config.gitPackage
    ];
  };
})
