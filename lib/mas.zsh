mas_installed=""

function mas_install_formulas() {
  mas_files=`dotfiles_find install.mas`
  if [ -n "$mas_files" ]; then
    mas_installed=$(mas list 2> /dev/null)
    for file in $mas_files; do
      while read formula; do
        mas_install $formula
      done < <(grep ^ $file)
    done
  fi
}

function mas_upgrade_formulas() {
  if type mas > /dev/null; then
    outdated=$(mas outdated 2> /dev/null | cut -d ' ' -f2- | cut -d '(' -f1 | cut -d– -f1 | cut -d- -f1 | sed -e 's/ *$//' | sed -e :a -e '$!N; s/\n/, /; ta')
    if [ -n "$outdated" ]; then
      run "upgrading apps ($outdated)" "mas upgrade"
    fi
  fi
}

function mas_install() {
  mas_check_and_install
  id="${1%% *}"
  name="${1#* }"
  if ! echo $mas_installed | grep -q "^$id"; then
    if mas install $id > /dev/null 2>&1; then
      success "installed $name"
    else
      fail "failed to install $name"
    fi
  fi
}

function mas_check_and_install() {
  if ! type mas > /dev/null; then
    info "mas is not installed, installing"
    brew_check_and_install
    brew_install mas
    user "enter Apple id"
    read -r appleid
    user "enter Apple password"
    read -rs applepwd
    if mas signin $appleid $applepwd > /dev/null 2>&1; then
      success "signed into App Store as $appleid"
    else
      fail "failed to sign in to App Store as $appleid"
    fi
  fi
}
