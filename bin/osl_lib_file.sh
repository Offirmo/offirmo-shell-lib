#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - file manipulation uitilities
##
## This file is meant to be sourced :
##    source osl_lib_file.sh

source osl_lib_output.sh
source osl_lib_debug.sh



# Ensure that a line exists
OSL_FILE_ensure_line_is_present_in_file()
{
	typeset var line="$1"
	typeset var file="$(OSL_FILE_realpath $2)"

	OSL_debug "* ensuring that line \"$line\" is present in file \"$file\""

	if ! [[ -f "$file" ]]; then
		OSL_OUTPUT_display_error_message "file \"$file\" not found !"
		return 1
	fi

	# REM : --fixed-strings : Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
	typeset var test=`grep --count --fixed-strings --line-regexp "$line" "$file"`

	if [[ $test -ne 0 ]]; then
		# the line is already in the file
		OSL_debug "  -> Already set."

		do_nothing=1
	else
		# the line is not in the file, add it
		OSL_debug "  -> Not set, adding it..."

		# 1) add it to the temp file
		echo "$line" >> "$file"
	fi

	return 0
}

## http://stackoverflow.com/questions/78497/design-patterns-or-best-practices-for-shell-scripts
OSL_FILE_find_common_path()
{
	typeset var path1="$1"
	typeset var path2="$2"
	return_value="OSL_FILE_find_common_path ERROR"

	local common_part="$path1" # for now

	while [[ "${path2#$common_part}" == "${path2}" ]]; do
		# no match, means that candidate common part is not correct
		# go up one level (reduce common part)
		common_part="$(dirname $common_part)"
	done
	return_value=$common_part
	return 0
}

# both $1 and $2 are absolute paths beginning with /
# returns relative path to $2/$target from $1/$source
OSL_FILE_find_relative_path()
{
	local source="$1"
	local target="$2"
	#echo "source : \"$source\""
	#echo "target : \"$target\""
	return_value="OSL_FILE_compute_relative_path ERROR"

	local common_part=$source # for now

	local result=""

	#echo "common_part is now : \"$common_part\""
	#echo "result is now      : \"$result\""
	#echo "target#common_part : \"${target#$common_part}\""
	while [[ "${target#$common_part}" == "${target}" ]]; do
		# no match, means that candidate common part is not correct
		# go up one level (reduce common part)
		common_part="$(dirname $common_part)"
		# and record that we went back
		if [[ -z $result ]]; then
			result=".."
		else
			result="../$result"
		fi
		#echo "common_part is now : \"$common_part\""
		#echo "result is now      : \"$result\""
		#echo "target#common_part : \"${target#$common_part}\""
	done

	#echo "common_part is     : \"$common_part\""

	if [[ $common_part == "/" ]]; then
		# special case for root (no common path)
		result="$result/"
	fi

	# since we now have identified the common part,
	# compute the non-common part
	forward_part="${target#$common_part}"
	#echo "forward_part = \"$forward_part\""

	if [[ -n $result ]] && [[ -n $forward_part ]]; then
		#echo "(simple concat)"
		result="$result$forward_part"
	elif [[ -n $forward_part ]]; then
		#echo "(concat with slash removal)"
		result="${forward_part:1}"
	else
		#echo "(no concat)"
		do_nothing=1
	fi
	#echo "result = \"$result\""
	return_value=$result

	return 0
}


## Absolute path of a file from a relative path.
## avantage over readlink : works even if we DON'T want symlinks to be followed
## thanks http://stackoverflow.com/a/3915986/587407
OSL_FILE_abspath()
{
	case "$*" in
	/*)printf "%s\n" "$*";;
	*)printf "%s\n" "$PWD/$*";;
	esac;
}


## absolute, expanded path of the given file (even if it doesn't exist)
## useful since expanding ~ in bash may be tricky
## thanks http://stackoverflow.com/a/11949850/587407
OSL_FILE_realpath()
{
	local path="$*"
	path="`eval echo ${path//>}`"
	## REM -m means "ok if doesn't exist"
	readlink -m "$path"
}