apt_install_upgrade() {
  if [[ "Linux" != "$(uname)" ]]; then
    return
  fi
  run "updating apt indexes" "sudo apt update"
  local apt_upgradable=$(apt list --upgradeable)
  for aptfile in `dotfiles_find_installer install.apt`; do
    for package in $(cat "$aptfile"); do
      if ! dpkg -s "$package" 1> /dev/null 2>& 1; then
        run "installing $package" "sudo apt --yes install $package"
      fi
      if echo "$apt_upgradable" | grep "^${package}/" > /dev/null; then
        run "upgrading $package" "sudo apt --yes install $package"
      fi
    done
  done
}
