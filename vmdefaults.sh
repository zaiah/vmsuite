#!/bin/bash -
#-----------------------------------------------------#
# vmdefaults.sh 
#
# Set all the defaults for different elements of nodes.
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
PROGRAM="vmdefault"                        	# Program name.

# usage message
# Show a usage message and die.
usage() {
   STATUS="${1:-0}"
   echo "Usage: ./${PROGRAM}
	[ -  ]

-l | --list              List settings and whatnot.
-n | --nics              Edit the default nics profile. 
-o | --node              Edit the default node settings. 
-s | --settings          Edit the defautl vmsuite program settings 

--load                   Load settings. 
-v|--verbose             Be verbose in output.
-h|--help                Show this help and quit.
"
   exit $STATUS
}

[ -z $BASH_ARGV ] && printf "Nothing to do\n" && usage 1
while [ $# -gt 0 ]
do
   case "$1" in
     -l|--list)
		  DISPLAY_DEFAULTS=true
		  ;;
     -n|--nics)
		  	EDIT=true
         EDIT_TABLE="nics"
      ;;
     -o|--node)
		  	EDIT=true
         EDIT_TABLE="node_defaults"
      ;;
     -s|--settings)
		  	EDIT=true
         EDIT_TABLE="settings"
      ;;
     --load)
         LOAD=true
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


# Edit some stuff.
if [ ! -z $EDIT ]
then
	# Why would this fail?
	# [ ! -f $DEFAULTS ] && echo "No defaults file!" && exit 1
	#PRIMARY_EDITOR="$("SELECT editor FROM settings WHERE user_owner = '$USER';")"

	# Evaluate what's thrown...
	load_from_db_columns "settings"

#	exit
	modify_from_db_columns $EDIT_TABLE 
fi


# Display all defaults.
if [ ! -z $DISPLAY_DEFAULTS ]
then

	# Load from db, places settings into namespace
	# Write to db, write all of our changes to DB.
	# 	(From file)
	# Write one or two back.
	#  (From varlist)

	# To writeback
	# Can't use array....
	# ...

	# Geez... this is a bit silly...
	ALL_DEFAULTS=( "nics" "node_defaults" "settings" )
	for DEF_FILE in ${ALL_DEFAULTS[@]}
	do
		echo "$DEF_FILE:"
		$__SQLITE -line $DB "SELECT * FROM $DEF_FILE"
		printf '\n'
	done
fi


# Load all at once.
# Move to lib...
if [ ! -z $LOAD ]
then
	ALL_DEFAULTS=( $(ls $BIN_DEFAULTS_DIR) )
	for DEF_FILE in ${ALL_DEFAULTS[@]}
	do
		[ ! -z $VERBOSE ] && echo "Loading $DEF_FILE..."
		$__SQLITE $DB < $BIN_DEFAULTS_DIR/$DEF_FILE
		echo $__SQLITE $DB $BIN_DEFAULTS_DIR/$DEF_FILE
	done
fi
