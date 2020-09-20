#!/bin/sh

mkdir -p /etc/ssh/keys
if test ! -f /etc/ssh/keys/ssh_host_rsa_key ; then
	echo "Generating RSA HostKey ..."
	ssh-keygen -t rsa -f /etc/ssh/keys/ssh_host_rsa_key -N "" -q
fi

if test ! -f /etc/ssh/keys/ssh_host_ecdsa_key ; then
	echo "Generating ECDSA HostKey ..."
	ssh-keygen -t ecdsa -f /etc/ssh/keys/ssh_host_ecdsa_key -N "" -q
fi
chmod -R 600 /etc/ssh/keys

mkdir -p /repos
deluser borg 2> /dev/null
delgroup borg 2> /dev/null
addgroup -g "$GID" borg 2> /dev/null
adduser -u "$UID" -G borg -h /repos -D borg 2> /dev/null
chown -R borg:borg /repos
passwd -u borg

if test ! -f /repofile ; then
	echo "No repofile found. Exiting."
	exit 1
fi
mkdir -p /repos/.ssh
cat /repofile | awk -F ";" '{ print "/repos/"$1 }' | xargs mkdir -p
cat /repofile | awk -F ";" '{ print $2 }' > /repos/.ssh/authorized_keys
chmod 600 /repos/.ssh/authorized_keys
chown borg:borg /repos/.ssh/authorized_keys

echo "Starting sshd ..."
touch /tmp/sshlog
/usr/sbin/sshd -f /etc/ssh/sshd_config -D -E /tmp/sshlog &
tail -f /tmp/sshlog
