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

	for line in $buffer; do
		OSL_debug $line
	done

	IFS="$OIFS" # restore Internal field separator
}

##########################################
## styles for functions in this lib
## We use error style as base, of course
OSL_OUTPUT_STYLE_STACK=${OSL_ANSI_CODE_SET_FG_RED}
OSL_OUTPUT_STYLE_FUNC=${OSL_OUTPUT_STYLE_STACK}${OSL_ANSI_CODE_SET_BRIGHT}
OSL_OUTPUT_STYLE_FILENAME=${OSL_OUTPUT_STYLE_STACK}${OSL_ANSI_CODE_SET_DIM}${OSL_ANSI_CODE_SET_FG_YELLOW}
OSL_OUTPUT_STYLE_LINENO=${OSL_OUTPUT_STYLE_STACK}${OSL_ANSI_CODE_SET_FG_MAGENTA}


OSL_print_stack()
{
	local skip_count="$*"
	[[ -z "$skip_count" ]] && skip_count=1

	for i in ${!FUNCNAME[*]}
	do
		[[ $i -ge $skip_count ]] && echo -e "   ${OSL_OUTPUT_STYLE_STACK}at $OSL_OUTPUT_STYLE_FUNC${FUNCNAME[$i]}$OSL_ANSI_CODE_SET_DIM() $OSL_OUTPUT_STYLE_FILENAME${BASH_SOURCE[$i]} ${OSL_OUTPUT_STYLE_LINENO}l.${BASH_LINENO[$i]} $OSL_OUTPUT_STYLE_DEFAULT"
	done
}
