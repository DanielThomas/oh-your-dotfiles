#!/usr/bin/env bats

load test_helper

run_default_homebrew_prefix() {
  run zsh -c '
    function uname() {
      if [[ "$1" == "-m" ]]; then
        echo x86_64
      else
        echo Linux
      fi
    }
    HOME="$1"
    source "$2/defaults/homebrew.zsh"
    echo "$HOMEBREW_PREFIX"
    source "$2/lib/homebrew.zsh"
    brew_prefix
  ' -- "$TEST_DIR/home" "${BATS_TEST_DIRNAME}/.."
}

@test "shell and installer use the standard Linuxbrew prefix for a new installation" {
  run_default_homebrew_prefix

  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "/home/linuxbrew/.linuxbrew" ]]
  [[ "${lines[1]}" == "/home/linuxbrew/.linuxbrew" ]]
}

@test "shell and installer continue to use an existing home-directory Linuxbrew installation" {
  mkdir -p "$TEST_DIR/home/.linuxbrew/bin"
  touch "$TEST_DIR/home/.linuxbrew/bin/brew"
  chmod +x "$TEST_DIR/home/.linuxbrew/bin/brew"

  run_default_homebrew_prefix

  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "$TEST_DIR/home/.linuxbrew" ]]
  [[ "${lines[1]}" == "$TEST_DIR/home/.linuxbrew" ]]
}
