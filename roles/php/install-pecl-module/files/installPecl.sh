#!/bin/sh
set -euo pipefail

readonly APNSCP_HOME=${APNSCP_HOME:-/usr/local/apnscp}
readonly PHPIZE=${PHPIZE:-${APNSCP_HOME}/bin/php-bins/apnscp_phpize}
readonly PHPCONFIG=${PHPCONFIG:-${APNSCP_HOME}/bin/php-bins/apnscp_php-config}
readonly XTRACFG=${XTRACFG:-""}

function fatal {
  echo "ERR: $@"
  exit 1
}

function cleanup {
  [[ ! -z $tmpdir ]] && [[ -d $tmpdir ]] && rm -rf "$tmpdir"
  popd
}

extension=$1
[[ -z $extension ]] && fatal "usage: `basename $0` peclextension"
readonly tmpdir=$(mktemp -p `pwd` -d  -t extension.XXXXXXX)
trap "{ [[ ! -z $tmpdir ]] && [[ -d $tmpdir ]] && rm -rf $tmpdir; }" EXIT SIGTERM
pushd $tmpdir  || fatal "failed to chdir to $tmpdir"

function download {
	EXTENSION=$1
	if [[ ${EXTENSION:0:4} == "http" ]]; then
		if [[ ${EXTENSION: -4} == ".git" ]]; then
			git clone $EXTENSION extension		
			pushd extension
			# Attempt to use most recent release instead of master
			latesttag=$(git describe --tags)
			[[ $? -eq 0 ]] && git checkout ${latesttag}
			popd
			return $?
		fi
		wget $EXTENSION
	else
		pecl download $extension
	fi
	[[ $? -ne 0 ]] && fatal "failed to download extension \`$extension'"
	FILE=(*.{tgz,gz,bz2,tar})
	[[ ${#FILE[@]} -eq 0 ]] && fatal "archive for \`$extension' not found, did it download OK?"
	tar -xaf ${FILE[0]}
	return 0
}

download $extension
pushd $(ls -d */ | head -n 1) 2> /dev/null

[[ $? -ne 0 ]] && fatal "extension \`$extension' not found"

if [[ ! -f config.m4 ]] ; then
  DIR=`find . -mindepth 1 -type f -name config.m4 -printf "%h" -quit`
  if [[ ! -z $DIR ]]; then  
	  echo "Moved to $DIR"
	  pushd $DIR
  fi
  if [[ -f autogen.sh ]]; then
  	./autogen.sh
	elif [[ -f configure.ac ]]; then
		autoreconf
	fi
  if [[ ! -f config.m4 ]]; then 
  	fatal "unable to find config.m4 in archive"
  fi
fi
# From install-pecl-module/tasks/verify-and-install.yml
declare -x MAKEFLAGS
$PHPIZE && ./configure --with-php-config=$PHPCONFIG $XTRACFG && make && make install
