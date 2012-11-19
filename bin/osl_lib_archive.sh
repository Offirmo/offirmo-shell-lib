#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   archives manipulation functions
##
## This file is meant to be sourced :
##    source osl_lib_archive.sh


## useful to unpack sources
OSL_ARCHIVE_unpack_to()
{
	local archive_path=$1
	local destination_dir=$2
	local expected_unpack_dir=$3 # optional, if natural unpack dir is not = archive name
	local return_code=1 # error/problem by default

	echo "* unpacking \"$archive_path\" to \"$destination_dir\"..."
	
	local archive_name=`basename $archive_path`
	local extension="${archive_name#*.}"
	local root="${archive_name%%.*}"

	echo "  - extension : $extension"
	echo "  - basename  : $root"
	echo "  - pwd       : $(pwd)"

	echo "  - testing expected destination dir : $destination_dir..."
	if [[ -d $destination_dir ]]; then
		echo "    --> already exist !"
		##
	else
		echo "  - unpack in progress..."
		local prev_wd=$(pwd)
		cd `dirname $destination_dir`
		if [[ -z $expected_unpack_dir ]]; then # rem : -z = zero-length ?
			expected_unpack_dir=$root
		fi
		echo "    - expected unpack dir : $expected_unpack_dir"
		#pwd
		## great hat tip to http://ubuntuforums.org/showpost.php?p=10287642&postcount=4
		case $archive_path in
		*.tar.bz2) tar xvjf   $archive_path ;;
		*.tar.gz)  tar xvzf   $archive_path ;;
		*.tar.xz)  tar Jxvf   $archive_path ;;
		*.bz2)     bunzip2    $archive_path ;;
		*.rar)     unrar x    $archive_path ;;
		*.gz)      gunzip     $archive_path ;;
		*.tar)     tar xvf    $archive_path ;;
		*.tbz2)    tar xvjf   $archive_path ;;
		*.tgz)     tar xvzf   $archive_path ;;
		*.zip)     unzip      $archive_path ;;
		*.Z)       uncompress $archive_path ;;
		*.7z)      7z x       $archive_path ;;
		*)         echo "XXX don't know how to extract .$extension : '$archive_path'..." && return 1;;
		esac
		return_code=$?
		if [[ $return_code -ne 0 ]]; then
			echo "XXX something failed during unpacking..."
		else
			mv  $expected_unpack_dir  $destination_dir
			return_code=$?
			echo "  - unpack done."
		fi

		## back to prev dir
		cd "$prev_wd"
	fi
	
	return $return_code
}
