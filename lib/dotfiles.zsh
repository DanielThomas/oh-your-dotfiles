# install/update/reload
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
  find $(dotfiles) -not -name '.git' -name "$1"
}

function dotfiles() {
  find "$HOME" -maxdepth 1 -type d -name '.*dotfiles*'
}
