#!/usr/bin/env bats

load test_helper

check_git_repos() {
  local os="$1" suffix="$2"
  create_files "plain.gitrepo" "foo.bar.gitrepo.$suffix" "wrong.gitrepo.other"
  mkdir -p "$TEST_DIR/lib"
  cp "$BATS_TEST_DIRNAME/../lib/"*.zsh "$TEST_DIR/lib/"
  # Load installer functions without running the interactive entry point.
  sed '$d' "$BATS_TEST_DIRNAME/../lib/install.zsh" > "$TEST_DIR/lib/install.zsh"
  run zsh -c '
    source "$2/lib/install.zsh"
    HOME="$2/home"
    function uname() {
      case "$1" in
        -m) echo arm64 ;;
        *) echo "$sim_os" ;;
      esac
    }
    sim_os="$3"
    function dotfiles() { echo "$test_dir"; }
    test_dir="$2"
    function install_file() { print -r -- "$1 $3"; }
    dotfiles_install
  ' -- "$BATS_TEST_DIRNAME/.." "$TEST_DIR" "$os"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"git $TEST_DIR/home/.plain"* ]]
  [[ "$output"$'\n' == *"git $TEST_DIR/home/.foo.bar"$'\n'* ]]
  [[ "$output" != *".gitrepo"* ]]
  [[ "$output" != *".wrong"* ]]
}

@test "macOS gitrepo strips OS suffix from destination" {
  check_git_repos Darwin darwin
}

@test "Linux gitrepo strips OS suffix from destination" {
  check_git_repos Linux linux
}

@test "gitrepo strips OS-architecture suffix from destination" {
  check_git_repos Darwin darwin-arm64
}
