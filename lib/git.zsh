git_clone_or_pull() {
  if [ -d $2 ]; then
    git_pull $1 $2
  else
    git_clone $1 $2
  fi
}

git_clone() {
  fetch=$(head -n 1 $1)
  push=$(head -2 $1| tail -1)
  dest=$2

  if ! git -C "$dest" clone --quiet $fetch $dest; then
    fail "clone for $fetch failed"
  fi
  if [ "$fetch" != "$push" ]; then
    git -C "$dest" remote set-url origin --push $push
  fi

  success "cloned $fetch to `basename $dest`"

  dir=$(dirname $1)
  base=$(basename ${1%.*})
  for patch in $(find $dir -maxdepth 2 -name $base\*.gitpatch); do
    pushd $dest >> /dev/null
    if ! git -C "$dest" am --quiet $patch; then
      fail "apply patch failed"
    fi

    success "applied $patch"
    popd >> /dev/null
  done
}

function git_pull() {
  fetch=$(head -n 1 $1)
  push=$(head -2 $1| tail -1)
  dest=$2

  git -C "$dest" remote set-url origin "$fetch"
  if [ "$fetch" != "$push" ]; then
    git -C "$dest" remote set-url origin --push $push
  fi

  if ! git -C "$dest" pull origin master --rebase --quiet; then
    fail "could not update $1"
  fi
  success "updated $1"
}
