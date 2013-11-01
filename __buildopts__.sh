#!/bin/bash -
#-----------------------------------------------------#
# buildopts.sh
#
# Will create a list based on input.
#
#
# Documentation.
# 
# Quick option for building out the options within
# a shell script.
#-----------------------------------------------------#
PROGRAM="buildopts"
DELIM=","
JOIN="="

usage() {
	STATUS=${1:-0}
	echo "
./$PROGRAM 

-f | --from <list>      Supply a list of options to create flags for.
-c | --license <type>   Add a particular license at the top of the script.
-o | --options          Generate a list of options.
-l | --logic            Generate accompanying logic.
-t | --to <file>        Make changes on <file>.
-v | --verbose          Be verbose in output.
-h | --help             Show help and quit.
"
	exit $STATUS
}

# break-list - creates an array based on some set of delimiters.
break_list_by_delim() {
	mylist=(`printf $1 | sed "s/${DELIM}/ /g"`)
	echo ${mylist[@]}		# Return the list all ghetto-style.
}

# break-maps - gives a map based on a set of delimiters.
break_maps_by_delim() {
	join="${2-=}"			# Allow for an alternate map marker.
	local m=(`printf $1 | sed "s/${join}/ /g"`)
	echo ${m[@]}			# Return the list all ghetto-style.
}

# Die if no string received.
[ -z $BASH_ARGV ] && echo "Nothing to do." && usage 1
while [ $# -gt 0 ]
do
	case "$1" in 
		-f|--from)
			shift
			FROM=$1
		;;
		-a|--according-to)
			shift
			ACC_FILE=$1
		;;
		-g|--generate)
			GENERATE=true
		;;
		-c|--clobber)
			CLOBBER=true
		;;
		-e|--license)
			SELECT_LICENSE=true
			shift
			LICENSE=$1
		;;
		-u|--usage)
			SHOW_USAGE=true
		;;
		-d|--die-on-no-arg)
			DO_DIENARG=true
		;;
		-o|--options)
			DO_OPTIONS=true
		;;
		-l|--logic)
			DO_LOGIC=true
		;;
		
		-m|--modify)
			MODIFY=true
			shift
			FILENAME=$1
		;;
		-n|--name)
			shift
			NAME_OF_SCRIPT=$1
		;;

		-t|--to)
			shift
			FILENAME=$1
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

# Need the ability to choose between action flags and logic / arugment flags.

# Generate a file.
FILENAME=${FILENAME:-'/dev/stdout'}
if [[ ! $FILENAME == '/dev/stdout' ]] && [ -f $FILENAME ] && [ ! -z $CLOBBER ]
then
	rm $RM_FLAGS $FILENAME
fi


# Choose a shell.
if [ -z $MODIFY ]
then
	( printf '#!/bin/bash -\n'
	printf '#\n'
	printf "# $NAME\n" ) >> $FILENAME
fi


# Choose licenses.
if [ ! -z $SELECT_LICENSE ]
then
	case $LICENSE in
		mit)
LICENSE_BODY='\n
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
# THE SOFTWARE.\n'
		;;

		gpl)
LICENSE_BODY="

"
		;;

	esac
	printf "$LICENSE_BODY" >> $FILENAME
fi


# Catch arguments here if we want them.
OPTS_FROM_LIST=( $( break_list_by_delim $FROM ) )
COUNTER=0
declare -a ARG_SUB_SET
for EACH_ARG in ${OPTS_FROM_LIST[@]}
do
	if [[ ${EACH_ARG:0:1} == '@' ]] 
	then 
 		ARG_SUB_SET[$COUNTER]=true 
	else
 		ARG_SUB_SET[$COUNTER]=false
	fi

	COUNTER=$(( $COUNTER + 1 ))
done	
unset COUNTER


# Move forward with setting flags.
ARG_FLAG_SET=( $(echo ${OPTS_FROM_LIST[@]} | tr [a-z] [A-Z]) )
COUNTER=0
LIM=$(( ${#OPTS_FROM_LIST[@]} - 1 ))


# Show a usage message.
if [ ! -z $SHOW_USAGE ]
then
	( printf '\n# usage message\n'
	printf '# Show a usage message and die.\n'
	printf 'usage() {\n'
	printf '   STATUS="${1:-0}"\n'
	printf '   echo "Usage: ./${PROGRAM}\n' ) >> $FILENAME

	# Logic
	for OPTCOUNT in `seq $COUNTER $LIM`
	do
		# Print formatted help with additional arguments.
		if [[ ${ARG_SUB_SET[$OPTCOUNT]} == true ]]
		then
			ARG_FLAG_NAME="${ARG_FLAG_SET[$OPTCOUNT]:1:${#ARG_FLAG_SET[$OPTCOUNT]}}"
			OPT_NAME="$( echo ${ARG_FLAG_NAME} | tr [A-Z] [a-z] )"
			printf -- \
				"$(printf -- "-${OPT_NAME:0:1}|--${OPT_NAME} <arg>                     " | \
				head -c 20)" >> $FILENAME
			printf "desc\n" >> $FILENAME

		# Print formatted help without arguments.
		else
			printf -- \
				"$(printf -- "-${OPTS_FROM_LIST[$OPTCOUNT]:0:1}|--${OPTS_FROM_LIST[$OPTCOUNT]}                      " | \
				head -c 20)" >> $FILENAME
			printf "desc\n" >> $FILENAME
		fi
	done


	( printf '\n"'
	printf '   exit $STATUS\n'
	printf '}\n\n' ) >> $FILENAME
fi


# Die on no arguments.
if [ ! -z $DO_DIENARG ]
then
	printf '\n[ -z $BASH_ARGV ] && printf "Nothing to do\\n" && usage 1\n' >> $FILENAME
fi


# If there's no list, manifest or file to read, this is pretty much useless.
if [ -z "$FROM" ] || [[ "${FROM:0:1}" == '-' ]]
then 
	echo "No list supplied!" 
	usage 1
fi


# Process all the options.
if [ ! -z $DO_OPTIONS ]
then
	# Do some basics.
	( printf 'while [ $# -gt 0 ]\ndo\n'
	printf '   case "$1" in\n' ) >> $FILENAME


	# Generate list of keywords.
	for OPTCOUNT in `seq $COUNTER $LIM`
	do
		#printf "Argument: ${ARG_SUB_SET[$OPTCOUNT]}"

		if [[ ${ARG_SUB_SET[$OPTCOUNT]} == true ]]
		then
			ARG_FLAG_NAME="${ARG_FLAG_SET[$OPTCOUNT]:1:${#ARG_FLAG_SET[$OPTCOUNT]}}"
			OPT_NAME="$( echo ${ARG_FLAG_NAME} | tr [A-Z] [a-z] )"

			# Can optionally loop these to go through whole range.
			# Also need to check if this first letter is a member of an array.
			( printf -- "     -${OPT_NAME:0:1}|"
			printf -- "--${OPT_NAME})\n"

			# Wants arg or not?
			printf "         $ARG_FLAG_NAME=true\n"
			printf "         shift\n"
			printf "         ${ARG_FLAG_NAME}_ARG=\$1\n" ) >> $FILENAME

			# Unset for the next round.
			unset ARG_FLAG_NAME
			unset OPT_NAME
		else
			( printf -- "     -${OPTS_FROM_LIST[$OPTCOUNT]:0:1}|"
			printf -- "--${OPTS_FROM_LIST[$OPTCOUNT]})\n"
			printf "         ${ARG_FLAG_SET[$OPTCOUNT]}=true\n" ) >> $FILENAME
		fi

		printf "      ;;\n" >> $FILENAME
	done	


	# End the arguments.
	( printf '      -*)\n   ' 
	printf '   printf \"Bad argument.\\n\";\n      exit 1\n   ;;\n'
	printf '      *) break;;\n'
	printf '   esac\nshift\n'	
	printf 'done\n' ) >> $FILENAME
fi


# Process all the logic.
if [ ! -z $DO_LOGIC ]
then
	# Logic
	for OPTCOUNT in `seq $COUNTER $LIM`
	do
		# ...
		if [[ ${ARG_SUB_SET[$OPTCOUNT]} == true ]]
		then
			ARG_FLAG_NAME="${ARG_FLAG_SET[$OPTCOUNT]:1:${#ARG_FLAG_SET[$OPTCOUNT]}}"
			printf "\nif [ ! -z \$${ARG_FLAG_NAME} ]\n" >> $FILENAME
		else
			printf "\nif [ ! -z \$${ARG_FLAG_SET[$OPTCOUNT]} ]\n" >> $FILENAME
		fi

		( printf "then\n"
		printf "   echo '...'\n"
		printf "fi\n" ) >> $FILENAME
	done
fi