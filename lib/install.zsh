#!/usr/bin/env zsh
libdir=${0:a:h}
source $libdir/dotfiles.zsh
source $libdir/terminal.zsh
source $libdir/homebrew.zsh
source $libdir/mas.zsh
source $libdir/git.zsh

function link_files() {
  case "$1" in
    link )
      link_file $2 $3
      ;;
    copy )
      copy_file $2 $3
      ;;
    git )
      git_clone_or_pull $2 $3
      ;;
    * )
      fail "Unknown link type: $1"
      ;;
  esac
}

function link_file() {
  ln -s -f $1 $2
  success "linked $1 to $2"
}

function copy_file() {
  mkdir -p $(dirname $2)
  cp $1 $2
  success "copied $1 to $2"
}

function open_file() {
  run "opening $1" "open $1"
  success "opened $1"
}

function install_file() {
  file_type=$1
  file_source=$2
  file_dest=$3
  if [ -f $file_dest ] || [ -d $file_dest ]; then
    overwrite=false
    backup=false
    skip=false

    if [ "$overwrite_all" = "false" ] && [ "$backup_all" = "false" ] && [ "$skip_all" = "false" ] && [ "$skip_all_silent" = "false" ] && [ "$force_all" = "false" ]; then
      user "File already exists: `basename $file_dest`, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
      read -r action

      case "$action" in
        o )
          overwrite=true;;
        O )
          overwrite_all=true;;
        b )
          backup=true;;
        B )
          backup_all=true;;
        s )
          skip=true;;
        S )
          skip_all=true;;
        * )
          ;;
      esac
    fi

    if [ "$overwrite" = "true" ] || [ "$overwrite_all" = "true" ]; then
      rm -rf "$file_dest"
      success "removed $file_dest"
      link_files $file_type $file_source $file_dest
    fi

    if [ "$backup" = "true" ] || [ "$backup_all" = "true" ]; then
      mv $file_dest $file_dest\.backup
      success "moved $file_dest to $file_dest.backup"
      link_files $file_type $file_source $file_dest
    fi

    if [[ "$force_all" = "true" ]] || [[ "$skip" = "false" && "$skip_all" = "false" && "$skip_all_silent" = "false" ]]; then
      link_files $file_type $file_source $file_dest
    elif [ "$skip_all_silent" = "false" ]; then
      success "skipped $file_source"
    fi
  else
    link_files $file_type $file_source $file_dest
  fi
}

function create_localrc() {
  LOCALRC=$HOME/.localrc
  if [ ! -f "$LOCALRC" ]; then
    echo "DEFAULT_USER=$USER" > $LOCALRC
    success "created $LOCALRC"
  fi
}

function dotfiles_install() {
  overwrite_all=false
  backup_all=false
  skip_all=false
  force_all=true

  # git repositories
  force_all=true
  for file_source in $(dotfiles_find \*.gitrepo); do
    file_dest="$HOME/.`basename \"${file_source%.*}\"`"
    install_file git $file_source $file_dest &
  done
  wait
  force_all=false

  # dotfiles can be in nested gitrepo files, so we continue until no destinations remain
  while true; do
    had_missing=false
    for file_source in $(dotfiles_find \*.gitrepo); do
      file_dest="$HOME/.`basename \"${file_source%.*}\"`"
      if [ ! -d "$file_dest" ]; then
        had_missing=true
        install_file git $file_source $file_dest &
      fi
      wait
    done
    if [ "$had_missing" = "false" ]; then
      break
    fi
  done

  force_all=true
  for file_source in $(dotfiles_find \*.themegitrepo); do
    file_dest="$HOME/.oh-my-zsh/custom/themes/`basename \"${file_source%.*}\"`"
    install_file git $file_source $file_dest &
  done
  wait
  force_all=false

  # symlinks
  for file_source in $(dotfiles_find \*.symlink); do
    file_dest="$HOME/.`basename \"${file_source%.*}\"`"
    if [ -L $file_dest ]; then
      if [ "$(readlink "$file_dest")" != "$file_source" ]; then
        install_file link $file_source $file_dest
      fi
    else
      install_file link $file_source $file_dest
    fi
  done

  # preferences
  for file_source in $(dotfiles_find \*.plist); do
    file_dest="$HOME/Library/Preferences/`basename $file_source`"
    install_file copy $file_source $file_dest
  done

  # gitconfig
  echo "[include]" > ~/.gitconfig
  for file_source in $(dotfiles_find \*.gitconfig); do
    echo "  path = $file_source" >> ~/.gitconfig
  done
  echo "  path = ~/user.gitconfig" >> ~/.gitconfig

  # fonts
  for file_source in $(dotfiles_find \*.otf); do
    file_dest="$HOME/Library/Fonts/$(basename $file_source)"
    install_file copy $file_source $file_dest
  done
  for file_source in $(dotfiles_find \*.ttf); do
    file_dest="$HOME/Library/Fonts/$(basename $file_source)"
    install_file copy $file_source $file_dest
  done
  for file_source in $(dotfiles_find \*.ttc); do
    file_dest="$HOME/Library/Fonts/$(basename $file_source)"
    install_file copy $file_source $file_dest
  done

  # launch agents
  for file_source in $(dotfiles_find \*.launchagent); do
    file_dest="$HOME/Library/LaunchAgents/$(basename $file_source | sed 's/.launchagent//')"
    install_file copy $file_source $file_dest
  done
}

function install_arch_list() {
  if sysctl -n machdep.cpu.brand_string | grep "Apple" > /dev/null; then
    echo "arm64e"
  fi
  echo "x86_64"
}

function install() {
  if sysctl -n machdep.cpu.brand_string | grep "Apple" > /dev/null; then
    if [ $(uname -m) != "arm64" ]; then
      fail "this command must be run on an arm64 terminal on Apple Silicon"
    fi
    if [[ ! -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
      run 'installing Rosetta' "/usr/sbin/softwareupdate --install-rosetta --agree-to-license"
    fi
  fi
  dotfiles_install
  for arch in $(install_arch_list); do
    info "running installers for $arch"
    arch -arch "$arch" "$libdir/install-arch.zsh"
  done
  create_localrc
}

function main() {
  skip_all_silent=false
  if [ "$1" = "update" ]; then
    info 'updating dotfiles'
    skip_all_silent=true
    install
    info 'complete! run dotfiles_reload or restart your session for environment changes to take effect'
  else
    info 'installing dotfiles'
    install
    info 'complete! use dotfiles_update to keep up to date. run dotfiles_reload or restart your session for environment changes to take effect'
  fi

  echo ''
}

main "$@"
