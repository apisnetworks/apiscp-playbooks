[[ -f /etc/sysconfig/apnscp ]] && . /etc/sysconfig/apnscp
APNSCP_HOME=${APNSCP_HOME:-/usr/local/apnscp}
APNSCPCMD=${APNSCPCMD:-${APNSCP_HOME}/bin/cmd}
alias upcp="[[ -d $APNSCP_HOME ]] && env APNSCP_HOME=${APNSCP_HOME} $APNSCP_HOME/build/upcp.sh"
alias cpcmd="apnscp_php ${APNSCP_HOME}/bin/cmd"
# avoid blowing up /.socket or bind mounts
alias rm='rm -i --one-file-system'
function site_stats { 
	if [ -z $1 ] ; then 
		CONSTRAINT="%"
	else 
		CONSTRAINT=$1 
	fi
	echo "select domain, ROUND(quota/1024./1024., 2)||' MB' as disk_quota, ROUND(threshold/1024./1024/1024,2)||' GB' as bw_quota FROM siteinfo JOIN bandwidth USING (site_id) JOIN diskquota USING (site_id) WHERE domain LIKE '$CONSTRAINT' OR email LIKE '$CONSTRAINT' ORDER BY domain" | psql -t appldb; 
}

# Change account username
function change_username { 
	$APNSCPCMD -d "$1" auth_change_username "$2"
}

# Change account domain
function change_domain { 
	$APNSCPCMD -d "$1" auth_change_domain "$2"
}

# Assume an account gets compromised, provide
# an easy way to change the password for the user
# @TODO use chage or better yet integrate it
function change_password { 
	$APNSCPCMD -d "$1" auth_change_username "$2"
}

# Generate a temporary password for a domain
# Used when gaining access to another account and
# without tripping the login/password reset notice
function temp_password {
	if [ $# -ne 1 ] ; then
		echo "usage: $0 <domain>"
		return 1
	fi
	adminuser=`$APNSCPCMD admin_get_meta_from_domain $1 siteinfo admin_user`
	newpass=`$APNSCPCMD auth_set_temp_password $1`
	echo "$adminuser -> $newpass"
}


function get_config { 
	DOMAIN=$1 
	CLASS=$2
	PARAM=$3
	if [ -z $PARAM ] ; then
		echo "usage: get_config domain svc_class svc_param"
		return 255
	fi
	SITE=$(get_site $DOMAIN)
	if [ ! -d /home/virtual/$SITE/info ] ; then
		echo "Invalid domain $DOMAIN"
		return 1
	fi
	if [ ! -f /home/virtual/$SITE/info/current/$CLASS ] ; then
		echo "Service class $CLASS does not exist"
		return 1
	fi
	set -f +B  VAL
	VAL=`perl -n  -e 'if (/^'$PARAM'\s*=/) { s/['\'']//g ;  s/^\s*'$PARAM'\s*=\s*//g ;  print; exit ; }' <  /home/virtual/$SITE/info/current/$CLASS`
	if [ $? -ne 0 ]; then
		echo "Param $PARAM does not exist";
		return 1;
	fi;
	echo $VAL
	set +f
	return 0
}

# Get siteXX from domain
function get_site {
	DOMAIN=$1
	if [[ ! "$DOMAIN" =~ ^site[[:digit:]]+$ ]] ; then
		DOMAIN=$(tcamgr  get /etc/virtualhosting/mappings/domainmap.tch "$DOMAIN" 2> /dev/null)
	fi
	echo $DOMAIN
	return
}

# Get numeric site identifier from site
function get_site_id {
	var=$(get_site $1)
	echo ${var#site}
}

# Match mail queue on term and remove
# You shouldn't need this, but nice to have
function rmspam {
	SPOOL=/var/spool/postfix
	EMAIL=$1
	let CNT=0
	grep -rsl "$EMAIL" $SPOOL/active/ $SPOOL/bounce/ $SPOOL/deferred/ $SPOOL/incoming/ | \
		{  while read ID ; do 
				ID=${ID##*/}
				((CNT++))
				postsuper -d $ID 2> /dev/null
			done
			echo "Removed $CNT messages"
		}
}

# Look for binaries under a directory for missing libraries
# Useful when building up new filesystem services
function bintrospect {
	BIN=$1
	ldd "$BIN"  | awk '{print $3}'  | grep '^/' | while read lib ; do
		[ -f "$lib" ] || continue
		strings "$lib" | egrep '^[A-Z_]+$'
	done | sort | uniq
}
