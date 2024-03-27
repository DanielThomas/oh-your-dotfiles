apt_install_upgrade() {
  if [[ "Linux" != "$(uname)" ]]; then
  	return
  fi
  packages=$(dotfiles_find_installer install.apt)
  if [[ -n "$packages" ]]; then
  	sudo apt update
	for file in "$packages"; do
		for package in $(cat "$packages"); do
			if dpkg -l "$package" > /dev/null; then
				run "installing $package"
				sudo apt install $(package)
			fi
		done
    done
  	sudo apt upgrade
  fi
}
