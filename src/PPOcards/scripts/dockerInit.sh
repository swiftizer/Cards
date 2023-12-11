#!/bin/bash

echo "Opening Docker..."
open /Applications/Docker.app 

# Wait for Docker to start
echo "Waiting for Docker to start..."
while ! docker system info > /dev/null 2>&1; do
    # Docker does not seem to be running, sleep for a while
    sleep 5
done

echo "Docker is running, setting up docker-compose..."
sudo docker-compose -f /Users/ser.nikolaev/Desktop/web/lab_05_web/docker-compose.yml up -d

if [ $? -ne 0 ] 
then
    echo -e "\nOh shit, he we go again...\n"
    sudo docker-compose -f /Users/ser.nikolaev/Desktop/web/lab_05_web/docker-compose.yml down
    sudo docker-compose -f /Users/ser.nikolaev/Desktop/web/lab_05_web/docker-compose.yml up -d
fi
