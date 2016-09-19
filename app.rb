require 'yajl'
require "net/http"
require 'net/https'
require "uri"
require 'active_support'

SPEAK_URL = ENV['SPEAK_URL'] || "http://localhost:7388/speak"

module PapertrailSpeakWebhook
  class App < Sinatra::Base
    get '/' do
      "200\n"
    end

    post '/submit' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))

      puts "Request going to #{SPEAK_URL}"

      response = Unirest.post SPEAK_URL, 
                        headers:{ "Content-Type" => "application/json" }, 
                        parameters: {message: 'New A M S loan boarded.'}.to_json

      puts response.body

      'ok'
    end
  end
end