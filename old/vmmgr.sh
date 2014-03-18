#!/bin/bash -
#===============================================================================
#
#          FILE:  vmmgr.sh
# 
#         USAGE:  ./vmmgr.sh 
# 
#   DESCRIPTION:  Carries out common commands.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR: Antonio Ramar Collins II (), zaiah.dj@gmail.com, ramar.collins@gmail.com
#       COMPANY: Vokay Ent. (vokayent@gmail.com)
#       CREATED: 04/04/2012 07:22:14 AM EDT
#      REVISION:  ---
#===============================================================================

#===============================================================================
# FUNCTIONS 
#===============================================================================
#set -o nounset                              # Treat unset variables as an error

usage() {
STATUS=${1-0}
printf "
Usage: ./vmmgr [ -bfkprsh ]

-l\tLists all VMs.
-f\tStarts a new process in the foreground.
-p\tStarts a new (set of) VM(s) according to a profile.
-b\tStarts a new instance of a VM.
-k\tStop an instance of a VM.
-r\tRestart an instance of a VM.
-s\tTake a snapshot of a VM.
-h\tShow this help message and quit.

"
exit $STATUS
}

# startVM - start a VM
startVM() {
	if [ ! -z $START_IN_FOREGROUND ]
	then
		VBoxManage startvm "$VMNAME" --type gui 
	elif [ ! -z $PROFILE_NAME ] || [ ! -z $START ]
	then
		VBoxManage startvm "$VMNAME" --type headless & # Send to background?
		# Save PID
	fi
}

# stopVM	- Stop a VM
stopVM() {
	echo "Stopping virtual machine: \"$VMNAME\""
	
	case "$STOPTYPE" in
		soft) # Soft Stop
		VBoxManage controlvm "$VMNAME" acpipowerbutton 
		;;
		hard) # Hard Stop
		VBoxManage controlvm "$VMNAME" poweroff
		;;
	esac
}

# restartVM - Hard restart a VM.
restartVM() {
	# If you write to a database, status management will be pretty simple.
	# PID is a better option though...
	# 1) Send soft SIGHUP to PID of VirtualBox process.
	# 2) Hard stop with VBoxManage and bring it back. 
	VBoxManage controlvm "$VMNAME" poweroff
	VBoxManage startvm "$VMNAME" --type headless 
}

# snapVM 	- Take a snapshot of some VM.
snapVM() {
	VBoxManage snapshot "$VMNAME" \
		take $SNAPSHOT_NAME \
		--description "$SNAPSHOT_DESCRIPTION"
}

#===============================================================================
# OPTIONS
#===============================================================================

# Rewrite this?
IFS=' 
'
VMNAME=$BASH_ARGV
if [ -z "$VMNAME" ]
then
	usage 1
fi

# Gotta catch our last argument.
case "$BASH_ARGV" in 
	-h | --help) usage 0;;
	-l | --list) 
		VBoxManage list vms
		;;
esac

# Then go for the options 
while [ $(( $# - 1 )) -gt 0 ]
do
	case "$1" in
		-f | --foreground) 
			START_IN_FOREGROUND=true
			action="start"
			;;
		-p | --with-profile) 
			shift
			PROFILE_NAME="$1"
			;;
		-b | --start) 
			START=true
			action="start"
			;;
		-k | --stop) 
			STOP=true
			shift
			STOPTYPE="$1"
			if [ $STOPTYPE != 'hard' ] && 
				[ $STOPTYPE != 'soft' ]
			then
				STOPTYPE="hard"
			fi
			action="stop"
			;;
		-r | --restart) 
			RESTART=true
			action="restart"
			;;
		-s | --snap) 
			shift
			SNAPSHOT_NAME="$1"
			action="snap"
			;;
		-h | --help) 
		   usage 0	
			;;
		-*) 
			# error - Write this...
			echo "Error: Unrecognized option $1"
		   usage 1	
			;;
		*) 
			break
			;;
	esac
	shift
done		

case "$action" in
	start) 	startVM
	;;	
	stop) 	stopVM
	;;
	restart) restartVM
	;;	
	snap) 	snapVM
	;;	
esac
