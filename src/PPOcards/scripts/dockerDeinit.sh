#!/bin/bash

# Find Docker process
docker_process=$(ps aux | grep '[D]ocker.app' | awk '{print $2}')

# Check if Docker process exists
if [ -z "$docker_process" ]
then
    echo "Docker is not running."
else
    # Kill Docker process
    echo "docker-compose downing..."
    sudo docker-compose -f /Users/ser.nikolaev/Desktop/web/lab_05_web/docker-compose.yml down
    echo "Killing Docker process..."
    kill -9 $docker_process
    echo "Docker process killed."
fi
