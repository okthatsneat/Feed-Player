web: bundle exec unicorn -p $PORT -E $RACK_ENV -c ./config/unicorn.rb
worker: bundle exec sidekiq -e production -C config/sidekiq.yml