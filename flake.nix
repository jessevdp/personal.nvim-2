{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wrappers = {
      url = "github:lassulus/wrappers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    wrappers,
    neovim-nightly-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          neovim-nightly-overlay.overlays.default
        ];
      };

      wrapNvim = import ./nix/wrap-nvim.nix {inherit wrappers;};
      nvimWrapped =
        (wrapNvim.apply {
          inherit pkgs;
          name = "nvim-wrapped-jessevdp";
          configRoot = ./.;
          extraPackages = with pkgs; [
            tree-sitter # for nvim-treesitter
          ];
        }).wrapper;
    in {
      packages.default = nvimWrapped;

      checks = import ./nix/checks {
        inherit pkgs nvimWrapped;
        src = ./.;
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          lua-language-server
          nil
          nixd
          stylua
          vscode-json-languageserver
        ];
        shellHook =
          # sh
          ''
            # Ensure ./nix/nvim-pack-lock-install.lua installs a symlink back to
            # the repo in place of the lockfile. This way changes to the lockfile
            # land back in the repo to be comitted.
            # See ./nix/nvim-pack-lock-install.lua for more details.
            export NVIM_PACK_LOCK_INSTALL_SOURCE_PATH="$PWD/nvim-pack-lock.json"
            export NVIM_PACK_LOCK_INSTALL_SYMLINK=1
          '';
      };
    });
}
