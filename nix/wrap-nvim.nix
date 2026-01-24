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
      NVIM_APPNAME = config.name;
      VIMINIT =
        "let \\$MYVIMRC='${configSource}/init.lua'"
        + " | set runtimepath^=${configSource}"
        + " | set runtimepath+=${configSource}/after"
        + " | source ${configSource}/init.lua";
    };
    extraPackages = [
      config.ripgrepPackage
      config.gitPackage
    ];
  };
})
