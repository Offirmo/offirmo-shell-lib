#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   debug functions : traces, 
##
## This file is meant to be sourced :
##    source osl_lib_debug.sh

source osl_inc_env.sh

source osl_lib_output.sh



# a quick and easy debug func
# use a special style
OSL_debug()
{
	echo -en $OSL_OUTPUT_STYLE_DEBUG
	echo "[Debug] $*"
	echo -en $OSL_ANSI_CODE_RESET
}

# same for a multi-lines buffer
# (output of a command for example)
OSL_debug_multi()
{
	local buffer="$*"
	
	# to split lines along \n, we must change the IFS
	local OIFS="$IFS" # backup Internal Field Separator
	IFS='
' # this makes IFS a newline

	echo -en $OSL_OUTPUT_STYLE_DEBUG
	for line in $buffer; do
		OSL_debug $line
	done
	echo -en $OSL_ANSI_CODE_RESET

	IFS=$OIFS # restore Internal field separator
}
