#!/bin/sh
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
pecl download $extension
[[ $? -ne 0 ]] && fatal "failed to download extension \`$extension'"
FILE=(*.{tgz,gz,bz2,tar})
[[ ${#FILE[@]} -eq 0 ]] && fatal "archive for \`$extension' not found, did it download OK?"

tar -xaf ${FILE[0]}
[[ $? -ne 0 ]] && fatal "extension \`$extension' not found"
if [[ ! -f config.m4 ]] ; then
  DIR=`find . -mindepth 1 -type f -name config.m4 -printf "%h" -quit`
  [[ -z $DIR ]] && fatal "unable to find config.m4 in archive"
  echo $DIR
  cd $DIR
fi
$PHPIZE && ./configure --with-php-config=$PHPCONFIG $XTRACFG && make && make install
