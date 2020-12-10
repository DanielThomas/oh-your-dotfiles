function brew() {
  local arch=$(uname -m)
  case $arch in
    x86_64)
      /usr/local/bin/brew $@
    ;;
    arm64)
      /opt/homebrew/bin/brew $@
    ;;
    *)
      >&2 echo "Unknown architecture $arch"
    ;;
  esac
}
