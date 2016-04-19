require 'sidekiq'
require 'autoscaler/sidekiq'
require 'autoscaler/heroku_scaler'

heroku = nil
if ENV['HEROKU_APP']
  heroku = Autoscaler::HerokuScaler.new
end

Sidekiq.configure_client do |config|
  if heroku
    config.client_middleware do |chain|
      chain.add Autoscaler::Sidekiq::Client, 'default' => heroku
    end
    config.redis = { :size => 1 } # ex http://manuelvanrijn.nl/sidekiq-heroku-redis-calc/
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    if heroku
      p "[Sidekiq] Running on Heroku, autoscaler is used"
      chain.add(Autoscaler::Sidekiq::Server, heroku, 60) # 60 seconds timeout
      
      config.redis = { :size => 8 } # ex http://manuelvanrijn.nl/sidekiq-heroku-redis-calc/

      # ex https://github.com/mperham/sidekiq/wiki/Advanced-Options
      database_url = ENV['DATABASE_URL']
      if database_url
        ENV['DATABASE_URL'] = "#{database_url}?pool=20"
        ActiveRecord::Base.establish_connection
      end

    else
      p "[Sidekiq] Running locally, so autoscaler isn't used"
    end
  end
end
