#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of string functions
##
## This file is meant to be executed.

source osl_lib_init.sh

source osl_lib_string.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib string funcs"

res=$(OSL_STRING_to_lower "AbCdEf")
OSL_SSPEC_string_should_eq "abcdef" "$res"

res=$(OSL_STRING_to_upper "AbCdEf")
OSL_SSPEC_string_should_eq "ABCDEF" "$res"


res=$(OSL_STRING_trim "AbCdEf")
OSL_SSPEC_string_should_eq "AbCdEf" "$res"

res=$(OSL_STRING_trim " AbCdEf")
OSL_SSPEC_string_should_eq "AbCdEf" "$res"

res=$(OSL_STRING_trim "AbCdEf ")
OSL_SSPEC_string_should_eq "AbCdEf" "$res"

res=$(OSL_STRING_trim "	 AbCdEf  ")
OSL_SSPEC_string_should_eq "AbCdEf" "$res"

res=$(OSL_STRING_trim "	 AbC dEf  ")
OSL_SSPEC_string_should_eq "AbC dEf" "$res"


OSL_SSPEC_end
