Offirmo-shell-lib
=================

The Offirmo Shell Lib (OSL) is a collection of useful shell functions for robust and advanced shell scripts.

Requirements : I use bash.

Offirmo Shell Lib is available at : https://github.com/Offirmo/offirmo-shell-lib

Note : The OSL has unit tests for maximum quality.

Introduction 
============

The user story
--------------
I found myself having to write a lot of shell scripts, for work and for home.

Over the time, I had to develop a lot of useful functions.

One day, I cleaned them up and packed them in this lib. Enjoy !

Requirements
------------
The OSL is targeted at bash. Never tested with another shell.

Installation
------------
Get a copy of the files and set your path to point to the OSL "bin" dir.
You can check if it works by typing :

 `osl_help.sh`
 
In your scripts, add this as soon as possible (ideally first instruction in your script for maximum features) :

 `source osl_lib_init.sh`

Usage
-----

On demand, source other OSL files as needed :

libs :
- `osl_lib_archive.sh     `  --> decompress any archive file
- `osl_lib_capabilities.sh`  --> detect version and check capabilities of host OS
- `osl_lib_debug.sh       `  --> traces
- `osl_lib_exit.sh        `  --> to abort execution with nice messages
- `osl_lib_file.sh        `  --> path manipulations, ensure a line is
- `osl_lib_init.sh        `  --> allow output saving and various nice hacks
- `osl_lib_mutex.sh       `  --> create and use mutexes (note : use 'rsrc' wrapper for additional features)
- `osl_lib_output.sh      `  --> various display functions : error, warnings...
- `osl_lib_rsrc.sh        `  --> safe rsrc manipulation protected by mutex
- `osl_lib_sspec.sh       `  --> shell unit tests, inspired from rspec
- `osl_lib_stamp.sh       `  --> manip of stamp files to detect access time and interferences (note : use 'rsrc' wrapper for additional features)
- `osl_lib_string.sh      `  --> string utilities
- `osl_lib_ui.sh          `  --> UI functions like asking yes or no, pause...
- `osl_lib_version.sh     `  --> version comparison utilities (newer/older)
- `osl_inc_ansi_codes.sh  `  --> defines ANSI codes for color

Special files :
- `osl_help.sh`  --> callable, display current OSL version
- `osl_inc_env.sh`  --> various constants

Experimental / in progress :
- `osl_lib_interrupt_func.sh`  --> exit hook (for mutex auto release)

  
That's it. You can now use the features.


The functions
=============

For now, look inside the unit tests of the file you're interested in, or look in the file itself.

TODO
====

- Better doc ;)
- improve decompression function
- refactor mutex code to avoid duplication
- mutex switch from read to write ?
- forward and aggregate state in rsrc fuctions
- Make default values redefinable
- Make it easier to disable color
- remove "bashisms"
- asserts ?
- More...

