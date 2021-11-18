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
PACMAN_VERSION="6.0.1"
INSTALL_DIR="${PSPDEV}/share/pacman"
BASE_PATH="${PWD}"

## Prepare the build environment
mkdir -p "${BASE_PATH}/build"
cd "${BASE_PATH}/build"
download_and_extract https://sources.archlinux.org/other/pacman/pacman-${PACMAN_VERSION}.tar.xz pacman-${PACMAN_VERSION}

## Fix some lines in the scripts which have hardcoded paths
find ./ -type f -name "*.in" -exec sed -i -e "s#LIBRARY=\${LIBRARY:-'@libmakepkgdir@'}#LIBRARY=\${LIBRARY:-\"\${PSPDEV}/share/makepkg\"}#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e "s#declare -r confdir='@sysconfdir@'#declare -r confdir=\"\${PSPDEV}/etc\"#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e "s#export TEXTDOMAINDIR='@localedir@'#export TEXTDOMAINDIR=\"\${PSPDEV}/share/locale\"#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e 's#@libmakepkgdir@#${PSPDEV}/share/makepkg#g' {} \;

## Apply patch
apply_patch pacman-${PACMAN_VERSION}

## Install meson and ninja in the current directory
setup_build_system

## Build pacman
meson build -Dprefix="${PSPDEV}" --buildtype=release \
  -Ddefault_library=static  -Dbuildscript=PSPBUILD \
  -Dprefix="${PSPDEV}" -Dsysconfdir="${PSPDEV}/etc" -Dbindir="${PSPDEV}/share/pacman/bin" -Dlocalstatedir="${PSPDEV}/var" \
  -Ddoc=disabled -Di18n=false
cd build
ninja

## Install
ninja install

## Install configuration files and wrapper script
cd "${BASE_PATH}"
install -d "${PSPDEV}/etc/"
install -m 644 config/pacman.conf "${PSPDEV}/etc/pacman.conf"
install -m 644 config/makepkg.conf "${PSPDEV}/etc/makepkg.conf"
install -d "${PSPDEV}/bin/"
install -m 755 scripts/psp-pacman "${PSPDEV}/bin/psp-pacman"
install -m 755 scripts/psp-makepkg "${PSPDEV}/bin/psp-makepkg"

## Make sure the dbpath directory exists
mkdir -p "${PSPDEV}/var/lib/pacman"

## Done
echo "psp-pacman installation finished."
