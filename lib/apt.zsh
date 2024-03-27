apt_install_upgrade() {
  if [[ "Linux" != "$(uname)" ]]; then
  	return
  fi
  run "updating apt indexes" "sudo apt update"
  package_files=$(dotfiles_find_installer install.apt)
  if [[ -n "$package_files" ]]; then
	for file in "$package_files"; do
		for package in $(cat "$package_files"); do
			if ! dpkg -l "$package" > /dev/null; then
				run "installing $package" "sudo apt --yes install $(package)"
			fi
		done
    done
  fi
}
