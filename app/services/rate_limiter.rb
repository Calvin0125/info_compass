class RateLimiter 
  def initialize(frequency_in_seconds)
    @time_of_last_call = Time.now - frequency_in_seconds
    @frequency_in_seconds = frequency_in_seconds
  end

  def limit
    @time_since_last_call = Time.now - @time_of_last_call
    if @time_since_last_call < @frequency_in_seconds
      sleep @frequency_in_seconds - @time_since_last_call
    end
    @time_of_last_call = Time.now
    yield
  end
end
