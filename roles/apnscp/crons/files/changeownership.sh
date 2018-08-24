#!/bin/sh
#
# (c) 2018 Apis Networks, INC
#
shopt -s nullglob
[[ -f /etc/sysconfig/apnscp ]] && . /etc/sysconfig/apnscp
TOMCAT_USER=${TOMCAT_USER:-tomcat}
WEB_USER=${WEB_USER:-apache}
DIR="/home/virtual/site[0-9]*/shadow"

if [ ! -z "$1" ] ; then
		DIR="$1"
fi

for i in $DIR ; do 
	admin=${i/\/shadow/}
	admin=${admin##*/}
	admin=${admin/site/admin}
	find $i/{home,usr/local,var/www} \( -group $WEB_USER -o -group $TOMCAT_USER \) -print \
		-exec chgrp $admin '{}' \;  \
		\( \
				\( \
					-type d -group $WEB_USER \
					-exec setfacl -n -m user:$admin:7 -d -m user:$admin:7,user:$WEB_USER:7 '{}' \; -print \
					-o \
					-type d -group $TOMCAT_USER \
					-exec setfacl -n -m user:$admin:7 -d -m user:$admin:7,user:$TOMCAT_USER:7 '{}' \; -print \
				\) \
				-exec chmod g+s,o+x '{}' \; \
				-o \
				-type f -exec setfacl -n -m user:$admin:6 '{}' \; \
		\)
done