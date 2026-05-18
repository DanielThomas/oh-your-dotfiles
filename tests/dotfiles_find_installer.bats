#!/usr/bin/env bats

load test_helper

@test "finds universal installer on native arch" {
  local arch=$(uname -m)
  create_files "install.sh" "install.sh.${arch}" "install.sh.${arch}-native"
  run_dotfiles_fn dotfiles_find_installer "'install.sh'"
  [[ "$output" == *"install.sh"* ]]
  [[ "$output" == *"install.sh.${arch}"* ]]
  [[ "$output" == *"install.sh.${arch}-native"* ]]
}

@test "translated arch excludes universal installer to prevent double-execution" {
  create_files "install.sh" "install.sh.x86_64" "install.sh.x86_64-native" "install.sh.arm64" "install.sh.arm64-native"
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
    dotfiles_find_installer 'install.sh'
  "
  [[ "$status" -eq 0 ]]
  # only the translated arch-specific installer
  [[ "$output" == *"install.sh.x86_64"* ]]
  # no universal (avoids double-execution)
  [[ "$output" != *"topic/install.sh"$'\n'* ]]
  # no native-only
  [[ "$output" != *"x86_64-native"* ]]
  # no other arch
  [[ "$output" != *"arm64"* ]]
}
