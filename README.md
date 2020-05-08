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

## Usage

Here is how to use ``psp-pacman`` and ``psp-makepkg``.

### Installing a package

Installing a ``*.pkg.tar.gz`` package with a PSP library can be done with:
```
psp-pacman -U package-name-1.0.2.pkg.tar.gz
```

### Building a package

Building a package requires a ``PSPBUILD`` script. Here is [an example](https://git.archlinux.org/pacman.git/plain/proto/PKGBUILD.proto) and [some documentation on which options are available](https://wiki.archlinux.org/index.php/PKGBUILD). Do **not** call it ``PKGBUILD``, though, use ``PSPBUILD`` instead. Also make sure to install libraries in ``$pkgdir/lib`` in your build script, since this will translate to ``$PSPDEV/psp/lib`` when installing. The architecure expected is mips.

Packages can be build by running the following command in a directory with a PSPBUILD file in it:
```
psp-makepkg
```

This will create a file called something like ``package-name-1.0.2.pkg.tar.gz``. This file can be shared or installed. Installing would be done using the following command:
```
psp-pacman -U package-name-1.0.2.pkg.tar.gz
```
