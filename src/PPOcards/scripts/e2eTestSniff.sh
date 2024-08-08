#!/bin/bash

# sudo bash scripts/dockerInit.sh
# sleep 1

open DerivedData/Build/Products/Debug-maccatalyst/PPOcards.app
sleep 1

# Run tcpdump in the background and save its PID
sudo tcpdump -i lo0 port 8078 -w log.pcap &
TCPDUMP_PID=$!

python3 getCardSetsE2eTest.py
sleep 3
open log.pcap

sudo kill $TCPDUMP_PID

cards_process=$(ps aux | grep 'PPOcards.app' | awk '{print $2}')

if [ -z "$cards_process" ]
then
    echo "cards is not running."
else
    echo "Killing Cards process..."
    kill -9 $cards_process
fi

# bash scripts/dockerDeinit.sh
