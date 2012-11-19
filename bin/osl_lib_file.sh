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



# Ensure that a cron line exists
OSL_FILE_ensure_line_is_present_in_file()
{
	typeset var line="$1"
	typeset var file="$2"

	echo "* ensuring that line \"$line\" is present in file \"$file\""

	if ! [[ -f "$file" ]]; then
		OSL_OUTPUT_display_error_message "file \"$file\" not found !"
		return 1
	fi
	
	# REM : --fixed-strings : Interpret PATTERN as a list of fixed strings, separated by newlines, any of which is to be matched.
	typeset var test=`grep --count --fixed-strings --line-regexp "$line" "$file"`

	if [[ $test -ne 0 ]]; then
		# the line is already in the file
		echo "  -> Already set."
		
		do_nothing=1
	else
		# the line is not in the file, add it
		echo "  -> Not set, adding it..."

		# 1) add it to the temp file
		echo "$line" >> "$file"
	fi

	return 0
}
