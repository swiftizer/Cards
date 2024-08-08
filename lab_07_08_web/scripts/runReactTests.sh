#!/bin/bash

open ../src/PPOcards/DerivedData/Build/Products/Debug-maccatalyst/PPOcards.app

npm install
npm test -- --watchAll=false
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