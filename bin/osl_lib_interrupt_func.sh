#! /bin/bash

## Offirmo Shell Library
## http://
##
## This file defines :
##   - a cleanup func that should be executed if interrupted
##
## This file is meant to be sourced :
##    source osl_lib_interrupt_func.sh


## the func that will be executed if interrupted
## warning : it may be executed several times if two abort signals are sent
OS_INTERRUPT_cleanup_func()
{
	## if interrupted, return code must be !0
	local return_code=2

	return $return_code
}

OS_INTERRUPT_cleanup_func_setup()
{
	trap 'OS_INTERRUPT_cleanup_func; exit $?' INT TERM EXIT
}
