#!/usr/bin/env bash
 #
 # $Id: rprc.sh,v 0.01 2005/10/15 23:21:42 edward Exp $</pre><pre> # -START-[ CONFIGURATION ]------------------------------------------ #</pre><pre> # -START-[ *** SCRIPT WILL NOT WORK WITHOUT SETTING THIS *** ]------ #
 # Full path to this script e.g. /usr/local/bin/rprc.sh
 #+ this needs to be set in order for ratpoison keybinds to work
 RPRC=""
 # -END-[ *** SCRIPT WILL NOT WORK WITHOUT SETTING THIS *** ]-------- #</pre><pre> # Default multiplier for mouse pointer rate unless otherwise
 #+ specified with -r, --rate
 MULTIPLIER="7"
 # Keys to use for mouse pointer manipulation
 # North
 KEY[0]="8"
 # East
 KEY[1]="6"
 # South
 KEY[2]="2"
 # West
 KEY[3]="4"
 # Northeast
 KEY[4]="9"
 # Northwest
 KEY[5]="7"
 # Southeast
 KEY[6]="3"
 # Southwest
 KEY[7]="1"
 # Mouse button 1
 KEY[8]="F1"
 # Mouse button 2
 KEY[9]="F2"
 # Mouse button 3
 KEY[10]="F3"
 # Mouse toggle hold button 1
 KEY[11]="F4"
 # Mouse toggle hold button 2
 KEY[12]="F5"
 # Mouse toggle hold button 3
 KEY[13]="F6"
 # -END-[ CONFIGURATION ]-------------------------------------------- #</pre><pre> # .Run a ratpoison command
 function rpc () {
   ratpoison --command "$*"
 }</pre><pre> if [ -z "$RPRC" ]; then
   printf "*** WARNING, YOU HAVE NOT SET \$RPRC IN $0 ***\n"
   printf "*** SCRIPT WILL NOT WORK PROPERLY UNTIL YOU DO SO ***\n"
 fi</pre><pre> if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
   # Print help
   PFFMT=( "%s\n" "   %-4s %-13s %s\n" )
   printf "${PFFMT[0]}" "Usage: $0 [arguments]"
   printf "${PFFMT[1]}" "-h," "--help" "Print this help message"
   printf "${PFFMT[1]}" "-i," "--initialize" "Initialize this script"
   printf "${PFFMT[1]}" "-t," "--toggle" "Toggle accepts (keybinds, button1, button2, and button3"
   printf "${PFFMT[1]}" "-r," "--rate" "Multiplier for manipulating mouse pointer rate"
   printf "${PFFMT[1]}" "-n," "--north" "Move mouse pointer north"
   printf "${PFFMT[1]}" "-e," "--east" "Move mouse pointer east"
   printf "${PFFMT[1]}" "-s," "--south" "Move mouse pointer south"
   printf "${PFFMT[1]}" "-w," "--west" "Move mouse pointer west"
   printf "${PFFMT[1]}" "-ne," "--northeast" "Move mouse pointer northeast"
   printf "${PFFMT[1]}" "-nw," "--northwest" "Move mouse pointer northwest"
   printf "${PFFMT[1]}" "-se," "--southeast" "Move mouse pointer southeast"
   printf "${PFFMT[1]}" "-sw," "--southwest" "Move mouse pointer southwest"
 fi</pre><pre> if [ "$1" == "-i" ] || [ "$1" == "--initialize" ]; then
   rpc alias rprc exec bash $RPRC --toggle keybinds
   rpc definekey root M rpr..c
 fi</pre><pre> if [ "$1" == "-t" ] || [ "$1" == "--toggle" ]; then
   # Toggle some useful keybindings for mouse pointer control
   if [ "$2" == "keybinds" ]; then
     if (( `rpc getenv rprc` == 1 )); then
       until (( ${NUMBER:=0} == ${#KEY[*]} )); do
         rpc undefinekey top ${KEY[$NUMBER]}
         (( NUMBER++ ))
       done
       rpc setenv rprc 0
     else
       rpc definekey top ${KEY[0]} exec bash $RPRC --north
       rpc definekey top ${KEY[1]} exec bash $RPRC --east
       rpc definekey top ${KEY[2]} exec bash $RPRC --south
       rpc definekey top ${KEY[3]} exec bash $RPRC --west
       rpc definekey top ${KEY[4]} exec bash $RPRC --northeast
       rpc definekey top ${KEY[5]} exec bash $RPRC --northwest
       rpc definekey top ${KEY[6]} exec bash $RPRC --southeast
       rpc definekey top ${KEY[7]} exec bash $RPRC --southwest
       rpc definekey top ${KEY[8]} ratclick 1
       rpc definekey top ${KEY[9]} ratclick 2
       rpc definekey top ${KEY[10]} ratclick 3
       rpc definekey top ${KEY[11]} exec bash $RPRC --toggle button1
       rpc definekey top ${KEY[12]} exec bash $RPRC --toggle button2
       rpc definekey top ${KEY[13]} exec bash $RPRC --toggle button3
       rpc setenv rprc 1
     fi
   elif [ "$2" == "button1" ]; then
     [ "`rpc getenv rprcbutton1`" == "(null)" ] &amp;&amp; rpc setenv rprcbutton1 up
     if [ `rpc getenv rprcbutton1` == "down" ]; then
       rpc rathold up 1
       rpc. setenv rprcbutton1 up
     elif [ `rpc getenv rprcbutton1` == "up" ]; then
       rpc rathold down 1
       rpc setenv rprcbutton1 down
     fi
   elif [ "$2" == "button2" ]; then
     [ "`rpc getenv rprcbutton2`" == "(null)" ] &amp;&amp; rpc setenv rprcbutton2 up
     if [ `rpc getenv rprcbutton2` == "down" ]; then
       rpc rathold up 2
       rpc setenv rprcbutton2 up
     elif [ `rpc getenv rprcbutton2` == "up" ]; then
       rpc rathold down 2
       rpc setenv rprcbutton2 down
     fi
   elif [ "$2" == "button3" ]; then
     [ "`rpc getenv rprcbutton3`" == "(null)" ] &amp;&amp; rpc setenv rprcbutton3 up
     if [ `rpc getenv rprcbutton3` == "down" ]; then
       rpc rathold up 3
       rpc setenv rprcbutton3 up
     elif [ `rpc getenv rprcbutton3` == "up" ]; then
       rpc rathold down 3
       rpc setenv rprcbutton3 down
     fi
   fi
 fi</pre><pre> if [ "$1" == "-r" ] || [ "$1" == "--rate" ]; then
   [ "$2" ] &amp;&amp; MULTIPLIER="$2" &amp;&amp; shift
   shift
 fi</pre><pre> if [ "$1" == "-n" ] || [ "$1" == "--north" ]; then
   # Move cursor north
   rpc ratrelwarp 0 $(( -1 * $MULTIPLIER ))
 elif [ "$1" == "-e" ] || [ "$1" == "--east" ]; then
   # Move cursor east
   rpc ratrelwarp $(( 1 * $MULTIPLIER )) 0
 elif [ "$1" == "-s" ] || [ "$1" == "--south" ]; then
   # Move cursor south
   rpc ratrelwarp 0 $(( 1 * $MULTIPLIER ))
 elif [ "$1" == "-w" ] || [ "$1" == "--west" ]; then
   # Move cursor west
   rpc ratrelwa.rp $(( -1 * $MULTIPLIER )) 0
 elif [ "$1" == "-ne" ] || [ "$1" == "--northeast" ]; then
   # Move cursor northeast
   rpc ratrelwarp $(( 1 * $MULTIPLIER )) $(( -1 * $MULTIPLIER ))
 elif [ "$1" == "-nw" ] || [ "$1" == "--northwest" ]; then
   # Move cursor northwest
   rpc ratrelwarp $(( -1 * $MULTIPLIER )) $(( -1 * $MULTIPLIER ))
 elif [ "$1" == "-se" ] || [ "$1" == "--southeast" ]; then
   # Move cursor southeast
   rpc ratrelwarp $(( 1 * $MULTIPLIER )) $(( 1 * $MULTIPLIER ))
 elif [ "$1" == "-sw" ] || [ "$1" == "--southwest" ]; then
   # Move cursor southwest
   rpc ratrelwarp $(( -1 * $MULTIPLIER )) $(( 1 * $MULTIPLIER ))
 fi
