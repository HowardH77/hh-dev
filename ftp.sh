#! /bin/sh
#  Synopsis:    ftp.sh [-h rhost] [-u user] [-p password] [-d rdir] get|put file ...
#  Description: Perform ftp-get or ftp-put to/from a remote FTP host
#               Options: -h Specify FTP host
#                        -u Specify remote user
#                        -p Specify remote user password
#                        -d Specify destination directory
#               Example 1) ftp_put /dir1/file1 /dir2/file2 to rhost:/destdir
#                 $ ftp.sh -h rhost -u ruser -p XXX -d /destdir put /dir1/file1 /dir2/file2
#               Example 2) ftp_get rhost:/dir1/file1 /dir2/file2 to /home/tmp
#                 $ ftp.sh -h rhost -u ruser -p XXX -d /home/tmp get /dir1/file1 /dir2/file2

Usage()
{
	{ if [ -n "$1" ]; then
	  	echo "$1"
	  fi
	  echo "Usage: $argv0 [-h rhost] [-u user] [-p password] [-d dest_dir] get|put file ..."
	} >&2
	exit 1
}


getfiles()
{
	for file; do
		rdir=`dirname $file`
		basename=`basename $file`
		getput_files="$getput_files
cd $rdir
get $basename $destdir/$basename"
	done
}


putfiles()
{
	for file; do
		basename=`basename $file`
		getput_files="$getput_files
put $file $destdir/$basename"
	done
	getput_files="$getput_files
cd $destdir
ls"  # list files in remote dir after ftp-put
}


# Main
argv0=`basename $0`
while getopts h:u:p:d: opt;do
	case $opt in
	  h) rhost=$OPTARG;;
	  u) user=$OPTARG;;
	  p) passwd=$OPTARG;;
	  d) destdir="$OPTARG";;
	  \?) Usage;;
	esac
done
shift `expr $OPTIND - 1`

case $argv0 in
  ftpget) getput=get;;
  ftpput) getput=put;;
  ftpput-local)
	getput=put
	rhost=localhost
	;;
  *) getput="$1"; shift;;
esac

if [ -z "$rhost" ]; then
	Usage "Error: $argv0 - Must specify FTP host"
fi
if [ -z "$user" ]; then
	Usage "Error: $argv0 - Must specify user"
fi
if [ -z "$passwd" ]; then
	printf "Password? " > /dev/tty
	stty -echo; read passwd; stty echo
fi
case "$getput" in
  get) getfiles "$@" ;;
  put) putfiles "$@" ;; 
  *) Usage "Error: $argv0 - Must specify 'get' or 'put'" ;;
esac

# cat <<-end_ftp
ftp -niv <<-end_ftp
	open $rhost
	user $user $passwd
	$getput_files
end_ftp

