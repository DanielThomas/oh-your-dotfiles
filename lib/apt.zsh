apt_install_upgrade() {
  if [[ "Linux" == "$(uname)" ]]; then
  	return
  fi
  packages=$(dotfiles_find_installer install.apt)
  if [[ -n "$packages" ]]; then
  	sudo apt update
	for file in "$packages"; do
		for package in $(cat $packages); do
			sudo apt install $(package)
		done
    done
  	sudo apt upgrade
  fi
}
