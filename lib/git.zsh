git_clone_or_pull() {
  if [ -d $2 ]; then
    git_pull $2
  else
    git_clone $1 $2
  fi
}

git_clone() {
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

function git_pull() {
  pushd $1 > /dev/null
  if ! git pull origin master --rebase --quiet; then
    fail "could not update $1"
  fi
  success "updated $1"
  popd >> /dev/null
}
