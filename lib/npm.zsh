npm_installed=""

function npm_command() {
  echo "$(brew_prefix)/bin/npm"
}

function npm_install_upgrade_formulas() {
  npm_install_formulas
  npm_upgrade_formulas
}

function npm_install_formulas() {
  npm_files=$(dotfiles_find install.npm)
  if [ -n "$npm_files" ]; then
    npm_check_and_install
    npm_installed=$($(npm_command) ls -g --depth=0 --parseable 2> /dev/null | sed -n 's|.*/node_modules/||p')
    for file in $npm_files; do
      while read formula; do
        npm_install $formula
      done < <(grep ^ $file)
    done
  fi
}

function npm_upgrade_formulas() {
  if [ -f $(npm_command) ]; then
    outdated=$($(npm_command) outdated -g --parseable 2> /dev/null | cut -d: -f4 | sed -e :a -e '$!N; s/\n/, /; ta')
    if [ -n "$outdated" ]; then
      run "upgrading npm packages ($outdated)" "$(npm_command) update -g"
    fi
  fi
}

function npm_install() {
  local package="$1"
  if [ -z "$package" ]; then
    return
  fi
  # strip version specifier, preserving scope for @scoped/packages
  local package_name
  if [[ "$package" == @* ]]; then
    package_name="@${${package#@}%%@*}"
  else
    package_name="${package%%@*}"
  fi
  if ! echo "$npm_installed" | grep -q "^${package_name}$"; then
    local output
    if output=$($(npm_command) install -g $package 2>&1); then
      success "installed $package"
    else
      fail "failed to install $package\n$output"
    fi
  fi
}

function npm_check_and_install() {
  if [ ! -f $(npm_command) ]; then
    info "npm is not installed, installing via homebrew"
    brew_check_and_install
    brew_run install node
  fi
}
