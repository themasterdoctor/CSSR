#!/bin/bash

unalias cp rm mv
SSH_CONFIG='/etc/ssh/ssh_config'
SSHD_CONFIG='/etc/ssh/sshd_config'
if [ -e $SSH_CONFIG ]; then
   echo "Securing $SSH_CONFIG"
   grep -v "^Host \*" /etc/ssh/ssh_config-preCIS | grep -v "#     Protocol 2,1" \
            > /tmp/cis/ssh_config.tmp
   awk '/^#.* Host /                { print "Host *"; print "Protocol 2"; next };
         /^#.*Port /                { print "Port 22"; next };
         /^#.*PubkeyAuthentication/ { print "PubkeyAuthentication yes"; next };
                                    { print }' /tmp/cis/ssh_config.tmp \
                                              > /tmp/cis/ssh_config.tmp2
   if [ "`egrep -l ^Protocol /tmp/cis/ssh_config.tmp2`" == "" ]; then
         echo 'Protocol 2' >> /tmp/cis/ssh_config.tmp2
   fi
   /bin/cp -pf /tmp/cis/ssh_config.tmp2 $SSH_CONFIG
   chown root:root $SSH_CONFIG
   chmod 0644        $SSH_CONFIG
   echo "diff $SSH_CONFIG-preCIS $SSH_CONFIG"
          diff $SSH_CONFIG-preCIS $SSH_CONFIG
else
   echo "OK - No $SSH_CONFIG to secure."
fi
if [ -e $SSHD_CONFIG ]; then
   echo "Securing $SSHD_CONFIG"
   # Had to put the " no" in for the RhostsRSAAuthentication source pattern
   # match, as otherwise the change was taking place twice so the file ended
   # up with TWO records like that. The " no" pattern made the one unique.
   # That 2nd record was a combination of comments in the original file.
   # Some lines ARE duplicated in the original config file, one is commented
   # out, the next one isn't.
   # Also, the spacing below is a little off so lines fit on the page.
   awk '/^#.*Port /                      { print "Port 22"; next };
         /^#.*Protocol /                 { print "Protocol 2"; next };
         /^#.*LogLevel /                 { print "LogLevel VERBOSE"; next };
         /^#PermitRootLogin /            { print "PermitRootLogin no"; next };
         /^#RhostsRSAAuthentication no / { print "RhostsRSAAuthentication no"; next };
         /^#HostbasedAuthentication / { print "HostbasedAuthentication no"; next };
         /^#.*IgnoreRhosts /             { print "IgnoreRhosts yes"; next };
         /^#.*PasswordAuthentication / { print "PasswordAuthentication no"; next };
         /^#.*PermitEmptyPasswords /     { print "PermitEmptyPasswords no"; next };
         /^PasswordAuthentication yes/   { next };
         /^#.*Banner /                   { print "Banner /etc/issue.net"; next };
                                        { print }' /etc/ssh/sshd_config-preCIS  > $SSHD_CONFIG
   chown root:root $SSHD_CONFIG
   chmod 0600      $SSHD_CONFIG
   echo "diff $SSHD_CONFIG-preCIS $SSHD_CONFIG"
         diff $SSHD_CONFIG-preCIS $SSHD_CONFIG
else
   echo "OK - No $SSHD_CONFIG to secure."
fi
chmod -R 0400 /tmp/cis/*
unset SSH_CONFIG SSHD_CONFIG CONFIGITEM

#!/bin/bash
for SERVICE in    \
    amanda        \
    chargen       \
    chargen-udp   \
    cups          \
    cups-lpd      \
    daytime       \
    daytime-udp   \
    echo          \
    echo-udp      \
    eklogin       \
    ekrb5-telnet  \
    finger        \
    gssftp        \
    imap          \
    imaps         \
    ipop2         \
    ipop3         \
    klogin        \
    krb5-telnet   \
    kshell        \
    ktalk         \
    ntalk         \
    rexec         \
    rlogin        \
    rsh           \
    rsync         \
    talk          \
    tcpmux-server \
    telnet        \
    tftp          \
    time-dgram    \
    time-stream   \
    uucp;
do
     if [ -e /etc/xinetd.d/$SERVICE ]; then
           echo "Disabling SERVICE($SERVICE) - `ls -la /etc/xinetd.d/$SERVICE`."
           /sbin/chkconfig ${SERVICE} off
     else
           echo "OK. SERVICE doesn't exist on this system ($SERVICE)."
     fi
done
#!/bin/bash
xyz="`tail -1 /etc/hosts.deny`"
if [ "$xyz" != "ALL: ALL" ]; then
     # Only make the change once
     echo "ALL: ALL" >> /etc/hosts.deny
fi
chown root:root /etc/hosts.deny
chmod 0644        /etc/hosts.deny
echo "diff   /etc/hosts.deny-preCIS /etc/hosts.deny"
      diff   /etc/hosts.deny-preCIS /etc/hosts.deny

#
#
# host.allow sample entires
# ASSUMTION: netmask is 255.255.255.0
#
# Change /etc/hosts.allow from:
# ALL: localhost, 192.168.50.2/255.255.255.0
# to:
# sshd : 192.168.50.4
# ALL EXCEPT sshd: localhost, 192.168.50.4/255.255.255.255

printf "ALL: localhost" >> /etc/hosts.allow
for I in `/sbin/ifconfig | grep "inet addr" | cut -f2 -d: | cut -f1-3 -d"." \
     | grep -v ^127 | sort -n`
do
     echo   "Adding (, $I) to /etc/hosts.allow."
     printf ", $I." >> /etc/hosts.allow;
done
echo >> /etc/hosts.allow
chown root:root /etc/hosts.allow
chmod 0644         /etc/hosts.allow
echo "diff /etc/hosts.allow-preCIS /etc/hosts.allow"
      diff /etc/hosts.allow-preCIS /etc/hosts.allow


#!/bin/bash
sed 's/022/027/'  /etc/rc.d-preCIS/init.d/functions > /etc/rc.d/init.d/functions
echo "umask 027"  >> /etc/sysconfig/init
chown root:root   /etc/sysconfig/init
chmod 0755        /etc/sysconfig/init
echo "diff /etc/sysconfig/init-preCIS  /etc/sysconfig/init"
      diff /etc/sysconfig/init-preCIS  /etc/sysconfig/init

#!/bin/bash
echo "The 'chkconfig' status of 'xinetd' is shown before it is turned off and"
echo "then after so it can visually be compared."
echo "Note: The remaining chkconfig checks, in this hardening script, do the"
echo "same thing."
/sbin/chkconfig --list    xinetd
/sbin/chkconfig --level 12345 xinetd off
/sbin/chkconfig --list    xinetd
#!/bin/bash 
# Uncomment these lines if you DO need sendmail running
#cd /etc/sysconfig
#cp -pf sendmail-preCIS sendmail
#chown root:root sendmail
#chmod 0644 sendmail
#
#
# Comment the following lines if sendmail needed
echo "DAEMON=no" > /etc/sysconfig/sendmail
echo "QUEUE=1h" >> /etc/sysconfig/sendmail
/sbin/chkconfig --list    sendmail
/sbin/chkconfig --level 12345 sendmail off
/sbin/chkconfig --list    sendmail
chown root:root     /etc/sysconfig/sendmail
chmod 0644          /etc/sysconfig/sendmail
echo "diff /etc/sysconfig/sendmail-preCIS /etc/sysconfig/sendmail"
      diff /etc/sysconfig/sendmail-preCIS /etc/sysconfig/sendmail
#!/bin/bash
echo " When doing this from within Xwindows the display will slow to a horrible"
echo " crawl as soon as the xfs service is disabled. Recommend doing this"
echo " script from init 3 (runlevel 3)."
# From a scripted perspective, this will be backwards from what the CIS Benchmark
# recommends. Philosophy is to leave the few known/necessary services on, that
# do remain in the minimialized baseline, and then as each other step/procedure
# below is covered, it will disable what we know we don't need for a secure and
# hardened baseline.
#
# The following services ARE stopped/disabled using the following effort for the
# baseline:
#
# This affects network/NFS mapping during system building and/or during kickstart
# %post processing.
#     autofs
#     automount
#     iptables
#     portmap
#     NFS services
#     NFS statd
#     system message bus
# ** Warning** Disabling 'nfs' at this point in the script forcefully unmounts
#               any NFS network mounts.
# The following services should normally be enabled, unless there is a compelling
# reason not to: (which is why this hardening section does not alter their state)
   for SERVICE in                 \
       acpid                      \
       amd                        \
       anacron                    \
       apmd                       \
       arpwatch                   \
       atd                        \
       autofs                     \
       avahi-daemon               \
       avahi-dnsconfd             \
       bpgd                       \
       bluetooth                  \
       bootparamd                 \
       capi                       \
       conman                     \
       cups                       \
       cyrus-imapd                \
       dc_client                  \
       dc_server                  \
      dhcdbd                     \
      dhcp6s                     \
       dhcpd                      \
       dhcrelay                   \
       dovecot                    \
       dund                       \
       firstboot                  \
       gpm                        \
       haldaemon                  \
       hidd                       \
       hplip           \
       httpd           \
       ibmasm          \
       ip6tables       \
       ipmi            \
       irda            \
       iscsi           \
       iscsid          \
       isdn            \
       kadmin          \
       kdump           \
       kprop           \
       krb524          \
       krb5kdc         \
       kudzu           \
       ldap            \
       lisa            \
       lm_sensors      \
       mailman         \
       mcstrans        \
       mdmonitor       \
       mdmpd           \
       microcode_ctl   \
       multipathd      \
       mysqld          \
       named           \
       netplugd        \
       nfs             \
       nfslock         \
       nscd            \
       ntpd            \
       openibd         \
       ospf6d          \
       ospfd           \
       pand            \
       pcscd           \
       portmap         \
       postgresql      \
       privoxy         \
       psacct          \
       radvd           \
       rarpd           \
       rdisc           \
       readahead_early \
       readahead_later \
       rhnsd           \
       ripd            \
       ripngd          \
       rpcgssd         \
       rpcidmapd       \
       rpcsvcgssd      \
       rstatd          \
       rusersd         \
       rwhod           \
       saslauthd       \
       sendmail        \
     setroubleshoot             \
     smartd                     \
     smb                        \
     snmpd                      \
     snmptrapd                  \
     spamassassin               \
     squid                      \
     tog-pegasus                \
     tomcat5                    \
     tux                        \
     winbind                    \
     wine                       \
     wpa_supplicant             \
     xend                       \
     xendomains                 \
     xinetd                     \
     ypbind                     \
     yppasswdd                  \
     ypserv                     \
     ypxfrd                     \
     yum-updatesd               \
     zebra;
do
      if [ -e /etc/init.d/$SERVICE ]; then
            # Doing business this way causes less needless errors that a
            # reviewer of the hardening process doesn't need to deal with.
            /sbin/service $SERVICE stop
            /sbin/chkconfig --level 12345 $SERVICE off
      else
            echo "SERVICE doesn't exist on this system ($SERVICE)."
      fi
done
#!/bin/bash
#
if [ `grep -v '^#' /etc/syslog.conf | grep -c 'authpriv'` -eq 0 ]; then
       echo "Established the following record in /etc/syslog.conf"
       echo "authpriv.*\t\t\t\t/var/log/secure"
       echo -e "authpriv.*\t\t\t\t/var/log/secure" >> /etc/syslog.conf
else
       echo "syslog OK. Didn't have to change syslog.conf for authpriv; the"
       echo "following record is good:"
       grep "^authpriv" /etc/syslog.conf | grep '/var/log/secure'
fi
# Add record for 'auth.*', too, placing it after the authpriv record
if [ `grep -v '^#' /etc/syslog.conf | grep -c 'auth.\*'` -eq 0 ]; then
     ed /etc/syslog.conf <<END_SCRIPT
1
/^authpriv
a
auth.*                                           /var/log/messages
.
w
q
END_SCRIPT
else
       echo "syslog OK. Didn't have to change syslog.conf for auth.*; the"
       echo "following record is good:"
       grep 'auth.\*' /etc/syslog.conf
fi

chown root:root /etc/syslog.conf
# Original/default permissions are 0644.
chmod 0600       /etc/syslog.conf
echo "diff /etc/syslog.conf-preCIS /etc/syslog.conf"
      diff /etc/syslog.conf-preCIS /etc/syslog.conf

# Create the log file if it doesn't already exist.
touch /var/log/secure
chown root:root /var/log/secure
chmod 0600      /var/log/secure
echo "Restarting syslog service to immediately implement the latest configuration."
/sbin/service syslog stop
/sbin/service syslog start
#!/bin/bash
#echo "Some errors MAY appear here for directories, logs and/or files not installed on this system."
cd /var/log
# Part 1
echo "Extra---Ensure the btmp log file for 'lastb' is in place and with proper"
echo "         permissions. This satisfies DISA SRR (GEN000440)"
touch /var/log/btmp
chown root:root /var/log/btmp
chmod 0600        /var/log/btmp
echo "Before listing of the log directory [explicit]."
ls -la /var/log
# Part 2
echo "LogPerms Part 1."
for LogFile in \
    boot.log          \
    btmp              \
    cron              \
    dmesg             \
    ksyms             \
    httpd             \
    lastlog           \
    maillog           \
    mailman           \
    messages          \
    news              \
    pgsql             \
    rpmpkgs           \
    sa                \
    samba             \
    scrollkeeper.log \
    secure            \
    spooler           \
    squid             \
    vbox              \
    wtmp
do
    # This check allows only entries that exist to have permissions set.
    # Visually cleaner for the person running it.
    if [ -e ${LogFile} ]; then
          # Utilizing recursive here is harmless when applied to a single file.
           chmod -R  o-rwx  ${LogFile}*
     else
           echo "LogFile didn't exist ($LogFile)."
     fi
done
echo "LogPerms Part 2."
for LogFile in \
     boot.log            \
     cron                \
     dmesg               \
     gdm                 \
     httpd               \
     ksyms               \
     lastlog             \
     maillog             \
     mailman             \
     messages            \
     news                \
     pgsql               \
     rpmpkgs             \
     samba               \
     sa                  \
     scrollkeeper.log \
     secure              \
     spooler             \
     squid               \
     vbox
do
     if [ -e ${LogFile} ]; then
           chmod -R g-w ${LogFile}*
     else
           echo "LogFile didn't exist ($LogFile)."
     fi
done
echo "LogPerms Part 3."
for LogFile in \
     boot.log          \
     cron              \
     httpd             \
     lastlog           \
     maillog           \
     mailman           \
     messages          \
     pgsql             \
     sa                \
     samba             \
     secure            \
     spooler
do
     if [ -e ${LogFile} ]; then
           chmod -R g-rx ${LogFile}*
     else
           echo "LogFile didn't exist ($LogFile)."
     fi
done
echo "LogPerms Part 4."
for LogFile in \
     gdm         \
     httpd       \
     news        \
     samba       \
     squid       \
     sa          \
     vbox
do
     if [ -e ${LogFile} ]; then
           chmod -R o-w ${LogFile}*
     else
           echo "LogFile didn't exist ($LogFile)."
     fi
done
echo "LogPerms Part 5."
for LogFile in \
     httpd       \
     samba       \
     squid       \
     sa
do
     if [ -e ${LogFile} ]; then
           chmod -R o-rx ${LogFile}*
     else
           echo "LogFile didn't exist ($LogFile)."
     fi
done
echo "LogPerms Part 6."
for LogFile in \
     kernel      \
     lastlog     \
     mailman     \
     syslog      \
     loginlog
do
     if [ -e ${LogFile} ]; then
           chmod -R u-x ${LogFile}*
     else
           echo "LogFile didn't exist ($LogFile)."
     fi
done
echo "LogPerms Part 7."
# Removing group write permissions to btmp and wtmp
chgrp utmp btmp
chmod g-w btmp
chgrp utmp wtmp
chmod g-w wtmp
# Fixing "/etc/rc.d/rc.sysinit", as it unsecures permissions for wtmp.
awk '( $1 == "chmod" && $2 == "0664" && $3 == "/var/run/utmp" && $4 == "/var/log/wtmp" ) {
	       print "chmod 0600 /var/run/utmp /var/log/wtmp"; next }; 
      ( $1 == "chmod" && $2 == "0664" && $3 == "/var/run/utmpx" && $4 == "/var/log/wtmpx" ) {
         print " chmod 0600 /var/run/utmpx /var/log/wtmpx"; next };
      { print }' /etc/rc.d-preCIS/rc.sysinit > /etc/rc.d/rc.sysinit
chown root:root /etc/rc.d/rc.sysinit
chmod 0700       /etc/rc.d/rc.sysinit
echo "diff /etc/rc.d-preCIS/rc.sysinit /etc/rc.d/rc.sysinit"
      diff /etc/rc.d-preCIS/rc.sysinit /etc/rc.d/rc.sysinit
echo "LogPerms Part 8."
[ -e news ]     && chown -R news:news news
[ -e pgsql ]    && chown postgres:postgres pgsql
[ -e squid ]    && chown -R squid:squid squid
[ -e lastlog ] && chmod  0600 lastlog
chown -R root:root .
echo ""
echo "Follow-on listing of the log directory [explicit]."
ls -la /var/log
#!/bin/bash
awk '( $3 ~ /^ext[23]$/ && $2 != "/" ) { $4 = $4 ",nodev" };         \
     { printf "%-26s%-22s%-8s%-16s %-1s %-1s\n",$1,$2,$3,$4,$5,$6 }' \
     /etc/fstab > /tmp/cis/fstab.tmp2
#             Kept /tmp/cis/fstab.tmp2 as input to the next step (CIS 7.2).
chown root:root /etc/fstab
chmod 0644      /etc/fstab
# Note: the diff IS not for the same pair of files, as this step is treated
# as intermediary. But, we'll show the users the damage done so far and
# they see the progress.
echo "diff /etc/fstab-preCIS /etc/fstab"
      diff /etc/fstab          /tmp/cis/fstab.tmp2
chmod -R 0400 /tmp/cis/*
#!/bin/bash
echo "Before ..."
ls -la /etc/group /etc/gshadow /etc/passwd   /etc/shadow
chown root:root   /etc/group   /etc/gshadow  /etc/passwd  /etc/shadow
chmod 0644        /etc/group   /etc/passwd
chmod 0400                                   /etc/gshadow /etc/shadow
echo "After ..."
ls -la /etc/group /etc/gshadow /etc/passwd /etc/shadow
#!/bin/bash
echo "The following script should produce no results..."
for PART in `awk '( $3 ~ "ext[23]" ) { print $2 }' /etc/fstab`;
do
     find $PART -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print
done
echo $0 "DONE"
#!/bin/bash
if [ -e /etc/X11/xdm/Xservers ]; then
     cd /etc/X11/xdm
     awk '( $1 !~ /^#/ && $3 == "/usr/X11R6/bin/X" ) { $3 = $3 " -nolisten tcp" };
     { print }' Xservers-preCIS > Xservers
     chown root:root Xservers
     chmod 0444      Xservers
     echo "diff Xservers-preCIS Xservers"
           diff Xservers-preCIS Xservers
     cd $cishome
else
     echo "No /etc/X11/xdm/Xservers file to secure."
fi
if [ -d /etc/X11/xinit ]; then
     cd /etc/X11/xinit
     if [ -e xserverrc ]; then
          echo "Fixing /etc/X11/xinit/xserverrc"
          awk '/X/ && !/^#/ { print $0 " :0 -nolisten tcp \$@"; next }; \
          { print }' xserverrc-preCIS > xserverrc
     else
          cat <<END_SCRIPT > xserverrc
#!/bin/bash
exec X :0 -nolisten tcp \$@
END_SCRIPT
     fi
     chown root:root xserverrc
     chmod 0755      xserverrc
     [ -e xserverrc-preCIS ] && echo "diff xserverrc-preCIS xserverrc"
     [ -e xserverrc-preCIS ] &&        diff xserverrc-preCIS xserverrc
     cd $cishome
else
     echo "No /etc/X11/xinit file to secure."
fi
#!/bin/bash
# With x.allow only users listed can use 'at' or 'cron'
# {where 'x' indicates either 'at' or 'cron'}
# Without x.allow then x.deny is checked, members of x.deny are excluded
# Without either (x.allow and x.deny), then only root can use 'at' and 'cron'
# At a minimum x.allow should exist and list root
echo "Attempting to list the following files for the 'before' picture."
echo "Any 'errors' are alright, as we are simply looking to see what exists."
ls -la /etc/at.allow /etc/at.deny /etc/cron.allow /etc/cron.deny
rm -f /etc/at.deny /etc/cron.deny
echo root > /etc/at.allow
echo root > /etc/cron.allow
chown root:root /etc/at.allow /etc/cron.allow
chmod 0400        /etc/at.allow /etc/cron.allow
if [ -e /etc/at.allow-preCIS ]; then
   echo "diff /etc/at.allow-preCIS /etc/at.allow"
   diff /etc/at.allow-preCIS         /etc/at.allow
fi
if [ -e /etc/cron.allow-preCIS ]; then
   echo "diff /etc/cron.allow-preCIS /etc/cron.allow"
   diff /etc/cron.allow-preCIS /etc/cron.allow
fi
echo "Listing the state of these AFTER imposing restrictions..."
echo "Missing file 'errors' are ok here too."
ls -la /etc/at.allow /etc/at.deny /etc/cron.allow /etc/cron.deny

#!/bin/bash
ls -lad /etc/cron* /var/spool/cron*
chown root:root /etc/crontab
chmod 0400        /etc/crontab
chown -R root:root /var/spool/cron
chmod -R go-rwx       /var/spool/cron
cd /etc
ls | grep cron | grep -v preCIS | xargs chown -R root:root
ls | grep cron | grep -v preCIS | xargs chmod -R go-rwx
cd $cishome
    # What about permissions for the following:
    #   drwxr-xr-x 2 root root 4096 Aug 2 2006   /etc/cron.d
    #   drwxr-xr-x 2 root root 4096 Aug 2 2006   /etc/cron.daily
    #   -rw-r--r-- 1 root root    0 Aug 2 2006   /etc/cron.deny
    #   drwxr-xr-x 2 root root 4096 Aug 2 2006   /etc/cron.hourly
    #   drwxr-xr-x 2 root root 4096 Aug 2 2006   /etc/cron.monthly
    #   drwxr-xr-x 2 root root 4096 Aug 2 2006   /etc/cron.weekly
    #   -rw-r--r-- 1 root root 255 Dec 10 2005   /etc/crontab
echo "After..."
ls -lad /etc/cron* /var/spool/cron*
#!/bin/bash
echo console > /etc/securetty
# These are acceptable for the GUI and runlevel 3, when trimmed down to 6
for i in `seq 1 6`; do
      echo vc/$i >> /etc/securetty
done
#
#### Commented this out to be more secure as it denies root logins to the physical TEXT console.
#### Additionally, disabling this is in compliance with the DISA STIG, as well.
#     Check pg 14 in Hardening Linux for additional safety in the /etc/inittab file.
# Do we want this as a required argument submitted on the command line?
#
#for i in `seq 1 6`; do
#        echo tty$i >> /etc/securetty
#done
chown root:root /etc/securetty
chmod 0400         /etc/securetty
echo "diff /etc/securetty-preCIS /etc/securetty"
       diff /etc/securetty-preCIS /etc/securetty
# Part 2
# Second modification of gdm.conf, if it exists.
if [ -e /etc/X11/gdm/gdm.conf ]; then
      #### There is another file to consider: "/etc/X11/gdm/gdm.conf"
      # "AllowRoot=true" should be set to false to prevent root from logging in to the gdm GUI.
      # "AllowRemoteRoot=true" should be set to false to prevent root logins from remote systems.
      # Doing this change is supportive of logging in as a regular user and using 'su' to get to root.
      # Before allowing a reboot, ensure at least one account is created for a SysAdmin type.
      cd /etc/X11/gdm
      /bin/cp -pf gdm.conf /tmp/cis/gdm.conf.tmp
      sed -e 's/AllowRoot=true/AllowRoot=false/'             \
          -e 's/AllowRemoteRoot=true/AllowRemoteRoot=false/' \
          -e 's/^#Use24Clock=false/Use24Clock=true/' /tmp/cis/gdm.conf.tmp > gdm.conf
      chown root:root gdm.conf
      chmod 0644      gdm.conf
      echo "diff gdm.conf-preCIS gdm.conf"
            diff gdm.conf-preCIS gdm.conf
      cd $cishome
else
     echo "No /etc/X11/gdm/gdm.conf file to further secure."
fi
# Part 3
echo "The following is only required when a serial console is used for this server."
echo "Either of these would be added manually post-baseline compliance, depending"
echo "on the COM port the serial cable is physically attached to."
echo "#     echo ttyS0 >> /etc/securetty"
echo "#     echo ttyS1 >> /etc/securetty"
chmod -R 0400 /tmp/cis/*
#!/bin/bash
# In the book "Hardening Linux", pg 20, it says using "/dev/null" is bad.
echo "Basically change the '/sbin/nologin' portion to '/dev/null' in /etc/passwd"
echo " and add an exclamation point to the password field in /etc/shadow."
cd /etc
for NAME in `cut -d: -f1 /etc/passwd`; do
     MyUID=`id -u $NAME`
     if [ $MyUID -lt 500 -a $NAME != 'root' ]; then
         /usr/sbin/usermod -L -s /dev/null $NAME
     fi
done
ls -la /etc/passwd
echo "sdiff passwd-preCIS passwd"
echo "--------------------------"
chown root:root /etc/passwd
chmod 0644      /etc/passwd
sdiff passwd-preCIS passwd
ls -la /etc/shadow
echo "sdiff shadow-preCIS shadow"
echo "--------------------------"
chown root:root /etc/shadow
chmod 0400       /etc/shadow
sdiff shadow-preCIS shadow
cd $cishome
#!/bin/bash
#
#
echo "Should produce no output"
awk -F: '( $2 == "" ) { print $1 }' /etc/shadow
#!/bin/bash
for DIR in `awk -F: '( $3 >= 500 ) { print $6 }' /etc/passwd`; do
     if [ $DIR != /var/lib/nfs ]; then
          chmod -R g-w   $DIR
          chmod -R o-rwx $DIR
     fi
done
#!/bin/bash
echo "Note: With this activated, only members of the wheel group can su to root."
cd /etc/pam.d/
awk '( $1=="#auth" && $2=="required" && $3~"pam_wheel.so" ) \
     { print "auth\t\trequired\t",$3,"\tuse_uid"; next };
     { print }' /etc/pam.d-preCIS/su > /etc/pam.d/su
chown root:root /etc/pam.d/su
chmod 0644       /etc/pam.d/su
echo "diff /etc/pam.d-preCIS/su /etc/pam.d/su"
      diff /etc/pam.d-preCIS/su /etc/pam.d/su
cd $cishome
# Part 2
# The process is beneficial when using kickstart for building of systems, then
# deliberately go back to all those systems and forcefully change the
# root/SysAdmin passwords to be in new.
echo "(${AdminsComma}) are to be System Administrators for this system."
for USERID in `echo $AdminSP`
    do
       echo "1. Dealing with userid($USERID)..."
       ID=`cat /etc/passwd | cut -d: -f1 | grep $USERID 2>&1`
       if [ "$ID" != "$USERID" ]; then
          # The user-id was NOT found
          echo "2a Adding new user ($USERID) 'procedure-compliant'."
          # Use grub-md5-crypt to generate the encrypted password
          useradd -f 7 -m -p '$1$PyDA7$L81b0Sp1u.DyGnjbRUp/3/' $USERID
          chage -m 7 -M 90 -W 14 -I 7 $USERID
       else
          echo "2b User ($USERID) already in the system."
          chage -m 7 -M 90 -W 14 -I 7 $USERID
       fi
       ls -la /home
    done
echo "Doing pwck -r"
/usr/sbin/pwck -r
echo ""
# Part 3
# Perform steps to ensure any users identified in $Admins are added to the "wheel"
# group. This is probably only going to add the example 'tstuser' account, or
# whichever userID the system builder names during the initial system build.
# Note: /etc/group requires entries to be comma-separated.
if [ "$Admins" != "" ]; then
     echo "At least one AdminID has been identified to be added to the wheel
group."
     echo "Admins(${Admins}), AdminSP(${AdminSP}), AdminsComma(${AdminsComma})."
     cd /etc
     # Resultant /etc/group file is now nicely sorted as well
     /bin/cp -pf group /tmp/cis/group.tmp
     awk -F: '($1~"wheel" && $4~"root") { print $0 "," Adds }; \
               ($1 != "wheel") {print}' Adds="`echo $AdminsComma`" \
              /tmp/cis/group.tmp | sort -t: -nk 3 > /tmp/cis/group.tmp1
     chown root:root /tmp/cis/group.tmp1
     chmod 0644       /tmp/cis/group.tmp1
     /bin/cp -pf /tmp/cis/group.tmp1 group
     echo "sdiff group-preCIS group"
            sdiff group-preCIS group
     cd $cishome
else
         echo "BAD.  No SysAdmin IDs were identified to be added to the wheel
group."
fi

#
#
# Part 4
echo "#### This is done in concert with Bastille that was executed before this step in the"
echo "#### standard baseline hardening. This will add SPACE-delimited SysAdmin userIDs to"
echo "#### the /etc/security/access.conf file. These are the same names as are added to"
echo "#### the wheel group in the /etc/group file. This action prohibits any user NOT in"
echo "#### the wheel group from logging in to the system on the physical console."
echo "#### Can treat this as a known entity with one entry to deal with since the state of"
echo "#### this system up to this point is well known."
echo "#### No differences may appear, if the same users are listed here, as were added by bastille."
#    The line in question resembles the following, 3 colon-separated fields:
#    -:ALL EXCEPT root tstuser:LOCAL
#    To be turned into something that looks like the following (sorted IDs are easier to read):
#    -:ALL EXCEPT abc-Admin root def-Admin tstuser:LOCAL
#
cd /etc/security
# Check if there are any uncommented lines to ADD $Admins to.
x="`grep -v ^# access.conf | wc -l | cut -d: -f1`"
echo "x($x)"
if [ "$x" == "0" ]; then
     # Most likely the Bastille hardening hasn't been applied yet.
     # Must manually add the users, as the file is otherwise 'empty'.
     echo "Manually adding the ($Admins); none previously existed there."
     echo "-:ALL EXCEPT root" $AdminSP":LOCAL" >> access.conf
else
     # Extract just the userIDs
     x="`grep -v ^# access.conf | cut -d: -f2 | cut -d' ' -f3-`"
     # Bundle in the new SysAdmin IDs passed during script invocation, and sort the names alphabetically.
     # Need a piece here to compare what's there with what we have to add, to avoid duplicates.
     y="`echo $AdminsComma $x | tr -s ',' ' ' | tr ' ' '\012' | sort -u | tr '\012' ' '`"
     echo "x($x), y($y)"; echo ""
     # 2nd -e is to eliminate the extra space before the final colon, if one exists.
     sed -e "s/$x/$y/" -e 's/ :L/:L/' access.conf-preCIS > access.conf
     # sed "s/$x/$y/" access.conf-preCIS | sed 's/ :L/:L/' > access.conf
fi
echo "diff /etc/security/access.conf-preCIS /etc/security/access.conf"
      diff /etc/security/access.conf-preCIS /etc/security/access.conf
chown root:root /etc/security/access.conf
chmod 0640       /etc/security/access.conf
cd $cishome
chmod -R 0400 /tmp/cis/*


#!/bin/bash
# The /etc/sudoers file contains one line that can be uncommented out to suitably
# permit SysAdmins with membership in the wheel group (i.e. the same ones who
# 'could' su to root) to utilize 'sudo' instead. Note: file consists of TABs
# between fields. 'visudo' IS the proper command to manually change this file,
# yet the change below passes muster when visudo is next executed.
echo "Implementing permissions for members of the wheel group to utilize sudo;"
echo "This prevents any user from having to 'su' to root for common"
echo "administrative tasks. Ideally now the root password would be changed to"
echo "something very few would know (hint!)."
sed 's/# %wheel   ALL=(ALL)   NOPASSWD: ALL/%wheel    ALL=(ALL)    NOPASSWD: ALL/' \
     /etc/sudoers-preCIS > /etc/sudoers
chown root:root /etc/sudoers
chmod 0440       /etc/sudoers
echo "diff /etc/sudoers-preCIS /etc/sudoers"
      diff /etc/sudoers-preCIS /etc/sudoers
echo  "More specifically, system owners are strongly encouraged to more tightly"
echo  "restrict who can utilize sudo on a name by name basis (explicitly) as well"
echo  "as further restrict what commands those SysAdmins are limited to using."
echo  "Align this with least-privilege."
