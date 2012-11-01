#! /bin/bash

## Offirmo Shell Library
## http://
##
## This file defines :
##   - unit test of color codes
##
## This file is meant to be executed.

source osl_lib_init.sh
source osl_lib_sspec.sh

source osl_inc_ansi_codes.sh

OSL_SSPEC_describe "Offirmo Shell Lib color codes"


# NOTE : since color is a visual perception,
# we can't easily test the correctness.
# So this unit test must be reviewed by a human.

it_should_display_properly_this_foreground_color()
{
	# params
	local color_radix=$1
	local color_code="OSL_ANSI_CODE_SET_FG_${color_radix}"
	
	local test_cmd="echo -e \"-\$$color_code This line should be in $color_radix on white. \$OSL_ANSI_CODE_RESET\""
	eval $test_cmd
}
it_should_display_properly_this_background_color()
{
	# params
	local color_radix=$1
	local color_code="OSL_ANSI_CODE_SET_BG_${color_radix}"
	
	local test_cmd="echo -e \"-$OSL_ANSI_CODE_SET_FG_WHITE\$$color_code This line should have a $color_radix background. \$OSL_ANSI_CODE_RESET\""
	eval $test_cmd
}

it_should_display_properly_this_color()
{
	# params
	local color_radix=$1
	
	it_should_display_properly_this_foreground_color $color_radix
	it_should_display_properly_this_background_color $color_radix
}

it_should_display_properly_this_color "BLACK"
it_should_display_properly_this_color "RED"


OSL_SSPEC_end
