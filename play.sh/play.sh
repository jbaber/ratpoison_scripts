#!/bin/bash

MUSIC=/home/yourhome/

name=`ratpoison -c "prompt Play "`

echo $name

if [ -z "$name" ] 

then

ratpoison -c "echo Nothing to play"

exit 0

fi

#killall mplayer

trap 'killall mplayer ; ratpoison -c "echo Stopped playing"' KILL

trap 'killall mplayer ; ratpoison -c "echo Stopped playing"' STOP

trap 'killall mplayer ; ratpoison -c "echo Stopped playing"' TERM

i=1

declare -a playlist

find $MUSIC -type f -iname "*$name*mp3" -print | sort |

(

read x

while [ -n "$x" ]

do

playlist[${i}]="$x"

i=`expr $i + 1`

read x

done

for i in `seq 1 "${#playlist[*]}"`

do

ratpoison -c "echo NP: ${playlist[i]#$MUSIC}" & 

mplayer "${playlist[i]}"

done

ratpoison -c "echo Finished playing"

)
