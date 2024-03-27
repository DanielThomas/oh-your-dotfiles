#!/usr/bin/env zsh
libdir=${0:a:h}
source $libdir/dotfiles.zsh
source $libdir/terminal.zsh
source $libdir/apt.zsh
source $libdir/homebrew.zsh
source $libdir/mas.zsh
source $libdir/git.zsh

function run_installers() {
  apt_install_upgrade
  brew_install_upgrade_formulas
  mas_install_upgrade_formulas

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
