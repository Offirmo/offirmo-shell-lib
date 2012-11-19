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
OSL_ARCHIVE_unpack_to
{
	local archive_path=$1
	local destination_dir=$2
	local expected_unpack_dir=$3 # optional

	echo "* unpacking $archive_path to $destination_dir..."
	
	archive_name=`basename $archive_path`
	extension="${archive_name#*.}"
	root="${archive_name%%.*}"

	echo "  - extension : $extension"
	echo "  - basename  : $root"

	echo "  - testing expected destination dir : $destination_dir..."
	if [[ -d $destination_dir ]]; then
		echo "    --> is already unpacked"
	else
		echo "  - unpack in progress..."
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
		*)         echo "XXX don't know how to extract .$extension : '$archive_path'..." && exit 1;;
		esac
		if [[ $? -ne 0 ]]; then
			echo "XXX something failed during unpacking..."
			exit 1
		fi
		mv  $expected_unpack_dir  $destination_dir
		echo "  - unpack done."
	fi
	
	return 0
}
