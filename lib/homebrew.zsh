brew_installed=""

function brew_install_formulas() {
  brew_installed=$(brew cask ls --versions 2> /dev/null)
  for file in `dotfiles_find install.homebrew-cask`; do
    for formula in `cat $file`; do
      brew_install $formula cask
    done
  done

  brew_installed=$(brew ls --versions 2> /dev/null)
  for file in `dotfiles_find install.homebrew`; do
    for formula in `cat $file`; do
      brew_install $formula
    done
  done
}

function brew_upgrade_formulas() {
  run 'updating homebrew' 'brew update'
  brew_upgrade &
  brew_upgrade cask &
  wait
}

function brew_install() {
  brew_check_and_install
  formula=$1
  if ! echo $brew_installed | grep -q $formula; then
    if brew $2 install $formula > /dev/null 2>&1; then
      success "installed $formula"
    else
      fail "failed to install $formula"
    fi
  fi
}

function brew_upgrade() {
  brew="brew $1"
  info "upgrading homebrew $1"
  for update in $(brew $1 outdated); do
    formula=$(echo "$update" | cut -d ' ' -f 1)
    run "upgrading $update" "$brew upgrade $formula"
  done
  run "cleaning up homebrew $1" "$brew cleanup"
}

function brew_check_and_install() {
  if ! test $(which brew); then
    info "homebrew is not installed, installing"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/versions
    brew tap homebrew/versions
  fi
}
