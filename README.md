# Danny's dotfiles #

Opinionated dotfiles repository for Mac OS with zsh and iTerm 2. Including Homebrew, Solarised and oh-my-zsh with the Agnoster theme.

Inspired by Zach Holman's dotfiles - https://github.com/holman/dotfiles.

## Install ##

- Assuming a clean install, run `xcode-select --install` to install the Developer Tools
- Fork and clone the repository `git clone <repopath> ~/.dotfiles`
- Start Terminal for installation (iTerm, fonts, colour schemes and preferences lists are automatically installed as part of the bootstrap, and iTerm will overwrite settings on exit)
- Run the bootstrap:`cd ~/.dotfiles; ./bootstrap.sh`. You'll be prompted at least once for your password for the Homebrew install
- Set `zsh` as your default shell: `sudo sh -c 'echo /usr/local/bin/zsh >> /etc/shells'; chsh -s /usr/local/bin/zsh`
- Start iTerm. If you see `zsh compinit: insecure directories` warnings, run: `compaudit | xargs chmod g-w`

## Local configuration ##

- Use `~/.localdotfiles` to keep anything you don't want to make public. It support the same structure as as this repository
- In particular, update `~/.gitconfig`:
    - Update the absolute paths for the includes (JGit doesn't support relative paths, so I have to keep them hard coded unfortunately)
    - There is a default include for `.gitconfig_local` to include your user configuration etc. Create it manually, or add a `gitconfig_local.symlink` file in `~/.localdotfiles`

## Update ##

Use `upgrade_dotfiles` to automatically update everything bootstrapped by the repository.

## Features ##

The repository is ordered by topic. Refer to the readme files in the individual topic directories for details of the features they provide.

## How it works ##

Files are processed automatically by `.zshrc` or the bootstrap process depending on their extension. Scripts set the environment, manage files, perform installation or enable plugins depending on the file name or extension. Bootstrap can be safely run repeatedly, you'll be prompted for the action you want to take if a destination file or directory already exists.

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
- `install.open`: A list of files to be handled by the default application association using the `open` command

### Plugins ###

- All topic directory names are implicitly added to the plugin list, so you get `osx` and `brew` automatically
- Plugins listed in `oh-my-zsh.plugins` files are read and added to this list

## Profiling Startup Time ##

If your shell is taking an excessive amount of time to start, run `zsh` with the `PROFILE_STARTUP` environment variable:

    PROFILE_STARTUP=true zsh

Then run `scripts/startlog.py` against the output in `/tmp` to determine the contributors to startup time. For more details, see:

[https://kev.inburke.com/kevin/profiling-zsh-startup-time/](https://kev.inburke.com/kevin/profiling-zsh-startup-time/)
