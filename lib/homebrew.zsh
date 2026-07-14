brew_installed=""

function brew_run() {
   HOMEBREW_NO_AUTO_UPDATE=1 $(brew_command) $@
}

function brew_command() {
  echo "$(brew_prefix)/bin/brew"
}

function brew_prefix() {
  local arch=$(uname -m)
  if [[ "Darwin" == "$(uname)" ]]; then
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
  else
    # Prefer standard path for bottle compatibility; keep existing $HOME installs working
    if [[ -x "$HOME/.linuxbrew/bin/brew" ]]; then
      echo "$HOME/.linuxbrew"
    else
      echo "/home/linuxbrew/.linuxbrew"
    fi
  fi
}

function brew_install_upgrade_formulas() {
  brew_install_formulas
  brew_upgrade_formulas
}

function brew_install_formulas() {
  extension="homebrew"
  if [[ "Darwin" != "$(uname)" ]]; then
    extension="linuxbrew"
  fi
  formulas=$(dotfiles_find_installer "install.${extension}")
  casks=$(dotfiles_find_installer "install.${extension}-cask")

  if [[ -n "$casks" || -n "$formulas" ]]; then
    brew_check_and_install
  fi

  if [ -n "$formulas" ]; then
    brew_installed=$(brew_run ls --versions 2> /dev/null)
    for file in `dotfiles_find_installer install.${extension}`; do
      brew_install formula "$file"
    done
  fi

  if [ -n "$casks" ]; then
    brew_installed=$(brew_run ls --cask --versions 2> /dev/null)
    for file in `dotfiles_find_installer install.${extension}-cask`; do
      brew_install cask "$file"
    done
  fi
}

function brew_install() {
  type="$1"
  file="$2"
  missing_formulas=""
  for formula in $(cat "$file"); do
    if ! echo $brew_installed | grep -q "^$formula "; then
      missing_formulas+="$formula "
    fi
  done
  missing_formulas=$(echo "$missing_formulas" | xargs)
  if [ ! -z "$missing_formulas" ]; then
    run "installing ${type}s from $file ($(echo "$missing_formulas" | sed -e :a -e '$!N; s/\n/, /; ta'))" "brew_run install --${type} $missing_formulas"
  fi
}

function brew_update() {
  prefix=$(brew_prefix)
  run "updating homebrew (prefix $prefix)" "brew_run update"
  success "updated homebrew (prefix $prefix)"
}

function brew_upgrade_formulas() {
  if [ -f $(brew_command) ]; then
    brew_update
    brew_upgrade formula
    if [[ "Darwin" == "$(uname)" ]]; then
      brew_upgrade cask
    fi
    wait
  fi
}

function brew_upgrade() {
  type="$1"
  outdated=$(brew_run outdated --${type} | sed -e :a -e '$!N; s/\n/, /; ta')
  if [ -n "$outdated" ]; then
    run "upgrading brew $type ($outdated)" "brew_run upgrade --${type}"
  fi
}

function brew_check_and_install() {
  if [ ! -f $(brew_command) ]; then
    prefix=$(brew_prefix)
    info "homebrew is not installed in $prefix"
    run "creating directory $prefix" "sudo mkdir -p ${prefix}"
    owner="$(whoami):$(id -g -n)"
    run "changing ownership of $prefix to $owner" "sudo chown -R ${owner} ${prefix}"
    run "downloading homebrew and extracting to $prefix" "curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${prefix}"
  fi
  brew_taps
}

function brew_taps() {
  brew_tapped=$(brew_run tap 2> /dev/null)
  local tap_trust_supported=false
  if [[ -z "$HOMEBREW_NO_REQUIRE_TAP_TRUST" ]] && brew_run command trust > /dev/null 2>&1; then
    tap_trust_supported=true
  fi
  for tapfile in `dotfiles_find_installer install.homebrew-tap`; do
    while read -r LINE || [[ -n "$LINE" ]]; do
      args=( ${=LINE} )
      tap="${args[1]}"
      if ! echo "$brew_tapped" | grep -q "$tap"; then
        run "tapping ${args[1]}" "brew_run tap ${args[1]} ${args[2]}"
      fi
      if [[ "$tap_trust_supported" == true ]]; then
        run "trusting ${tap}" "brew_run trust --tap ${tap}"
      fi
    done < $tapfile
  done
}
