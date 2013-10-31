#!/bin/bash -
#======================================
# FILE:  vmbuilder.sh 
# USAGE:  ./vmmgr.sh 
# 
# DESCRIPTION:  
# Sets up miniature 
# Linuxes using VirtualBox.
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
# AUTHOR: 
# Antonio Ramar Collins II (), 
# zaiah.dj@gmail.com, 
# ramar.collins@gmail.com
#
# COMPANY: Vokay Ent. (vokayent@gmail.com)
# CREATED: 04/04/2012 07:22:14 AM EDT
# REVISION:  ---
#======================================


# how do we run the install process...

#======================================
# usage message.
#======================================
usage() {
	STATUS="${1-0}"
	MSG="$2"
	[ ! -z "$MSG" ] && echo $MSG
	echo "Usage:
./vmbuilder [ -acdimnsr ] <arg>
            [ --help ]

-a | --ip-address <N>     Define an IP address for the new node.
-c | --clone <name>       Define a new name for the clone.
-d | --domain <domain>    Define an actual domain name for the new node.
-f | --fs-size <N in mb>  Define the size of the node's filesystem.
-i | --image <img>        Build from specified image.
-m | --ram <N in mb>      Create a new node with specified name.
-n | --new <VM_NAME>       Create a new node with specified name.
-s | --ssh-key <key>      Import an SSH key for use with the node.
-r | --remove <VM_NAME>    Get rid of a particular VM.

-u | --username <name>    Create a user for the node with specified username.
--from-disk               Use the files from the CD versus an iso file.
-h | --help               Display a short help and exit. 
"
	exit $STATUS
}


# _pickIso()
# Select an ISO file (b/c they can be pretty hard to spell out)
_pickIso() {
	# Generate a short menu of ISO files.
	printf "Please select the image you like to use for your new node:\n\n"
	declare -a avail_imgs=($(find -L "$ISO_DIR" -iname "*.iso")) 

	for pcount in $(seq 0 ${#avail_imgs[*]})
	do
		if [ $pcount == ${#avail_imgs[*]} ]
		then
			break
		fi	
		index=$(( $pcount + 1 ))
		printf "\t${index})${avail_imgs[${pcount}]}\n"
	done

	read ans
	n=$(( $ans - 1 ))

	# Should we have any reason to mount this?
	iso=${avail_imgs[$n]}
}


# set () - Sets all parameters for the builder.
_set() {
	source $VM_CONFIG
	
	# Stop if no vm name.
	if [ -z $VM_NAME ]
	then
		printf "No Node specified!"
		printf "Node names will always be the last argument to this command."
		printf "Example:\n\n\tvmbuilder -i debian-3.6.9.iso devil\n"
		printf "Will create a Debian-based node called 'devil'\n"
		usage 1
	fi

	# Pick an iso if the user didn't pick.
	iso=${iso-""}
	if [ -z $iso ] && [ ! -z $MEDIUM ]
	then
		iso="none"
	elif [ -z $iso ] && [ -z $MEDIUM ] 
	then
		_pickIso
	fi

	# Source names
	RAM=${RAM-$RAM_DEFAULT}
	OS_TYPE=${OS_TYPE-$OS_TYPE_DEFAULT}
	NICS=${NICS-$NICS_DEFAULT}
	NIC_TYPES=${NIC_TYPES-$NIC_TYPES_DEFAULT}
	HDD=${HDD-$HDD_DEFAULT}				
	HDD_TYPE=${HDD_TYPE-$HDD_TYPE_DEFAULT}

printf "
VM\t=\t $VM_NAME
ISO\t=\t$iso
RAM\t=\t$RAM
OS\t=\t$OS_TYPE
NICS\t=\t$NICS
NICTYPE =\t$NIC_TYPES
HDD\t=$HDD
HDDTYPE =\t$HDD_TYPE" > $HOME/.vmmgr/profiles/${VM_NAME}.sh
}


# Opens the VM Profile in your chosen editor.
edit() {
	$__EDITOR $VM_PROFILE
}



# Clone a VM.
clone() {
	[ -z "$VM_NAME" ] || [ -z "$CLONE_NAME" ] && usage 1 "You must \
		specify a virtual machine to clone."
	VBoxManage clonevm $VM_NAME --name $CLONE_NAME --register
}


# Remove a VM.
remove() {
	[ -z "$VM_NAME" ] && usage 1 "You must specify \
		a virtual machine to get rid of."
	VBoxManage unregistervm $VM_NAME --delete
}


# Makes a new VM according to a few different options.
new() {
	# Is there a cleaner way to find the defualt machine folder?
	term='Default machine folder:' 
	isovault=$(VBoxManage list systemproperties | \
		grep "$term" | sed "s/$term//") 

	# You'll have to catch each of these errors.
	VBoxManage createvm \
		--name "$VM_NAME" \
		--register

	VBoxManage modifyvm "$VM_NAME" \
		--memory "$RAM" \
		--acpi on \
		--boot1 dvd \
		--nic1 nat \
		--nic2 hostonly 		# nics...

	VBoxManage createhd \
		--filename "${isovault}/${VM_NAME}.vdi" \
		--size "$HDD"

	VBoxManage storagectl "$VM_NAME" \
		--name "IDE Controller" \
		--add "$HDD_TYPE" \
		--controller PIIX4

	VBoxManage storageattach "$VM_NAME" \
		--storagectl "IDE Controller" \
		--port 0 \
		--device 0 \
		--type hdd \
		--medium "${isovault}/${VM_NAME}.vdi"

	# Use the CD drive.
	if [ ! -z $MEDIUM ] 	
	then
		# Do some detection.
		media="host:/dev/sr0"
	else
		media="$iso"
	fi	

	VBoxManage storageattach "$VM_NAME" \
		--storagectl "IDE Controller" \
		--port 0 \
		--device 0 \
		--type dvddrive \
		--medium "$media"
}


# Variables
#VM_NAME=$BASH_ARGV
VM_CONFIG="$HOME/.vmmgr/_vmdefaults.sh"
MEDIUM=

# Options.
[ -z "$BASH_ARGV" ] && usage 1 "Nothing to do."
while [ $# -gt 0 ]
do
	case "$1" in
		# Define an IP address.
		-a | --ip-address)
			shift
			ipaddress="$1"
			;;			

		# Do some cloning magic.
		-c | --clone)
			action="clone"
			shift
			CLONE_NAME="$1"
			;;			
		
		# Set up a domain name.
		-d | --domain)
			shift
			domain="$1"
			;;

		# Pick an image.
		-i | --image)
			shift
			iso="$1"
			[[ "$iso" == $BASH_ARGV ]] && unset iso && break
			;;			# Get an image.
		-f | --fs-size)
			shift
			fssize="$1"
			;;			# Define the size of the box.
		-m | --ram)
			shift
			RAM="$1"
			;;			# Allocate x ram.
		--from-disk)			
			MEDIUM=true
			;;			# Use the disk drive.
		-u | --username)
			shift 
			username="$1"
			;; 		# Use this username when connecting to box.
		-s | --ssh-key)
			shift 
			sshkey="$1"
			;;			# Use this key with this box.

		# Create a new VM.
		-n | --new)
			action="new"
			shift
			VM_NAME="$1"
		;;			

		# Remove a box from records and stuff.
		-r | --remove)
			action="remove"
			shift
			VM_NAME="$1"
			;;	
	
		# Select a VM_name
		-t | --from-this-vm)
			shift
			VM_NAME="$1"
			;;
	
		# Regenerate the aliases.
		-g | --regenerate)
			action="regenerate"
			;;	

		# Help messages.
		-h | --help) 
			usage 0
			;;

		-*) echo "$1 - Not an option." 
			usage 1
			;;
		*) break
			;;
	esac
	shift 
done

_d=$(dirname $(readlink -f $0))


# Set all required options.
# Check that virtualbox exists...

# Eval
action=${action-""}
[ ! -z "$action" ] && \
	case "$action" in
		new) _set; new;;
		usage) usage;;
		remove) remove;;
		clone) clone;;
	esac
