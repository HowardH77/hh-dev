# Name: $HOME/.bashrc

if [ -w $HOME/log/rc.log ]; then date +"%c -- .bashrc: Trace \$-='$-'" >> $HOME/log/rc.log; fi

TMPDIR=$HOME/.tmp; export TMPDIR
EDITOR=vi; export EDITOR

unalias  l ll ldir 2>/dev/null
function l { ls --color=never -CF "$@"; }
function ll { ls --color=never -lF "$@"; }
# function ldir { ls --color=never -l "$@" | grep ^d; }

function vip
{
	tmpfile=/tmp/.vip.$$
	trap "rm -f $tmpfile" 0 15
	umask 077
	tee $tmpfile
	if [ -s $tmpfile ]; then
		vi "$@" $tmpfile >/dev/tty </dev/tty
	fi
}

if [ -r ~/.localrc ]; then 
	. ~/.localrc; 
	if [ $? -ne 0 ]; then
		return
	fi
fi

case $- in
    *i*) # Interactive shell 
	xtitle
	HISTSIZE=5000
	HISTFILESIZE=5000
	HISTCONTROL=ignoredups
	shopt -s histappend
	shopt -s checkwinsize;  # Check the window size after each command and update the values of LINES and COLUMNS if necessary
	set -o vi
	alias cd=chdir
	chdir () 
	{ 
		unset ndir
		case $# in
		  0) ndir=$HOME ;;
                     # Implements ksh "cd $1 $2" functionality
		  2) ndir=`echo $PWD | sed -e "s*$1*$2*"` ;;
		  4) ndir=`echo $PWD | sed -e "s*$1*$2*" -e "s*$3*$4*"` ;;
		esac
		'cd' "${ndir:-$1}" && 
			if [ "${PWD#/*/*/}" = "$PWD" ]; then
				PS1='$PWD> ';
			else
				PS1="..${PWD#${PWD%/*/*}}> ";
			fi
	}

	trap 'echo ReturnCode=$?' ERR
	;;

      *) # Non-Interactive shell 
	return
	;;
esac

