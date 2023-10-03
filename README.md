## Monitoring LSI/Broadcom MegaRAID controllers on ESXi hosts with Zabbix
----

**This template is based on template by Oleg Pchelnikov - https://internet-lab.ru/zabbix_lsi_win**
**Repository address - https://github.com/ghost9777/zabbix_megaraid_esxi**

**Repository address - https://github.com/ghost9777/zabbix_megaraid_esxi**

----
You need a Linux VM to collect json files from ESXi hosts. It can be a separate VM or Zabbix server itself but separate one is recommended. Assume VM name is **`raidmon`**. Create a user to let ESXi hosts send json files to **`raidmon`** VM by SCP. Let's name this user **`esxi-raidmon`** for example. 

You need to generate SSH key pair for this user by using `ssh-keygen -t ecdsa` or your preffered method. Place public key into *`/home/esxi-raidmon/.ssh/authorized_keys`*. Dont't forget to limit access to this file:
```
chown esxi-raidmon:esxi-raidmon /home/esxi-raidmon/.ssh/authorized_keys
chmod 600 /home/esxi-raidmon/.ssh/authorized_keys
```
Rename private key file to *`$VMName_$UserName_id`*. This will be *`raidmon_esxi-raidmon_id`* in our example case. 

Connect by SSH to your ESXi host and install StorCLI. You can use package found in this repository or download it from Broadcom web site.
```
esxcli software vib install -v /tmp/VMWare-ESXi7.0-StorCLI.zip --no-sig-check
```
Change dir to *`/vmfs/volumes`*. Move to one of the host's VMFS volumes and create directory to store scripts and id files. Copy all *`.sh`* files from repository *`scripts`* folder and *`raidmon_esxi-raidmon_id`* file to this directory. Make install script executable by `chmod 755 install.sh`

You need to edit *`install.sh`* and *`send-raid-stats.sh`* scripts and provide at least correct address of **`raidmon`** VM. Don't forget to change TARGETNAME and USER variables if you are using your own values.

Now you can run *`install.sh`* script. This will enable outbound SSH firewall rule, connect by SSH to **`raidmon`** VM to generate and save *`known_hosts`* file and add *`init-raid-stats.sh`* to *`/etc/rc.local.d/local.sh`* of ESXi host to make monitoring persistant across reboots. When SSH session started you need just accept fingerprint and press ENTER three times to skip connection. You don't need to provide password to connect to **`raidmon`** VM.

You can check *`/etc/rc.local.d/local.sh`* to be shure *`init-raid-stats.sh`* is added before "exit 0" line.

Now you can manually run *`init-raid-stats.sh`* script to add main *`send-raid-stats.sh`* to CRON and start sending StorCLI json files to **`raidmon`** VM without ESXi host reboot. Check that *`raidstatus_*`* files are present in *`/tmp`* dir of your **`raidmon`** VM.

Install "Zabbix Agent 2" on **`raidmon`** VM, add this VM to your Zabbix server and attach "Template LSI RaidMon ESXi hosts discovery" to it. Make shure Zabbix Agent have access to *`/tmp/raidstatus_*`* files if you have Selinux enabled.

If everything was done right you will find new virtual host in your Zabbix inventory few minutes later named **`RaidMon - $ESXi_host_name`**. You can monitor any number of ESXi hosts with unique hostnames with one **`raidmon`** VM. Template will dicover them automatically by parsing *`raidstatus_*`* filenames found in *`/tmp`* directory.

This template supports multiple controllers per host. It will discover and monitor:
+ controllers
+ cache vault units
+ BBU units
+ logical discs
+ physical discs installed in enclosures and backplanes
+ physical discs NE - disks connected directly to contorller without enclosures and backplanes

Template was exported from Zabbix 6.4 and tested with Zabbix Agent 2 but it should work with conventional Zabbix Agent as well. Scripts have been tested on ESXi 7.0.
