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
DIR="$HOME/.vmsuite"
DB="$HOME/.vmsuite/vm.db"

# Program directories.
BIN_SQL_DIR="$BINDIR/sql"

# Host directories.
HOST_ISO_DIR="$DIR/img"
HOST_VBOX_DIR="$DIR/vbox"
HOST_KEY_DIR="$DIR/keys"
HOST_FILE_DIR="$DIR/file"

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
get_vm_by_id() {
	# If no parameters given, throw this back.
	echo $($__SQLITE $DB "SELECT id FROM $SUPPLIED_TABLE WHERE $PARAM = '$VALUE';")
}


# _update_vm_by_id() 
# Retrieve a vm by ID.  Don't repeat anywhere.
update_vm_by_id() {
	echo "..."
}


# _remove_item_by_id() 
# Retrieve a vm by ID.  Don't repeat anywhere.
remove_item_by_id() {
	echo "..."
}


# Set all flags.
if [ ! -z $VERBOSE ]
then
	MV_FLAGS="-v"
	LN_FLAGS="-v"
	MKDIR_FLAGS="-pv"
	GZCREATE_FLAGS="czvf"
	BZ2CREATE_FLAGS="cjvf"
	UNGZ_FLAGS="xzvf"
	UNBZ2_FLAGS="xjvf"
	SCP_FLAGS="-v"
	RM_FLAGS="-rfv"
else
	MV_FLAGS=
	LN_FLAGS=
	MKDIR_FLAGS="-p"
	GZCREATE_FLAGS="czf"
	BZ2CREATE_FLAGS="cjf"
	UNGZ_FLAGS="xzf"
	UNBZ2_FLAGS="xjf"
	SCP_FLAGS=
	RM_FLAGS="-rf"
fi


