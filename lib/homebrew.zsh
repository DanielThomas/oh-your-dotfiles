brew_installed=""

function brew_install_formulas() {
  for file in `dotfiles_find install.homebrew-cask`; do
    brew_check_and_install
    formulas=$(cat "$file" | sed -e :a -e '$!N; s/\n/, /; ta')
    run "installing from $file ($formulas)" 'brew cask install $(cat "'$file'")'
  done

  for file in `dotfiles_find install.homebrew`; do
    brew_check_and_install
    formulas=$(cat "$file" | sed -e :a -e '$!N; s/\n/, /; ta')
    run "installing from $file ($formulas)" 'brew install $(cat "'$file'")'
  done
}

function brew_update() {
    run 'updating homebrew' 'brew update'
    success 'updated homebrew'
}

function brew_upgrade_formulas() {
  brew_upgrade &
  brew_upgrade cask &
  wait
}

function brew_upgrade() {
  if type brew > /dev/null; then
    brew="brew $1"
    outdated=$(eval $brew outdated | sed -e :a -e '$!N; s/\n/, /; ta')
    if [ -n "$outdated" ]; then
      run "upgrading homebrew $1 ($outdated)" "$brew upgrade"
      run "cleaning up homebrew $1" "$brew cleanup"
    fi
  fi
}

function brew_check_and_install() {
  if ! type brew > /dev/null; then
    info "homebrew is not installed, installing"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew tap caskroom/versions
  fi
}
