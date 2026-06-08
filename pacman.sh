#!/usr/bin/env bash
# pacman.sh by Wouter Wijsman (wwijsman@live.nl)

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

## Install makepkg from source if it isn't already available
if ! which makepkg > /dev/null; then
    echo "Did not find makepkg, downloading and building pacman from source"
    wget https://gitlab.archlinux.org/pacman/pacman/-/archive/v7.1.0/pacman-v7.1.0.tar.gz
    tar -xvf pacman-v7.1.0.tar.gz
    cd pacman-v7.1.0
    meson build --buildtype=release -Ddoc=disabled -Di18n=false
    cd build
    ninja
    export PATH="${PWD}:${PATH}"
    cd ../..
fi

## Build the package
ls -l
CARCH="$(./get-arch)" makepkg -p PSPBUILD --nofakeroot .

## Create the required directories for installation
mkdir -m 755 -p "${PSPDEV}/var/lib/pacman"

## Add the directory with pacman's binaries to the start of the PATH
export PATH="${PWD}/pkg/psp-pacman/share/pacman/bin:${PATH}"

export LD_LIBRARY_PATH="${PWD}/pkg/psp-pacman/lib:${LD_LIBRARY_PATH}"

## The package in $PSPDEV using the pacman that was build
./pkg/psp-pacman/share/pacman/bin/pacman  \
  --root "${PSPDEV}" \
  --dbpath "${PSPDEV}/var/lib/pacman" \
  --config "pacman.conf" \
  --arch "$(./get-arch)" \
  --noconfirm \
  -U psp-pacman-*-$(./get-arch).pkg.tar.gz
