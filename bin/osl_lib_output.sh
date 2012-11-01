#! /bin/bash

## Offirmo Shell Library
## http://
##
## This file is meant to be sourced :
##    source osl_lib_output.sh

source osl_inc_env.sh
source osl_inc_ansi_codes.sh


##########################################
### styles for functions in this lib
## default / reset
OSL_OUTPUT_STYLE_DEFAULT=${OSL_ANSI_CODE_RESET}
## base
OSL_OUTPUT_STYLE_STRONG=${OSL_ANSI_CODE_SET_BRIGHT}${OSL_ANSI_CODE_SET_FG_BLACK} # strong but not an error
OSL_OUTPUT_STYLE_WEAK=${OSL_ANSI_CODE_SET_FG_WHITE} # opposite of strong
OSL_OUTPUT_STYLE_PROBLEM=${OSL_ANSI_CODE_SET_FG_RED}
OSL_OUTPUT_STYLE_WARNING=${OSL_ANSI_CODE_SET_FG_YELLOW}
OSL_OUTPUT_STYLE_SUCCESS=${OSL_ANSI_CODE_SET_FG_GREEN}
# detailed
OSL_OUTPUT_STYLE_DEBUG=${OSL_OUTPUT_STYLE_WEAK}
OSL_OUTPUT_STYLE_ERROR=${OSL_OUTPUT_STYLE_PROBLEM}


##########################################
## useful functions
OSL_OUTPUT_bold()
{
	echo ${OSL_ANSI_CODE_SET_BRIGHT}$*${OSL_ANSI_CODE_RESET}
}
OSL_OUTPUT_under()
{
	echo ${OSL_ANSI_CODE_SET_UNDERLINE}$*${OSL_ANSI_CODE_RESET}
}
OSL_OUTPUT_blue()
{
	echo ${OSL_ANSI_CODE_SET_FG_BLUE}$*${OSL_ANSI_CODE_RESET}
}
OSL_OUTPUT_red()
{
	echo ${OSL_ANSI_CODE_SET_FG_RED}$*${OSL_ANSI_CODE_RESET}
}




# display a notification
# use a special style
OSL_OUTPUT_notify()
{
	echo -en $OSL_OUTPUT_STYLE_STRONG
	echo "Note : $*"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
}

# display a warning
# use a special style
OSL_OUTPUT_warn()
{
	echo ""
	echo -en $OSL_OUTPUT_STYLE_WARNING
	echo "Warning : $*"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
}

# display an error message in a clearly visible way
# params : all params will be displayed
OSL_OUTPUT_display_error_message()
{
	echo ""
	echo -en $OSL_OUTPUT_STYLE_ERROR
	echo "XXX $*"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
}

# display an error message in a clearly visible way
# AND stop execution
# params : all params will be displayed
OSL_OUTPUT_abort_execution_with_message()
{
	OSL_OUTPUT_display_error_message $*
	echo -en $OSL_OUTPUT_STYLE_ERROR
	echo "Execution aborted."
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
	echo ""
	exit 1
}

# display a "not implemented" warning message
# but doesn't stop execution
# params : all params will be displayed
OSL_OUTPUT_warn_not_implemented()
{
	OSL_OUTPUT_warn "$* : Sorry, went through a part not yet implemented."
}


# display a "not implemented" error message
# and stop execution
# params : all params will be displayed
OSL_OUTPUT_abort_execution_because_not_implemented()
{
	OSL_OUTPUT_abort_execution_with_message "$* : Sorry, this feature is not implemented yet."
}