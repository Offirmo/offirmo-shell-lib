Offirmo-shell-lib
=================

The Offirmo Shell Lib (OSL) is a collection of useful shell functions for robust and advanced shell scripts.

I use bash.

Offirmo Shell Lib is available at : https://github.com/Offirmo/offirmo-shell-lib

Introduction 
============

The user story
--------------
I found myself having to write a lot of shell scripts, for work and for home.

Over the time, I had to develop a lot of useful functions.

One day, I cleaned them up and packed them in this lib. Enjoy !

Requirements
------------
The OSL is targeted at bash, though since I used to be forced to use ksh, it should be mostly compatible with ksh.

Installation
------------
Get a copy of the files and set your path to point to the OSL "bin" dir.
You can chek if it works by typing :

 `osl_help.sh`
 
In your scripts, add this as soon as possible (ideally first instruction in your script for maximum features) :

 `source osl_lib_init.sh`

Usage
-----

On demand, source other OSL files as needed :

libs :
- `osl_lib_archive.sh     `  --> decompress any archive file
- `osl_lib_capabilities.sh` --> detect version and check capabilities of host OS
- `osl_lib_debug.sh       `  --> traces
- `osl_lib_exit.sh        `  --> to abort execution with nice messages
- `osl_lib_init.sh        `  --> allow output saving and various nice hacks
- `osl_lib_output.sh      `  --> various display functions : error, warnings...
- `osl_lib_rsrc.sh        `  --> safe rsrc manipulation protected by mutex
- `osl_lib_sspec.sh       `  --> shell unit tests, inspired from rspec
- `osl_lib_stamp.sh       `  --> manip of stamp files to detect access time and interferences
- `osl_lib_string.sh      `  --> string utilities
- `osl_lib_ui.sh          `  --> UI functions like asking yes or no, pause...
- `osl_lib_version.sh     `  --> version comparison utilities (newer/older)
- `osl_inc_ansi_codes.sh  `  --> defines ANSI codes for color

Special files :
 osl_help.sh  --> callable, display current OSL version
 osl_inc_env.sh  --> various constants

Experimental / in progress :
 osl_lib_interrupt_func.sh  --> exit hook (for mutex auto release)
 osl_lib_mutex.sh  --> create and use mutexes

  
That's it. You can now use the features.


The functions
=============

ANSI (color) codes
------------------

First there is a very useful feature : ANSI color codes definitions. Having an error message displayed in bright RED and a success message in green is extremely helpful !

 `echo -en $OSL_ANSI_CODE_SET_FG_GREEN$OSL_ANSI_CODE_SET_BRIGHT`
 `echo -n "Success !"`
 `echo -e $OSL_ANSI_CODE_RESET`

Styled display (echo) functions
-------------------------------

Various echo wrappers functions :

 `OSL_OUTPUT_notify <message>`
 `OSL_OUTPUT_warn <message>`           <-- in orange
 `OSL_OUTPUT_display_error_message <message>`   <-- in red of course
 `OSL_OUTPUT_warn_not_implemented`
 
 `OSL_debug <message>`      <-- output in light gray prefixed with [debug]
 `OSL_debug_multi <multi-line message>`    <-- output in light gray prefixed with [debug]

Flow control
------------
Those functions abort (exit) the execution of the script :

 OSL_EXIT_abort_execution_with_message <message>
 OSL_EXIT_abort_execution_because_not_implemented

Saving output to a file
-----------------------
A cool feature is the ability to have a copy of the script output sent to a file, while still displaying normal output (using "tee")

 OSL_INIT_engage_tee_redirection_to_logfile

Various UI functions
--------------------

 OSL_UI_ask_confirmation <pending operation>
 OSL_UI_pause

and more, doc to do.


TODO
====

- Better doc ;)
- Make default values redefinable
- Make it easier to disable color
- asserts ?
- More...
