# Bergamota-ng

Bergamota-ng is a replacement firmware for Realtek 8196e platform. It currently
supports 150mbps(RTL8818) and 300mbps(RTL8192EE) companion chipsets.

Most firmwares based on realtek uses old software, known for a series of vulnerabilities
and lots of bugs. Most vendors does not even update stuff they got from realtek.
The original RTK SDK is badly written, specially the web interface. Bergamota does not
use any of this sources, only the patched kernel, and the Wireless driver from realtek.

There are two kernel versions available 2.6 and 3.10, both share the same codebase for the wireless driver,
but the 2.6 version runs better and more stable than version 3.10. Bergamota uses version 2.6.

Filesystem used as rootfs is Squashfs, and for persistent storage JFFS2.

Bergamota-ng does not have a web interface, yet. All administration is done
using the system shell. Future plans are to include web administration
tool.


Bergamota-ng Features

Realtek 8192cd kernel sources are patched against WPA2 key reinstallation attacks
Updated system binaries, busybox, dnsmasq, iproute, iptables, etc.
Custom startup system with berga-cli, a command line interface and system manager


Planned Feaures:

DNS over HTTPS (DOH)
Transparent TOR relay on secondary and third wireless



Known limitations


Reading compressed wireless calibration data and MAC address on some vendors, currently only plain format
