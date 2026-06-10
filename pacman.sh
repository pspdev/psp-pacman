#!/usr/bin/env bash
# pacman.sh by Wouter Wijsman (wwijsman@live.nl)
# This script is legacy, don't use it. It is only here to make the existing workflows not fail.

# Exit on errors
set -e

## Remove $CC and $CXX for configure
unset CC
unset CXX

## Make sure PSPDEV is set
if [ -z "${PSPDEV}" ]; then
    echo "The PSPDEV environment variable has not been set"
    exit 1
fi

## Enter the script directory.
cd "$(dirname "$0")"
WORKDIR="${PWD}"

## MacOS specific environment variables
if [ "$(uname -s)" == "Darwin" ]; then
    export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$(brew --prefix bash)/bin:$PATH"
    export PKG_CONFIG_PATH="$(brew --prefix libarchive)/lib/pkgconfig"
fi

source PSPBUILD
export pkgdir="${PSPDEV}"
rm -rf pacman-v${pkgver}
wget -nc ${source[0]}
tar -xvf pacman-v${pkgver}.tar.gz
prepare
cd "$WORKDIR"
build
cd "$WORKDIR"
package
