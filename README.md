# personal-nvim

Portable Neovim (nightly) configuration.

## Installation

#### Clone

**Prerequisites:**
- Git
- [Tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) (for nvim-treesitter)
- [ripgrep](https://github.com/BurntSushi/ripgrep) ([optional](https://neovim.io/doc/user/options.html#'grepprg'))

Clone into your Neovim config directory:

```bash
git clone https://github.com/jessevdp/personal-nvim ~/.config/nvim
```

> [!NOTE]
> The default location is `~/.config/nvim`. You can customize this with [`XDG_CONFIG_HOME`](https://neovim.io/doc/user/starting.html#%24XDG_CONFIG_HOME) or [`NVIM_APPNAME`](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME).

#### Nix

A wrapped version of Neovim is available via Nix. It bundles all dependencies & config. Run it like:

```bash
nix run github:<username>/<repo>
```

## Contributing / Development

See [CONTRIBUTING.md](./CONTRIBUTING.md).
