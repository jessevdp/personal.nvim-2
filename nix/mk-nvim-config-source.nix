{pkgs, ...}: {root}: let
  inherit (pkgs) lib;

  entries = [
    "init.lua"
    "after/"

    # see :h runtimepath / vimfiles
    "filetype.lua" # filetypes (:h new-filetype)
    "autoload/"    # automatically loaded scripts (:h autoload-functions)
    "colors/"      # color scheme files (:h colorscheme)
    "compiler/"    # compiler files (:h compiler)
    "doc/"         # documentation (:h write-local-help)
    "ftplugin/"    # filetype plugins (:h write-filetype-plugin)
    "indent/"      # indent scripts (:h indent-expression)
    "keymap/"      # key mapping files (:h mbyte-keymap)
    "lang/"        # menu translations (:h menutrans)
    "lsp/"         # LSP client configurations (:h lsp-config)
    "lua/"         # (:h Lua) plugins
    "menu.vim"     # GUI menus (:h menu.vim)
    "pack/"        # packages (:h packadd)
    "parser/"      # treesitter syntax parsers (:h treesitter)
    "plugin/"      # plugin scripts (:h write-plugin)
    "queries/"     # treesitter queries (:h treesitter)
    "rplugin/"     # remote-plugin scripts (:h remote-plugin)
    "spell/"       # spell checking files (:h spell)
    "syntax/"      # syntax files (:h mysyntaxfile)
    "tutor/"       # tutorial files (:h Tutor)

  ];

  relativeEntries = map (entry: lib.path.append root entry) entries;
  existingEntries = with builtins; filter pathExists relativeEntries;
in
  lib.fileset.toSource {
    inherit root;
    fileset =
      lib.fileset.intersection
      (lib.fileset.unions existingEntries)
      (lib.fileset.gitTracked root);
  }
