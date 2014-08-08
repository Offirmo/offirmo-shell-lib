#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - a cleanup func that should be executed if interrupted
##
## This file is meant to be sourced :
##    source osl_lib_interrupt_hook.sh

source osl_lib_debug.sh


## what exit code should be returned 
OSL_INTERRUPT_default_failure_exit_code=2


## the func that will be executed if interrupted
## warning : it may be executed several times if two abort signals are sent
OSL_INTERRUPT_hook()
{
	## if interrupted, return code must be !0
	local return_code=$OSL_INTERRUPT_default_failure_exit_code
	
	if [[ $OSL_INTERRUPT_hook_count -gt 0 ]]; then
		for i in ${OSL_INTERRUPT_hook_index[@]}; do
			OSL_debug "* calling exit func \"${OSL_INTERRUPT_hook_name[$i]}\"..."
			${OSL_INTERRUPT_hook_name[$i]}
		done
	fi
	
	return $return_code
}


OSL_INTERRUPT_hook_INT()
{
	OSL_debug "*** INT exit hook called ***"
	OSL_INTERRUPT_hook
	return $?
}
OS_INTERRUPT_hook_TERM()
{
	OSL_debug "*** TERM exit hook called ***"
	OSL_INTERRUPT_hook
	return $?
}
OSL_INTERRUPT_hook_EXIT()
{
	OSL_debug "*** exit hook called ***"
	OSL_INTERRUPT_hook
	# don't care about return value
}


## install the interrupt catcher func
OSL_INTERRUPT_hook_setup()
{
	if [[ -z "$OSL_INTERRUPT_ENABLED" ]]; then
		OSL_INTERRUPT_hook_count=0 # number of exit func registered
		OSL_INTERRUPT_hook_index=0 # index of the item. indexes[n] = n, this is a hack for looping over elements
		OSL_INTERRUPT_hook_name=0 # index of the item. indexes[n] = n, this is a hack for looping over elements

		trap 'OSL_INTERRUPT_hook_INT;  exit $?' INT
		trap 'OSL_INTERRUPT_hook_TERM; exit $?' TERM

		# normal exit : exit code is preserved
		trap 'OSL_INTERRUPT_hook_EXIT' EXIT
		OSL_INTERRUPT_ENABLED=true
		OSL_debug "interrupt hooks are now set"
	fi
}

## automatic install ? good idea ?
## to review...
OSL_INTERRUPT_hook_setup


OSL_INTERRUPT_add_exit_hook()
{
	local exit_hook=$1
	local return_code=1

	OSL_INTERRUPT_hook_index[$OSL_INTERRUPT_hook_count]=$OSL_INTERRUPT_hook_count
	OSL_INTERRUPT_hook_name[$OSL_INTERRUPT_hook_count]=$exit_hook
	# and eventually, increment the count/index
	OSL_INTERRUPT_hook_count=`expr $OSL_INTERRUPT_hook_count + 1`
	return_code=0

	OSL_debug "interrupt func \"$exit_hook\" installed."
	
	return $return_code
}
