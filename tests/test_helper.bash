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
