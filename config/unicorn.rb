# Minimal sample configuration file for Unicorn (not Rack) when used
# with daemonization (unicorn -D) started in your working directory.
#
# See http://unicorn.bogomips.org/Unicorn/Configurator.html for complete
# documentation.
# See also http://unicorn.bogomips.org/examples/unicorn.conf.rb for
# a more verbose configuration using more features.

#listen 2007 # by default Unicorn listens on port 8080
worker_processes 2 # this should be >= nr_cpus
pid "/Users/philipphofmann/Dev/rails_projects/Feed-Player/tmp/pids/unicorn.pid" if ENV['RAILS_ENV'] == "development"
#stderr_path "/path/to/app/shared/log/unicorn.log"
#stdout_path "/path/to/app/shared/log/unicorn.log"

preload_app true

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end
  sleep 1
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end

  if defined?(Sidekiq)
    Sidekiq.configure_client do |config|
      config.redis = { :size => 1 }
    end
  end
end
