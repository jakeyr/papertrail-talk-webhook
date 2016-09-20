require 'yajl'
require "net/http"
require 'net/https'
require "uri"
require 'active_support'

SPEAK_URL = ENV['SPEAK_URL'] || "http://localhost:7388/speak"

def speak(message)
  return lambda { Unirest.post "#{SPEAK_URL}/speak",
                        headers:{ "Content-Type" => "application/json" },
                        parameters: {message: message}.to_json
  }
end

def play(url)
  return lambda { Unirest.post "#{SPEAK_URL}/play",
                        headers:{ "Content-Type" => "application/json" },
                        parameters: {url: url}.to_json
  }
end

$ACTION_MAP = {
  13445233 => speak("New A M S loan has been boarded")
  #13445233 => play("http://www.moviesoundclips.net/download.php?id=1628&ft=mp3")
}

module PapertrailSpeakWebhook
  class App < Sinatra::Base
    get '/' do
      "200\n"
    end

    post '/submit' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))

      puts "Request going to #{SPEAK_URL}"

      puts payload['saved_search']['id']
      puts  $ACTION_MAP[payload['saved_search']['id']]
      response = $ACTION_MAP[payload['saved_search']['id']].call()

      puts response.body

      'ok'
    end
  end
end
