#!/bin/sh
FILE=/tmp/mysql.wait

is_locked() {
        # Check to see if /var/lib/mysql/ibdata1 is locked by a MySQL process
        # It may be running in recovery mode, so do not restart MySQL
        PIDS=$(ps -opid= -C mysqld)
        [[ -z $PIDS ]] && return 0
        for p in $PIDS ; do
                lsof -b -F n0l  -w -p $p | egrep -q -a '^[^[:space:]]*W[[:space:]]*.*/ibdata1'
                if [ $? -eq 1 ] ; then
                        # not locked
                        return 0
                fi
        done
        [ -z $p ] && return 0
        return 1
}

for i in $(seq 1 10) ; do
        is_locked
        [[ $? -eq 0 ]] && exit 0
        sleep 5
done

exit 1