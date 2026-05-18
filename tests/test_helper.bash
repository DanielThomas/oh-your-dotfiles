setup() {
  TEST_DIR="$(mktemp -d)"
  TEST_TOPIC_DIR="$TEST_DIR/topic"
  mkdir -p "$TEST_TOPIC_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

# Run a dotfiles function in zsh with the test environment
# Overrides dotfiles() and defaults to isolate from the real home directory
run_dotfiles_fn() {
  local fn="$1"
  shift
  run zsh -c "
    defaults='$TEST_DIR/empty_defaults'
    mkdir -p \"\$defaults\"
    source '${BATS_TEST_DIRNAME}/../lib/dotfiles.zsh'
    function dotfiles() { echo '$TEST_DIR'; }
    $fn $*
  "
}

# Run a dotfiles function in zsh with a simulated platform (os/arch)
# Usage: run_dotfiles_fn_with_platform <uname_m> <uname_s> <apple_silicon:true|false> <fn> <args...>
run_dotfiles_fn_with_platform() {
  local sim_arch="$1" sim_os="$2" sim_apple="$3" fn="$4"
  shift 4
  local sysctl_override=""
  if [[ "$sim_apple" == "true" ]]; then
    sysctl_override="
    function sysctl() {
      if [[ \"\$2\" == 'machdep.cpu.brand_string' ]]; then echo 'Apple M1'
      else command sysctl \"\$@\"
      fi
    }"
  fi
  run zsh -c "
    defaults='$TEST_DIR/empty_defaults'
    mkdir -p \"\$defaults\"
    source '${BATS_TEST_DIRNAME}/../lib/dotfiles.zsh'
    function dotfiles() { echo '$TEST_DIR'; }
    function uname() {
      if [[ \"\$1\" == '-m' ]]; then echo '${sim_arch}'
      elif [[ -z \"\$1\" || \"\$1\" == '-s' ]]; then echo '${sim_os}'
      else command uname \"\$@\"
      fi
    }
    ${sysctl_override}
    $fn $*
  "
}

# Create files relative to TEST_TOPIC_DIR
create_files() {
  for f in "$@"; do
    touch "$TEST_TOPIC_DIR/$f"
  done
}

# Create files relative to TEST_DIR
create_files_in() {
  local dir="$1"
  shift
  mkdir -p "$TEST_DIR/$dir"
  for f in "$@"; do
    touch "$TEST_DIR/$dir/$f"
  done
}
