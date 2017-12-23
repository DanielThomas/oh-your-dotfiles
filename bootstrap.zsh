# oh-your-zshrc location
ZSHRC=$(dirname $(realpath ${0:a}))

# load shared functions
for lib_file ($ZSHRC/lib/*.zsh); do
  source $lib_file
done

if [ "$1" = "update" ]; then
  info 'updating dotfiles'
  pull_repos

  run_installers
  brew_upgrade
  install_formulas
  run 'cleaning up homebrew' 'brew cleanup'
  run 'cleaning up homebrew-cask' 'brew cask cleanup'
else
  info 'installing dotfiles'
  install_dotfiles
  run_installers
  install_formulas
  create_localrc
fi

info 'complete!'
echo ''
