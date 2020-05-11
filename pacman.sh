#!/bin/bash
# pacman.sh by Wouter Wijsman (wwijsman@live.nl)

# Exit on errors
set -e
set -u

## Remove $CC and $CXX for configure
unset CC
unset CXX

## Enter the psp-pacman directory.
cd "$(dirname "$0")"

## Load common functions
source common.sh

## Variables used to build
PACMAN_VERSION="5.2.1"
INSTALL_DIR="${PSPDEV}/share/pacman"
BASE_PATH="${PWD}"

## Only install if pacman is not available
if ! which "pacman" >/dev/null 2>&1; then
    mkdir -p "${BASE_PATH}/build"
    cd "${BASE_PATH}/build"
    download_and_extract https://sources.archlinux.org/other/pacman/pacman-${PACMAN_VERSION}.tar.gz pacman-${PACMAN_VERSION}
    #apply_patch pacman-${PACMAN_VERSION}

    ## Install meson and ninja in the current directory
    setup_build_system

    ## Build pacman
    meson build
    meson configure build -Dprefix="${PSPDEV}" -Dbuildscript=PSPBUILD -Droot-dir="${PSPDEV}" -Dbindir="${PSPDEV}/share/pacman/bin" -Ddoc=disabled
    cd build
    ninja

    ## Install
    ninja install
fi

## Install configuration files and wrapper script
cd "${BASE_PATH}"
install -D -m 644 config/pacman.conf "${PSPDEV}/etc/pacman.conf"
install -D -m 644 config/makepkg.conf "${PSPDEV}/etc/makepkg.conf"
install -D -m 755 scripts/psp-pacman "${PSPDEV}/bin/psp-pacman"
install -D -m 755 scripts/psp-makepkg "${PSPDEV}/bin/psp-makepkg"

## Make sure the dbpath directory exists
mkdir -p "${PSPDEV}/var/lib/pacman"

## Done
echo "Installation finished."
