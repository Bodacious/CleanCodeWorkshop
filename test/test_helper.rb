ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

require "mocha/minitest"

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all

    protected

    def test_yaml_store_path
      Rails.root.join("db/#{Rails.env}.products.yml")
    end
    def create_test_yaml_store
      FileUtils.touch(test_yaml_store_path)
    end
    def destroy_test_yaml_store
      FileUtils.rm(test_yaml_store_path)
    end
  end
end
