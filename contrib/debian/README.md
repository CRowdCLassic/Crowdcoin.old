
Debian
====================
This directory contains files used to package crowdclassicd/crowdclassic-qt
for Debian-based Linux systems. If you compile crowdclassicd/crowdclassic-qt yourself, there are some useful files here.

## crowdclassic: URI support ##


crowdclassic-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install crowdclassic-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your crowdclassic-qt binary to `/usr/bin`
and the `../../share/pixmaps/crowdclassic128.png` to `/usr/share/pixmaps`

crowdclassic-qt.protocol (KDE)

