# Contributing

## Nix

This flake exposes a wrapped version of `nvim` that bundles this config along with dependencies & a specific version of `nvim`. It is exposed as the flake's default package. Run it with:

```bash
nix run <path-to-flake>
```

#### Development

`vim.pack` expects its lockfile at a fixed location: `stdpath('config')/nvim-pack-lock.json`. This path is [not (yet) configurable](https://github.com/neovim/neovim/issues/27539). The wrapped version of `nvim` uses [`nix/nvim-pack-lock-install.lua`](./nix/nvim-pack-lock-install.lua) to install the lockfile (which is part of the flake & tracked in git) to Neovim's expected location on startup.

For development, updates to the lockfile need to land back in the repo. We can configure [`nix/nvim-pack-lock-install.lua`](./nix/nvim-pack-lock-install.lua) to install a symlink back to the repo in place of the `nvim-pack-lock.json` instead of a copy of the lockfile. This ensures `vim.pack` updates (e.g., `:lua vim.pack.update()`) land back in the repo to be committed.

This is achieved using the `NVIM_PACK_LOCK_ISNTALL_` ENV variables:

```sh
NVIM_PACK_LOCK_INSTALL_SYMLINK=1 \
NVIM_PACK_LOCK_INSTALL_SOURCE_PATH=/path/to/repo/nvim-pack-lock.json \
nix run <path-to-flake>
```

For convenience, the dev shell configures these ENV variables. Enter the dev shell manually by running:

```sh
nix develop
```

(With [direnv](https://direnv.net/), the dev shell activates automatically (see [.envrc](./.envrc)).)

Once in the dev shell, just running the wrapped `nvim` will ensure its lockfile points back to the one tracked in the repo:

```sh
nix run <path-to-flake> # e.g. `nix run .`
```
