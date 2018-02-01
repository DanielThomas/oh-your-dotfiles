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

function brew_update() {
    run 'updating homebrew' 'brew update'
    success 'updated homebrew'
}

function brew_upgrade_formulas() {
  brew_upgrade &
  brew_upgrade cask &
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
  outdated=$(eval $brew outdated | sed -e :a -e '$!N; s/\n/, /; ta')
  if [ -n "$outdated" ]; then
    run "upgrading homebrew $1 ($outdated)" "$brew upgrade"
    run "cleaning up homebrew $1" "$brew cleanup"
  fi
}

function brew_check_and_install() {
  if ! test $(which brew); then
    info "homebrew is not installed, installing"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/versions
    brew tap homebrew/versions
  fi
}
