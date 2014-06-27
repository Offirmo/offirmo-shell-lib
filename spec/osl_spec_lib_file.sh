#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of string functions
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh

source osl_lib_file.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib file funcs"

TEST_FILE="$HOME/.osl_lib_test_file_xxx_toremove"
TEST_LINE1="titi toto		 tata  "
TEST_LINE2="titi toto" ## must be a subset of former to check correct grep

## init
rm -f "$TEST_FILE"

echo -e "add line to file : test on nonexistent file $OSL_OUTPUT_STYLE_ERROR(error msg expected)$OSL_OUTPUT_STYLE_DEFAULT"
OSL_FILE_ensure_line_is_present_in_file "$TEST_LINE1" "$TEST_FILE"
OSL_SSPEC_return_code_should_be_NOK $?

touch "$TEST_FILE"

echo "add line to file : test on existing file"
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


echo "test OSL_FILE_find_common_path"
OSL_FILE_find_common_path "A/B/C" "A"
OSL_SSPEC_string_should_eq "$return_value" "A"
OSL_FILE_find_common_path "/A/B/C" "/A"
OSL_SSPEC_string_should_eq "$return_value" "/A"
OSL_FILE_find_common_path "/A/B/C" "/A/B"
OSL_SSPEC_string_should_eq "$return_value" "/A/B"
OSL_FILE_find_common_path "/A/B/C" "/A/B/C"
OSL_SSPEC_string_should_eq "$return_value" "/A/B/C"
OSL_FILE_find_common_path "/A/B/C" "/A/B/C/D"
OSL_SSPEC_string_should_eq "$return_value" "/A/B/C"
OSL_FILE_find_common_path "/A/B/C" "/A/B/C/D/E"
OSL_SSPEC_string_should_eq "$return_value" "/A/B/C"
OSL_FILE_find_common_path "/A/B/C" "/A/B/D"
OSL_SSPEC_string_should_eq "$return_value" "/A/B"
OSL_FILE_find_common_path "/A/B/C" "/A/B/D/E"
OSL_SSPEC_string_should_eq "$return_value" "/A/B"
OSL_FILE_find_common_path "/A/B/C" "/A/D"
OSL_SSPEC_string_should_eq "$return_value" "/A"
OSL_FILE_find_common_path "/A/B/C" "/A/D/E"
OSL_SSPEC_string_should_eq "$return_value" "/A"
OSL_FILE_find_common_path "/A/B/C" "/D/E/F"
OSL_SSPEC_string_should_eq "$return_value" "/"

echo "test OSL_FILE_find_relative_path"
OSL_FILE_find_relative_path "A/B/C" "A"
OSL_SSPEC_string_should_eq "$return_value" "../.."
OSL_FILE_find_relative_path "./A/B/C" "./A"
OSL_SSPEC_string_should_eq "$return_value" "../.."
OSL_FILE_find_relative_path "/A/B/C" "/A"
OSL_SSPEC_string_should_eq "$return_value" "../.."
OSL_FILE_find_relative_path "/A/B/C" "/A/B"
OSL_SSPEC_string_should_eq "$return_value" ".."
OSL_FILE_find_relative_path "/A/B/C" "/A/B/C"
OSL_SSPEC_string_should_eq "$return_value" ""
OSL_FILE_find_relative_path "/A/B/C" "/A/B/C/D"
OSL_SSPEC_string_should_eq "$return_value" "D"
OSL_FILE_find_relative_path "/A/B/C" "/A/B/C/D/E"
OSL_SSPEC_string_should_eq "$return_value" "D/E"
OSL_FILE_find_relative_path "/A/B/C" "/A/B/D"
OSL_SSPEC_string_should_eq "$return_value" "../D"
OSL_FILE_find_relative_path "/A/B/C" "/A/B/D/E"
OSL_SSPEC_string_should_eq "$return_value" "../D/E"
OSL_FILE_find_relative_path "/A/B/C" "/A/D"
OSL_SSPEC_string_should_eq "$return_value" "../../D"
OSL_FILE_find_relative_path "/A/B/C" "/A/D/E"
OSL_SSPEC_string_should_eq "$return_value" "../../D/E"
OSL_FILE_find_relative_path "/A/B/C" "/D/E/F"
OSL_SSPEC_string_should_eq "$return_value" "../../../D/E/F"


echo "test OSL_FILE_abspath"
## we use this own script as a test file,
## since we conveniently already have all necessary infos
OSL_SSPEC_string_should_eq "$(OSL_FILE_abspath "$OSL_INIT_script_full_path")" "$OSL_INIT_script_full_path"
owd=`pwd`
cd "$OSL_INIT_script_full_dir"
OSL_SSPEC_string_should_eq "$(OSL_FILE_abspath "$OSL_INIT_script_base_name")" "$OSL_INIT_script_full_path"
cd "$owd"


echo "test OSL_FILE_realpath"
OSL_SSPEC_string_should_eq "/home/`whoami`/.bashrc" "$(OSL_FILE_realpath "~/.bashrc")"
OSL_SSPEC_string_should_eq "`pwd`/osl_spec_lib_file.sh" "$(OSL_FILE_realpath "osl_spec_lib_file.sh")"
OSL_SSPEC_string_should_eq "`pwd`/inexisting_foo" "$(OSL_FILE_realpath "inexisting_foo")"


OSL_SSPEC_end
