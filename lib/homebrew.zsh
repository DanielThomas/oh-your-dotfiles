brew_installed=""

function brew_run() {
   $(brew_command) $@
}

function brew_command() {
  echo "$(brew_prefix)/bin/brew"
}

function brew_prefix() {
  local arch=$(uname -m)
  case $arch in
    x86_64)
      echo "/usr/local"
    ;;
    arm64)
      echo "/opt/homebrew"
    ;;
    *)
      >&2 echo "Cannot determine brew prefix, unknown architecture $arch"
    ;;
  esac
}

function brew_install_upgrade_formulas() {
  brew_install_formulas
  brew_upgrade_formulas
}

function brew_install_formulas() {
  casks=$(dotfiles_find_installer install.homebrew-cask)
  if [ -n "$casks" ]; then
    brew_check_and_install
    brew_installed=$(brew_run ls --cask --versions 2> /dev/null)
    for file in `dotfiles_find_installer install.homebrew-cask`; do
      brew_install cask "$file"
    done
  fi

  formulas=$(dotfiles_find_installer install.homebrew)
  if [ -n "$formulas" ]; then
    brew_check_and_install
    brew_installed=$(brew_run ls --versions 2> /dev/null)
    for file in `dotfiles_find_installer install.homebrew`; do
      brew_install formula "$file"
    done
  fi
}

function brew_install() {
  type="$1"
  file="$2"
  missing_formulas=""
  for formula in $(cat "$file"); do
    if ! echo $brew_installed | grep -q $formula; then
      missing_formulas+="$formula "
    fi
  done
  missing_formulas=$(echo "$missing_formulas" | xargs)
  if [ ! -z "$missing_formulas" ]; then
    run "installing casks from $file ($(echo "$missing_formulas" | sed -e :a -e '$!N; s/\n/, /; ta'))" "brew_run install --${type} $missing_formulas"
  fi
}

function brew_update() {
  prefix=$(brew_prefix)
  run "updating homebrew (prefix $prefix)" "brew_run update"
  success "updated homebrew (prefix $prefix)"
}

function brew_upgrade_formulas() {
  brew_update
  brew_upgrade formula &
  brew_upgrade cask &
  wait
}

function brew_upgrade() {
  type="$1"
  outdated=$(brew outdated --${type} | sed -e :a -e '$!N; s/\n/, /; ta')
  if [ -n "$outdated" ]; then
    run "upgrading brew $type ($outdated)" "brew upgrade --${type}"
  fi
}

function brew_check_and_install() {
  if [ ! -f $(brew_command) ]; then
    prefix=$(brew_prefix)
    if [ "$prefix" = "/usr/local" ]; then
      info "homebrew is not installed in $prefix, running standard installer"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      info "homebrew is not installed in $prefix, installing to custom prefix"
      info "creating directory $prefix"
      sudo mkdir -p "$prefix"
      owner="$(whoami):$(id -g -n)"
      info "changing ownership of $prefix to $owner"
      sudo chown -R "$owner" "$prefix"
      info "downloading homebrew and extracting to $prefix"
      curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C "$prefix"
    fi
  fi
  brew_taps
}

function brew_taps() {
  for tapfile in `dotfiles_find_installer install.homebrew-tap`; do
    while read -r LINE || [[ -n "$LINE" ]]; do
      args=($(echo $LINE))
      HOMEBREW_NO_AUTO_UPDATE=1 brew_run tap ${args[@]}
    done < $tapfile
  done
}
