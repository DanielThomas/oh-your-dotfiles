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

# oh-your-zshrc
export ZSHRC=$(dirname $(realpath $(echo ${(%):-%x})))
source "$ZSHRC/lib/dotfiles.zsh"

# find all zsh files
typeset -U config_files
config_files=($(dotfiles_find \*.zsh))

# use .localrc for things that need to be kept secret
if [[ -a $HOME/.localrc ]]
then
  source $HOME/.localrc
fi

ZSH=$ZSHRC/oh-my-zsh
if [ ! -d "$ZSH" ]; then
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh is not installed, run dotfiles_install"
    return
  else
    ZSH="$HOME/.oh-my-zsh"
  fi
fi

DEFAULT_USER=$(whoami)
DISABLE_AUTO_UPDATE="true"
ZSH_THEME="agnoster"

# configure plugins
plugins=("${(@f)$(
find $(dotfiles) -not -name '.git' -d 1 -type d -exec basename {} \;

find $(dotfiles) -name oh-my-zsh.plugins -d 2 -exec cat {} \;
)}")

for file in ${(M)config_files:#*/oh-my-zsh.zsh}
do
  source $file
done

OH_MY_ZSH="$ZSH/oh-my-zsh.sh"

if [[ -a "$OH_MY_ZSH" ]]
then
  source "$OH_MY_ZSH"
fi

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
for d in $(dotfiles)
do
  export PATH=$d/bin:$PATH
done

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
