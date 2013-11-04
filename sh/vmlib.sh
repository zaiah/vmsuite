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


# Typechecking.
typecheck() {
	# Is this null?
	if [ -z $1 ]
	then
		printf "null"

	# Is this an integer?
	else
		# Send error nowhere.
		STAT=$(echo $(( $1 )) 2>/dev/null | echo $? )

		# Still should probably catch strings.
		if [ ! $STAT == 0 ]
		then
			printf "string"
		else
			# Is string 
			printf "integer"
		fi
	fi
}


# Handle strings or numbers.
convert() {
	# Is this null?
	if [ -z $1 ]
	then
		printf "''"

	# Is this an integer?
	else
		# Send error nowhere.
		STAT=$(echo $(( $1 )) 2>/dev/null | echo $? )

		# Still should probably catch strings.
		if [ ! $STAT == 0 ]
		then
			printf "'$1'"
		else
			# Is string 
			printf $1 
		fi
	fi
}


# crazy string shit...
function join() {
	local IFS="$1"
	shift
	echo "$*"
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



#------------------------------------------------------
# eval_flags 
# 
# Set all flags.
#-----------------------------------------------------#
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


#------------------------------------------------------
# load_from_db_columns 
# 
# Load something from a database according to column names.
#-----------------------------------------------------#
load_from_db_columns() {
	# Die if no table name.
	TABLE="$1"

	if [ -z "$TABLE" ]
	then
		echo "In function: load_from_db_columns()"
		echo "\tNo table name supplied, You've made an error in coding."
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

		# It may be more intelligent to go line by line for this...
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
			( printf "DEFAULT_${XX}='"
			echo $LFDB_RES | \
				awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
				sed "s/$/'/"
			printf "${XX}="
			printf '${'
			printf "$XX"
			printf ':-${DEFAULT_'
			printf "$XX"
			printf '}}\n' ) >> $TMPFILE
			COUNTER=$(( $COUNTER + 1 ))
		done

		# Load these within the program.
		#cat $TMPFILE
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE
	fi
}



#------------------------------------------------------
# modify_from_db_columns() {
# 
# Write values from scripts to database.
#-----------------------------------------------------#
modify_from_db_columns() {
	# Die if no table name.
	TABLE="$1"
	if [ -z "$TABLE" ]
	then
		echo "In function: load_from_db_columns()"
		echo "\tNo table name supplied, You've made an error in coding."
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
			tr '|' ',' ) )

		LFDB_VARS=( $( $__SQLITE $DB < $TMPFILE | \
			head -n 1 | \
			tr '|' ' ' | \
			tr [a-z] [A-Z] ) )

		LFDB_ID=$( $__SQLITE $DB < $TMPFILE | \
			tail -n 1 | \
			awk -F '|' '{ print $1 }')

		[ -e $TMPFILE ] && rm $TMPFILE


		# Get all items.
		printf "SELECT ${LFDB_HEADERS[@]} FROM ${TABLE};\n" >> $TMPFILE
		LFDB_RES=$( $__SQLITE $DB < $TMPFILE | tail -n 1 )
		[ -e $TMPFILE ] && rm $TMPFILE


		# Need a few traps to get rid of these files if things go wrong.


		# Output database values as variables within temporary file.
		TMPFILE=$TMP/__dbvar.sh
		COUNTER=0
		for XX in ${LFDB_VARS[@]}
		do
			if [[ ! $XX == 'ID' ]]
			then
				# Needs some basic string / number checking
				( printf "${XX}='"
				echo $LFDB_RES | \
					awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
					sed "s/$/'/"
				#printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
				) >> $TMPFILE
			fi
			COUNTER=$(( $COUNTER + 1 ))
		done


		# Load these within the program.
		MODIFY=true
		[ ! -z $MODIFY ] && $EDITOR $TMPFILE
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE


		# Check through the list and see what's changed.
		# Output database values as variables within temporary file.
		TMPFILE=$TMP/__cmp.sh
		COUNTER=0
		for XX in ${LFDB_VARS[@]}
		do
			if [[ ! $XX == 'ID' ]]
			then
				# Needs some basic string / number checking
				( printf "ORIG_${XX}='"
				echo $LFDB_RES | \
					awk -F '|' "{ print \$$(( $COUNTER + 1 )) }" | \
					sed "s/$/'/"
				#printf $LFDB_RES | awk -F '|' "{ print \$$(( $COUNTER + 1 )) }"
				) >> $TMPFILE
			fi
			COUNTER=$(( $COUNTER + 1 ))
		done
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE


		# Load stuff.
		TMPFILE=$TMP/__load.sh
		COUNTER=0
		printf "SQL_LOADSTRING=\"UPDATE $TABLE SET " >> $TMPFILE
		for XX in ${LFDB_VARS[@]}
		do
			if [[ ! $XX == 'ID' ]]
			then
				# Variables...
				USER="${!XX}"
				VAR_NAME="ORIG_$XX"
				ORIG="${!VAR_NAME}"
				COLUMN_NAME="$(echo ${XX} | tr [A-Z] [a-z])"

				# Check values and make sure they haven't changed.
				FV=
				if [[ "$USER" == "$ORIG" ]]
				then
					FV=$ORIG
				else
					FV=$USER
				fi

				# Evaluate with that neat little typechecking function.
				VAR_TYPE=$(typecheck $USER)
				printf "$COLUMN_NAME = "  >> $TMPFILE
				[[ $VAR_TYPE == "null" ]] && printf "''" >> $TMPFILE
				[[ $VAR_TYPE == "string" ]] && printf "'$FV'" >> $TMPFILE
				[[ $VAR_TYPE == "integer" ]] && printf "$FV" >> $TMPFILE

				# Wrap final clause in the statement.
				if [ $COUNTER == $(( ${#LFDB_VARS[@]} - 1 )) ] 
				then
					( printf '\n' 
					printf "WHERE id = $LFDB_ID;\"\n" ) >> $TMPFILE
				else
					printf ',\n' >> $TMPFILE
				fi	
			fi
			COUNTER=$(( $COUNTER + 1 ))
		done
		unset COUNTER

		# Load the new stuff.
		source $TMPFILE
		[ -e $TMPFILE ] && rm $TMPFILE
		
		# Only write if they've changed?
		# (You'll need the id of whatever is being modified as well...)

		# Do the write.
		#echo $SQL_LOADSTRING
		$__SQLITE $DB "$SQL_LOADSTRING"

		#vi -O $TMP/__{cmp,dbvar}.sh
		# Write stuff to database 
		[ -e $TMPFILE ] && rm $TMPFILE
	fi
}


