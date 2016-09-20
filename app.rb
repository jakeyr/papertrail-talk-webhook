require 'yajl'
require "net/http"
require 'net/https'
require "uri"
require 'active_support'
require 'pg'

SPEAK_URL = ENV['SPEAK_URL'] || "http://localhost:7388/speak"

def speak(message)
  Unirest.post "#{SPEAK_URL}/speak",
    headers:{ "Content-Type" => "application/json" },
    parameters: {message: message}.to_json
end

def play(url)
  Unirest.post "#{SPEAK_URL}/play",
    headers:{ "Content-Type" => "application/json" },
    parameters: {url: url}.to_json
end

def act(id)
  uri = URI.parse(ENV['DATABASE_URL'])

  conn = PG::Connection.open :host     => uri.host,
                             :user     => uri.user,
                             :password => uri.password,
                             :port     => uri.port || 5432,
                             :dbname   => uri.path[1..-1]

  puts "Request going to #{SPEAK_URL}"
  puts "Taking action for alert #{id}"

  res = conn.exec_params('SELECT value,action FROM pt_id_map WHERE pt_id = $1', [id])

  response = send(res[0]['action'],res[0]['value'])
end

module PapertrailSpeakWebhook
  class App < Sinatra::Base
    get '/' do
      "200\n"
    end

    post '/submit/papertrail' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))
      act(payload['saved_search']['id'])
      'ok'
    end

    post '/submit/librato' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))
      act(payload['alert']['id'])
      'ok'
    end

  end
end
