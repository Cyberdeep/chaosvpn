#!/bin/sh

# Use at your own risk.
#
# This script will extract all host IP addresses
# from the node files in /etc/tinc/chaos/hosts/
# and generate a separate Target file for smokeping.
#
# Smokeping itself need an include statement in
# /etc/smokeping/config to the specified Target file:

TARGET_FILE=/etc/smokeping/config.d/Targets.chaosvpn

echo "Please adjust this file and read the comments."
exit 0

if [ ! -d /etc/smokeping/config.d ] ; then echo "Smokeping config.d folder not found. Exit." ; exit 1 ; fi
if [ ! -d /etc/tinc/chaos/hosts ] ; then echo "ChaosVPN config folders not at predefined location. Exit." ; exit 1; fi

# Generated the smokeping Target file
do_generate_config() {
	# Create a site section
	cat > "$TARGET_FILE" <<- _EOF_
		+ ChaosVPN
		menu = ChaosVPN
		title = ChaosVPN Network

	_EOF_

	for CVPN_IP in $(grep Subnet /etc/tinc/chaos/hosts/* | grep '/32' | awk -F '=' '{print$2}' | sed 's/\/32//' | sort -n | uniq -u) ; do
		CVPN_LABEL=$(echo $CVPN_IP | sed 's/\.//;' | sed 's/\.//;' | sed 's/\.//;')

		# Create the host subsection
		cat >> "$TARGET_FILE" <<- _EOF_
			++ CVPN_$CVPN_LABEL
			menu = $CVPN_IP
			title = ChaosVPN - $CVPN_IP
			host = $CVPN_IP

		_EOF_
	done
}

# Reloads smokeping
do_smokeping_reload() {
	# Restarting Service
	if [ -x /etc/init.d/smokeping ] ; then
		/etc/init.d/smokeping reload >/dev/null
	else
		echo "Smokeping init script not found."
	fi
}


do_generate_config
do_smokeping_reload

