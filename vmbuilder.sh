#!/bin/bash -
#-----------------------------------------------------#
# vmbuilder
#
# Helps build VMs.
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
#-----------------------------------------------------#

LIB="sh/vmlib.sh"
BINDIR="$(dirname "$(readlink -f $0)")"   	# The program's directory.
source "$BINDIR/$LIB"	                     # Include the library.
PROGRAM="vmbuilder"                         	# Program name.


# usage message
# Show a usage message and die.
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -cnroa ] <vmname>
	[ -bfmx -xl -bl -nl ] <N in mb>
	[ -iuvh <arg> ]

VM Creation Options:
-c | --clone <vmname>           Clone the machine <vmname>.
-n | --new <vmname>             Create a new machine called <vmname>.
-r | --remove <vmname>          Remove a machine called <vmname>.
-o | --morph <vmname>           Permanently change the settings of machine 
                                <vmname>.
-a | --morph-and-copy <vmname>  Clone the machine <vmname> and change the 
                                clone's settings.

VM Boot Parameters:
--from-disk                     Choose to boot from disk media. 
--choose-image                  Choose from a list of .iso or .img files. 
-i | --image <file>             Choose to boot from an .iso or .img file.

VM Parameter Options 
(must be used either with --morph, --morph-and-copy or --new flags): 
-b | --balloon <N>              Set balloon size of RAM for vm selected.
-f | --fs_size <N>              Set the total disk size of the vm's harddrive.
-m | --ram <N>                  Set the RAM to be used by the vm. 
-x | --cpu <N>                  Set the number of CPUs to be used by the vm.
-xl | --cpu-limit <N>           Set the limit of CPU execution for vm. 
-bl | --disk-bandwidth <N>      Set the disk i/o limit of vm. 
-nl | --nw-bandwidth <N>        Set the network i/o limit of vm. 
-os | --os-type <N>             Set type of O/S intended to deploy with.

General Options:
-u | --uuid <arg>               Select a VM by <uuid> instead of name. 
-v | --verbose                  Be verbose in output.
-h | --help                     Show this help and quit.
"
   exit $STATUS
}


# pickIso()
# Select an ISO file (b/c they can be pretty hard to spell out)
pick_iso() {
	# Generate a short menu of ISO files.
	# This will be coming from the databse
	# disk_img table
	printf "Please select the image you like to use for your new node:\n\n"
	declare -a avail_imgs=($(find -L "$ISO_DIR" -iname "*.iso")) 

	# Show a long menu.
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


# Die on no arg.
[ -z $BASH_ARGV ] && printf "Nothing to do\n" && usage 1
while [ $# -gt 0 ]
do
   case "$1" in
		# Actions
     -c|--clone)
         CLONE=true
         shift
         NAME=$1
      ;;
		-n|--new)
         NEW=true
         shift
         NAME=$1
      ;;
     -r|--remove)
         REMOVE=true
         shift
         NAME=$1
      ;;
     -o|--morph)
         MORPH=true
         shift
         NAME=$1
      ;;
     -a|--morph_and_copy)
         MORPH_AND_COPY=true
         shift
         NAME=$1
      ;;
      -u|--uuid)
         shift
         UUID_ARG=$1
      ;;

		# Parameters
		-b|--balloon)
			shift
			BALLOON=$1
		;;
     -f|--fs_size)
         shift
         FS_SIZE=$1
      ;;
     -m|--ram)
         shift
         RAM=$1
      ;;
		-x|--cpus)
			shift
			CPUS=$1
		;;
		-xl|--cpu-limit)
			shift
			CPU_EX=$1
		;;
		-bl|--disk-bandwidth)
			shift
			DISK_BW=$1
		;;
		-nl|--nw-bandwidth)
			shift
			NET_BW=$1
		;;
		-os|--os-type)
			shift
			OS_TYPE=$1
		;;

		# Boot parameters
      --choose-image)
			USE_IMAGE=true
			CHOOSE_IMAGE=true
		;;

      -i|--image)
			USE_IMAGE=true
         shift
         IMAGE=$1
      ;;

      -f|--from-disk)
			USE_IMAGE=true
         FROM_DISK=true
      ;;

		# General options.
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

# Set verbosity.
eval_flags


# Create a totally new VM.
if [ ! -z $NEW ]
then
	# Handles both defaults and user supplied.
	load_from_db_columns "settings"
	load_from_db_columns "node_defaults"

	# Is there a cleaner way to find the defualt machine folder?
	term='Default machine folder:' 
	DEFAULT_MACHINE_FOLDER=$(VBoxManage list systemproperties | \
		grep "$term" | awk '{print $4}')
		#grep "$term" | sed "s/$term//" | sed 's/          //') 


	# You'll have to catch each of these errors.
	# A name could exist here...
	[ ! -z $VERBOSE ] && "Creating machine $NAME..."
	VBoxManage createvm \
		--name "$NAME" \
		--ostype "$OS_TYPE" \
		--register

	VBoxManage modifyvm "$NAME" \
		--memory "$RAM" \
		--guestmemoryballoon "$BALLOON" \
		--cpus "$CPUS" \
		--cpuexecutioncap "$CPU_EX" \
		--acpi on \
		--boot1 dvd \
		--nic1 nat \
		--nictype1 "82543GC" \
		--nic2 hostonly \
		--nictype2 "82545EM" \
		--hostonlyadapter2 "vboxnet1"  # This will change often...

	# Set nw i/o limit
	# Not catching flags...
	if [ ! -z "$NET_BW" ] && $(( $NET_BW > 0 ))
	then
		[ ! -z $VERBOSE ] && "Setting network I/O limit on $NAME"
		VBoxManage bandwidthctl $NAME \
			add "nwlim" \
				--type network \
				--limit ${NET_BW} # megabit limit
	fi

	# Set disk i/o limit
	if [ ! -z "$DISK_BW" ] && $(( $DISK_BW > 0 ))
	then
		[ ! -z $VERBOSE ] && "Setting disk I/O limit on $NAME"
		VBoxManage bandwidthctl $NAME \
			add "hddlim" \
				--type disk \
				--limit ${DISK_BW} # megabit limit
	fi

	[ ! -z $VERBOSE ] && "Creating machine storage at $DEFAULT_MACHINE_FOLDER..."

	VBoxManage createhd \
		--filename "${DEFAULT_MACHINE_FOLDER}/${NAME}.vdi" \
		--size "$FS_SIZE"
	
	VBoxManage storagectl "$NAME" \
		--name "IDE Controller" \
		--add "ide" \
		--controller PIIX4

	VBoxManage storageattach "$NAME" \
		--storagectl "IDE Controller" \
		--port 0 \
		--device 0 \
		--type hdd \
		--medium "${DEFAULT_MACHINE_FOLDER}/${NAME}.vdi"

	# Mount boot media while creating. 
	if [ ! -z $USE_IMAGE ] 	
	then
		# Choose the first hard disk.
		if [ ! -z $FROM_DISK ] 
		then
			# Assume the first disk drive on most *nix.
			ASSUMED_MEDIUM="/dev/sr0"

			# You'll need to check and make sure this device exists.
			if [ ! -b "$ASSUMED_MEDIUM" ] 
			then 
				echo "No disk drive found at $ASSUMED_MEDIUM." 
				MEDIA=
			else
				MEDIA="host:${ASSUMED_MEDIUM}"
			fi

		# Bring up selection menu.
		elif [ ! -z $CHOOSE_IMAGE ]
		then
			# Show a nice little dialog.
			echo "Please select the image you like to use for your new node:"

			# Show a long menu.
			ISO_DIR="$HOME/vm/iso"
			declare -a AVAIL_IMGS=( $(find -L "$ISO_DIR" -iname "*.iso") ) 
			for __PCOUNT in $(seq 0 ${#AVAIL_IMGS[*]})
			do
				if [ $__PCOUNT == ${#AVAIL_IMGS[*]} ]
				then
					break
				fi	
				__AI_INDEX=$(( $__PCOUNT + 1 ))
				printf "\t${__AI_INDEX})${AVAIL_IMGS[${__PCOUNT}]}\n"
			done

			read ANS 
			__AI_USER_SEL=$(( $ANS - 1 ))

			# Should we have any reason to mount this?
			MEDIA="${AVAIL_IMGS[$__AI_USER_SEL]}"

		# Use a supplied image filename.
		else
			if [ ! -f $IMAGE ] 
			then 
				echo "The selected iso image does not seem to exist."
				echo "Did you use the correct path?"
				exit 1
			else
				MEDIA="$IMAGE"
			fi
		fi
	fi

	# Mount the drive and boot disk.
	if [ ! -z "$MEDIA" ]
	then
		[ ! -z $VERBOSE ] && "Adding external DVD drive and boot disc..."
		VBoxManage storageattach "$NAME" \
			--storagectl "IDE Controller" \
			--port 0 \
			--device 1 \
			--type dvddrive \
			--medium "$MEDIA"
	else
		# Just mount the drive.
		[ ! -z $VERBOSE ] && "Adding external DVD drive."
		VBoxManage storageattach "$NAME" \
			--storagectl "IDE Controller" \
			--port 0 \
			--device 1 \
			--type dvddrive
	fi	

	exit
fi

# Remove a VM.
if [ ! -z $REMOVE ]
then
	[ -z $NAME ] && echo "Nothing to delete!" && usage 1
	[ ! -z $VERBOSE ] && echo "Removing VM: $NAME"
	VBoxManage unregistervm $NAME --delete
fi

# Clone a single VM. 
if [ ! -z $CLONE ]
then
	echo "..."
fi


# Permanently modify a VM.
if [ ! -z $MORPH ]
then
	echo "..."
	
	if [ -z "$MORPH_ARG" ]
	then
		echo "Need something to morph!"
		usage 1
	fi

	# Long version:
	# Set clause according to what's available
	# Save to database (can be done in background)
	# If something goes seriously wrong, you can always rollback.
	# I guess you should save the old one too...
	# Modify the thing
	where "name=$MORPH_ARG"	
	modify_from_db_columns "vm_img"
fi


# Modify and make a new copy of a VM.
if [ ! -z $MORPH_AND_COPY ]
then
	echo "..."
fi

