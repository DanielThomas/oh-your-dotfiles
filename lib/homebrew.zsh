function install_formulas() {
  # assume that the installer did it's job, and use the default path for brew if it's not there already
  if ! test $(which brew); then
    source $DOTFILES_ROOT/brew/path.zsh
  fi

  for file in `dotfiles_find install.homebrew-cask`; do
    for formula in `cat $file`; do
      brew_install $formula cask
    done
  done

  for file in `dotfiles_find install.homebrew`; do
    for formula in `cat $file`; do
      brew_install $formula
    done
  done
}

function brew_install() {
  formula=$1
  if ! brew $2 ls --versions $formula 2> /dev/null | grep -q $formula; then
    if brew $2 install $formula > /dev/null 2>&1; then
      success "installed $formula"
    else
      fail "failed to install $formula"
    fi
  fi
}

function upgrade_formulas() {
  run "updating homebrew" "brew update"
  brew_upgrade
  brew_upgrade cask
}

function brew_upgrade() {
  info "upgrading homebrew $1"
  for update in $(brew $1 outdated); do
    formula=$(echo "$update" | cut -d ' ' -f 1)
    run "upgrading $update" "brew $1 upgrade $formula"
  done
}
