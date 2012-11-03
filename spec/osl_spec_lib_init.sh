#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - a set of calls to unit test functions to check them
##
## This file is meant to be executed.

source osl_lib_init.sh

# Test the tee redirection on ourself
OSL_INIT_engage_tee_redirection_to_logfile

source osl_lib_sspec.sh

OSL_SSPEC_describe "Offirmo Shell Lib init vars and services"


# since the tested file was included,
# some vars are supposed to be set :
echo "- checking exec dates..."
echo "  - date for humans : $OSL_INIT_exec_date_for_human"
OSL_SSPEC_string_should_not_be_empty "$OSL_INIT_exec_date_for_human"
echo "  - date for files : $OSL_INIT_exec_date_for_file"
OSL_SSPEC_string_should_not_be_empty "$OSL_INIT_exec_date_for_file"

echo "- checking current script infos..."
OSL_SSPEC_string_should_eq "osl_spec_lib_init.sh" $OSL_INIT_script_base_name
OSL_SSPEC_string_should_not_be_empty "$OSL_INIT_script_full_dir"
OSL_SSPEC_string_should_not_be_empty "$OSL_INIT_script_base_name"
OSL_SSPEC_string_should_eq           "$OSL_INIT_script_full_dir/$OSL_INIT_script_base_name"  $OSL_INIT_script_full_path

echo "- checking IFS backup..."
OSL_SSPEC_string_should_not_be_empty "$OSL_INIT_ORIGINAL_IFS"

echo "- checking log..."
OSL_SSPEC_string_should_not_be_empty "$OSL_INIT_LOGFILE"
OSL_SSPEC_string_should_eq "$OSL_INIT_DEFAULT_LOG_DIR/log.$OSL_INIT_exec_date_for_file.$USER.$OSL_INIT_script_base_name.log" $OSL_INIT_LOGFILE

echo "- tee redirection..."
OSL_SSPEC_file_should_exist "$OSL_INIT_LOGFILE"


OSL_SSPEC_end
