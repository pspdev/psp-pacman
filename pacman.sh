#!/usr/bin/env bash
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
PACMAN_VERSION="7.1.0"
INSTALL_DIR="${PSPDEV}/share/pacman"
BASE_PATH="${PWD}"

## Prepare the build environment
mkdir -p "${BASE_PATH}/build"
cd "${BASE_PATH}/build"
download_and_extract https://gitlab.archlinux.org/pacman/pacman/-/archive/v${PACMAN_VERSION}/pacman-v${PACMAN_VERSION}.tar.gz pacman-v${PACMAN_VERSION}

## Apply patch
apply_patch pacman-${PACMAN_VERSION}-rootless
apply_patch pacman-${PACMAN_VERSION}-psp-strip

## Fix some lines in the scripts which have hardcoded paths
find ./ -type f -name "*.in" -exec sed -i -e "s#LIBRARY=\${LIBRARY:-'@libmakepkgdir@'}#LIBRARY=\${LIBRARY:-\"\${PSPDEV}/share/makepkg\"}#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e "s#declare -r confdir='@sysconfdir@'#declare -r confdir=\"\${PSPDEV}/etc\"#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e "s#export TEXTDOMAINDIR='@localedir@'#export TEXTDOMAINDIR=\"\${PSPDEV}/share/locale\"#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e "s#'@libmakepkgdir@'#\${PSPDEV}/share/makepkg#g" {} \;
find ./ -type f -name "*.in" -exec sed -i -e "s#@libmakepkgdir@#\${PSPDEV}/share/makepkg#g" {} \;

## Install meson and ninja in the current directory
setup_build_system

## Build pacman
meson build -Dprefix="${PSPDEV}" --buildtype=release \
  -Ddefault_library=static  -Dbuildscript=PSPBUILD \
  -Droot-dir="${PSPDEV}" -Dsysconfdir="etc" -Dmakepkg-template-dir="share/makepkg-template" -Dbindir="share/pacman/bin" -Dlocalstatedir="var" \
  -Ddoc=disabled -Di18n=false -Dbash-completions-dir="share/bash-completion/completions"
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
install -m 755 scripts/get-arch "${PSPDEV}/share/pacman/bin/get-arch"
install -d "${PSPDEV}/etc/pacman.d/gnupg/"
install -d "${PSPDEV}/var/log/"
install -d "${PSPDEV}/etc/pacman.d/hooks"

## Make sure the dbpath directory exists
mkdir -p "${PSPDEV}/var/lib/pacman"

## Store build information
BUILD_FILE="${PSPDEV}/build.txt"
if [[ -f "${BUILD_FILE}" ]]; then
  sed -i'' '/^psp-pacman /d' "${BUILD_FILE}"
fi
git log -1 --format="psp-pacman %H %cs %s" >> "${BUILD_FILE}"

## Done
echo "psp-pacman installation finished."
