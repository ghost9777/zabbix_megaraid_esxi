# zabbix_megaraid_esxi
# Monitoring LSI / Broadcom MegaRAID controllers on ESXi hosts wit Zabbix

This template is based on template by Oleg Pchelnikov - https://internet-lab.ru/zabbix_lsi_win

You need a Linux VM to collect json files from ESXi hosts. This might be a separate VM or Zabbix server itself but separate one is recommended. Assume VM name is **raidmon**.

Create a user for ESXi hosts access to **raidmon** VM. Let's name it **esxi-raidmon** for example. 

You need to generate SSH key pair for this user by using *"ssh-keygen -t ecdsa"* or your preffered method. Place .pub key into */home/esxi-raidmon/.ssh/authorized_keys*
Dont't forget to limit access to this file:
*chown esxi-raidmon:esxi-raidmon /home/esxi-raidmon/.ssh/authorized_keys*
*chmod 600 /home/esxi-raidmon/.ssh/authorized_keys*

Rename private key file to *%VMName%_%UserName%_id*. This will be *raidmon_esxi-raidmon_id* in our example case.

Connect by SSH to your ESXi host and install StorCLI. You can use package provided in this repository or download it from Broadcom web site.
*esxcli software vib install -v /tmp/VMWare-ESXi7.0-StorCLI.zip --no-sig-check*

Move to */vmfs/volumes". Move to one of the host VMFS volumes and create directory to store script and id files. Copy all .sh files from *scrips* folder and *raidmon_esxi-raidmon_id* file to this directory.
Make install script executable by "chmod 755 install.sh"

You need to edit *install.sh* and *send-raid-stats.sh* scripts and provide at least correct address of **raidmon** VM. Don't forget to change TARGETNAME and USER variables if you are using you own values.

Now you can run *install.sh" script. This will enable outbound SSH rule, connect by SSH to you **raidmon** VM to generate and save *known_host" file and add *init-raid-stats.sh* to */etc/rc.local.d/local.sh* of ESXi host to make monitoring persistant across host reboots.
When SSH session started you need just accept fingerprint and press ENTER 3 times to skip connection. You don't need to provide password to connect to **raidmon** VM.

You can check */etc/rc.local.d/local.sh* to be shure *init-raid-stats.sh* added before "exit 0" line.

Now you can run *init-raid-stats.sh* script to add main *send-raid-stats.sh* to CRON and start sending json files to **raidmon** VM. Check that *raidstatus_*" files are present in */tmp" dir of your **raidmon** VM.

Install "Zabbix Agent 2" on **raidmon** VM, add this VM to you Zabbix server and attach "Template LSI RaidMon ESXi hosts discovery" to it. Make shure Zabbix Agent have access to "/tmp/raidstatus_*" files if you have Selinux enabled.

If everything was done right you will find new virtual host in your Zabbix inventory named *RaidMon - %ESXi_host_name%*
