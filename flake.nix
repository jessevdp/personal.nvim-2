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
    in {
      packages.default =
        (wrapNvim.apply {
          inherit pkgs;
          name = "nvim-wrapped-jessevdp";
          configRoot = ./.;
          extraPackages = with pkgs; [
            tree-sitter # for nvim-treesitter
          ];
        }).wrapper;

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
        ];
      };
    });
}
