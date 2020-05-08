#!/bin/bash
# pacman-sudo.sh by Wouter Wijsman (wwijsman@live.nl)

## Enter the psp-pacman directory.
cd "$(dirname "$0")" || { echo "ERROR: Could not enter the psp-pacman directory."; exit 1; }

export PSPDEV=/usr/local/pspdev
export PATH=$PATH:$PSPDEV/bin

## Run the pacman script.
./pacman.sh $@ || { echo "ERROR: Could not run the pacman script."; exit 1; }