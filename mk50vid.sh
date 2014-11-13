#!/bin/bash
SIZE=$1
SPEED=$2
DECAY=$3
FILE="50pict-size${SIZE}-quartz-speed${SPEED}-decay${DECAY}-3-7s"
go run pict.go --speed=$SPEED --decay=$DECAY --size=$SIZE > $FILE.sco
csound -o $FILE.wav sine.orc $FILE.sco
#mplayer 50.mov --audiofile=$FILE.wav
avconv  -i 50.mov -i $FILE.wav  -c:v libx264 $FILE.mp4
