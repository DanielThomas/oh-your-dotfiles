apt_install_upgrade() {
  if [[ "Linux" != "$(uname)" ]] || ! which apt &> /dev/null; then
    return
  fi
  run "updating apt indexes" "sudo apt update"
  local apt_upgradable=$(apt list --upgradeable)
  local apt_packages=()
  for aptfile in `dotfiles_find_installer install.apt`; do
    for package in $(cat "$aptfile"); do
      if ! dpkg -s "$package" 1> /dev/null 2>& 1; then
        apt_packages+="$package"
      fi
      if echo "$apt_upgradable" | grep "^${package}/" > /dev/null; then
        apt_packages+="$package"
      fi
    done
  done
  if [ ${#apt_packages[@]} -gt 0 ]; then
    run "installing ${apt_packages[*]}" "sudo apt --yes install ${apt_packages[*]}"
  fi
}
