git_clone_or_pull() {
  if [ -d $2 ]; then
    git_pull $1 $2
  else
    git_clone $1 $2
  fi
  git_patch $1
}

git_clone() {
  fetch=$(head -n 1 $1)
  push=$(head -2 $1| tail -1)
  dest=$2

  if ! git clone --quiet $fetch $dest; then
    warn "clone for $fetch failed"
    return
  fi
  if [ "$fetch" != "$push" ]; then
    git -C "$dest" remote set-url origin --push $push
  fi

  success "cloned $fetch to `basename $dest`"
}

function git_pull() {
  fetch=$(head -n 1 $1)
  push=$(head -2 $1| tail -1)
  dest=$2

  git -C "$dest" remote set-url origin "$fetch"
  if [ "$fetch" != "$push" ]; then
    git -C "$dest" remote set-url origin --push $push
  fi

  current_sha=$(git -C "$dest" rev-parse --short HEAD)
  branch=$(git -C "$dest" rev-parse --abbrev-ref HEAD)
  remote=$(git -C "$dest" remote get-url origin)
  run "pulling $dest from $remote" "git -C $dest pull origin $branch --rebase --quiet"
  new_sha=$(git -C "$dest" rev-parse --short HEAD)
  if [ "$current_sha" != "$new_sha" ]; then
    success "updated $1 from $current_sha to $new_sha (branch $branch)"
  fi
}

git_patch() {
  dir=$(dirname $1)
  base=$(basename ${1%.*})
  for patch in $(find $dir -maxdepth 2 -name $base\*.gitpatch); do
    run "applying $patch to $dest" "git -C "$dest" apply --quiet $patch"
  done
}
