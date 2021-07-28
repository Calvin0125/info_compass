require 'rails_helper.rb'

describe RateLimiter do
  it "limits the given block to the given frequency" do
    class TestRateLimiter 
       @@limiter = RateLimiter.new(1)
      def self.hello
        @@limiter.limit { return "hello" }
      end
    end

    time = Time.now
    TestRateLimiter.hello
    TestRateLimiter.hello
    expect(Time.now - time).to be >= 1
  end
end
