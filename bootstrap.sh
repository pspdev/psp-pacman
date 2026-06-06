#!/usr/bin/env bash

## Make sure PSPDEV is set
if [ -z "${PSPDEV}" ]; then
    echo "The PSPDEV environment variable has not been set"
    exit 1
fi

if [ ! -d "${PSPDEV}" ]; then
    echo "${PSPDEV} does not exist"
    exit 2
fi

## Enter the script directory.
cd "$(dirname "$0")"

## Build the package
CARCH="$(./get-arch)" makepkg -p PSPBUILD .

## Create the required directories for installation
install -d -m 755 -p "${PSPDEV}/var/lib/pacman"

## Add the directory with pacman's binaries to the start of the PATH
export PATH="${PWD}pkg/psp-pacman/share/pacman/bin:${PATH}"
export LD_LIBRARY_PATH="${PWD}pkg/psp-pacman/lib:${LD_LIBRARY_PATH}"

## The package in $PSPDEV using the pacman that was build
./pkg/psp-pacman/share/pacman/bin/pacman  \
  --root "${PSPDEV}" \
  --dbpath "${PSPDEV}/var/lib/pacman" \
  --config "pacman.conf" \
  --arch "$(./get-arch)" \
  -U psp-pacman-*-$(./get-arch).pkg.tar.gz
