#!/bin/bash -
#------------------------------------------------------
# vmgo.sh 
# 
# Deploy vmsuite for the first time.
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

LIB="vmlib.sh"
source "$(dirname "$(readlink -f $0)")/$LIB"	# Include the library.
PROGRAM="vmgo"                            	# Program name.
BINDIR="$(dirname "$(readlink -f $0)")"   	# The program's directory.


# usage message
# Show a usage message and die.
usage() {
	STATUS="${1:-0}"
	echo "Usage: ./${PROGRAM}

--first-run               Build databases and prepare client system.
--rebuild                 Rebuild databases for new versions.
--no-server-setup         Skip the whole server setup step.
--update                  Update virtualbox.
"
	exit $STATUS
}


# create_databases_and_tables 
# 	Create or recreate $PROGRAM's internal database.	
create_databases_and_tables () {
}



# Die if no options received.
[ -z $BASH_ARGV ] && echo "Nothing to do." && usage 1
while [ $# -gt 0 ]
do
	case "$1" in 
		--set-host-directory)
		shift
		HOST_DIRECTORY=$1
		;;
		--first-run)
		FIRST_RUN=true
		;;
		--rebuild)
		REBUILD=true
		;;
		--install)
		INSTALL=true
		;;
		--at|--set-install-directory)
		shift
		INSTALL_DIRECTORY=$1
		;;
		--no-server-setup)
		SKIP_SERVER=true
		;;
		-v|--verbose)
		usage 0
		;;
		-h|--help)
		usage 0
		;;
		-*)
		;;
		*)
		;;
	esac
shift
done


# Do the first run.
if [ ! -z $FIRST_RUN ]
then
  # Set directory.
  [ ! -z "$HOST_DIRECTORY" ] && DIR="$HOST_DIRECTORY" 

  # Do filesystem purtyness.
  mkdir $MKDIR_FLAGS $DIR/{img,file,vbox,keys}
  mkdir $MKDIR_FLAGS $DIR/vbox/{src,bin}

	# Create the database tables.
  # Useful to break up single files..
	# cat vm.sql | grep CREATE | sed 's/CREATE TABLE //' | sed 's/ (//'
  if [ ! -f $DB ] 
  then
		declare -a TABLES 
		TABLES=( $( ls $BIN_SQL_DIR ) )
		for __SQL__  in ${TABLES[@]}
		do 
			[ ! -z $VERBOSE ] && echo "Creating table: ${SSQL_FILE%%.sql}"
			[ -e "$__SQL__" ] && $__SQLITE $DB < $__SQL__
		done
	fi

	# Set up some server for syncing your vms to.
	if [ -z $SKIP_SERVER ]
	then
		echo "Syncing to server..."
	fi
fi 



# Do the install.
if [ ! -z $INSTALL ]
then
	# Create folder.
	[ ! -d "$INSTALL_DIRECTORY" ] && mkdir $MKDIR_FLAGS $INSTALL_DIRECTORY

	# Link
	SUITE_LIST=( $(ls $BINDIR/*.sh) )
	for PFILE in ${SUITE_LIST[@]}
	do
		echo ln $LNFLAGS "${PFILE}" "${INSTALL_DIR}/$(basename ${PFILE%%.sh})"
	done

	# Write a record of these for later removal.
fi



# Rebuild the databases.
if [ ! -z $REBUILD ]
then
	# Arrays and fun.
	declare -a SSQL_TABLES

	# Make a backup copy.
	DB_BACKUP="$(dirname $DB)/.db.bak"
	cp $CPFLAGS $DB $DB_BACKUP

	# Create temporaries of whatever's in there now.
	SSQL_TABLES=( $($__SQLITE $DB ".tables") )
	for SSQL_TABLE in ${SSQL_TABLES[@]}
	do
		# First, see if there are even records to convert.
		SQL_RECORD_DUMP=$( $__SQLITE $DB "SELECT * FROM ${SSQL_TABLE} LIMIT 1" ) 

		# Die if not.
		if [ -z $SQL_RECORD_DUMP ] 
		then
			printf "Nothing to convert from table: $SSQL_TABLE.\n"
			continue	
	
		# Move forward if so.		
		else
			printf "\nTransferring old data from table: $SSQL_TABLE.\n"
		fi

		# Will need to use a temporary file to do this because of the way
		# transactions work.
		TMP="/tmp"
		TMPFILE=$TMP/__${PROGRAM}.sql
		SQL_LOADFILE="$BINDIR/sql/${SSQL_TABLE}.sql"
		[ -e $TMPFILE ] && rm $TMPFILE
		touch $TMPFILE

		# I need the headers from my old tables.
		# printf "BEGIN TRANSACTION;" > $TMPFILE
		printf ".headers ON\nSELECT * FROM ${SSQL_TABLE};\n" >> $TMPFILE
		SSQL_HEADERS=$($__SQLITE $DB < $TMPFILE | head -n 1 | sed 's/id|//' | tr '|' ',')
		#echo $SSQL_HEADERS

		# Remove this file.
		[ -e $TMPFILE ] && rm $TMPFILE

		# Add temporary. 
		printf "CREATE TEMP TABLE 
		tmp_${SSQL_TABLE}( $SSQL_HEADERS );\n" >> $TMPFILE 

#		echo "CREATE TEMP TABLE tmp_${SSQL_TABLE}( $SSQL_HEADERS );"
	
		# Load everything that's currently loaded.	
		printf "INSERT INTO tmp_${SSQL_TABLE} ( 
		$SSQL_HEADERS ) SELECT $SSQL_HEADERS FROM $SSQL_TABLE;\n" >> $TMPFILE 

#		echo "INSERT INTO tmp_${SSQL_TABLE} ( $SSQL_HEADERS ) SELECT $SSQL_HEADERS FROM $SSQL_TABLE;" 

		# Use the option to bail if something went wrong...
		# (Such as if we dropped a column...)

		# Drop the old table.
		printf "DROP TABLE ${SSQL_TABLE};\n" >> $TMPFILE

		# Load the new tables here.
		if [ -e "$SQL_LOADFILE" ]
		then
			printf ".read ${SQL_LOADFILE}\n" >> $TMPFILE
		else
			printf "This version of the cli needs to be updated."
			printf "kirk is missing crucial files to recreate its databases."
			exit 1
		fi	
	
		# Insert the old records.
		printf "INSERT INTO ${SSQL_TABLE} ( 
		$SSQL_HEADERS ) SELECT $SSQL_HEADERS FROM tmp_${SSQL_TABLE};\n" >> $TMPFILE 
	
		# Debug	
		printf "SELECT * FROM ${SSQL_TABLE} ORDER BY id DESC LIMIT 1;\n" >> $TMPFILE 

		# Run
		RECORDS_AFF=$($__SQLITE $DB < $TMPFILE | tail -n 1 | awk -F '|' '{print $1}')
		printf "$RECORDS_AFF records modified and converted in table: ${SSQL_TABLE}.\n\n"
	done

	# Load anything new. 
	declare -a SQL_MAKE
	SQL_MAKE=( $(ls $BINDIR/files/sql) )
	SQL_FILEPATH=$BINDIR/files/sql

	for SSQL_FILE in ${SQL_MAKE[@]}
	do
		# Test if the table is present in the database.
		for SSQL_TABLE_NAME in ${SSQL_TABLES[@]}
		do
			if [[ ${SSQL_FILE%%.sql} == $SSQL_TABLE_NAME ]]
			then
				IS_IN_DB=true
				break
			fi	
		done	

		# Load what remains to be loaded.
		if [ ! $IS_IN_DB ]
		then	
			SQL_FILENAME=$SQL_FILEPATH/$SSQL_FILE
			echo "Adding new table: ${SSQL_FILE%%.sql}"
	#		[ -e "$SQL_FILEPATH" ] && echo "$SSQL_FILE exists"
			[ -e "$SQL_FILENAME" ] && $__SQLITE $DB < $SQL_FILENAME
		fi

		# Get rid of backup.
		#[ -f "$DB_BACKUP" ] && rm $RMFLAGS $DB_BACKUP


		# Reset.
		unset IS_IN_DB
	done
fi

