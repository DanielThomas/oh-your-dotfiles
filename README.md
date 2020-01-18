*You got your Oh My Zsh in my dotfiles!*

The flexibility of dotfiles meets the power of [Oh My Zsh](https://github.com/robbyrussell/oh-my-zsh) and [Homebrew](https://brew.sh/).

Inspired by and compatible with [Zach Holman's dotfiles](https://github.com/holman/dotfiles).

## Install ##

The framework is only currently tested on macOS.

1. Clone this repository to `~/.oh-your-dotfiles`
```
git clone https://github.com/DanielThomas/oh-your-dotfiles.git ~/.oh-your-dotfiles
```
2. Link the zshrc file to `~/.zshrc`
```
ln -s ~/.oh-your-dotfiles/oh-your.zshrc ~/.zshrc
```
3. If you're not on a macOS release where it's the default, change your default shell to `zsh`
```
chsh -s /bin/zsh
```
4. Start a new terminal session and run `dotfiles_install`. If you haven't yet got the Command-line Developer Tools installed you'll be prompted to install them (On Apple Silicon run installations/updates only under the a native Terminal)

### Post Install ###

After installation, optionally switch to the Homebrew managed `zsh`:

```
sudo sh -c "echo /usr/local/bin/zsh >> /etc/shells"
chsh -s /usr/local/bin/zsh
```

You're good to go! 

Create yourself a dotfiles repository using the conventions below. See https://github.com/DanielThomas/dotfiles for an example of a dotfiles repository.

## Built-in Functions ##

- `dotfiles` - list dotfiles locations
- `dotfiles_find` - find files within dotfiles locations, for example `dotfiles_find \*.gitrepo`
- `dotfiles_install` - run dotfiles installers
- `dotfiles_update` - update dotfiles installed files. Equivalent to running `dotfiles_install` and choosing `S` to skip existing

## How it works ##

Dotfiles sources are found using the pattern `$HOME/.*dotfiles*`.

The files within are processed automatically by `.zshrc` or the installation process depending on their extension. 

Scripts set the environment, manage files, perform installation or enable plugins depending on the file name or extension. Bootstrap can be safely run repeatedly, you'll be prompted for the action you want to take if a destination file or directory already exists.

### Architecture ###

The file conventions support an architecture suffix, for instance `path.zsh.x86_64` or `path.zsh.arm64` which will make the configuration apply conditionally to that architecture.

Installers are run regardless of the prevailing architecture if the machine supports that architecture (i.e. `x86_64` on `arm64` via Rosetta 2) using `arch` to force the architecture. The `brew` command is also shimmed with a function to use the architecture specific location, `/usr/local` for `x86_64` and `/opt/homebrew` for `arm64` based on the prevailing architecture, run `brew` with `arch -x86_64 brew` in an `arm64` terminal to manually install Intel formulas/casks.

Installer files without a suffix are assumed to be universal and are run using the native architecture for the machine. For files that are strictly compatible with a native architecture, add `-native`, for instance `x86_64-native` to indicate that it should be ignored even with `x86_64` translation.

### Environment ###

These files set your shell's environment:

- `oh-my-zsh.zsh` Loaded before oh my zsh is sourced, useful for configuration of a theme (ZSH_THEME)
- `path.zsh`: Loaded first after oh my zsh is sourced, and expected to setup `$PATH`
- `*.zsh`: Get loaded into your environment
- `completion.zsh`: Loaded last, and expected to setup autocomplete

### Files ###

The following extensions will cause files to be created in your home directory:

- `*.symlink`: Automaticlly symlinked into your `$HOME` as a dot file during bootstrap. For example, `myfile.symlink` will be linked as `$HOME/.myfile`
- `*.gitrepo`: Contains a URL to a Git repository to be cloned as a dotfile. For example `myrepo.gitrepo` will be cloned to `$HOME/.myrepo`
- `*.gitconfig`: These file are `include.path`ed into `$HOME/.gitconfig`. Additional local configuration can be added to `$HOME/user.gitconfig`.
- `*.themegitrepo`: Contains a URL to a Git repository to be cloned as a custom zsh theme. For example `mytheme.gitrepo` will be cloned to `$HOME/.oh-my-zsh/custom/themes/mytheme`
- `*.gitpatch`: Name `repo-<number>.gitpatch` to apply custom patches to a `gitrepo` repository
- `*.otf`, `*.ttf`, `*.ttc`: Fonts are copied to `~/Library/Fonts` during bootstrap
- `*.plist`: Preference lists are copied to `~/Library/Preferences` during bootstrap
- `*.launchagent`: Files are copied to `~/Library/LaunchAgents` during bootstrap

### Installers ###

Installation steps during bootstrap can be handled in several ways:

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
