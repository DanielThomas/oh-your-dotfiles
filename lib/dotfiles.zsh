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
  $ZSHRC/lib/installers.zsh
}

function dotfiles_update() {
  $ZSHRC/lib/installers.zsh update
}

function dotfiles_reload() {
  source $HOME/.zshrc
}

function dotfiles_find() {
  find $(dotfiles) -name "$1"
}

function dotfiles() {
  files=("$defaults")
  files+=($(find "$HOME" -maxdepth 1 -type d -name '.*dotfiles*'  -not -name '.oh-your-dotfiles'))
  echo "${files[@]}"
}
