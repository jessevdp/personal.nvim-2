{ wrappers, ... }:
wrappers.lib.wrapModule ({config, lib, ...}: let
  mkNvimConfigSource = import ./mk-nvim-config-source.nix {
    inherit (config) pkgs;
  };

  configSource = mkNvimConfigSource {
    root = config.configRoot;
  };

  xdgConfigPackage = config.pkgs.runCommand "xdg-config-${config.name}" { src = configSource; } ''
    mkdir -p "$out/${config.name}"
    cp -R "$src/." "$out/${config.name}/"
    if [ -f "$out/${config.name}/init.lua" ]; then
      rm "$out/${config.name}/init.lua"
    fi
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
      NVIM_APPNAME = config.name;
      XDG_CONFIG_DIRS = "${xdgConfigPackage}\${XDG_CONFIG_DIRS:+:$XDG_CONFIG_DIRS}";
    };
    flags = {
      "-u" = "${configSource}/init.lua";
    };
    extraPackages = [
      config.ripgrepPackage
      config.gitPackage
    ];
  };
})
