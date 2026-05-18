#!/usr/bin/env bats

load test_helper

# Native architecture

@test "finds universal and os-only installers on native arch" {
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  create_files "install.sh" "install.sh.${os}"
  run_dotfiles_fn dotfiles_find_installer "'install.sh'"
  [[ "$output" == *"topic/install.sh"* ]]
  [[ "$output" == *"install.sh.${os}"* ]]
}

@test "finds arch suffixed installers on native arch" {
  local arch=$(uname -m)
  create_files "install.homebrew-cask.${arch}" "install.homebrew-cask.${arch}-native"
  run_dotfiles_fn dotfiles_find_installer "'install.homebrew-cask'"
  [[ "$output" == *"install.homebrew-cask.${arch}"* ]]
  [[ "$output" == *"install.homebrew-cask.${arch}-native"* ]]
}

@test "finds os-arch suffixed installers on native arch" {
  local arch=$(uname -m)
  local os=$(uname -s | tr '[:upper:]' '[:lower:]')
  create_files "install.sh.${os}-${arch}" "install.sh.${os}-${arch}-native"
  run_dotfiles_fn dotfiles_find_installer "'install.sh'"
  [[ "$output" == *"install.sh.${os}-${arch}"* ]]
  [[ "$output" == *"install.sh.${os}-${arch}-native"* ]]
}

# Translated architecture (simulated x86_64 on Apple Silicon)

@test "translated arch excludes universal and os-only installers to prevent double-execution" {
  create_files "install.sh" "install.sh.darwin" "install.sh.darwin-x86_64" "install.sh.x86_64"
  run_dotfiles_fn_with_platform x86_64 Darwin true dotfiles_find_installer "'install.sh'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"install.sh.x86_64"* ]]
  [[ "$output" == *"darwin-x86_64"* ]]
  # no universal
  [[ "$output" != *"topic/install.sh"$'\n'* ]]
  # no os-only
  [[ "$output" != *"install.sh.darwin"$'\n'* ]]
}

@test "translated arch finds arch suffixed installer but not native" {
  create_files "install.homebrew-cask.x86_64" "install.homebrew-cask.x86_64-native" "install.homebrew-cask.arm64"
  run_dotfiles_fn_with_platform x86_64 Darwin true dotfiles_find_installer "'install.homebrew-cask'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"install.homebrew-cask.x86_64"* ]]
  [[ "$output" != *"x86_64-native"* ]]
  [[ "$output" != *"arm64"* ]]
}

@test "translated arch finds os-arch installer but not os-arch-native" {
  create_files "install.sh.darwin-x86_64" "install.sh.darwin-x86_64-native" "install.sh.darwin-arm64" "install.sh.linux-x86_64"
  run_dotfiles_fn_with_platform x86_64 Darwin true dotfiles_find_installer "'install.sh'"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"darwin-x86_64"* ]]
  [[ "$output" != *"darwin-x86_64-native"* ]]
  [[ "$output" != *"darwin-arm64"* ]]
  [[ "$output" != *"linux-x86_64"* ]]
}
