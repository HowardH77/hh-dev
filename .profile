# ~howard.hong/.profile

umask 022
date +"%c -- .profile" >> $HOME/log/rc.log

PATH="$HOME/bin:$HOME/.local/bin:$PATH:."; export PATH

if [ -n "$DISPLAY" ]; then xrdb -merge $HOME/.Xdefaults; fi

if [ -f "$HOME/.bashrc" -a -n "$BASH_VERSION" ]; then
	BASH_ENV=$HOME/.bashrc; export BASH_ENV
	. "$HOME/.bashrc"
fi

ssh-add -l | grep -q '/home/howard.hong/.aws/terraform/ec2-key-pair.pem'
if [ $? -ne 0 ]; then
	ssh-add $HOME/.aws/terraform/ec2-key-pair.pem > $HOME/log/ssh-add.log 2>&1
fi
