<div align="center">

### `dotfiles`

If this doesn't power my workflows, what does?

</div>

### Overview

Concise manual for these macOS dotfiles.

- [`.zshrc`](.zshrc): shell aliases plus `fzf`, `zoxide`, and `eza` setup.
- [`.tmux.conf`](.tmux.conf): a `Ctrl+a` prefix that stays inactive in WezTerm.
- [`.wezterm.lua`](.wezterm.lua): WezTerm panes, tabs, workspaces, launcher, quick-select, and Neovim pane handoff.
- [`nvim/`](nvim): Neovim setup for LSP, Telescope, Neo-tree, formatting, linting, debugging, tests, sessions, and custom UI.

The Neovim config started from [theovim](https://github.com/theopn/theovim) and is now customized. WezTerm and Neovim both use Tokyo Night.

```text
.
├── .zshrc
├── .tmux.conf
├── .wezterm.lua
├── bin
│   └── tmux-client-is-wezterm
├── install.sh
└── nvim
    ├── init.lua
    ├── lazy-lock.json
    ├── lua/{plugins,ui}
    ├── after/ftplugin
    └── doc
```

### Install

Run from the repo root:

```sh
brew bundle --file Brewfile
./install.sh
```

The [Brewfile](Brewfile) installs the Homebrew-managed CLI tools, apps, and fonts. The installer links `~/.zshrc`, `~/.tmux.conf`, and the tmux client helper to their tracked files, backs up existing files, installs Oh My Zsh helpers, and keeps a few shell-tool/font checks for direct installer usage.

### Shell

[`.zshrc`](.zshrc) enables:

- `fzf --zsh` for fuzzy history, file, and completion widgets
- `zoxide` through `z` for frecent directory jumping
- `eza` aliases: `ls`, `ll`, `la`, `lt`

### WezTerm

Defaults:

- shell: `zsh -l`
- theme: `Tokyo Night`
- variants: `tokyonight`, `tokyonight-night`, `tokyonight-storm`, `tokyonight-moon`, `tokyonight-day`
- font fallback: JetBrains Mono Nerd Font, IosevkaTerm Nerd Font, Symbols Nerd Font Mono, Menlo
- 90% opacity, macOS blur, resize-only decorations
- status: workspace/key table/leader on the left, cwd/process/time on the right
- inactive panes are dimmed

Leader key: `Ctrl+a`. Press it, then press a command key within 1000 ms.

### WezTerm Cheatsheet

- Panes: `Ctrl+a s` split vertically, `Ctrl+a v` split horizontally, `Ctrl+a h/j/k/l` move, `Ctrl+a q` close, `Ctrl+a z` zoom, `Ctrl+a o` rotate, `Ctrl+a r` resize mode.
- Resize mode: `h/j/k/l` resize, `Esc` or `Enter` exits.
- Neovim-aware movement: `Alt+h/j/k/l` moves across WezTerm panes or hands off to Neovim; `Alt+Arrow` resizes panes.
- Tabs: `Ctrl+a t` new tab, `Ctrl+a [` / `]` previous/next, `Ctrl+a n` navigator, `Ctrl+a e` rename, `Ctrl+a 1..9` jump.
- Tab moving: `Ctrl+a m` enters move mode; `h/j` moves left, `k/l` moves right, `Esc` or `Enter` exits. `Ctrl+a Shift+{` / `Shift+}` also move the current tab.
- Workspaces: `Ctrl+a w` fuzzy launcher, `Ctrl+a p` switch/create workspace from current cwd, `Ctrl+a Shift+p` prompt for a workspace name from current cwd.
- Copy/search/tools: `Ctrl+a c` copy mode, `Ctrl+a f` quick-select paths/hashes/URLs/tokens, `Ctrl+a /` search scrollback, `Ctrl+a Space` command palette.

Launch menu entries include `Home`, `Dotfiles`, and `Neovim Config`.

Suggested flow: open WezTerm, jump with `Ctrl+a w`, create a project workspace with `Ctrl+a p`, split with `Ctrl+a s/v`, and move between terminal panes and Neovim with `Alt+h/j/k/l`.

### tmux

[`.tmux.conf`](.tmux.conf) uses the same `Ctrl+a` prefix as WezTerm. Outside WezTerm, press `Ctrl+a Ctrl+a` to send `Ctrl+a` to the active pane. Inside WezTerm, tmux passes `Ctrl+a` through without activating its prefix so WezTerm owns the leader key. The active client's process tree determines the behavior, so it remains correct when terminals share a tmux server.

### Neovim

Entry point: [`nvim/init.lua`](nvim/init.lua). Plugins are in [`nvim/lua/plugins`](nvim/lua/plugins); custom UI modules are in [`nvim/lua/ui`](nvim/lua/ui).

Main features:

- `lazy.nvim`, transparent theme setup, custom dashboard/statusline/tabline
- Mason-backed LSP servers, format-on-save, optional linting
- Telescope search and Neo-tree file explorer
- DAP debugging, terminal-based tests, persistent undo, session restore

Core behavior:

- relative numbers, cursor line/column, mouse, true color, visible whitespace
- smart case search, `inccommand=split`
- vertical splits right, horizontal splits below
- `Esc` clears search highlighting
- `j/k`, `n/N`, and `Ctrl+d/u` keep movement centered/ergonomic

#### Neovim Cheatsheet

- General: `Esc` clears search, `Esc Esc` leaves terminal mode, `Ctrl+s` fixes nearest spelling suggestion in insert mode.
- Clipboard/selection: `<leader>a` select all, `<leader>y` yank visual selection to system clipboard, `<leader>p` shows registers in normal mode or replaces visual selection without overwriting the unnamed register.
- Buffers: `[b` / `]b` previous/next, `<leader>b` prepare `:b`, `<leader>k` prepare `:bdelete`.
- Tabs/windows: `gt` / `gT` next/previous tab, `{count}gt` jump to tab, `Ctrl+h/j/k/l` move or create splits, `Alt+h/j/k/l` move across Neovim/WezTerm, `Alt+Arrow` resize, `Ctrl+w +/-/</>` resize Vim windows.
- Terminals: `<leader>tt` or `:Floaterminal` toggles the floating terminal, `<leader>tb` opens a bottom terminal, `<leader>tr` opens a right terminal.
- Commands: `:TrimWhitespace` removes trailing whitespace; `:CD` sets local cwd to the current file directory.
- Neo-tree: `<leader>n` toggle/reveal, `Enter` open, `t` open in new tab, `q` close, `?` help, `Ctrl+h/l` move between tree and editor, `Ctrl+w w` cycle windows.
- Telescope: `<leader>sf` files, `<leader>sg` live grep, `<leader>/` current buffer, `<leader><leader>` buffers, `<leader>s.` recent files, `<leader>sr` resume, `<leader>sn` Neovim config, `<leader>fb` file browser.
- More Telescope: `<leader>sh` help, `<leader>sk` keymaps, `<leader>ss` pickers, `<leader>sw` current word, `<leader>sd` diagnostics, `<leader>s/` grep open files.
- Git: `<leader>gf/gc/gs` Git files/commits/status, `<leader>gg` Neogit, `<leader>gl` log graph, `<leader>gb/gB` full/inline blame, `<leader>gp` hunk preview, `<leader>gd` buffer diff, `<leader>go/gq` open/close Diffview, `<leader>gh/gH` file/repo history, `]h/[h` next/previous hunk.
- Diagnostics/LSP: `[d/]d` previous/next diagnostic, `<leader>e` diagnostic float, `<leader>q` location list, `gd/gr/gI/gD` definition/references/implementation/declaration, `<leader>D` type definition, `<leader>ds/ws` symbols, `<leader>rn` rename, `<leader>ca` code action, `<leader>th` inlay hints.
- Formatting/linting: `<leader>F` or `<leader>cf` format buffer, `<leader>cl` lint current buffer.
- Debugging: `<leader>db` breakpoint, `<leader>dB` conditional breakpoint, `<leader>dc` continue/start, `<leader>di/do/dO` step into/over/out, `<leader>dr` REPL, `<leader>dt` terminate, `<leader>du` UI, `<leader>dl` last config, `<leader>dn/dN` nearest/last Go test.
- Tests/sessions: `<leader>tn/tf/ts/tl/tv` nearest/file/suite/last/output; `<leader>wr/wl/wd` restore cwd/last session or stop saving sessions.
- Completion/snippets: `Ctrl+n/j` next, `Ctrl+p/k` previous, `Ctrl+e` abort, `Ctrl+b/f` scroll docs, `Ctrl+y` or `Enter` confirm, `Ctrl+Space` trigger, `Tab` / `Shift+Tab` item or snippet jump, `Ctrl+l/h` snippet forward/back.
- Editing helpers: `gc` comments, `sa/sd/sr/sf/sF/sh/sn` surrounds, `a/i` textobjects from `mini.ai`, autopairs, colorizer, TODO jumps with `]t/[t`.
- Treesitter selection: `Ctrl+Space` start/expand, `Ctrl+s` expand scope, `Alt+Space` shrink.

#### Language Support

- Managed LSP servers: `bashls`, `clangd`, `gopls`, `helm_ls`, `jdtls`, `lua_ls`, `pyright`, `rust_analyzer`, `taplo`, `texlab`, `yamlls`.
- Configured linters: `shellcheck`, `ruff`, `luacheck`, `markdownlint`.
- DAP tools installed through Mason: `codelldb`, `delve`, `debugpy`.
- Java uses `nvim-java` for jdtls, DAP, test runner, build helpers, runtime switching, and refactors.
- Treesitter enables highlighting, indentation, and incremental selection for common shell, C/C++, Go, Java, JSON, LaTeX, Lua, Markdown, Python, Rust, TOML, Vim, and YAML files.
- [`nvim/after/ftplugin`](nvim/after/ftplugin) adds spell checking for Markdown/TeX/text, `:RunPython`, `:RunC`, `:RunCpp`, `:RunLua`, and Java indentation defaults.

Useful Java commands:

- `:JavaDap config`
- `:JavaTest runCurrentClass`
- `:JavaTest runCurrentMethod`
- `:JavaTest debugCurrentClass`
- `:JavaTest debugCurrentMethod`
- `:JavaBuild buildWorkspace`
- `:JavaSettings changeRuntime`
- `:JavaRefactor extractVariable`
- `:JavaRefactor extractMethod`

Suggested flow: open a project with `nvim .`, restore with `<leader>wl`, browse with `<leader>n` or search with `<leader>sf/<leader>sg`, use LSP actions, save for format-on-save, run `<leader>cl` when needed, test with `<leader>tn/<leader>tf`, debug with `<leader>dc`, and move across terminal/editor panes with `Alt+h/j/k/l`.

### Dependencies

Homebrew dependencies are managed in [Brewfile](Brewfile). Run:

```sh
brew bundle --file Brewfile
```

Notes:

- Run `xcode-select --install` before `brew bundle` on a new Mac.
- After installing `rustup-init`, run `rustup default stable` and `rustup component add rustfmt` if you use Rust formatting.
- Go formatters that are usually installed outside Homebrew: `go install mvdan.cc/gofumpt@latest` and `go install golang.org/x/tools/cmd/goimports@latest`.
- Treesitter downloads newly added parsers on first start after updates.
- `nvim-java` installs jdtls, the Java debug adapter, and test bundles through Mason on first use.

### Customize

Main files to edit:

- [`.zshrc`](.zshrc)
- [`.wezterm.lua`](.wezterm.lua)
- [`nvim/init.lua`](nvim/init.lua)
- [`nvim/lua/plugins/`](nvim/lua/plugins)
- [`nvim/lua/ui/`](nvim/lua/ui)
- [`nvim/after/ftplugin/`](nvim/after/ftplugin)
