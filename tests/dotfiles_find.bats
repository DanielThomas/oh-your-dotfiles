#!/usr/bin/env bats

load test_helper

@test "finds files matching a glob pattern" {
  create_files "path.zsh" "other.zsh" "completion.zsh"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"path.zsh"* ]]
  [[ "$output" == *"other.zsh"* ]]
  [[ "$output" == *"completion.zsh"* ]]
}

# OS suffix

@test "finds os suffixed files" {
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  create_files "path.zsh" "path.zsh.${os}"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"path.zsh.${os}"* ]]
}

@test "excludes os suffixed files for wrong os" {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local other_os="linux"
  else
    local other_os="darwin"
  fi
  create_files "path.zsh" "path.zsh.${other_os}"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"topic/path.zsh"* ]]
  [[ "$output" != *"${other_os}"* ]]
}

@test "finds os suffixed files on simulated linux" {
  create_files "path.zsh" "path.zsh.linux" "path.zsh.darwin"
  run_dotfiles_fn_with_platform x86_64 Linux false dotfiles_find "'*.zsh'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"path.zsh.linux"* ]]
  [[ "$output" != *"path.zsh.darwin"* ]]
}

# OS-arch suffix

@test "finds os-arch suffixed files" {
  local arch=$(uname -m)
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  create_files "path.zsh" "path.zsh.${os}-${arch}"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"path.zsh.${os}-${arch}"* ]]
}

@test "excludes os-arch files for wrong os" {
  local arch=$(uname -m)
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local other_os="linux"
  else
    local other_os="darwin"
  fi
  create_files "path.zsh" "path.zsh.${other_os}-${arch}"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"topic/path.zsh"* ]]
  [[ "$output" != *"${other_os}-${arch}"* ]]
}

@test "excludes os-arch files for wrong arch" {
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  if [[ "$(uname -m)" == "arm64" ]]; then
    local other_arch="x86_64"
  else
    local other_arch="arm64"
  fi
  create_files "path.zsh" "path.zsh.${os}-${other_arch}"
  run_dotfiles_fn dotfiles_find "'*.zsh'"
  [[ "$output" == *"topic/path.zsh"* ]]
  [[ "$output" != *"${os}-${other_arch}"* ]]
}

# Ignored directories

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

# .env files

@test "finds env files with os-arch suffix" {
  local arch=$(uname -m)
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  create_files "java.env" "java.env.${os}-${arch}"
  run_dotfiles_fn dotfiles_find "'*.env'"
  [[ "$output" == *"java.env"* ]]
  [[ "$output" == *"java.env.${os}-${arch}"* ]]
}
