# install/update/reload
function realpath() {
  OURPWD=$PWD
  cd "$(dirname "$1")"
  LINK=$(readlink "$(basename "$1")")
  while [ "$LINK" ]; do
    cd "$(dirname "$LINK")"
    LINK=$(readlink "$(basename "$1")")
  done
  REALPATH="$PWD/$(basename "$1")"
  cd "$OURPWD"
  echo "$REALPATH"
}

defaults=$(realpath "${0:a:h}/../defaults")

function dotfiles_install() {
  $DOTFILES_DIR/lib/install.zsh $1
}

function dotfiles_update() {
  $DOTFILES_DIR/lib/install.zsh update
}

function dotfiles_reload() {
  source $HOME/.zshrc
}

function dotfiles_find() {
  local arch=$(uname -m)
  local arch_native="$arch"
  if [[ "Darwin" == "$(uname)" ]]; then
    if sysctl -n machdep.cpu.brand_string | grep "Apple" > /dev/null; then
      arch_native="arm64"
    fi
  fi
  if [ "$arch_native" = "$arch" ]; then
    find -L $(dotfiles) -type f $(dotfiles_find_ignore) -name "$1" -o -name "$1.${arch}" -o -name "$1.${arch}-native"
  else
    find -L $(dotfiles) -type f $(dotfiles_find_ignore) -name "$1" -o -name "$1.${arch}"
  fi
}

function dotfiles_find_installer() {
  local arch=$(uname -m)
  local arch_native="$arch"
  if [[ "Darwin" == "$(uname)" ]]; then
    if sysctl -n machdep.cpu.brand_string | grep "Apple" > /dev/null; then
      arch_native="arm64"
    fi
  fi
  # only return universal installers for the native architecture to avoid double-executing the installers
  if [ "$arch_native" = "$arch" ]; then
    find -L $(dotfiles) -type f $(dotfiles_find_ignore) -name "$1" -o -name "$1.${arch}" -o -name "$1.${arch}-native"
  else
    find -L $(dotfiles) -type f $(dotfiles_find_ignore) -name "$1.${arch}"
  fi
}

function dotfiles_find_symlink() {
  find -L $(dotfiles) $(dotfiles_find_ignore) -name "*.symlink"
}

function dotfiles_find_ignore() {
  for ignore in $(dotfiles_ignored); do
    printf "-not -path %s " "$ignore"
  done
}

function dotfiles_ignored() {
  find -L $(dotfiles) -type f -name ".dotfiles_ignore" -exec dirname {} \; | sed 's#$#/*#'
  for dotfile in $(dotfiles); do
    echo "$dotfile/bin/*"
    echo "$dotfile/.*"
  done
}

function dotfiles() {
  files=("$defaults")
  for file in $(find "$HOME" -maxdepth 1 -name '.*dotfiles*'  -not -name '.oh-your-dotfiles' | sort); do
    if [ -d "$file" ]; then
      files+=($file)
    fi
  done
  echo "${files[@]}"
}
