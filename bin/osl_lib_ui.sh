#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - "high level" user interaction methods
##
## This file is meant to be sourced :
##    source osl_lib_ui.sh

source osl_lib_output.sh


##########################################
### User interface utils

# Ask for confirmation.
# http://www.linuxquestions.org/questions/programming-9/shell-script-asking-for-confirmation-375475/
# Style is inspired by SVN commands.
#
# Params :
# - $1 : message that will be displayed
# - $2 : (optional) timeout in s. Will return "abort" if timeout
#
# Returns :
# - !0 = abort, 0 = proceed
# XXX timout feature in progress, to improve
OSL_UI_CONFIRMATION_DEFAULT_TIMEOUT_S=0 # no timeout
OSL_UI_CONFIRMATION_timeout_s=$OSL_UI_CONFIRMATION_DEFAULT_TIMEOUT_S # this value can be changed
OSL_UI_ask_confirmation()
{
	local message=$1
	local timeout=$2
	local return_code=1 # abort by default
	local read_return_code=0
	
	echo -en $OSL_OUTPUT_STYLE_STRONG
	echo $message
	if [[ -n "$timeout" ]]; then
		read -n1 -t $timeout -p "are you sure ? Choose : P)roceed, A)bort : "
	else
		read -n1 -p "are you sure ? Choose : P)roceed, A)bort : "
	fi
	read_return_code=$?
	echo -e $OSL_OUTPUT_STYLE_DEFAULT # reset color + new line

	if [[ $read_return_code != 0 ]]; then
		# error
		echo -en $OSL_OUTPUT_STYLE_ERROR
		if [[ -n "$timeout" ]]; then
			# most likely timeout
			echo "Timeout, I abort."
		else
			echo "Error ?, I abort."
		fi
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
		# return code stays false
	else
		# OK, reply
		case $REPLY in
		p | P)
			echo "You chose to proceed."
			return_code=0 # success
			;;
		a | A)
			echo "You chose to abort."
			# return code stays false
			;;
		* )
			echo -en $OSL_OUTPUT_STYLE_ERROR
			echo "I don't understand, I abort."
			echo -en $OSL_OUTPUT_STYLE_DEFAULT
			# return code stays false
			;;
		esac
	fi
	
	echo "" # for better clarity
	return $return_code
}


# Pause waiting for user input.
#
# Params :
# - (all params will be displayed)
#
# Returns :
# - none
OSL_UI_pause()
{
	local message="$*"

	if [[ -z $message ]]; then
		message="Pause..."
	fi
	
	echo $*
	
	echo -en $OSL_OUTPUT_STYLE_STRONG
	read -n1 -s -p "(press a key to continue)" # one char, silent mode (no echo), with given prompt
	echo -e $OSL_OUTPUT_STYLE_DEFAULT # reset color + new line
}
