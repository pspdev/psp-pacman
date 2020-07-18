#!/bin/bash
# pacman.sh by Wouter Wijsman (wwijsman@live.nl)

# Exit on errors
set -e
set -u

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

    ## Apply temporary patch
    ## Will probably not be needed for the next version of pacman
    apply_patch pacman-${PACMAN_VERSION}

    if [ "$(uname)" == "Darwin" ]; then
        BPFX="`brew --prefix`"
        # link in keg-only deps
        export PKG_CONFIG_PATH="$BPFX/opt/libarchive/lib/pkgconfig:$BPFX/opt/openssl/lib/pkgconfig"
        # use 'install' from coreutils
        export PATH="$BPFX/opt/coreutils/libexec/gnubin:$PATH"
    else
        ## Install meson and ninja in the current directory
        setup_build_system
    fi

    ## Build pacman
    meson build
    meson configure build -Dprefix="${PSPDEV}" --buildtype=release \
      -Ddefault_library=static  -Dbuildscript=PSPBUILD \
      -Droot-dir="${PSPDEV}" -Dbindir="${PSPDEV}/share/pacman/bin" \
      -Ddoc=disabled -Di18n=false
    cd build
    ninja

    ## Install
    ninja install
fi

## Install configuration files and wrapper script
cd "${BASE_PATH}"
mkdir -p "${PSPDEV}/bin"
mkdir -p "${PSPDEV}/etc"
install -m755 scripts/psp-{pacman,makepkg} "${PSPDEV}/bin"
install -m644 config/{pacman,makepkg}.conf "${PSPDEV}/etc"

## Make sure the dbpath directory exists
mkdir -p "${PSPDEV}/var/lib/pacman"

## Done
echo "psp-pacman installation finished."
