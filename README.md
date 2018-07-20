The flexibility of dotfiles meets the power of [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh).

Inspired by and compatible with [Zach Holman's dotfiles](https://github.com/holman/dotfiles).

## Install ##

1. Clone this repository to `$HOME/.oh-your-zshrc` and symlink `oh-your.zshrc` to `$HOME/.zshrc`.
2. ...

## Features ##

...

See https://github.com/DanielThomas/dotfiles for an example of a dotfiles repository.

## Built-in Functions ##

- `dotfiles` - list dotfiles locations
- `dotfiles_find` - find files within dotfiles locations, for example `dotfiles_find \*.gitrepo`
- `dotfiles_install` - run dotfiles installers
- `dotfiles_update` - update dotfiles installed files. Equivalent to running `dotfiles_install` and choosing `S` to skip existing

## How it works ##

Dotfiles sources are found using the pattern `$HOME/.*dotfiles*`.

The files within are processed automatically by `.zshrc` or the installation process depending on their extension. Scripts set the environment, manage files, perform installation or enable plugins depending on the file name or extension. Bootstrap can be safely run repeatedly, you'll be prompted for the action you want to take if a destination file or directory already exists.

### Environment ###

These files set your shell's environment:

- `path.zsh`: Loaded first, and expected to setup `$PATH`
- `*.zsh`: Get loaded into your environment
- `completion.zsh`: Loaded last, and expected to setup autocomplete

### Files ###

The following extensions will cause files to be created in your home directory:

- `*.symlink`: Automaticlly symlinked into your `$HOME` as a dot file during bootstrap. For example, `myfile.symlink` will be linked as `$HOME/.myfile`
- `*.gitrepo`: Contains a URL to a Git repository to be cloned as a dotfile. For example `myrepo.gitrepo` will be cloned to `$HOME/.myrepo`
- `*.gitpatch`: Name `repo-<number>.gitpatch` to apply custom patches to a `gitrepo` repository
- `*.otf`, `*.ttf`, `*.ttc`: Fonts are copied to `~/Library/Fonts` during bootstrap
- `*.plist`: Preference lists are copied to `~/Library/Preferences` during bootstrap
- `*.launchagent`: Files are copied to `~/Library/LaunchAgents` during bootstrap

### Installers ###

Installation steps during bootstrap can be handled in three ways:

- `install.sh`: An installation shellscript
- `install.homebrew`: A list of Homebrew formulas to install
- `install.homebrew-cask`: A list of Homebrew casks to install
- `install.homebrew-tap`: A list of Homebrew taps
- `install.mas`: A list of App Store apps to install
- `install.open`: A list of files to be handled by the default application association using the `open` command

#### Installing from the App Store with `install.mas` files ####

Applications from the App Store are referenced by a numeric id rather than a name.
In order to find out the id you can use the command `mas search <term>`.
Entries in `install.mas` should be in the format `<id> <name>` (the same format as the results of `mas search`).

### Plugins ###

- All topic directory names are implicitly added to the plugin list, so you get `osx` and `brew` automatically
- Plugins listed in `oh-my-zsh.plugins` files are read and added to this list

## Profiling Startup Time ##

If your shell is taking an excessive amount of time to start, run `zsh` with the `PROFILE_STARTUP` environment variable:

    PROFILE_STARTUP=true zsh

Then run `tools/startlog.py` against the output in `/tmp` to determine the contributors to startup time. For more details, see:

[https://kev.inburke.com/kevin/profiling-zsh-startup-time/](https://kev.inburke.com/kevin/profiling-zsh-startup-time/)
