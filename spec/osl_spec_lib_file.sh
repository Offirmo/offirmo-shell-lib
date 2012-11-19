#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of string functions
##
## This file is meant to be executed.

source osl_lib_init.sh

source osl_lib_file.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib file funcs"

TEST_FILE="$HOME/.osl_lib_test_file_xxx_toremove"
TEST_LINE1="titi toto		 tata  "
TEST_LINE2="titi toto" ## must be a subset of former to check correct grep

## init
rm -f "$TEST_FILE"

echo "test on nonexistent file (error msg expected)"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE1" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_NOK $?

touch "$TEST_FILE"

echo "test 1 : initial add"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE1" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "`cat "$TEST_FILE"`" "$TEST_LINE1"

echo "test 2 : second add"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE1" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "`cat "$TEST_FILE"`" "$TEST_LINE1"

echo "test 2 : second add"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE1" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "`cat "$TEST_FILE"`" "$TEST_LINE1"

echo "test 3 : different, ambiguous add"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE2" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "`cat "$TEST_FILE"`" "$TEST_LINE1
$TEST_LINE2"

echo "test 4 : initial add again"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE1" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "`cat "$TEST_FILE"`" "$TEST_LINE1
$TEST_LINE2"


## cleanup
rm -f "$TEST_FILE"

OSL_SSPEC_end
