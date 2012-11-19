#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   methods for unit testing shell scripts.
##   Inspired from rspec (http://rspec.info/)
##   hence the name : sspec (shell spec)
##
## This file is meant to be sourced :
##    source osl_lib_sspec.sh

source osl_inc_env.sh
source osl_lib_output.sh


##########################################
### Unit test utils

# start of a unit test suite.
# Display an informative header.
OSL_SSPEC_describe()
{
	local feature_designation=$1
	
	echo ""
	echo "+++ Starting unit test suite... +++"
	echo "- date : `date`"
	echo "- testing : $feature_designation"
	echo ""
}


## end of a unit test suite.
## reset some things for safety
OSL_SSPEC_end()
{
	# just in case
	echo -en $OSL_COLOR_CODE_ANSI_RESET
	echo ""
	echo "+++ Unit test suite finished. +++"
	echo ""
}


# Assert execution
# check an execution result code against an expected value
# display messages if not OK
#
# params :
# $1 = expected return code
# $2 = actual return code
#
# see also : return_code_should_be_OK, return_code_should_be_NOK
OSL_SSPEC_return_code_should_eq()
{
	local expected_return_code=$1
	local actual_return_code=$2
	
	if [[ "$expected_return_code" != "$actual_return_code" ]]; then
		echo -e $OSL_OUTPUT_STYLE_ERROR
 		echo "XXX DON'T PASS XXX ERROR expected return code '$expected_return_code', got '$actual_return_code'"
		echo -e $OSL_OUTPUT_STYLE_DEFAULT
	else
		echo -en $OSL_OUTPUT_STYLE_SUCCESS
		echo ">>> PASS"
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
	fi
}
OSL_SSPEC_return_code_should_be_OK()
{
	OSL_SSPEC_return_code_should_eq 0 $1
}

OSL_SSPEC_return_code_should_be_NOK()
{
	local actual_return_code=$1
	
	if [[ $actual_return_code -eq 0 ]]; then
		# return = OK, this is not what we expected
		echo -e $OSL_OUTPUT_STYLE_ERROR
 		echo "XXX DON'T PASS XXX ERROR expected return code !0"
		echo -e $OSL_OUTPUT_STYLE_DEFAULT
	else
		# return code !0, as expected
		echo -en $OSL_OUTPUT_STYLE_SUCCESS
		echo ">>> PASS"
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
	fi
}


# Assert the value of a string
# against an expected value
# display messages if not OK
OSL_SSPEC_string_should_eq()
{
	local str_expected=$1
	local str_got=$2
	
	if [[ $str_got != $str_expected ]]; then
		echo -e $OSL_OUTPUT_STYLE_ERROR
		#debug $str_expected
		#debug $str_got
		echo "XXX DON'T PASS XXX ERROR expected \"$str_expected\", got \"$str_got\""
		echo -e $OSL_OUTPUT_STYLE_DEFAULT
	else
		echo -en $OSL_OUTPUT_STYLE_SUCCESS
		echo ">>> PASS"
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
	fi
}

OSL_SSPEC_string_should_not_be_empty()
{
	local str=$1
	
	if [[ -z "$str" ]]; then
		echo -e $OSL_OUTPUT_STYLE_ERROR
		echo "XXX DON'T PASS XXX ERROR expected a string to not be empty !"
		echo -e $OSL_OUTPUT_STYLE_DEFAULT
	else
		echo -en $OSL_OUTPUT_STYLE_SUCCESS
		echo ">>> PASS"
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
	fi
}

OSL_SSPEC_string_should_be_empty()
{
	local str=$1
	
	if [[ -z "$str" ]]; then
		echo -en $OSL_OUTPUT_STYLE_SUCCESS
		echo ">>> PASS"
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
	else
		echo -e $OSL_OUTPUT_STYLE_ERROR
		echo "XXX DON'T PASS XXX ERROR expected the string to be empty, but got '$str' !"
		echo -e $OSL_OUTPUT_STYLE_DEFAULT
	fi
}

# Test the presence of a file
OSL_SSPEC_file_should_exist()
{
	local expected_file=$1
	
	if [[ -f "$expected_file" ]]; then
		echo -en $OSL_OUTPUT_STYLE_SUCCESS
		echo ">>> PASS"
		echo -en $OSL_OUTPUT_STYLE_DEFAULT
	else
		echo -e $OSL_OUTPUT_STYLE_ERROR
		echo "XXX DON'T PASS XXX ERROR expected presence of file '$expected_file' !"
		echo -e $OSL_OUTPUT_STYLE_DEFAULT
	fi
}

# Mark the need for a test not implemented yet
OSL_SSPEC_should_spec()
{
	local msg=$*
	
	echo -en $OSL_OUTPUT_STYLE_WARNING
	echo "TODO test : $msg"
	echo -en $OSL_OUTPUT_STYLE_DEFAULT
}
