#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - various funcs for exiting a script
##     (usually because of an error)
##
## This file is meant to be sourced :
##    source osl_lib_exit.sh

source osl_lib_output.sh


# display an error message in a clearly visible way
# AND stop execution
# params : all params will be displayed
OSL_EXIT_abort_execution_with_message()
{
	OSL_OUTPUT_display_error_message $*
	echo -en $OSL_OUTPUT_STYLE_ERROR
	echo "Execution aborted."
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
	echo ""
	exit 1
}


# display a "not implemented" error message
# and stop execution
# params : all params will be displayed
OSL_EXIT_abort_execution_because_not_implemented()
{
	OSL_EXIT_abort_execution_with_message "$* : Sorry, this feature is not implemented yet."
}


# stop execution if given return code is not 0
# params : all params will be displayed except the first one
OSL_EXIT_abort_execution_if_bad_retcode()
{
	local return_code=$1
	if [[ $return_code -ne 0 ]]; then
		OSL_EXIT_abort_execution_with_message "Internal error : a critical op just failed : $2 $3 $4 $5 $6 $7 $8 $9"
	fi
}
