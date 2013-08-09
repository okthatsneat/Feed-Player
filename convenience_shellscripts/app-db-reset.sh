#!/bin/bash

#stop sidekiq
sidekiqctl stop /Users/philipphofmann/Dev/rails_projects/Feed-Player/tmp/pids/sidekiq.pid 5
sleep 6
echo 'sidekiq stopped'
#stop redis
pkill redis-server
echo 'redis stopped'
#stop rails server
kill -INT $(cat /Users/philipphofmann/Dev/rails_projects/Feed-Player/tmp/pids/server.pid)
echo 'rails stopped'
#reset postgres db
rake db:reset
echo 'postgres reset'
#stop postrgress db server
pg_ctl -D /usr/local/var/postgres stop -s -m fast
echo 'postgres stopped'
rm ./log/development.log
./app-start.sh