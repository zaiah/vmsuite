#!/bin/bash -
#------------------------------------------------------
# vmmgr.sh (vmmgs, vmmgm)
# 
# Shortcuts to start and stop single VMs and groups.
#
# ---------
# Licensing
# ---------
# 
# Copyright (c) 2013 Vokayent
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#------------------------------------------------------

LIB="sh/vmlib.sh"
BINDIR="$(dirname "$(readlink -f $0)")"   	# The program's directory.
source "$BINDIR/$LIB"	                     # Include the library.
PROGRAM="vmgo"                            	# Program name.


# usage message
# Show a usage message and die.
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-l|--list           List all running vms. 
-f|--foreground     Start a VM in the foreground. 
-b|--background     Start a VM in the background. 
-n|--name           Refer to a vm by name. 
-a|--alias          Use an alias for a VM. 
-k|--kill           Kill a particualr VM 
-r|--restart        Restart a VM. 
-s|--snap           Take a snapshot of a VM. 
-v|--verbose        Be verbose in output.
-h|--help           Show this help and quit.
"
   exit $STATUS
}


# Die if no options received.
[ -z $BASH_ARGV ] && echo "Nothing to do." && usage 1
while [ $# -gt 0 ]
do
   case "$1" in
     -l|--list)
         LIST=true
      ;;
     -f|--foreground)
         FOREGROUND=true
			shift
			VMNAME="$1"
      ;;
     -b|--background)
         BACKGROUND=true
			shift
			VMNAME="$1"
      ;;
     -n|--name)
         NAME=true
      ;;
     -a|--alias)
         ALIAS=true
      ;;
     -k|--kill)
         KILL=true
			shift
			VMNAME="$1"
      ;;
     --hardkill)
         HARDKILL=true
			shift
			VMNAME="$1"
      ;;
     -r|--restart)
         RESTART=true
			shift
			VMNAME="$1"
      ;;
     -s|--snap)
         SNAP=true
			shift
			VMNAME="$1"
      ;;
      --is-running)
        IS_RUNNING=true
			shift
			VMNAME="$1"
      ;;
      --script)
        SCRIPT=true
      ;;
      -v|--verbose)
        VERBOSE=true
      ;;
      -h|--help)
        usage 0
      ;;
      -*)
      printf "Bad argument.\n";
      exit 1
     ;;
      *) break;;
   esac
shift
done

# Set verbosity and other flags.
eval_flags

[ ! -z $IS_RUNNING ] && {
	if [ ! -z "$SCRIPT" ] 
	then
		if [ ! -z "`VBoxManage list runningvms | grep "$VMNAME"`" ]
		then
			printf "true\n"
		else
			printf "false\n"
		fi	

	else
		if [ ! -z "`VBoxManage list runningvms | grep "$VMNAME"`" ]
		then
			printf "$VMNAME is running.\n"
		else
			printf "$VMNAME is not running.\n"
		fi	
	fi	
}

[ ! -z $LIST ] && VBoxManage list vms

[ ! -z $FOREGROUND ] && VBoxManage startvm "$VMNAME" --type gui 

[ ! -z $BACKGROUND ] && VBoxManage startvm "$VMNAME" --type headless & 

if [ ! -z $ALIAS ]
then
   echo '...'
fi

[ ! -z $KILL ] && VBoxManage controlvm "$VMNAME" acpipowerbutton 

[ ! -z $HARDKILL ] && VBoxManage controlvm "$VMNAME" poweroff 

[ ! -z $RESTART ] && {
	VBoxManage controlvm "$VMNAME" poweroff
	VBoxManage startvm "$VMNAME" --type headless 
}

[ ! -z $SNAP ] && {
	VBoxManage snapshot "$VMNAME" \
		take $SNAPSHOT_NAME \
		--description "$SNAPSHOT_DESCRIPTION"
}
