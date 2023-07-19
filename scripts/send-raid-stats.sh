#!/bin/sh

TARGETNAME=raidmon			# Short name of the Raidmon VM to generate correct Identify filename
TARGETHOST=raidmon.yourdomain.com 	# Fully qualified name or IP to connect to Raidmon VM
USER=esxi-raidmon 			# User on the Raidmon VM under which SCP logs in

SOURCENAME=$(hostname -s)
SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname ${SCRIPT})

cd /opt/lsi/storcli64/

./storcli64 show all j > /tmp/raidstatus_${SOURCENAME}_ctldisc
./storcli64 /call show all j > /tmp/raidstatus_${SOURCENAME}_ctlinfo
./storcli64 /call/bbu show all j > /tmp/raidstatus_${SOURCENAME}_bbuinfo
./storcli64 /call/cv show all j > /tmp/raidstatus_${SOURCENAME}_cvinfo
./storcli64 /call/vall show all j > /tmp/raidstatus_${SOURCENAME}_ldinfo
./storcli64 /call/eall/sall show j > /tmp/raidstatus_${SOURCENAME}_pddisc
./storcli64 /call/eall/sall show all j > /tmp/raidstatus_${SOURCENAME}_pdinfo
./storcli64 /call/sall show j > /tmp/raidstatus_${SOURCENAME}_nepddisc
./storcli64 /call/sall show all j > /tmp/raidstatus_${SOURCENAME}_nepdinfo

scp -i ${SCRIPT_PATH}/${TARGETNAME}_${USER}_id /tmp/raidstatus_${SOURCENAME}_* ${USER}@${TARGETHOST}:/tmp > /dev/null

