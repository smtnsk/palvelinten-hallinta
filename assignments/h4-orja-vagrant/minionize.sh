#!/bin/sh

## Require root privileges
if [ "$(id -u)" -ne "0" ]; then
    printf "ERROR: This script needs to be run with root priviliges.\n"
    exit
fi

## Require 2 arguments (master and id)
if [ "$#" -eq "2" ]; then
    ## Install salt-minion if necessary
    if [ ! -x "$(command -v salt-minion)" ]; then
	printf "\nsalt-minion not found, installing ... "
	
	apt-get update > /dev/null
	apt-get install salt-minion -y > /dev/null

	printf "Done!"
    fi
    
    printf "\nModifying /etc/salt/minion ... "

    sed -i "1s/^/master: $1\nid: $2\n/" /etc/salt/minion

    printf "Done!"
    printf "\nRestarting salt-minion ...\n\n"

    systemctl restart salt-minion
    sleep 1
    systemctl status salt-minion
else
    printf "ERROR: Invalid number of arguments.\nCorrect usage: ./minionize.sh <master> <id>\n"
    exit
fi
