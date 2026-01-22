---@type vim.lsp.Config
return {
  settings = {
    nixd = {
      nixpkgs = {
        expr = [[
          let
            flake = builtins.getFlake (toString ./.);
          in import flake.inputs.nixpkgs {
            system = builtins.currentSystem;
            overlays = [
              flake.inputs.neovim-nightly-overlay.overlays.default
            ];
          }
        ]],
      },

      formatting = {
        command = { "alejandra" },
      },
    },
  },
}
