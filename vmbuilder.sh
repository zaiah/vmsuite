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
-m | --morph_and_copy <arg>     desc
--from_disk <arg>               desc
-n | --name <arg>               desc
-u | --uuid <arg>               desc
-i | --image <arg>              desc

VM Parameter Options: 
-i | --ip_address <arg>         desc
-d | --domain <arg>             desc
-f | --fs_size <arg>            desc
-r | --ram <arg>                desc

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
		--edit-defaults)
			EDIT_DEFAULTS=true
		;;
     -i|--ip_address)
         IP_ADDRESS=true
         shift
         IP_ADDRESS_ARG=$1
      ;;
     -c|--clone)
         CLONE=true
         shift
         CLONE_ARG=$1
      ;;
     -d|--domain)
         DOMAIN=true
         shift
         DOMAIN_ARG=$1
      ;;
     -f|--fs_size)
         FS_SIZE=true
         shift
         FS_SIZE_ARG=$1
      ;;
     -i|--image)
         IMAGE=true
         shift
         IMAGE_ARG=$1
      ;;
     -r|--ram)
         RAM=true
         shift
         RAM_ARG=$1
      ;;
     -n|--new)
         NEW=true
         shift
         NEW_ARG=$1
      ;;
     -r|--remove)
         REMOVE=true
         shift
         REMOVE_ARG=$1
      ;;
     -m|--morph)
         MORPH=true
         shift
         MORPH_ARG=$1
      ;;
     -m|--morph_and_copy)
         MORPH_AND_COPY=true
         shift
         MORPH_AND_COPY_ARG=$1
      ;;
     -n|--name)
         NAME=true
         shift
         NAME_ARG=$1
      ;;
     -u|--uuid)
         UUID=true
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

# Edit the defaults and write them back into the database.
if [ ! -z $EDIT_DEFAULTS ]
then
	# Why would this fail?
	[ ! -f $DEFAULTS ] && echo "No defaults file!" && exit 1

	# Get all the default records.
	# Let's design something to where we don't 
	# need to worry about columns names.
	# $__SQLITE $DB "SELECT * FROM defaults" 

	
	# Output to a temporary file to edit.
#RAM=$RAM
#BALLOON=$BALLOON
#FS_SIZE=$FS_SIZE
#OS_TYPE=$OS_TYPE
#NIC_COUNT=$NIC_COUNT
#NIC_1=$NIC_1
#NIC_2=$NIC_2

#echo $RAM
#echo $BALLOON
#echo $FS_SIZE
#echo $OS_TYPE
#echo $NIC_COUNT
#echo $NIC_1
#echo $NIC_2

	# Load the new changes.
	source $DEFAULTS
	$__SQLITE $DB "INSERT INTO defaults VALUES (
		null,
		$RAM,
		$FS_SIZE,
		'$OS_TYPE',
		'$NIC_PROF'
	);"
fi

# Create a totally new VM.
if [ ! -z $NEW ]
then
	echo "..."
fi

# Remove a VM.
if [ ! -z $REMOVE ]
then
	echo "..."
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
fi


# Modify and make a new copy of a VM.
if [ ! -z $MORPH_AND_COPY ]
then
	echo "..."
fi

