function info() {
  printf "  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

function user() {
  printf "\r  [ \033[0;33m??\033[0m ] %s " "$1"
}

function success() {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

function warn() {
  printf "\r\033[2K  [ \033[0;31m!!\033[0m ] %s\n" "$1"
}

function fail() {
  printf "\r\033[2K  [ \033[0;31m!!\033[0m ] %s\n" "$1"
  echo ''
  exit 1
}

function run() {
  set +e
  info "$1"
  output=$(eval $2 2>&1)
  if [ $? -ne 0 ]; then
    fail "failed to run '$1': $output"
    exit 1
  fi
  set -e
}
