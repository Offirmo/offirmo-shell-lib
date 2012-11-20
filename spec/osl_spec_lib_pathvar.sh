#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of path var funcs
##
## This file is meant to be executed.

source osl_lib_init.sh

source osl_lib_pathvar.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib PATH funcs"


echo "- check_if_PLV_contains_this_path() unit tests :"
TESTPATH="/sbin"
OSL_PATHVAR_check_if_PLV_contains_this_path  TESTPATH "toto"
OSL_SSPEC_return_code_should_be_NOK $?
OSL_PATHVAR_check_if_PLV_contains_this_path  TESTPATH "/sbin"
OSL_SSPEC_return_code_should_be_OK $?

echo "- append_to_PLV_if_not_already_there() unit tests :"

TESTPATH="/bin:/sbin"
OSL_PATHVAR_append_to_PLV_if_not_already_there  TESTPATH "toto"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "/bin:/sbin:toto" "$TESTPATH"

OSL_PATHVAR_append_to_PLV_if_not_already_there  TESTPATH "toto"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "/bin:/sbin:toto" "$TESTPATH"

TESTPATH=""
OSL_PATHVAR_append_to_PLV_if_not_already_there  TESTPATH "toto"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "toto" "$TESTPATH"
OSL_PATHVAR_append_to_PLV_if_not_already_there  TESTPATH "toto"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "toto" "$TESTPATH"



echo "- prepend_to_PLV_if_not_already_there() unit tests :"

TESTPATH="/bin:/sbin"
OSL_PATHVAR_prepend_to_PLV_if_not_already_there  TESTPATH "toto"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "toto:/bin:/sbin" "$TESTPATH"
OSL_PATHVAR_prepend_to_PLV_if_not_already_there  TESTPATH "titi"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "titi:toto:/bin:/sbin" "$TESTPATH"
OSL_PATHVAR_prepend_to_PLV_if_not_already_there  TESTPATH "titi"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "titi:toto:/bin:/sbin" "$TESTPATH"

TESTPATH=""
OSL_PATHVAR_prepend_to_PLV_if_not_already_there  TESTPATH "titi"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "titi" "$TESTPATH"
OSL_PATHVAR_prepend_to_PLV_if_not_already_there  TESTPATH "titi"
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "titi" "$TESTPATH"

OSL_SSPEC_end
