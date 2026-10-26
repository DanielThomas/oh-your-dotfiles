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

@test "bootstraps Homebrew from the main branch" {
  run zsh -c '
    source "$1/lib/homebrew.zsh"
    test_prefix="$2"
    function brew_prefix() { echo "$test_prefix"; }
    function brew_command() { echo "$test_prefix/bin/brew"; }
    function info() { :; }
    function run() { print -r -- "$2"; }
    function brew_taps() { :; }
    brew_check_and_install
  ' -- "${BATS_TEST_DIRNAME}/.." "$TEST_DIR/homebrew"

  [[ "$status" -eq 0 ]]
  [[ "$output" == *"curl -fL https://github.com/Homebrew/brew/tarball/main"* ]]
  [[ "$output" != *"tarball/master"* ]]
}

@test "reports Homebrew tap listing failures" {
  run zsh -c '
    set -e
    source "$1/lib/terminal.zsh"
    source "$1/lib/homebrew.zsh"
    function brew_run() {
      print -u2 "Homebrew startup failed"
      return 1
    }
    brew_taps
  ' -- "${BATS_TEST_DIRNAME}/.."

  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Homebrew startup failed"* ]]
  [[ "$output" == *"failed to list Homebrew taps"* ]]
}

@test "installs formulas when Homebrew has no inventory yet" {
  cat > "$TEST_DIR/install.linuxbrew" <<'EOF'
ripgrep
EOF

  run zsh -c '
    set -e
    source "$1/lib/homebrew.zsh"
    test_dir="$2"
    function dotfiles_find_installer() {
      if [[ "$1" == "install.linuxbrew" ]]; then
        echo "$test_dir/install.linuxbrew"
      fi
    }
    function brew_check_and_install() { true; }
    function brew_run() {
      if [[ "$1" == "ls" ]]; then
        return 1
      fi
      echo "$*"
    }
    function run() { eval "$2"; }
    brew_install_formulas
  ' -- "${BATS_TEST_DIRNAME}/.." "$TEST_DIR"

  [[ "$status" -eq 0 ]]
  [[ "$output" == "install --formula ripgrep" ]]
}

@test "trusts only untrusted declared taps when Homebrew supports tap trust" {
  cat > "$TEST_DIR/install.homebrew-tap" <<'EOF'
atlassian/tap https://github.com/atlassian/homebrew-tap
gdubw/gng
EOF

  run zsh -c '
    source "$1/lib/homebrew.zsh"
    test_dir="$2"
    function dotfiles_find_installer() { echo "$test_dir/install.homebrew-tap"; }
    function brew_run() {
      if [[ "$1" == "tap" && "$#" -eq 1 ]]; then
        echo "gdubw/gng"
      elif [[ "$1" == "command" && "$2" == "trust" ]]; then
        return 0
      elif [[ "$1" == "tap-info" ]]; then
        cat <<EOF
[
  {
    "name": "gdubw/gng",
    "trusted": true
  }
]
EOF
      else
        echo "$*"
      fi
    }
    function run() { eval "$2"; }
    brew_taps
  ' -- "${BATS_TEST_DIRNAME}/.." "$TEST_DIR"

  [[ "$status" -eq 0 ]]
  [[ "${lines[0]}" == "tap atlassian/tap https://github.com/atlassian/homebrew-tap" ]]
  [[ "${lines[1]}" == "trust --tap atlassian/tap" ]]
  [[ "${#lines[@]}" -eq 2 ]]
}
