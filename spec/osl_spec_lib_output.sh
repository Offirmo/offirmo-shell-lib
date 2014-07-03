#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of color codes
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh

source osl_lib_output.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib output primitives"


# NOTE : since color is a visual perception,
# we can't easily test the correctness.
# So this unit test must be reviewed by a human.

echo "test OSL_OUTPUT_bold :"
OSL_OUTPUT_bold "   This text should be bold"

echo "test OSL_OUTPUT_under :"
OSL_OUTPUT_under "   This text should be underlined"

echo "test OSL_OUTPUT_blue :"
OSL_OUTPUT_blue "   This text should be blue"

echo "test OSL_OUTPUT_red :"
OSL_OUTPUT_red "   This text should be red"


echo "test semantic styles :"
echo -e "${OSL_OUTPUT_STYLE_DEFAULT}This is STYLE_DEFAULT.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e  "${OSL_OUTPUT_STYLE_STRONG}This is STYLE_STRONG.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e    "${OSL_OUTPUT_STYLE_WEAK}This is STYLE_WEAK.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e "${OSL_OUTPUT_STYLE_PROBLEM}This is STYLE_PROBLEM.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e "${OSL_OUTPUT_STYLE_WARNING}This is STYLE_WARNING.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e "${OSL_OUTPUT_STYLE_SUCCESS}This is STYLE_SUCCESS.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e   "${OSL_OUTPUT_STYLE_DEBUG}This is STYLE_DEBUG.$OSL_OUTPUT_STYLE_DEFAULT"
echo -e   "${OSL_OUTPUT_STYLE_ERROR}This is STYLE_ERROR.$OSL_OUTPUT_STYLE_DEFAULT"


echo "test OSL_OUTPUT_notify :"
OSL_OUTPUT_notify "This is a notification"

echo "test OSL_OUTPUT_warn :"
OSL_OUTPUT_warn "This is a warning"
echo

echo "test OSL_OUTPUT_display_error_message :"
OSL_OUTPUT_display_error_message "This is an error"
echo

echo "test OSL_OUTPUT_display_success_message :"
OSL_OUTPUT_display_success_message "This is a success."
echo

echo "test OSL_OUTPUT_warn_not_implemented :"
OSL_OUTPUT_warn_not_implemented "(here is a custom not implemented message)"
echo



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







OSL_SSPEC_end
