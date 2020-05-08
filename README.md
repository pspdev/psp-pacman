# PSP Pacman

This respository contains all the files needed to build and install the pacman package managed for the PSP toolchain. Pacman can be used to build and manage packages with libraries for the PSP.

This package provides the following commands:
- **psp-pacman** - Allows users to install and manage PSP library packages.
- **psp-makepkg** - Allows users to build packages from PSPBUILD files.

## Dependencies

On Ubuntu/Debian, the following packages need to be installed:
- libarchive-dev
- libcurl4-openssl-dev
- libssl-dev
- pkg-config
- python3
- python3-venv

Besides that, the [PSP toolchain](https://github.com/pspdev/psptoolchain) will need to be installed before installing this.

## Installation
1. Install the dependencies.
2. Make sure the environment variable ``$PSPDEV`` is set in your shell. Use ``echo $PSPDEV`` to confirm this.
3. If ``$PSPDEV`` is set to ``/usr/local/pspdev``, install with the following command:
```
sudo ./pacman-sudo.sh
```
If you've installed the PSP toolchain in a user writable location use:
```
./pacman.sh
```
