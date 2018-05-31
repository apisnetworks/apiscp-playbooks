MATCH=\\bwheel\\b
if [[ `id -nG $LOGNAME` =~ $MATCH ]] ; then
	DIR="/usr/local/lib/python/$PYENV_VERSION"
else
	DIR="$HOME/.pyenv/python/$PYENV_VERSION"
fi
[ -d "$DIR" ] || mkdir -p "$DIR"
PYTHONPATH="$DIR"
export PYTHONPATH
