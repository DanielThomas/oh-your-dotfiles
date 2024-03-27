apt_install_upgrade() {
  if [[ "Linux" == "$(uname)" ]]; then
  	return
  fi
  packages=$(dotfiles_find_installer install.apt)
  if [[ -n "$packages" ]]; then
  	sudo apt update
  	sudo apt install $(packages)
  	sudo apt upgrade
  fi
}
