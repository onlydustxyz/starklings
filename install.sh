#!/usr/bin/env bash
set -e

echo Installing starklings

STARKLINGS_DIR=${STARKLINGS_DIR-"$HOME/.starklings"}
mkdir -p "$STARKLINGS_DIR"


PLATFORM="$(uname -s)"
case $PLATFORM in
  Linux)
    PLATFORM="Linux"
    ;;
  Darwin)
    PLATFORM="macOS"
    ;;
  *)
    echo "unsupported platform: $PLATFORM"
    exit 1
    ;;
esac

STARKLINGS_REPO="https://github.com/onlydustxyz/starklings"

echo Retrieving the latest version from $STARKLINGS_REPO...

LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' "${STARKLINGS_REPO}/releases/latest")
LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

echo Using version $LATEST_VERSION

LATEST_RELEASE_URL="${STARKLINGS_REPO}/releases/download/${LATEST_VERSION}"
STARKLINGS_TARBALL_NAME="starklings-${PLATFORM}.tar.gz"
TARBALL_DOWNLOAD_URL="${LATEST_RELEASE_URL}/${STARKLINGS_TARBALL_NAME}"

echo "Downloading starklings from ${TARBALL_DOWNLOAD_URL}"
curl -L $TARBALL_DOWNLOAD_URL | tar -xvzC $STARKLINGS_DIR

STARKLINGS_BINARY_DIR="${STARKLINGS_DIR}/dist/starklings"
STARKLINGS_BINARY="${STARKLINGS_BINARY_DIR}/starklings"
chmod +x $STARKLINGS_BINARY

case $SHELL in
*/zsh)
    PROFILE=$HOME/.zshrc
    PREF_SHELL=zsh
    ;;
*/bash)
    PROFILE=$HOME/.bashrc
    PREF_SHELL=bash
    ;;
*/fish)
    PROFILE=$HOME/.config/fish/config.fish
    PREF_SHELL=fish
    ;;
*)
    echo "error: could not detect shell, manually add ${STARKLINGS_BINARY_DIR} to your PATH."
    exit 1
esac

if [[ ":$PATH:" != *":${STARKLINGS_BINARY_DIR}:"* ]]; then
    echo >> $PROFILE && echo "export PATH=\"\$PATH:$STARKLINGS_BINARY_DIR\"" >> $PROFILE
fi

echo && echo "Detected your preferred shell is ${PREF_SHELL} and added starklings to PATH. Run 'source ${PROFILE}' or start a new terminal session to use starklings."
echo "Then, simply run 'starklings --help' "
