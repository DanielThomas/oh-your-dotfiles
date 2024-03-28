apt_install_upgrade() {
  if [[ "Linux" != "$(uname)" ]]; then
    return
  fi
  package_files=$(dotfiles_find_installer install.apt)
  if [[ -n "$package_files" ]]; then
    run "updating apt indexes" "sudo apt update"
    for file in "$package_files"; do
        for package in $(cat "$package_files"); do
            if ! dpkg -s "$package" 1> /dev/null 2>& 1; then
                run "installing $package" "sudo apt --yes install $package"
            fi
        done
    done
  fi
}
