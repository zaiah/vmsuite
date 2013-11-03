#!/bin/bash
#------------------------------------------------------
# vmlib.sh 
# 
# Library for handling mundane repetitive tasks.
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

#source "$(dirname "$(readlink -f $0)")/conf/__config.sh"
BINDIR="$(dirname "$(readlink -f $0)")"   # The program's directory.

# Giant list that will be maintanined here.
__SQLITE="/usr/bin/sqlite3"
HOST_DIR="$HOME/.vmsuite"
DB="$HOST_DIR/vm.db"


# Program directories and files.
BIN_SQL_DIR="$BINDIR/sql"
BIN_DEFAULTS_DIR="$BINDIR/defaults"


# Host directories.
HOST_ISO_DIR="$DIR/img"
HOST_VBOX_DIR="$DIR/vbox"
HOST_KEY_DIR="$DIR/keys"
HOST_FILE_DIR="$DIR/file"
HOST_INSTALL_DIRECTORY="$HOME/bin"


# Handle strings or numbers.
convert_val() {
	echo "..."
}

# Giant wrapper to handle parameters.
set_params() {
case "$1" in
esac
}


# _get_vm_by_id() 
# Retrieve a vm by ID.  Don't repeat anywhere.
get_by_id() {
	# If no parameters given, throw this back.
	echo $($__SQLITE $DB "SELECT id FROM $SUPPLIED_TABLE WHERE $PARAM = '$VALUE';")
}


# _update_vm_by_id() 
# Retrieve a vm by ID.  Don't repeat anywhere.
update_by_id() {
	# If no parameters given, throw this back.
	DB_ID=$($__SQLITE $DB "SELECT id FROM $SUPPLIED_TABLE WHERE $PARAM = '$VALUE';")
	echo $($__SQLITE $DB "SELECT id FROM $SUPPLIED_TABLE WHERE $PARAM = '$VALUE';")
}


# _remove_item_by_id() 
# Retrieve a vm by ID.  Don't repeat anywhere.
remove_by_id() {
	DB_ID=$($__SQLITE $DB "SELECT id FROM $SUPPLIED_TABLE WHERE $PARAM = '$VALUE';")
	echo $($__SQLITE $DB "DELETE FROM $SUPPLIED_TABLE WHERE $PARAM = '$VALUE';")
}


# load_parameters()
# Load every parameter as something...



# Set all flags.
eval_flags() {
if [ ! -z $VERBOSE ]
then
	MV_FLAGS="-v"
	LN_FLAGS="-sv"
	MKDIR_FLAGS="-pv"
	GZCREATE_FLAGS="czvf"
	BZ2CREATE_FLAGS="cjvf"
	UNGZ_FLAGS="xzvf"
	UNBZ2_FLAGS="xjvf"
	SCP_FLAGS="-v"
	RM_FLAGS="-rfv"
else
	MV_FLAGS=
	LN_FLAGS="-s"
	MKDIR_FLAGS="-p"
	GZCREATE_FLAGS="czf"
	BZ2CREATE_FLAGS="cjf"
	UNGZ_FLAGS="xzf"
	UNBZ2_FLAGS="xjf"
	SCP_FLAGS=
	RM_FLAGS="-rf"
fi
}


# Load something from a database according to column names.
load_from_db_columns() {
	# Die if no table name.
	TABLE="$1"

	if [ -z "$TABLE" ]
	then
		echo "No table name supplied, You've made an error in coding."
		exit 1
	else
		# Use Some namespace...
		# LFDB
		TMP="/tmp"
		TMPFILE=$TMP/__lfdb.sql
		[ -e $TMPFILE ] && rm $TMPFILE
		touch $TMPFILE

		# Choose a table and this function should: 
		# Get column titles and create variable names.
		printf ".headers ON\nSELECT * FROM ${TABLE};\n" >> $TMPFILE
		LFDB_HEADERS=( $( $__SQLITE $DB < $TMPFILE | \
			head -n 1 | \
			sed 's/id|//' | \
			tr '|' ',' ) )
		LFDB_VARS=( $( $__SQLITE $DB < $TMPFILE | \
			head -n 1 | \
			sed 's/id|//' | \
			tr '|' ' ' | \
			tr [a-z] [A-Z] ) )
		[ -e $TMPFILE ] && rm $TMPFILE

		# Get whatever settings we've asked for.
		printf "SELECT ${LFDB_HEADERS[@]} FROM ${TABLE};\n" >> $TMPFILE
		LFDB_RES=$( $__SQLITE $DB < $TMPFILE | tail -n 1 )
		[ -e $TMPFILE ] && rm $TMPFILE

		# Output a list of variables to temporary file.
		# This code needs to be introduced to our application somehow
		# eval is one choice
		# Files and source are another... (but not reliable if deleted) 
		TMPFILE=$TMP/__var.sh
		COUNTER=0
		for XX in ${LFDB_VARS[@]}
		do
			#printf "${XX:-${DEFAULT_$XX}}\n"
			( printf "DEFAULT_${XX}="
			printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
			printf "${XX}="
			printf '${'
			printf "$XX"
			printf ':-${DEFAULT_'
			printf "$XX"
			printf '}}\n' ) >> $TMPFILE
			COUNTER=$(( $COUNTER + 1 ))
		done

		# Load these within the program.
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE
	fi
}
