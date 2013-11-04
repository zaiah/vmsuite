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
	[ -  ]

VM Creation Options:
-c | --clone <arg>              desc
-n | --new <arg>                desc
-r | --remove <arg>             desc
-m | --morph <arg>              desc
-a | --morph_and_copy <arg>     desc
--from_disk <arg>               desc
-u | --uuid <arg>               desc
-i | --image <arg>              desc

VM Parameter Options: 
-p | --ip_address <arg>         desc
-d | --domain <arg>             desc
-f | --fs_size <arg>            desc
-x | --ram <arg>                desc

General Options:
--edit-defaults                 Edit the defaults that ship with vmsuite.
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
     -p|--ip_address)
         shift
         IP_ADDRESS_ARG=$1
      ;;
     -c|--clone)
         CLONE=true
         shift
         NAME=$1
      ;;
     -d|--domain)
         shift
         DOMAIN=$1
      ;;
     -f|--fs_size)
         shift
         FS_SIZE=$1
      ;;
     -i|--image)
         shift
         IMAGE=$1
      ;;
     -x|--ram)
         shift
         RAM=$1
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
     -m|--morph)
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
     -f|--from_disk)
         FROM_DISK=true
         shift
         FROM_DISK_ARG=$1
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
		--acpi on \
		--boot1 dvd \
		--nic1 nat \
		--nictype1 "82543GC" \
		--nic2 hostonly \
		--nictype2 "82545EM" \
		--hostonlyadapter2 "vboxnet1"  # This will change often...

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

	# Use the CD drive.
	if [ ! -z $MEDIUM ] 	
	then
		# Do some detection.
		MEDIA="host:/dev/sr0"
	else
		MEDIA="$IMAGE"
	fi	

#read
	[ ! -z $VERBOSE ] && "Adding external media and boot disc..."
	VBoxManage storageattach "$NAME" \
		--storagectl "IDE Controller" \
		--port 0 \
		--device 1 \
		--type dvddrive \
		--medium "$MEDIA"
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

