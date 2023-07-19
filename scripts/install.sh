#!/bin/sh

RAIDMON=raidmon.yourdomain.com   # Fully qualified name or IP to connect to Raidmon VM

SCRIPT_PATH=$(dirname $(readlink -f $0))
SCRIPT=${SCRIPT_PATH}/init-raid-stats.sh

esxcli network firewall ruleset set -e=true -r=sshClient

chmod 755 init-raid-stats.sh
chmod 755 send-raid-stats.sh
chmod 600 *_id

echo -e "\033[1;33mSSH clent will connect to ${RAIDMON} to obtain known_hosts file. You just need accept fingerprint and press ENTER 3 times to skip connection.\033[0m"
read -n 1 -s -p "Press any key to start SSH"

ssh root@${RAIDMON}
cp /.ssh/known_hosts ${SCRIPT_PATH}

sed -i "/^exit 0/i ${SCRIPT}" /etc/rc.local.d/local.sh
