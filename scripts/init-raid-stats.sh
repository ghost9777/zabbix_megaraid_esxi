#!/bin/sh
SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname ${SCRIPT})

esxcli network firewall ruleset set -e=true -r=sshClient

kill $(cat /var/run/crond.pid)
echo "*/10 * * * * ${SCRIPT_PATH}/send-raid-stats.sh" >> /var/spool/cron/crontabs/root
crond

mkdir /.ssh
chmod 700 /.ssh
cp ${SCRIPT_PATH}/known_hosts /.ssh
