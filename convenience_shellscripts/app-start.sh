#!/bin/bash
#pg-start=
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start &
echo 'postgres started'
#rails server
rails s &
echo 'rails started'
#redis-start=
redis-server ~/.rvm/etc/redis.conf &
echo 'redis started'
#sidekiq-start=
bundle exec sidekiq -C /Users/philipphofmann/Dev/rails_projects/Feed-Player/config/sidekiq.yml &
echo 'sidekiq started'
