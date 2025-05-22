ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "mocha/minitest"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Override `#run` to make it call `#around` on each test run
    def run
      around { super }
    end

    protected

    def with_temp_db(content = nil, &block)
      Tempfile.open do |tempfile|
        tempfile.write(content.to_s)
        tempfile.rewind
        block.call(tempfile)
      end
    end

    def around
      yield
    end

  end
end
