mas_installed=""

function mas_install_upgrade_formulas() {
  mas_install_formulas
  mas_upgrade_formulas
}

function mas_install_formulas() {
  mas_files=`dotfiles_find install.mas`
  if [ -n "$mas_files" ]; then
    mas_check_and_install
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
    brew install mas
    login_to_Mac_App_Store
  fi
}

function login_to_Mac_App_Store () {
  #	Attempt at workaround for High Sierra error that prevents logging into Mac App Store
  #		See Mike Ratcliffe, https://github.com/mas-cli/mas/issues/107#issuecomment-335514316
  # Test if signed in. If not, launch MAS and sign in.

  until (mas account > /dev/null); # If signed in, drop to outer "done"
  do
    #	If here, not logged in
	  echo -e "You are not yet logged into the Mac App Store."
	  echo -e "I will launch the Mac App Store now."
	  echo -e "\nPlease log in to the Mac App Store..."
	  open -a "/Applications/App Store.app"

    # until loop waits patiently until scriptrunner signs into Mac App Store
	  until (mas account > /dev/null);
	  do
		  sleep 3
    	  echo -e "… zzz …."
  	done	
  done
  echo -e "You are signed into the Mac App Store."
  signed_in_user=$(mas account)
  echo -e "MAS user name: $signed_in_user"
}
