#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
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
OSL_OUTPUT_STYLE_STRONG=${OSL_ANSI_CODE_SET_BRIGHT} # strong but not an error
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
	echo -en $OSL_ANSI_CODE_SET_BRIGHT
	echo "$*"
	echo -en ${OSL_ANSI_CODE_RESET}
}
OSL_OUTPUT_under()
{
	## seems this code doesn't really exists...
	echo -en ${OSL_ANSI_CODE_SET_UNDERLINE}
	echo "$*"
	echo -en ${OSL_ANSI_CODE_RESET}
}
OSL_OUTPUT_blue()
{
	echo -en ${OSL_ANSI_CODE_SET_FG_BLUE}
	echo "$*"
	echo -en ${OSL_ANSI_CODE_RESET}
}
OSL_OUTPUT_red()
{
	echo -en ${OSL_ANSI_CODE_SET_FG_RED}
	echo "$*"
	echo -en ${OSL_ANSI_CODE_RESET}
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
	echo -e "Warning : $*"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
}

# display an error message in a clearly visible way
# params : all params will be displayed
OSL_OUTPUT_display_error_message()
{
	## send to stderr ?
	echo ""
	echo -en $OSL_OUTPUT_STYLE_ERROR
	echo -e "XXX $*"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
	[[ -n "$OSL_debug_activated" ]] && OSL_print_stack 2
}

# display a success message in a clearly visible way
# params : all params will be displayed
OSL_OUTPUT_display_success_message()
{
	echo ""
	echo -en $OSL_OUTPUT_STYLE_SUCCESS
	echo -e "$*"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
}


# display a "not implemented" warning message
# but doesn't stop execution
# params : all params will be displayed
OSL_OUTPUT_warn_not_implemented()
{
	OSL_OUTPUT_warn "$* : Sorry, went through a part not yet implemented."
	[[ -n "$OSL_debug_activated" ]] && OSL_print_stack 2
}
