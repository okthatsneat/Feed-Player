#!/bin/bash

#stop sidekiq, redis, rails, postgres servers
/Users/philipphofmann/Dev/rails_projects/Feed-Player/app-stop.sh
#start postgres db
#start rails server
#start redis
#start sidekiq
/Users/philipphofmann/Dev/rails_projects/Feed-Player/app-start.sh
echo 'app fully restarted'

