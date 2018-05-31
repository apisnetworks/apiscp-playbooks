#!/bin/sh
find /root/Mail/{new,cur}/ -type f -mtime +14 -exec rm -f {} \;

FILELIST="/tmp/rmlist.$$"
for i in /home/virtual/site*/fst ; do 
	SITE=$(echo $i | awk -F/ '{print $4}')
	SIZE=$((echo -n "(" ; find $i/home/*/Mail/.Spam/{cur,new} -type f -mtime +90  -fprintf $FILELIST "%p\0" -printf "%s+" ; echo "0)/1024/1024") | bc)
	echo $SITE $SIZE KB
	if [[ `stat -c%s $FILELIST` -gt 0 ]] ; then 
		cat $FILELIST | xargs -0 rm -f
	fi
	rm -f $FILELIST
	usleep 50000
done > /dev/null 2>&1
