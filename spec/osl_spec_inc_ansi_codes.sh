#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - unit test of color codes
##
## This file is meant to be executed.

## reset path to be sure we test this local OSL instance
export PATH=../bin:$PATH

source osl_lib_init.sh

source osl_inc_ansi_codes.sh

source osl_lib_sspec.sh


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

it_should_display_properly_this_color_with_modifiers()
{
	# params
	local color_radix=$1
	local color_code="OSL_ANSI_CODE_SET_FG_${color_radix}"

	local test_cmd="echo -e \"-\$$color_code $color_radix ${OSL_ANSI_CODE_SET_BRIGHT}Bright ${OSL_ANSI_CODE_SET_DIM}Dim ${OSL_ANSI_CODE_SET_UNDERLINE}Underline
	\$OSL_ANSI_CODE_RESET\""
	eval $test_cmd
}

it_should_display_properly_this_color()
{
	# params
	local color_radix=$1

	it_should_display_properly_this_foreground_color $color_radix
	it_should_display_properly_this_background_color $color_radix
	it_should_display_properly_this_color_with_modifiers $color_radix
}

it_should_display_properly_this_color "BLACK"
it_should_display_properly_this_color "RED"
it_should_display_properly_this_color "GREEN"
it_should_display_properly_this_color "YELLOW"
it_should_display_properly_this_color "BLUE"
it_should_display_properly_this_color "MAGENTA"
it_should_display_properly_this_color "CYAN"
it_should_display_properly_this_color "WHITE"


OSL_SSPEC_end
