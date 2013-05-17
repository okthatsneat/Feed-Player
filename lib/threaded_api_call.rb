# credit http://softwarebyjosh.com/2012/02/29/design-pattern-threads-with-retries.html
class ThreadedApiCall

  def initialize(options, &block)
    execute_in_thread(DEFAULT_OPTS.merge(options), &block)
  end

  def join
    @thread.join
  end

  def result
    @result
  end

  private

  def execute_in_thread(opts, &block)
    @thread = Thread.new do 
      attempts = 0
      wait_time = 1

      while (attempts < opts[:max_attempts])
        begin
          attempts += 1
          @result = block.call
        rescue Exception => e
          opts[:logger].error "request failed for: #{opts[:name]}"
          opts[:logger].info "will retry in #{wait_time} seconds" if attempts < opts[:max_attempts]
          sleep wait_time

          # exponential backoff between retries
          wait_time *= opts[:wait_interval]
        ensure
          opts[:logger].flush
        end
      end
    end
  end

  DEFAULT_OPTS = {
    :name          => "generic api request",
    :max_attempts  => 2,
    :logger        => Rails.logger,
    :wait_interval => 2 # seconds
  }
end