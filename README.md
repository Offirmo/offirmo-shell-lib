shell-lib
=========

The Offirmo Shell Lib (OSL) is a collection of useful shell (bash) functions for robust and advanced scripts.

The user story
==============
I found myself having to write a lot of shell scripts.
I had to write some functions used often in a lot of scripts.
So I packed them in this lib. Enjoy !

Installation
============
Get a copy of the file and set your path to point to the "bin" dir.
In your script, add this as soon as possible (ideally first instruction) :

 source osl_lib_init.sh

That's it. You can now use the features.


The functions
=============

First there is a very useful feature : ANSI color codes definitions. Having an error message displayed in bright RED and a success message in green is so helpful !

 echo -en $OSL_ANSI_CODE_SET_FG_GREEN$OSL_ANSI_CODE_SET_BRIGHT
 echo -n "Success !"
 echo -e $OSL_ANSI_CODE_RESET

Still with errors, various display functions :

 OSL_OUTPUT_notify <message>
 OSL_OUTPUT_warn <message>           <-- in orange
 OSL_OUTPUT_display_error_message <message>   <-- in red of course
 OSL_OUTPUT_warn_not_implemented
 
 OSL_debug <message>
 OSL_debug_multi <multi-line message>
 
 And functions to abort the execution :
 
 OSL_OUTPUT_abort_execution_with_message <message>
 OSL_OUTPUT_abort_execution_because_not_implemented

A cool feature is the ability to have a copy of the script output sent to a file, while still displaying normal output (using tee of course)

 OSL_INIT_engage_tee_redirection_to_logfile

Various UI functions :

 OSL_UI_ask_confirmation <pending operation>
 OSL_UI_pause

and more, doc to do.


