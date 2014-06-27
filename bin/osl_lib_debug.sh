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


if [[ -z "$OSL_debug_activated" ]]; then
	OSL_debug_activated=false
fi

# a quick and easy debug func
# use a special style
OSL_debug()
{
	$OSL_debug_activated && echo -en $OSL_OUTPUT_STYLE_DEBUG
	$OSL_debug_activated && echo -e "[Debug] $*"
	$OSL_debug_activated && echo -en $OSL_ANSI_CODE_RESET
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

	IFS="$OIFS" # restore Internal field separator
}


OSL_print_stack()
{
	local skip_count="$*"
	[[ -z "$skip_count" ]] && skip_count=1

	for i in ${!FUNCNAME[*]}
	do
		[[ $i -ge $skip_count ]] && echo -e "   ${OSL_OUTPUT_STYLE_ERROR}at $OSL_ANSI_CODE_SET_BRIGHT${FUNCNAME[$i]}$OSL_ANSI_CODE_SET_DIM() $OSL_ANSI_CODE_SET_FG_YELLOW${BASH_SOURCE[$i]} ${OSL_ANSI_CODE_SET_BRIGHT}l.${BASH_LINENO[$i]} $OSL_OUTPUT_STYLE_DEFAULT"
	done
}
