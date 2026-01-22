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

  nvimInit =
    config.pkgs.writeText "nvim-init.lua"
    # lua
    ''
      dofile([[${./nvim-pack-lock-install.lua}]]).run({
        source_path = [[${configSource}/nvim-pack-lock.json]],
        wanst_symlink = false,
      })

      vim.env.MYVIMRC = [[${configSource}/init.lua]]
      vim.opt.runtimepath:prepend([[${configSource}]])
      vim.opt.runtimepath:append([[${configSource}/after]])

      vim.cmd.source([[${configSource}/init.lua]])
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
      VIMINIT = "luafile ${nvimInit}";
    };
    extraPackages = [
      config.ripgrepPackage
      config.gitPackage
    ];
  };
})
