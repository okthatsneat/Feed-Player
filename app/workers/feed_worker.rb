class FeedWorker
  include Sidekiq::Worker
  
  def perform(feed_id)
		feed = Feed.find(feed_id)
    # get the embeded content and create tracks   
		feed_parser.parse if (feed_parser = FeedParser.new(feed))
  end
end