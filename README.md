# Asuswrt-shell-monitoring
ASUS TUF-BE3600 stock ssh shell access plugins

This will showcase a short introduction in how much shell tools are available on the router on the stock firmware to get almost anything you need (monitoring,iptable scripts,...).

This is a feature always completely overlooked by any reviewer and might help linux minded people to chose their new router who is linux/busybox powered, and might integrate flawlessly in their linux projects.

Its basicly a big promotional piece (and thank you) to ASUS, trying to highlight its most treasured (and forgotten) feature: ssh with shell access directly to the router. They did a good job there leaving most tools exposed to the user, and basicly no one even seems to know.


# check_asusr_linkspeeds.sh
With the broadcom SoC, physical ports are not directly exposed. Due to the architecture of Broadcom-based consumer routers, physical Ethernet ports are typically not exposed as individual interfaces in the Linux networking stack. Instead, the switch ASIC (often integrated with the SoC) is abstracted behind a single aggregated interface.
WAN and LAN planes (as I understand it) are still visible, as are our radio emmiters.
This script monitors these available planes. as far as I understand it:

interface ==> what it is
wl0.1 ==> WLAN network 1 (2.4ghz)
w1.1 ==> WLAN network 2 (5ghz)
eth0 ==> main WAN plane
eth1 ==> main LAN plane

The "wl" devices might be the band or the "networks" you created in the GUI. For me, one network is only 2.4ghz and the other is only 5ghz.
