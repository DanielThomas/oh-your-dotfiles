source "${0:a:h}/homebrew.zsh"
BREW_PATH=""
if [[ ":$PATH:" != *":$HOMEBREW_PREFIX/bin:"* ]]; then
  BREW_PATH="${HOMEBREW_PREFIX}/bin:"
fi
if [[ ":$PATH:" != *":$HOMEBREW_PREFIX/sbin:"* ]]; then
  BREW_PATH="${BREW_PATH}${HOMEBREW_PREFIX}/sbin:"
fi
if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
  BREW_PATH="${BREW_PATH}/usr/local/bin:"
fi
if [[ ":$PATH:" != *":/usr/local/sbin:"* ]]; then
  BREW_PATH="${BREW_PATH}/usr/local/sbin:"
fi
if [ ! -z "$BREW_PATH" ]; then
  export PATH="${BREW_PATH}${PATH}"
fi
