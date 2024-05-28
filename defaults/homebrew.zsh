if [ "Darwin" = "$(uname)" ]; then
  case $(uname -m) in
      x86_64)
        HOMEBREW_PREFIX="/usr/local"
      ;;
      arm64)
        HOMEBREW_PREFIX="/opt/homebrew"
      ;;
      *)
        >&2 echo "Unknown architecture $(uname -m) unable to set HOMEBREW_PREFIX environment"
      ;;
  esac
else
  HOMEBREW_PREFIX="$HOME/.linuxbrew"
fi
export HOMEBREW_PREFIX


function brew() {
  if [ -z "$HOMEBREW_PREFIX" ]; then
    brew $@
  else
    "$HOMEBREW_PREFIX/bin/brew" $@
  fi
}
