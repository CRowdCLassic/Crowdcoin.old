Sample init scripts and service configuration for crowdclassicd
==========================================================

Sample scripts and configuration files for systemd, Upstart and OpenRC
can be found in the contrib/init folder.

    contrib/init/crowdclassicd.service:    systemd service unit configuration
    contrib/init/crowdclassicd.openrc:     OpenRC compatible SysV style init script
    contrib/init/crowdclassicd.openrcconf: OpenRC conf.d file
    contrib/init/crowdclassicd.conf:       Upstart service configuration file
    contrib/init/crowdclassicd.init:       CentOS compatible SysV style init script

1. Service User
---------------------------------

All three Linux startup configurations assume the existence of a "crowdclassiccore" user
and group.  They must be created before attempting to use these scripts.
The OS X configuration assumes crowdclassicd will be set up for the current user.

2. Configuration
---------------------------------

At a bare minimum, crowdclassicd requires that the rpcpassword setting be set
when running as a daemon.  If the configuration file does not exist or this
setting is not set, crowdclassicd will shutdown promptly after startup.

This password does not have to be remembered or typed as it is mostly used
as a fixed token that crowdclassicd and client programs read from the configuration
file, however it is recommended that a strong and secure password be used
as this password is security critical to securing the wallet should the
wallet be enabled.

If crowdclassicd is run with the "-server" flag (set by default), and no rpcpassword is set,
it will use a special cookie file for authentication. The cookie is generated with random
content when the daemon starts, and deleted when it exits. Read access to this file
controls who can access it through RPC.

By default the cookie is stored in the data directory, but it's location can be overridden
with the option '-rpccookiefile'.

This allows for running crowdclassicd without having to do any manual configuration.

`conf`, `pid`, and `wallet` accept relative paths which are interpreted as
relative to the data directory. `wallet` *only* supports relative paths.

For an example configuration file that describes the configuration settings,
see `contrib/debian/examples/crowdclassic.conf`.

3. Paths
---------------------------------

3a) Linux

All three configurations assume several paths that might need to be adjusted.

Binary:              `/usr/bin/crowdclassicd`  
Configuration file:  `/etc/crowdclassiccore/crowdclassic.conf`  
Data directory:      `/var/lib/crowdclassicd`  
PID file:            `/var/run/crowdclassicd/crowdclassicd.pid` (OpenRC and Upstart) or `/var/lib/crowdclassicd/crowdclassicd.pid` (systemd)  
Lock file:           `/var/lock/subsys/crowdclassicd` (CentOS)  

The configuration file, PID directory (if applicable) and data directory
should all be owned by the crowdclassiccore user and group.  It is advised for security
reasons to make the configuration file and data directory only readable by the
crowdclassiccore user and group.  Access to crowdclassic-cli and other crowdclassicd rpc clients
can then be controlled by group membership.

3b) Mac OS X

Binary:              `/usr/local/bin/crowdclassicd`  
Configuration file:  `~/Library/Application Support/CRowdCLassicCore/crowdclassic.conf`  
Data directory:      `~/Library/Application Support/CRowdCLassicCore`
Lock file:           `~/Library/Application Support/CRowdCLassicCore/.lock`

4. Installing Service Configuration
-----------------------------------

4a) systemd

Installing this .service file consists of just copying it to
/usr/lib/systemd/system directory, followed by the command
`systemctl daemon-reload` in order to update running systemd configuration.

To test, run `systemctl start crowdclassicd` and to enable for system startup run
`systemctl enable crowdclassicd`

4b) OpenRC

Rename crowdclassicd.openrc to crowdclassicd and drop it in /etc/init.d.  Double
check ownership and permissions and make it executable.  Test it with
`/etc/init.d/crowdclassicd start` and configure it to run on startup with
`rc-update add crowdclassicd`

4c) Upstart (for Debian/Ubuntu based distributions)

Drop crowdclassicd.conf in /etc/init.  Test by running `service crowdclassicd start`
it will automatically start on reboot.

NOTE: This script is incompatible with CentOS 5 and Amazon Linux 2014 as they
use old versions of Upstart and do not supply the start-stop-daemon utility.

4d) CentOS

Copy crowdclassicd.init to /etc/init.d/crowdclassicd. Test by running `service crowdclassicd start`.

Using this script, you can adjust the path and flags to the crowdclassicd program by
setting the CRCD and FLAGS environment variables in the file
/etc/sysconfig/crowdclassicd. You can also use the DAEMONOPTS environment variable here.

4e) Mac OS X

Copy org.crowdclassic.crowdclassicd.plist into ~/Library/LaunchAgents. Load the launch agent by
running `launchctl load ~/Library/LaunchAgents/org.crowdclassic.crowdclassicd.plist`.

This Launch Agent will cause crowdclassicd to start whenever the user logs in.

NOTE: This approach is intended for those wanting to run crowdclassicd as the current user.
You will need to modify org.crowdclassic.crowdclassicd.plist if you intend to use it as a
Launch Daemon with a dedicated crowdclassiccore user.

5. Auto-respawn
-----------------------------------

Auto respawning is currently only configured for Upstart and systemd.
Reasonable defaults have been chosen but YMMV.
