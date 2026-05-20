#!/usr/bin/env bats

load test_helper

# Helper: run .zshrc env loading logic in isolation against the test dotfiles
run_env_loader() {
  run zsh -c "
    export DOTFILES_DIR='${BATS_TEST_DIRNAME}/..'
    defaults='$TEST_DIR/empty_defaults'
    mkdir -p \"\$defaults\"
    source '${BATS_TEST_DIRNAME}/../lib/dotfiles.zsh'
    function dotfiles() { echo '$TEST_DIR'; }

    typeset -U env_files
    env_files=(\$(dotfiles_find \*.env))
    for file in \$env_files; do
      while IFS= read -r line || [[ -n \"\$line\" ]]; do
        [[ -z \"\$line\" || \"\$line\" == \#* ]] && continue
        local key=\"\${line%%=*}\"
        local val=\"\${line#*=}\"
        [[ \"\$val\" == \"~\" || \"\$val\" == \"~/\"* ]] && val=\"\$HOME\${val:1}\"
        if [[ \"\$key\" == \"PATH\" ]]; then
          export PATH=\"\$val:\$PATH\"
        else
          export \"\$key\"=\"\$val\"
        fi
      done < \"\$file\"
    done

    $1
  "
}

@test "sets environment variables from .env files" {
  echo "GOPATH=/home/user/go" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $GOPATH'
  [[ "$output" == "/home/user/go" ]]
}

@test "overwrites existing variables" {
  echo "EDITOR=vim" > "$TEST_TOPIC_DIR/system.env"
  EDITOR=nano run_env_loader 'echo $EDITOR'
  [[ "$output" == "vim" ]]
}

@test "prepends PATH entries" {
  echo "PATH=/custom/bin" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $PATH'
  [[ "$output" == "/custom/bin:"* ]]
}

@test "prepends multiple PATH entries from separate lines" {
  printf "PATH=/first/bin\nPATH=/second/bin\n" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $PATH'
  [[ "$output" == "/second/bin:/first/bin:"* ]]
}

@test "skips blank lines and comments" {
  printf "# a comment\n\nGOPATH=/home/user/go\n# another comment\n" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $GOPATH'
  [[ "$output" == "/home/user/go" ]]
}

@test "handles values containing equals signs" {
  echo "JAVA_OPTS=-Xmx=512m" > "$TEST_TOPIC_DIR/java.env"
  run_env_loader 'echo $JAVA_OPTS'
  [[ "$output" == "-Xmx=512m" ]]
}

@test "expands ~ to HOME in values" {
  echo "GOPATH=~/go" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $GOPATH'
  [[ "$output" == "$HOME/go" ]]
}

@test "expands bare ~ to HOME" {
  echo "MY_DIR=~" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $MY_DIR'
  [[ "$output" == "$HOME" ]]
}

@test "expands ~ in PATH values" {
  echo "PATH=~/bin" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $PATH'
  [[ "$output" == "$HOME/bin:"* ]]
}

@test "does not expand ~ in the middle of values" {
  echo "OPTS=foo~bar" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $OPTS'
  [[ "$output" == "foo~bar" ]]
}

@test "does not expand ~user syntax" {
  echo "DIR=~nobody" > "$TEST_TOPIC_DIR/dev.env"
  run_env_loader 'echo $DIR'
  [[ "$output" == "~nobody" ]]
}
