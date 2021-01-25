#!/bin/bash

runtime=$1
endtime=$(date -ud "$runtime"seconds +%s)

initial_process=$(ps ax -o pid,user,ppid,cmd | grep -v "ps ax" | grep -v $0)
var=""

if [ $# -gt 2 ] || [ $# -lt 1 ]
then
    echo -e "Please provide the number of seconds to monitor the sistem as argument\n"
    exit 1
fi

NC='\033[0m'
GR='\033[1;32;1;40m'
RED='\033[1;31;1;40m'
YL='\033[1;33;4;40m'
LC='\033[1;36m'

while [[ $(date -u +%s) -le $endtime ]]
do
    new_process=$(ps ax -o pid,user,ppid,cmd | grep -v "ps ax" | grep -v $0)
    difr=$(diff <(echo "$initial_process") <(echo "$new_process") | grep [\<\>])
    while IFS= read -r line
    do
        if [[ $line = \>* ]]
        then
            pid=$(echo "$line" | tr -s ' ' | cut -d' ' -f2)
            user=$(echo "$line" | tr -s ' ' | cut -d' ' -f3)
            cmd=$(echo "$line" | tr -s ' ' | cut -d' ' -f 5-)
            ppid=$(echo "$line" | tr -s ' ' | cut -d' ' -f4)
            pcmd=$(echo -e "$initial_process\n$new_process" | grep "$ppid" | tr -s ' ' | cut -d' ' -f 5- | head -n 1)
            var="$var$user,$pid,$cmd,$ppid,$pcmd\n"
        fi
    done <<< $difr
    initial_process=$new_process

done

if [ "$#" -eq 1 ]
then
    echo -e "$var" | sed '/^$/d' > log.txt
fi

if [ "$#" -eq 2 ]
then
    (echo -e "$var" | grep "$2" | sed '/^$/d') > log.txt
    (echo -e "$var" | grep -v "$2" | sed '/^$/d') >> log.txt
fi

while IFS= read -r line
do
            echo -e "${GR}=====================================${NC}"
            echo -e "${YL}[+] New process started:${NC}"
            echo -en "${LC}USER:${NC} "
            echo "$line" | cut -d',' -f1

            echo -en "${LC}PID:${NC} "
            echo "$line" | cut -d',' -f2

            echo -en "${LC}COMMAND:${NC} "
            echo "$line" | cut -d',' -f3

            echo -en "${LC}PPID:${NC} "
            echo "$line" | cut -d',' -f4

            echo -en "${LC}PCMD:${NC} "
            echo "$line" | cut -d',' -f5
            echo -e "${RED}=====================================${NC}"

            echo
            echo

done <<< $(cat log.txt | grep '\S')
