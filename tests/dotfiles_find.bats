#!/usr/bin/env bats

load test_helper

@test "finds files matching a glob pattern" {
  create_files "path.zsh" "other.zsh" "completion.zsh"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"path.zsh"* ]]
  [[ "$output" == *"other.zsh"* ]]
  [[ "$output" == *"completion.zsh"* ]]
}

@test "finds native architecture suffixed files" {
  local arch=$(uname -m)
  create_files "path.zsh" "path.zsh.${arch}" "path.zsh.${arch}-native"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"path.zsh.${arch}"* ]]
  [[ "$output" == *"path.zsh.${arch}-native"* ]]
}

@test "excludes files for non-native architecture" {
  if [[ "$(uname -m)" == "arm64" ]]; then
    local other_arch="x86_64"
  else
    local other_arch="arm64"
  fi
  create_files "path.zsh" "path.zsh.${other_arch}" "path.zsh.${other_arch}-native"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"path.zsh"* ]]
  [[ "$output" != *"path.zsh.${other_arch}"* ]]
}

@test "translated arch finds universal and arch-suffixed but not native-only" {
  create_files "path.zsh" "path.zsh.x86_64" "path.zsh.x86_64-native" "path.zsh.arm64" "path.zsh.arm64-native"
  # Simulate x86_64 running on Apple Silicon by overriding uname and sysctl
  run zsh -c "
    defaults='$TEST_DIR/empty_defaults'
    mkdir -p \"\$defaults\"
    source '${BATS_TEST_DIRNAME}/../lib/dotfiles.zsh'
    function dotfiles() { echo '$TEST_DIR'; }
    function uname() {
      if [[ \"\$1\" == '-m' ]]; then echo 'x86_64'
      else command uname \"\$@\"
      fi
    }
    function sysctl() {
      if [[ \"\$2\" == 'machdep.cpu.brand_string' ]]; then echo 'Apple M1'
      else command sysctl \"\$@\"
      fi
    }
    dotfiles_find '*.zsh'
  "
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"path.zsh.x86_64"* ]]
  # universal files are still found
  [[ "$output" == *"topic/path.zsh"* ]]
  # native-only excluded under translation
  [[ "$output" != *"x86_64-native"* ]]
  # other arch excluded
  [[ "$output" != *"arm64"* ]]
}

@test "excludes files in directories with .dotfiles_ignore" {
  create_files "path.zsh"
  create_files_in "ignored_topic" "path.zsh"
  touch "$TEST_DIR/ignored_topic/.dotfiles_ignore"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"topic/path.zsh"* ]]
  [[ "$output" != *"ignored_topic/path.zsh"* ]]
}

@test "excludes hidden directory files" {
  create_files "visible.zsh"
  mkdir -p "$TEST_DIR/.hidden"
  touch "$TEST_DIR/.hidden/secret.zsh"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"visible.zsh"* ]]
  [[ "$output" != *"secret.zsh"* ]]
}

@test "excludes bin directory files" {
  create_files "visible.zsh"
  create_files_in "bin" "tool.zsh"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"visible.zsh"* ]]
  [[ "$output" != *"tool.zsh"* ]]
}

@test "finds env files with architecture suffix" {
  local arch=$(uname -m)
  create_files "java.env" "java.env.${arch}"
  run_dotfiles_fn dotfiles_find "'*.env'"
  [[ "$output" == *"java.env"* ]]
  [[ "$output" == *"java.env.${arch}"* ]]
}
