#!/usr/bin/zsh

WS='/home/myles/workspace/webapp'
BUILDDIR="$WS/build"
MIRRORBASE='http://mirror.pelco.org/yapt/endura-pl4-x86_64'
RPMFOLDER=''
remote_choice='b'
local_choice='b'

# Check for a host
if [[ $# -lt 1 ]]; then
    echo "Must specify host."
    return 1
fi

if [[ $# -ge 3 ]]; then
    read res'?Trunk or branch?(t/b): '
else
    echo "Using remote $remote_choice local $local_choice"
    res=$remote_choice
fi

# Looking for trunk dir
if [[ $remote_choice == 't' ]]; then
    RPMFOLDER="$MIRRORBASE/webapp-SNAPSHOT"

elif [[ $remote_choice == 'b' ]]; then
    RPMFOLDER="$MIRRORBASE/webapp"
else
    echo "Invalid selection."
    return 1
fi

if [[ $local_choice == 't' ]]; then
    WEBDIR=`find $BUILDDIR -maxdepth 1 -type d -name '*SNAPSHOT*'`

elif [[ $local_choice == 'b' ]]; then
    WEBDIR=`find $BUILDDIR -maxdepth 1 -type d -name 'webapp-[0-9]\.*'`
else
    echo "Invalid selection."
    return 1
fi

# Check for auxillary commands
if [[ $# -ge 2 ]]; then
    if [[ $2 == 'backup' ]]; then
        echo "Downloading RPM and uninstalling."
        # download the rpm from mirror and uninstall from box
        wget='wget '
        rest='/`productconfig | grep webapp`.noarch.rpm && rpm -e `rpm -qa | grep webapp`'
        /usr/bin/ssh -l root $1 "$wget$RPMFOLDER$rest"
    elif [[ $2 == 'restore' ]]; then

        echo "Removing var/html from $1"
        /usr/bin/ssh -l root $1 'rm -rf /var/www/html/*'

        echo "Restoring from backup."
        # re-install from backed-up RPM
        /usr/bin/ssh -l root $1 'rm -rf /var/www/html/* && rpm -ivh `ls | grep webapp` && rm `ls | grep webapp`'
        return 0
    else
        echo "Unknown command"
        return 1
    fi
fi

if [[ -z "$WEBDIR" ]]; then
   echo "No build folder found, check that you have run gwt-compile."
   return 1
fi

echo "Removing var/html from $1"
/usr/bin/ssh -l root $1 'rm -rf /var/www/html/*'
echo "Copying to $1"
/usr/bin/scp -r $WEBDIR/sm5200 $WEBDIR/*.html $WEBDIR/*.css $WEBDIR/public root@$1:/var/www/html/
