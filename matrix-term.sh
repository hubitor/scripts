#!/bin/bash
state=()
data=()
current=""
# Min length of matrix line
MIN=5
W=$(tput cols)
H=$(tput lines)
DATA_SIZE=$((W*(H-1)))
PER_COL=15
PER_LINE=2
SLEEP=0.2
FG_COLOR=32
#BG_COLOR=40

quit() {
	echo -ne "\e[?25h"
	echo -ne "\e[0m"
	stty echo
	clear
	exit 0
}
# set SIGTERM handler
trap quit HUP TERM
# quit the loops on SIGINT
trap 'break 2' INT

# No echo stdin
stty -echo
# hide the cursor
echo -ne "\e[?25l"
# set the output color
echo -ne "\e[1m"
echo -ne "\e[${FG_COLOR}m"
[ -n "$BG_COLOR" ] && echo -ne "\e[${BG_COLOR}m"
clear
# intialize the columns state counter to 0
for ((i=0; i < $W; i++));
do
        state[$i]=0
done

while true;
do
        current=""
        for ((i=0; i < $W; i++));
        do
		# set the new state of the current column
		if (( state[$i] == 0 ))
		then
			(( state[$i] = (RANDOM % PER_COL == 0) ? 1 : 0 ))
		elif (( state[$i] < MIN ))
		then
			(( state[$i]++ ))
		else
			(( state[$i] = (RANDOM % PER_LINE == 0) ? (state[$i] + 1) : 0 ))
		fi
		# if state is 0 add a space otherwise add  0 or 1 (%2)
		(( state[$i] == 0 )) && current="${current} " \
		|| current="${current}$((state[$i]%2))"
        done
	# add the new line to the data
        data="${current}${data:0:$DATA_SIZE}"
        sleep $SLEEP
        echo -ne "\e[1;1H${data}"
done
quit
