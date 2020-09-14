brew_installed=""

function brew_install_upgrade_formulas() {
  export HOMEBREW_INSTALL_CLEANUP=true
  brew_install_formulas
  brew_upgrade_formulas
}

function brew_install_formulas() {
  casks=$(dotfiles_find install.homebrew-cask)
  if [ -n "$casks" ]; then
    brew_check_and_install
    brew_installed=$(brew cask ls --versions 2> /dev/null)
    for file in `dotfiles_find install.homebrew-cask`; do
      brew_install "$file" cask
    done
  fi

  formulas=$(dotfiles_find install.homebrew)
  if [ -n "$formulas" ]; then
    brew_check_and_install
    brew_installed=$(brew ls --versions 2> /dev/null)
    for file in `dotfiles_find install.homebrew`; do
      brew_install "$file"
    done
  fi
}

function brew_install() {
  if [ -z "$2" ]; then
    brew_command="brew"
  else
    brew_command="brew $2"
  fi
  missing_formulas=""
  for formula in $(cat "$file"); do
    if ! echo $brew_installed | grep -q $formula; then
      missing_formulas+="$formula "
    fi
  done
  missing_formulas=$(echo "$missing_formulas" | xargs)
  if [ ! -z "$missing_formulas" ]; then
    run "installing from $file ($(echo "$missing_formulas" | sed -e :a -e '$!N; s/\n/, /; ta'))" "eval $brew_command install $missing_formulas"
  fi
}

function brew_update() {
  if type brew > /dev/null; then
    run 'updating homebrew' 'brew update'
    success 'updated homebrew'
  fi
}

function brew_upgrade_formulas() {
  brew_update
  brew_upgrade formula &
  brew_upgrade cask &
  wait
}

function brew_upgrade() {
  if type brew > /dev/null; then
    type="$1"
    outdated=$(brew outdated --${type} | sed -e :a -e '$!N; s/\n/, /; ta')
    if [ -n "$outdated" ]; then
      run "upgrading brew $type ($outdated)" "brew upgrade --${type}"
    fi
  fi
}

function brew_check_and_install() {
  if ! type brew > /dev/null; then
    info "homebrew is not installed, installing"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2>&1 | sed 's/^/         /'
  fi
  brew_taps
}

function brew_taps() {
    for tapfile in `dotfiles_find install.homebrew-tap`; do
      while read -r LINE || [[ -n "$LINE" ]]; do
        args=($(echo $LINE))
        HOMEBREW_NO_AUTO_UPDATE=1 brew tap ${args[@]}
      done < $tapfile
    done
}

