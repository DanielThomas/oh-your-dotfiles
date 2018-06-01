# install/update/reload
local defaults=$(realpath "${0:a:h}/../defaults")

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
  find $defaults $(dotfiles) -not -name '.git' -name "$1"
}

function dotfiles() {
  find "$HOME" -maxdepth 1 -type d -name '.*dotfiles*'
}
