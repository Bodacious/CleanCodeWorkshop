require 'bundler'

Bundler.require(:sinatra)

require_relative './config/boot'
run ThirdPartyService