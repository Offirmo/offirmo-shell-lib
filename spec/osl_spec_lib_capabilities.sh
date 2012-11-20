#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of string functions
##
## This file is meant to be executed.

source osl_lib_init.sh

source osl_lib_capabilities.sh

source osl_lib_sspec.sh


OSL_SSPEC_describe "Offirmo Shell Lib capabilities detection"

echo "* for info : uname raw data :"
uname --all
echo ""

echo "* linux detection..."

OSL_CAPABILITIES_ensure_current_linux_distribution_detected
OSL_SSPEC_return_code_should_be_OK $?
OSL_SSPEC_string_should_eq "$OSL_CAPABILITIES_OS_DISTRIBUTION_DETECTED"  "true"

echo "OSL_CAPABILITIES_OS          = $OSL_CAPABILITIES_OS"
echo "OSL_CAPABILITIES_REV         = $OSL_CAPABILITIES_REV"
echo "OSL_CAPABILITIES_ARCH        = $OSL_CAPABILITIES_ARCH"
echo "OSL_CAPABILITIES_DIST        = $OSL_CAPABILITIES_DIST"
echo "OSL_CAPABILITIES_PSEUDONAME  = $OSL_CAPABILITIES_PSEUDONAME"
echo "OSL_CAPABILITIES_INFO_FILE   = $OSL_CAPABILITIES_INFO_FILE"

echo "OSL_CAPABILITIES_OSSTR       = $OSL_CAPABILITIES_OSSTR"

echo "OSL_CAPABILITIES_is_debian_based() -> $(OSL_CAPABILITIES_is_debian_based)"
echo "OSL_CAPABILITIES_has_apt()         -> $(OSL_CAPABILITIES_has_apt)"


## tested on a RedHat :
# OSL_CAPABILITIES_OS          = Linux
# OSL_CAPABILITIES_REV         = 5.3
# OSL_CAPABILITIES_ARCH        = x86_64
# OSL_CAPABILITIES_DIST        = RedHat
# OSL_CAPABILITIES_PSEUDONAME  = Tikanga
# OSL_CAPABILITIES_INFO_FILE   = /etc/redhat-release
# OSL_CAPABILITIES_OSSTR       = Linux RedHat 5.3 (Tikanga 2.6.18-128.el5 x86_64)
# OSL_CAPABILITIES_is_debian_based() -> false
# OSL_CAPABILITIES_has_apt()         -> false



OSL_SSPEC_end
