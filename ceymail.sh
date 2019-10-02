#!/bin/bash
#Author: Ceylavi
#Company: Ceylavi Technologies Inc. ©2019
echo "CeyMail 1.0"
<<<<<<< HEAD
#Ma nigga
=======
>>>>>>> d10606391b41d168815f0862a96c66dbb8f72e9f
printf "Author: Ceylavi\n"
printf "Company: Ceylavi Technologies Inc. ©2019\n"
printf "support: cey@ceylavi.com\n"

install(){
echo "CeyMan 1.0"
printf "Installing CeyMail Database Manager...\n"
sleep 1s

rm -f /usr/local/bin/ceymail
mkdir -p /ceymail
cp -r . /ceymail/.
chmod -R 755 /ceymail
ln -s /ceymail/ceymail.sh /usr/local/bin/ceymail

echo "CeyMail requires aptitude to be installed."
read -p "Install aptitude? (y/n): " ians
while [[ $ians = "" ]]; do
	echo "You haven't entered an input."
	read -p "Install aptitude? (y/n): " ians
done
if [[ $ians = y ]]; then

apt install aptitude -y
echo "Aptitude Installed!"
echo "Installing CeyMail..."
aptitude install wget unzip curl tar -y >/dev/null
aptitude install mariadb-server -y >/dev/null
debconf-set-selections <<< "postfix postfix/mailname string $domain"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
aptitude install postfix postfix-mysql postfix-policyd-spf-python postfix-pcre -y >/dev/null
aptitude install dovecot-common dovecot-imapd dovecot-pop3d dovecot-core dovecot-lmtpd dovecot-mysql -y >/dev/null
aptitude install opendkim opendkim-tools -y >/dev/null
aptitude install spamassassin spamc -y >/dev/null

echo "CeyMail Installed..."
echo "Create Database & Configure CeyMail"
echo "run ceymail"

elif [[ $ians = n ]]; then
	echo "Goodbye."
	return

else
	echo "Your input was incorrect. Try again."
	return
fi
}

ceyman(){
	if [[ ! -d /ceymail ]]; then
		echo "CeyMail hasn't been installed. Install CeyMail"
		exit 0
	else
	"/ceymail/ceyman/ceyman.sh"
	fi
}

configure(){

dovecotlocation=/etc/dovecot
postfixlocation=/etc/postfix
spamasslocation=/etc/spamassassin
mysqllocation=/var/lib/mysql
opendkimlocation=/etc/opendkim.conf

if [[ ! -d $dovecotlocation || ! -d $postfixlocation || ! -d $spamasslocation || ! -d $mysqllocation || ! -f $opendkimlocation ]]; then 
	echo "One or more core softwares are not installed!"
	if [[ ! -d $dovecotlocation ]]; then
		echo "Dovecot is not installed!"
	fi
	if [[ ! -d $postfixlocation ]]; then
		echo "Postfix is not installed!"
	fi
	if [[ ! -d $spamasslocation ]]; then
		echo "SpamAssassin is not installed!"
	fi
	if [[ ! -d $mysqllocation ]]; then
		echo "MySQL is not installed!"
	fi
	if [[ ! -d $opendkimlocation ]]; then
		echo "OpenDKIM is not installed!"
	fi

	exit 0
fi

if [[ ! -d /ceymail ]]; then
		echo "CeyMail hasn't been installed. Install CeyMail"
		exit 0
	else

read -p "Database: " db
    if [[ $db = exit ]]; then
    	return
    fi
    while [[ $db = "" ]]; do
	echo "You haven't entered an input."
	read -p "Database: " db
	if [[ $db = exit ]]; then
	exit 0
	fi
	done
	while [[ ! -e /var/lib/mysql/$db  ]]; do
	echo "Database does not exist!"
	read -p "Database: " db
	if [[ $db = exit ]]; then
	exit 0
	fi
    done
read -p "Database User: " dbuser
	if [[ $dbuser = exit ]]; then
	exit 0
	fi
read -p "Database Password: " dbpass
	if [[ $dbpass = exit ]]; then
	exit 0
	fi
read -p "Mailname (enter domain name without the '.com' part): " mailname
	if [[ $mailname = exit ]]; then
	exit 0
	fi
read -p "Domain Name without www. (eg. example.com): " domain
	if [[ $domain = exit ]]; then
	exit 0
	fi

cd /ceymail
echo "Configuring CeyMail..."
cat <<EOF > hostname
$domain
EOF


cat <<EOF > hosts
127.0.0.1 $domain localhost.localdomain localhost localdomain

#IPv6
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

mv hostname /etc/hostname
mv hosts /etc/hosts

#POSTFIX

cat <<EOF > main.cf
myorigin = $domain
smtpd_banner = $domain ESMTP $mailname
biff = no
append_dot_mydomain = no
readme_directory = no

smtpd_tls_cert_file= /etc/letsencrypt/live/mail/fullchain.pem
smtpd_tls_key_file= /etc/letsencrypt/live/mail/privkey.pem
smtpd_use_tls=yes
smtpd_tls_auth_only = yes
smtp_tls_security_level = may
smtpd_tls_security_level = may
smtpd_sasl_security_options = noanonymous, noplaintext
smtpd_sasl_tls_security_options = noanonymous
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
smtpd_sasl_auth_enable = yes
smtpd_helo_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_invalid_helo_hostname, reject_non_fqdn_helo_hostname
smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_non_fqdn_recipient, reject_unknown_recipient_domain, reject_unlisted_recipient, reject_unauth_destination, check_policy_service unix:private/policyd-spf
smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_non_fqdn_sender, reject_unknown_sender_domain
smtpd_relay_restrictions = permit_mynetworks, permit_sasl_authenticated, defer_unauth_destination

myhostname = $domain
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mydomain = $domain
mydestination = localhost
relayhost =
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = all

virtual_transport = lmtp:unix:private/dovecot-lmtp
virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf, mysql:/etc/postfix/mysql-virtual-email2email.cf

disable_vrfy_command = yes
strict_rfc821_envelopes = yes
smtpd_delay_reject = yes
smtpd_helo_required = yes
smtp_always_send_ehlo = yes
smtpd_timeout = 30s
smtp_helo_timeout = 15s
smtp_rcpt_timeout = 15s
smtpd_recipient_limit = 40
minimal_backoff_time = 180s
maximal_backoff_time = 3h

invalid_hostname_reject_code = 550
non_fqdn_reject_code = 550
unknown_address_reject_code = 550
unknown_client_reject_code = 550
unknown_hostname_reject_code = 550
unverified_recipient_reject_code = 550
unverified_sender_reject_code = 550

policyd-spf_time_limit = 3600
#header_checks = pcre:/etc/postfix/header_checks
compatibility_level = 2

milter_default_action = accept
milter_protocol = 2
smtpd_milters = unix:/spamass/spamass.sock, inet:localhost:8891
non_smtpd_milters = unix:/spamass/spamass.sock, inet:localhost:8891
EOF

cat <<EOF > mysql-virtual-mailbox-domains.cf
user = $dbuser
password = $dbpass
hosts = 127.0.0.1
dbname = $db
query = SELECT 1 FROM virtual_domains WHERE name='%s'
EOF

cat <<EOF > mysql-virtual-mailbox-maps.cf
user = $dbuser
password = $dbpass
hosts = 127.0.0.1
dbname = $db
query = SELECT 1 FROM virtual_users WHERE email='%s'
EOF

cat <<EOF > mysql-virtual-alias-maps.cf
user = $dbuser
password = $dbpass
hosts = 127.0.0.1
dbname = $db
query = SELECT destination FROM virtual_aliases WHERE source='%s'
EOF

cat <<EOF > mysql-virtual-email2email.cf
user = $dbuser
password = $dbpass
hosts = 127.0.0.1
dbname = $db
query = SELECT email FROM virtual_users WHERE email='%s'
EOF

#cat <<EOF > header_checks
#/^Received: .*/		IGNORE
#/^X-Originating-IP:/	IGNORE
#EOF

cat <<EOF > dynamicmaps.cf
pcre	postfix-pcre.so dict_pcre_open
mysql 	/usr/lib/postfix/postfix-mysql.so.1.0.1 dict_mysql_open
EOF

cat <<EOF > master.cf

EOF

echo '#
# Postfix master process configuration file.  For details on the format
# of the file, see the master(5) manual page (command: "man 5 master" or
# on-line: http://www.postfix.org/master.5.html).
#
# Do not forget to execute "postfix reload" after editing this file.
#
# ==========================================================================
# service type  private unpriv  chroot  wakeup  maxproc command + args
#               (yes)   (yes)   (no)    (never) (100)
# ==========================================================================
smtp      inet  n       -       y       -       -       smtpd
#smtp      inet  n       -       y       -       1       postscreen
#smtpd     pass  -       -       y       -       -       smtpd
#dnsblog   unix  -       -       y       -       0       dnsblog
#tlsproxy  unix  -       -       y       -       0       tlsproxy
submission inet n       -       y       -       -       smtpd
  -o content_filter=spamassassin  
  -o syslog_name=postfix/submission
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_tls_auth_only=yes
  -o smtpd_reject_unlisted_recipient=yes
  -o smtpd_enforce_tls=yes
  -o smtpd_sasl_type=dovecot
  -o smtpd_sasl_path=private/auth
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
#  -o receive_override_options=no_milters
#  -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
#smtps     inet  n       -       y       -       -       smtpd
#  -o syslog_name=postfix/smtps
#  -o smtpd_tls_wrappermode=yes
#  -o smtpd_sasl_auth_enable=yes
#  -o smtpd_reject_unlisted_recipient=no
#  -o smtpd_client_restrictions=$mua_client_restrictions
#  -o smtpd_helo_restrictions=$mua_helo_restrictions
#  -o smtpd_sender_restrictions=$mua_sender_restrictions
#  -o smtpd_recipient_restrictions=
#  -o smtpd_relay_restrictions=permit_sasl_authenticated,reject
#  -o milter_macro_daemon_name=ORIGINATING
#628       inet  n       -       y       -       -       qmqpd
pickup    unix  n       -       y       60      1       pickup
cleanup   unix  n       -       y       -       0       cleanup
qmgr      unix  n       -       n       300     1       qmgr
#qmgr     unix  n       -       n       300     1       oqmgr
tlsmgr    unix  -       -       y       1000?   1       tlsmgr
rewrite   unix  -       -       y       -       -       trivial-rewrite
bounce    unix  -       -       y       -       0       bounce
defer     unix  -       -       y       -       0       bounce
trace     unix  -       -       y       -       0       bounce
verify    unix  -       -       y       -       1       verify
flush     unix  n       -       y       1000?   0       flush
proxymap  unix  -       -       n       -       -       proxymap
proxywrite unix -       -       n       -       1       proxymap
smtp      unix  -       -       y       -       -       smtp
relay     unix  -       -       y       -       -       smtp
        -o syslog_name=postfix/$service_name
#       -o smtp_helo_timeout=5 -o smtp_connect_timeout=5
showq     unix  n       -       y       -       -       showq
error     unix  -       -       y       -       -       error
retry     unix  -       -       y       -       -       error
discard   unix  -       -       y       -       -       discard
local     unix  -       n       n       -       -       local
virtual   unix  -       n       n       -       -       virtual
lmtp      unix  -       -       y       -       -       lmtp
anvil     unix  -       -       y       -       1       anvil
scache    unix  -       -       y       -       1       scache
#
# ====================================================================
# Interfaces to non-Postfix software. Be sure to examine the manual
# pages of the non-Postfix software to find out what options it wants.
#
# Many of the following services use the Postfix pipe(8) delivery
# agent.  See the pipe(8) man page for information about ${recipient}
# and other message envelope options.
# ====================================================================
#
# maildrop. See the Postfix MAILDROP_README file for details.
# Also specify in main.cf: maildrop_destination_recipient_limit=1
#
maildrop  unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail argv=/usr/bin/maildrop -d ${recipient}
#
# ====================================================================
#
# Recent Cyrus versions can use the existing "lmtp" master.cf entry.
#
# Specify in cyrus.conf:
#   lmtp    cmd="lmtpd -a" listen="localhost:lmtp" proto=tcp4
#
# Specify in main.cf one or more of the following:
#  mailbox_transport = lmtp:inet:localhost
#  virtual_transport = lmtp:inet:localhost
#
# ====================================================================
#
# Cyrus 2.1.5 (Amos Gouaux)
# Also specify in main.cf: cyrus_destination_recipient_limit=1
#
#cyrus     unix  -       n       n       -       -       pipe
#  user=cyrus argv=/cyrus/bin/deliver -e -r ${sender} -m ${extension} ${user}
#
# ====================================================================
# Old example of delivery via Cyrus.
#
#old-cyrus unix  -       n       n       -       -       pipe
#  flags=R user=cyrus argv=/cyrus/bin/deliver -e -m ${extension} ${user}
#
# ====================================================================
#
# See the Postfix UUCP_README file for configuration details.
#
uucp      unix  -       n       n       -       -       pipe
  flags=Fqhu user=uucp argv=uux -r -n -z -a$sender - $nexthop!rmail ($recipient)
#
# Other external delivery methods.
#
ifmail    unix  -       n       n       -       -       pipe
  flags=F user=ftn argv=/usr/lib/ifmail/ifmail -r $nexthop ($recipient)
bsmtp     unix  -       n       n       -       -       pipe
  flags=Fq. user=bsmtp argv=/usr/lib/bsmtp/bsmtp -t$nexthop -f$sender $recipient
scalemail-backend unix	-	n	n	-	2	pipe
  flags=R user=scalemail argv=/usr/lib/scalemail/bin/scalemail-store ${nexthop} ${user} ${extension}
mailman   unix  -       n       n       -       -       pipe
  flags=FR user=list argv=/usr/lib/mailman/bin/postfix-to-mailman.py
  ${nexthop} ${user}

policyd-spf    unix    -     n      n     -     0     spawn
	user=policyd-spf argv=/usr/bin/policyd-spf

spamassassin	unix	-	n	n	-	-	pipe
	user=spamd argv=/usr/bin/spamc -f -e	
	/usr/sbin/sendmail -oi	-f  ${sender} ${recipient}' > master

mv main.cf /etc/postfix/main.cf
mv master /etc/postfix/master.cf
mv mysql-virtual-email2email.cf /etc/postfix/mysql-virtual-email2email.cf
mv mysql-virtual-mailbox-maps.cf /etc/postfix/mysql-virtual-mailbox-maps.cf
mv mysql-virtual-alias-maps.cf /etc/postfix/mysql-virtual-alias-maps.cf
mv mysql-virtual-mailbox-domains.cf /etc/postfix/mysql-virtual-mailbox-domains.cf
#mv header_checks /etc/postfix/header_checks
mv dynamicmaps.cf /etc/postfix/dynamicmaps.cf

postmap /etc/postfix/mysql-virtual-email2email.cf
postmap /etc/postfix/mysql-virtual-mailbox-domains.cf
postmap /etc/postfix/mysql-virtual-alias-maps.cf
postmap /etc/postfix/mysql-virtual-mailbox-maps.cf


#DOVECOT

if id "vmail" >/dev/null 2>&1; then
	userdel vmail
fi

cat <<EOF > dovecot.conf
!include_try /usr/share/dovecot/protocols.d/*.protocol
protocols = imap pop3 lmtp

!include conf.d/*.conf
!include_try local.conf

postmaster_address=postmaster@$domain

EOF

cat <<EOF > deny-users.imap
ubuntu
root
test
EOF

cat <<EOF > dovecot-sql.conf.ext
driver = mysql
connect = host=127.0.0.1 dbname=$db user=$dbuser password=$dbpass
default_pass_scheme = SHA512-CRYPT
password_query = SELECT email AS user, password FROM virtual_users WHERE email='%u';
EOF

cat <<EOF > dovecot-dict-sql.conf.ext
map {
	pattern = priv/quota/storage
	table = quota
	username_field = username
	value_field = bytes
}

map {
	pattern = priv/quota/messages
	table = quota
	username_field = username
	value_field = messages
}

map {
	pattern = shared/expire/$user/$mailbox
	table = expires
	value_field = expire_stamp

	fields {
		username = $user
		mailbox = $mailbox
	}
}
EOF

cat <<EOF > dovecot-dict-auth.conf.ext
default_pass_scheme = MD5
iterate_prefix = userdb/

key passdb {
	key = passdb/%u
	format = json
}

key userdb {
	key = userdb/%u
	format = json
}

key quota {
	key = userdb/%u/quota
	default_value = 100M
}

passdb_objects = passdb

userdb_objects = userdb

userdb_fields {
	quota_rule = *:storage=%{dict:quota}
	mail = maildir:/var/mail/vhosts/%d/%n
}
EOF

#conf.d files
#10-auth.conf
cat <<EOF > 10-auth.conf
disable_plaintext_auth = yes
auth_mechanisms = plain login

!include auth-deny.conf.ext
!include auth-system.conf.ext
!include auth-sql.conf.ext
EOF

#10-mail.conf
cat <<EOF > 10-mail.conf
mail_location = maildir:/var/mail/vhosts/%d/%n/

namespace inbox {

	type = private
	separator = /
	inbox = yes
	subscriptions = yes
}

mail_privileged_group = mail
EOF

#auth-sql.conf.ext
cat <<EOF > auth-sql.conf.ext
passdb {
	driver = sql
	args = /etc/dovecot/dovecot-sql.conf.ext
}

userdb {
	driver = sql
	args = /etc/dovecot/dovecot-sql.conf.ext
}

userdb {
	driver = static
	args = uid=vmail gid=vmail home=/var/vmail/%d/%n
}
EOF

#10-master.conf
cat <<EOF > 10-master.conf
service imap-login {
	inet_listener imap {
		port = 0
	}
	inet_listener imaps {
		port = 993
		ssl = yes
	}
}

service pop3-login {
	inet_listener pop3 {
		port = 0
	}
	inet_listener pop3s {
		port = 995
		ssl = yes
	}
}

service lmtp {
	unix_listener /var/spool/postfix/private/dovecot-lmtp {
		mode = 0600
		user = postfix
		group = postfix
	}
}

service auth {
	unix_listener auth-userdb {
		mode = 0600
		user = vmail
	}
	unix_listener /var/spool/postfix/private/auth {
		mode = 0660
		user = postfix
		group = postfix
	}
	user = dovecot
}

service auth-worker {
	user = vmail
}
EOF

#10-ssl.conf
cat <<EOF >10-ssl.conf
ssl = required
ssl_cert = </etc/letsencrypt/live/mail/fullchain.pem
ssl_key = </etc/letsencrypt/live/mail/privkey.pem

disable_plaintext_auth=yes
ssl_client_ca_dir = /etc/ssl/certs
ssl_protocols = !SSLv3
EOF

#15-mailboxes.conf
cat <<EOF > 15-mailboxes.conf
namespace inbox {
	mailbox Drafts {
		special_use = \Drafts
		auto = subscribe
	}

	mailbox Junk {
		special_use = \Junk
		auto = subscribe
	}

	mailbox Trash {
		special_use = \Trash
		auto = subscribe
	}

	mailbox Sent {
		special_use = \Sent
		auto = subscribe
	}

	mailbox Archive {
		special_use = \Archive
		auto = subscribe
	}

	mailbox virtual/All {
		special_use = \All
		auto = subscribe
	}
}
EOF

#auth-deny.conf.ext
cat <<EOF > auth-deny.conf.ext
passdb {
	driver = passwd-file
	deny = yes
	args = /etc/dovecot/deny-users.imap
}
EOF

#Create Vhosts folder
mkdir -p /var/mail/vhosts/$domain

#Users & Grous
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail

#Permissions
chown -R vmail:vmail /var/mail
chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot



#Moving Files
#dovecot conf.d files
mv auth-sql.conf.ext /etc/dovecot/conf.d/auth-sql.conf.ext
mv 10-auth.conf /etc/dovecot/conf.d/10-auth.conf
mv 10-mail.conf /etc/dovecot/conf.d/10-mail.conf
mv 10-master.conf /etc/dovecot/conf.d/10-master.conf
mv 10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
mv 15-mailboxes.conf /etc/dovecot/conf.d/15-mailboxes.conf
mv auth-deny.conf.ext /etc/dovecot/conf.d/auth-deny.conf.ext

#dovecot files
mv dovecot.conf /etc/dovecot/dovecot.conf
mv deny-users.imap /etc/dovecot/deny-users.imap
mv dovecot-sql.conf.ext /etc/dovecot/dovecot-sql.conf.ext
mv dovecot-dict-sql.conf.ext /etc/dovecot/dovecot-dict-sql.conf.ext
mv dovecot-dict-auth.conf.ext /etc/dovecot/dovecot-dict-auth.conf.ext


#OPENDKIM
mkdir -p /etc/mail/dkim-keys/$domain
cd /etc/mail/dkim-keys/$domain
opendkim-genkey -t -s mail -d $domain
mv mail.private $mailname.private
mv mail.txt	$mailname.txt
mkdir -p /ceymail/opendkim
cp $mailname.private $mailname.txt /ceymail/opendkim/
mkdir -p /etc/opendkim

cd /ceymail

cat <<EOF > key.table

mail._domainkey.$domain	$domain:mail:/etc/mail/dkim-keys/$domain/$mailname.private

EOF

cat <<EOF > signing.table

*@$domain  		mail._domainkey.$domain

EOF

cat <<EOF > trusted.hosts

localhost
$domain

EOF

cat <<EOF > opendkim.conf

Syslog 		yes
UMask		007
Socket		inet:8891@localhost

KeyTable		refile:/etc/opendkim/key.table
SigningTable	refile:/etc/opendkim/signing.table

ExternalIgnoreList	refile:/etc/opendkim/trusted.hosts
InternalHosts		refile:/etc/opendkim/trusted.hosts

Canonicalization	relaxed/simple
Mode 				sv
SubDomains			no
AutoRestart			yes
AutoRestartRate		10/1M
Background			yes
DNSTimeout			10
SignatureAlgorithm	rsa-sha256

PidFile				/var/run/opendkim/opendkim.pid
OversignHeaders		From
TrustAnchorFile		/usr/share/dns/root.key

UserID 				opendkim

EOF


#Moving Files
mv opendkim.conf /etc/opendkim.conf
mv key.table /etc/opendkim/key.table
mv signing.table /etc/opendkim/signing.table
mv trusted.hosts /etc/opendkim/trusted.hosts

cat <<EOF > DNS_Records.txt

Add these DNS Records
DNS Records
------------
		MX
Priority	Host 			Target
10			 @		$domain

All extra domain names should have the main domain name as the target.

		SPF
Host	 	virtual_users
 @		v=spf1 a mx -all

		DMARC
	 Host	 				Value
_dmarc.$domain		v=DMARC1; p=quarantine; pct=100;

EOF

cp opendkim/$mailname.txt DKIM_Record.txt


#SpamAssassin

cd /ceymail
groupadd spamd
useradd -g spamd -s /bin/false -d /var/log/spamassassin spamd
mkdir -p /var/log/spamassassin
chown spamd:spamd /var/log/spamassassin

cat <<EOF > local.cf

rewrite_header Subject SPAM *_SCORE_*

report_safe 0

required_score 3.0

use_bayes 1

bayes_auto_learn 1

use_bayes_rules 1

skip_rbl_checks 0

use_razor2 0

use_dcc 0

use_pyzor 0

ifplugin Mail::SpamAssassin::Plugin::Shortcircuit

EOF


cat <<EOF > spamassassin

# /etc/default/spamassassin

ENABLED=1
SAHOME="/var/log/spamassassin/"
OPTIONS="--create-prefs --max-children 5 --helper-home-dir --username spamd \
-H ${SAHOME} -s ${SAHOME}spamd.log"
PIDFILE="/var/run/spamd.pid"
CRON=1

EOF


#Moving Files
mv local.cf /etc/spamassassin/local.cf
mv spamassassin /etc/default/spamassassin

chown postfix:postfix /var/lib/postfix/* >/dev/null
chmod 600 /var/lib/postfix/* >/dev/null
chmod 2755 /usr/sbin/postdrop >/dev/null
postfix set-permissions >/dev/null
chown -R root:root /etc/postfix >/dev/null
chown -R opendkim:opendkim /etc/mail/dkim-keys >/dev/null
chown -R opendkim:opendkim /etc/opendkim >/dev/null
chmod -R 700 /etc/mail/dkim-keys >/dev/null
gpasswd -a vmail dovecot >/dev/null
chown -R vmail:dovecot /etc/dovecot >/dev/null
chmod -R 0751 /etc/dovecot >/dev/null
chown -R vmail:vmail /var/mail/vhosts >/dev/null
chown -R www-data:www-data /var/www/html/public_html >/dev/null

#Restarting All Services
service postfix restart
service dovecot restart
service opendkim restart
service apache2 restart
service mariadb restart
service spamassassin restart

fi

#End Configuration

echo "CeyMail has successfully been configured."
echo "Instructions are in /ceymail/instructions.txt"
cd /ceymail
cat > instructions.txt <<EOF
Instructions
-------------
1. You have to manually add the DNS Records.
DNS Records and DKIM Record can be found in /ceymail
With the DKIM Record, remove white spaces, double quotes and brackets at the ends.
Add a TXT record for DKIM with an example like this...
THIS IS JUST AN EXAMPLE.

	Host 				Value
mail._domainkey  v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkasd9B
BAQEFAAOCAQ8AMIIBCgKCAQEAmm/O85FT4I+ZoH9UWkszxtIuC0HQQ6MHR4L8/
D+lEKhOjTT//6F3doFiHPO8wm5fU6WaTWCwoM5dwpiAW+z7tYQDAYK8jH6N4Jg
ZbcWRoU6U0eqltBMiR2IWWDOpoS0H7utf6JvJcZA6xz9QFiK5c7ro7ZmBnHM42
3f0oshFIbxbhqptOm75uBokGKDL+FBeFGD5jzIoVvw0hoP/2tah9pTs3NpeqbX
bP4j5aPaSrqA584N5XbXXj3i42hHPp9KwlPT2JgKA5dUNRD1Cok8mlqjfVzuKZ
/InSyOB6m7uaD4I0t3ijlTIp36Ny0V1ZyEIDpvOmrOkeU+rM/RKjd2CewIDAQAB

Configure Apache, PHP and Certbot (SSL)
Add 'Alias /mail "/var/www/html/public_html/mail"' to your site's apache configuration file (e.g. /etc/apache2/sites-available/$domain.conf and $domain-le-ssl.conf)
2. CD into /etc/letsencrypt/live
3. Copy fullchain.pem and privkey.pem into /etc/letsencrypt/live/mail/.
4. Make sure your server's firewall allows all the ports used by CeyMail.
(80, 443, 25, 465, 587, 993, 143, 110, 995)
5. To login to your email, visit $domain/mail.
Login with superadmin (no password)
Change admin username and password
Go to database tab and test database connection, create/update tables and update configuration.
Go to the mail servers tab
Add New Server with these settings
Display Name: 'Your Company'
Leave Domains empty.
IMAP Server: $domain 		Port: 993	SSL:Yes
SMTP Server: $domain 		Port: 587	SSL:No
SMTP authentication: use incoming mail's login/password of the user.
Tick 'use mail threading if supported by the server.'
Tick 'Use full email address as login.'
Save & logout and login with your email address.
Note: Remember to update DKIM DNS Records after *Reconfiguring CeyMail*.
EOF



}

uninstall(){
dovecotlocation=/etc/dovecot
postfixlocation=/etc/postfix
opendkimlocation=/etc/opendkim
spamasslocation=/etc/spamassassin

read -p "Are you sure you want to uninstall CeyMail? (y/n): " unans
if [[ $unans = y ]]; then
echo "Uninstalling CeyMail..."
aptitude remove postfix postfix-mysql postfix-policyd-spf-python opendkim opendkim-tools spamassassin spamc dovecot-common dovecot-imapd dovecot-pop3d dovecot-core dovecot-lmtpd dovecot-mysql -y > /dev/null
aptitude purge postfix postfix-mysql postfix-policyd-spf-python opendkim opendkim-tools spamassassin spamc dovecot-common dovecot-imapd dovecot-pop3d dovecot-core dovecot-lmtpd dovecot-mysql -y > /dev/null

if id "vmail" >/dev/null 2>&1; then
	userdel vmail
fi
if id "opendkim" >/dev/null 2>&1; then
	userdel opendkim
fi
if id "postfix" >/dev/null 2>&1; then
	userdel postfix
fi
if id "spamd" >/dev/null 2>&1; then
	userdel spamd
fi
if id "policyd-spf" >/dev/null 2>&1; then
	userdel policyd-spf
fi

rm /usr/local/bin/ceymail
rm -rf /ceymail /etc/dovecot /etc/postfix /etc/opendkim /etc/opendkim.conf /etc/spamassassin /var/www/html/public_html/mail
	
	read -p "Uninstall MySQL? (y/n): " mysqlans
	if [[ $mysqlans = n ]]; then
		exit 0
	elif [[ $mysqlans = y ]]; then
		aptitude remove mariadb-server -y >/dev/null
		aptitude purge mariadb-server -y >/dev/null
		if [[ -d /var/lib/mysql ]]; then
			rm -rf /var/lib/mysql
		fi
		echo "CeyMail Uninstalled"
		exit 0
	else 
		echo "Your input is incorrect."
		read -p "Uninstall MySQL? (y/n): " mysqlans
	if [[ $mysqlans = n ]]; then
		exit 0
	elif [[ $mysqlans = y ]]; then
		aptitude remove mariadb-server -y >/dev/null
		aptitude purge mariadb-server -y >/dev/null
		if [[ -d /var/lib/mysql ]]; then
			rm -rf /var/lib/mysql
		fi
		echo "CeyMail Uninstalled"
		exit 0
	fi
	fi
	while [[ $mysqlans = "" ]]; do
		echo "You haven't entered an input."
		read -p "Uninstall MySQL? (y/n): " mysqlans
	if [[ $mysqlans = n ]]; then
		exit 0
	elif [[ $mysqlans = y ]]; then
		aptitude remove mariadb-server -y >/dev/null
		aptitude purge mariadb-server -y >/dev/null
		if [[ -d /var/lib/mysql ]]; then
			rm -rf /var/lib/mysql
		fi
		echo "CeyMail Uninstalled"
		exit 0
	else 
		echo "Your input is incorrect."
	fi
	done

		echo "CeyMail Uninstalled"
exit 0


elif [[ $unans = n ]]; then
	echo "Goodbye!"
	return

else 
	echo "Your input is incorrect!"
	return
fi

}

pi=99


pa="1. Manage Database"
pb="2. Configure CeyMail"
py="i - Install CeyMail"
pu="u - Uninstall CeyMail"
px="e - exit"

while [[ $pi -gt 0 ]]; do
echo ""
echo $pa
echo $pb
echo "-----------------------"
echo $py
echo $pu
echo $px
echo ""
read -p "Enter an option: " pans

while [[ $pans = "" ]]; do
	echo "You haven't entered an input."
	read -p "Enter an option: " pans
	if [[ $pans = exit ]]; then
	exit 0
	elif [[ $pans = e ]]; then
	exit 0
	fi
done

if [[ $pans = 1 ]]; then
	ceyman

elif [[ $pans = 2 ]]; then
	configure
	sed -i --follow-symlinks 's/2. Configure CeyMail/2. Reconfigure CeyMail/g' /ceymail/ceymail.sh
elif [[ $pans = i ]]; then
	install
	sed -i --follow-symlinks 's/i - Install CeyMail/CeyMail is installed./g' /ceymail/ceymail.sh
elif [[ $pans = u ]]; then
	uninstall

elif [[ $pans = e ]]; then
	exit 0

elif [[ $pans = exit ]]; then
	exit 0

else 
	echo "Your input is incorrect!"
	exit 0

fi
(( pi-- ))
done
