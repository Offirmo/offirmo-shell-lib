#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of version functions
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh

source osl_lib_version.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib version funcs"


OSL_SSPEC_should_spec "func to test if good format"

## first test equality of alternate notations
res=$(OSL_VERSION_compare "1.0.0.0" "1")
OSL_SSPEC_string_should_eq 0 $res
res=$(OSL_VERSION_compare "1.0.0.0" "1.0")
OSL_SSPEC_string_should_eq 0 $res
res=$(OSL_VERSION_compare "1.0.0.0" "1.0.0")
OSL_SSPEC_string_should_eq 0 $res
res=$(OSL_VERSION_compare "1.0.0.0" "1.0.0.0")
OSL_SSPEC_string_should_eq 0 $res

res=$(OSL_VERSION_compare "1.0.0.0" "1.0.0.1")
OSL_SSPEC_string_should_eq -1 $res
res=$(OSL_VERSION_compare "1.0.1.0" "1.0.0.1")
OSL_SSPEC_string_should_eq 1 $res
res=$(OSL_VERSION_compare "2.8.10" "2.6")
OSL_SSPEC_string_should_eq 1 $res

res=$(OSL_VERSION_compare "1.0.0.0" "2.0.0.0")
OSL_SSPEC_string_should_eq -1 $res

res=$(OSL_VERSION_compare "3.4" "4.7.2")
OSL_SSPEC_string_should_eq -1 $res

res=$(OSL_VERSION_compare "1.0.8" "0.7")
OSL_SSPEC_string_should_eq 1 $res


OSL_VERSION_test_greater_or_equal "1.0.0.0" "1.0.0.0"
OSL_SSPEC_return_code_should_be_OK $?
OSL_VERSION_test_greater_or_equal "1.3.0.0" "1.0.0.0"
OSL_SSPEC_return_code_should_be_OK $?
OSL_VERSION_test_greater_or_equal "1.0.0.0" "1.0.2.0"
OSL_SSPEC_return_code_should_be_NOK $?
OSL_VERSION_test_greater_or_equal "2.8.10" "2.6"
OSL_SSPEC_return_code_should_be_OK $?


OSL_VERSION_test_smaller_or_equal "1.0.0.0" "1.0.0.0"
OSL_SSPEC_return_code_should_be_OK $?
OSL_VERSION_test_smaller_or_equal "1.0.0.0" "1.3.0.0"
OSL_SSPEC_return_code_should_be_OK $?
OSL_VERSION_test_smaller_or_equal "1.0.2.0" "1.0.0.0"
OSL_SSPEC_return_code_should_be_NOK $?


OSL_SSPEC_end
