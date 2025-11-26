#!/bin/bash

# Wait for everything to be ready - User Data runs very fast! 
sleep 15

# user data runs as root!
cd /home/ubuntu

# cd to correct folder
cd nodejs20-se-test-app-2025
cd app

# DB connection env var
export DB_HOST=mongodb://<PRIVATE IP MONGODB>:27017/posts

# npm install
sudo npm install

# seed database
node seeds/seed.js

# start app
pm2 start app.js