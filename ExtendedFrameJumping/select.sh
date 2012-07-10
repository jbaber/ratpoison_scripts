#!/bin/sh

# select.sh - a script for convenient window switching in ratpoison.

if [ $# -eq 0 ]; then
  echo Usage: select.sh REGEXP NAME COMMAND
  echo Example: bind e exec select.sh \'\^\(Emacs:\|emacs\@\)\' Emacs emacs \&
  exit 1
elif [ -n "$4" ]; then
  echo "Too many arguments."
  exit 1
fi

## Command line arguments
regexp="$1"
name="$2"
command="$3"

## The list of windows
windows="$(ratpoison -c 'windows %n %s %l %t')" # The list of windows.

## Count the number of matching windows
matches=0 # The number of windows that matches $regexp.

i=0; while true; do
  i=$(($i+1))
  window="$(echo "$windows"|tr '\n' '\t'|cut -f$i)"
  [ -z "$window" ] && break
  if echo "$(echo "$window"|cut -d' ' -f4-)"|egrep -q "$regexp"; then
    matches=$(($matches+1))
  fi
done

## Select the most recent window matching $regexp, except for the
## current one. If no window matches, run $command.
if [ $matches -gt 0 ]; then
  i=0; while true; do
    i=$(($i+1))
    window="$(echo "$windows"|sort -nrk3|tr '\n' '\t'|cut -f$i)"
    if echo "$(echo "$window"|cut -d' ' -f4-)"|egrep -q "$regexp"; then
      if [ "$(echo "$window"|cut -d' ' -f2)" = '*' ]; then
	if [ $matches = 1 ]; then
	  exec ratpoison -c "echo No other $name window"
	else
	  continue
	fi
      else
	exec ratpoison -c "select $(echo "$window"|cut -d' ' -f1)"
      fi
    fi
  done
else
  exec $command
fi
