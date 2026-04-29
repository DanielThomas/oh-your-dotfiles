#!/usr/bin/env zsh

if [ -n "$DOTFILES_XTRACE" ]; then
  setopt xtrace
fi

libdir=${0:a:h}
source $libdir/dotfiles.zsh
source $libdir/terminal.zsh
source $libdir/homebrew.zsh
if [[ "Linux" == "$(uname)" ]]; then
  source $libdir/apt.zsh
fi
if [[ "Darwin" == "$(uname)" ]]; then
  source $libdir/mas.zsh
fi
source $libdir/git.zsh

function run_installers() {
  if [[ "Linux" == "$(uname)" ]]; then
    apt_install_upgrade
  fi
  brew_install_upgrade_formulas
  if [[ "Darwin" == "$(uname)" ]]; then
    mas_install_upgrade_formulas
  fi

  dotfiles_find_installer install.sh | while read installer ; do run "running ${installer}" "${installer}" ; done

  for file_source in $(dotfiles_find_installer install.open); do
    OLD_IFS=$IFS
    IFS=$'\n'
    basedir="$(dirname $file_source)"
    for file in `cat $file_source`; do
      canonical_file="$basedir/$file"
      open_file "$canonical_file"
    done
    IFS=$OLD_IFS
  done
}

function run_postinstall() {
  dotfiles_find_installer post-install.sh | while read installer ; do run "running ${installer}" "${installer}" ; done
}

function main() {
  run_installers
  run_postinstall
}

main "$@"
