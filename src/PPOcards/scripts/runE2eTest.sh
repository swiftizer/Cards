#!/bin/bash

open DerivedData/Build/Products/Debug-maccatalyst/PPOcards.app

python3 getCardSetsE2eTest.py
exit_code=$?

cards_process=$(ps aux | grep 'PPOcards.app' | awk '{print $2}')

if [ -z "$cards_process" ]
then
    echo "cards is not running."
else
    echo "Killing Cards process..."
    kill -9 $cards_process
fi

exit $exit_code