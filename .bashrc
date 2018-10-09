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

return;  # Skip keyme salt state additions



[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

complete -C '/usr/bin/aws_completer' aws;  # awscli command completion

# RFID Aliases [Automatically Generated]
alias clone-rfid="PYTHONPATH=/opt/kiosk2 /opt/kiosk2/rfid_reader/clone_card.py"
alias duplicate-rfid="PYTHONPATH=/opt/kiosk2 /opt/kiosk2/rfid_reader/reader.py"
# End RFID Aliases
# Transponder Aliases [Automatically Generated]
alias write-transponder='PYTHONPATH=/opt/kiosk2 python3 /opt/kiosk2/transponder/write_transponder.py'
alias upgrade-884='PYTHONPATH=/opt/kiosk2 python3 /opt/kiosk2/transponder/scripts/upgrade_884.py'
alias check-884-battery='PYTHONPATH=/opt/kiosk2 python3 /opt/kiosk2/transponder/scripts/check_battery.py'
# End Transponder Aliases
# Review Tools Aliases [Automatically Generated]
alias quick-transaction-review='review tool transactions'
alias quick-kiosk-scan-review='review tool kiosk_scans'

alias review='/opt/review_tools/review.py -p'
alias beta-review='/opt/review_tools/review.py -b'
alias quick-review='/opt/review_tools/review.py -p -q'
alias beta-quick-review='/opt/review_tools/review.py -b -q'
alias error-transaction-review='/opt/review_tools/review.py queue error_transaction'
alias lockout-transaction-review='/opt/review_tools/review.py queue lockout_transaction'
alias duplication-transaction-review='/opt/review_tools/review.py queue duplication_transaction'
# End Review Tools Aliases
# Count Kiosk Scans Aliases [Automatically Generated]
alias count_kiosk_scans='pushd /opt/kiosk_review/count_kiosk_scans 2>&1 1>/dev/null; python count_scans.py ;popd 2>&1 1>/dev/null'
# End Count Kiosk Scans Aliases
# Kiosk Review Aliases [Automatically Generated]
alias kiosk_review='pushd /opt/kiosk_review/human_review_kiosk 2>&1 1>/dev/null; python kiosk_human_review.py production; popd 2>&1 1>/dev/null'
# End Kiosk Review Aliases
# Mobile Detection Aliases [Automatically Generated]
alias legacy-review='pushd /opt/mobile-detection 2>&1 1>/dev/null; ./scripts/human_review.py -l production;popd 2>&1 1>/dev/null'
alias kiosk-check='/opt/mobile-detection/scripts/download_kiosk_scans.py'
function local-review { /opt/mobile-detection/scripts/human_review.py --images "$1" "$2" development; }
# End Mobile Detection Aliases
