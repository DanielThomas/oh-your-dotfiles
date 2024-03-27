apt_install_upgrade() {
  if [[ "Linux" != "$(uname)" ]]; then
  	return
  fi
  run "updating apt indexes" "sudo apt update"
  packages=$(dotfiles_find_installer install.apt)
  if [[ -n "$packages" ]]; then
	for file in "$packages"; do
		for package in $(cat "$packages"); do
			if dpkg -l "$package" > /dev/null; then
				run "installing $package" "sudo apt --yes install $(package)"
			fi
		done
    done
  fi
}
