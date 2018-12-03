
Debian
====================
This directory contains files used to package crowdcoind/crowdcoin-qt
for Debian-based Linux systems. If you compile crowdcoind/crowdcoin-qt yourself, there are some useful files here.

## crowdcoin: URI support ##


crowdcoin-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install crowdcoin-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your crowdcoin-qt binary to `/usr/bin`
and the `../../share/pixmaps/crowdcoin128.png` to `/usr/share/pixmaps`

crowdcoin-qt.protocol (KDE)

