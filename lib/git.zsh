git_clone () {
  repo=$(head -n 1 $1)
  dest=$2
  if ! git clone --quiet $repo $dest; then
    fail "clone for $repo failed"
  fi

  success "cloned $repo to `basename $dest`"

  dir=$(dirname $1)
  base=$(basename ${1%.*})
  for patch in $(find $dir -maxdepth 2 -name $base\*.gitpatch); do
    pushd $dest >> /dev/null
    if ! git am --quiet $patch; then
      fail "apply patch failed"
    fi

    success "applied $patch"
    popd >> /dev/null
  done
}

function git_pull_repos() {
  git_pull "$ZSHRC" &
  for file in $(dotfiles_find \*.gitrepo); do
    repo="$HOME/.`basename \"${file%.*}\"`"
    if [ -d "$repo" ]; then
      git_pull "$repo" &
    fi
  done
  wait
}

function git_pull() {
  pushd $1 > /dev/null
  if ! git pull origin master --rebase --quiet; then
    fail "could not update $repo"
  fi
  success "updated $1"
  popd >> /dev/null
}
