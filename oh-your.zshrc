if [[ "$PROFILE_STARTUP" == true ]]; then
    PS4=$'%D{%M%S%.} %N:%i> '
    exec 3>&2 2> /tmp/startlog.$$
    setopt xtrace prompt_subst
fi

## configure oh-your-zshrc ##

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

# oh-your-zshrc location
ZSHRC=$(dirname $(realpath $(echo ${(%):-%x})))

# dotfiles location
export DOTFILES=$HOME/.dotfiles

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

# find all zsh files
typeset -U config_files
config_files=($(find -L "$DOTFILES" -name \*.zsh))

# use .localrc for things that need to be kept secret
if [[ -a $HOME/.localrc ]]
then
  source $HOME/.localrc
fi

## configure and load oh-my-zsh ##

ZSH=$ZSHRC/oh-my-zsh
if [ ! -d "$ZSH" ]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is not installed"
    # TODO install if necessary
  else
    ZSH="$HOME/.oh-my-zsh"
  fi
fi

# disable update, we handle that
DISABLE_AUTO_UPDATE="true"

# set default user
DEFAULT_USER=$(whoami)

# configure theme(s)
ZSH_THEME="agnoster"

# configure plugins
plugins=("${(@f)$(
# define oh-my-zsh plugins implicitly based on topics
find $DOTFILES $DOTFILES/local/ -not -name '.git' -d 1 -type d -exec basename {} \;

# add any plugins defined by files
find -L $DOTFILES -name oh-my-zsh.plugins -d 2 -exec cat {} \;
)}")

for file in ${(M)config_files:#*/oh-my-zsh.zsh}
do
  source $file
done

source $ZSH/oh-my-zsh.sh

## load dotfiles ##

# load the path files
for file in ${(M)config_files:#*/path.zsh}
do
  source $file
done

# default homebrew locations
BREW=/usr/local/bin:/usr/local/sbin
export PATH=$BREW:$PATH

# put the bin/ directories first on the path
export PATH=$DOTFILES/bin:$DOTFILES/local/bin:$PATH

# load everything else
for file in ${${${config_files:#*/path.zsh}:#*/completion.zsh}:#*/oh-my-zsh.zsh}
do
  source $file
done

# load every completion after autocomplete loads
for file in ${(M)config_files:#*/completion.zsh}
do
  source $file
done

unset config_files

if [[ "$PROFILE_STARTUP" == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
fi
