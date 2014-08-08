#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of debug functions
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh

source osl_lib_debug.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib debug primitives"


# NOTE : since color is a visual perception,
# we can't easily test the correctness.
# So this unit test must be reviewed by a human.

it_should_work()
{
	echo "test OSL_debug :"
	OSL_debug "this is a debug info"

	echo "test OSL_debug_multi :"
	OSL_debug "this is a multiline debug info : `ls`"

	echo "test OSL_print_stack : (default)"
	OSL_print_stack
	echo "test OSL_print_stack : (2 skips)"
	OSL_print_stack 2
}


echo -e "\n\nXXX\nXXX with debug = false XXX\nXXX\n"
OSL_debug_activated=false
it_should_work

echo -e "\n\nXXX\nXXX with debug = true XXX\nXXX\n"
OSL_debug_activated=true
it_should_work



OSL_SSPEC_end
