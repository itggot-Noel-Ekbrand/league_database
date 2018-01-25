class App < Sinatra::Base
enable :sessions
require 'open-uri'
require 'json'

	get('/') do
		slim(:home)
	end

	post('/') do
	username = params["username"]
	session[:user] = username
	redirect('/:username')
	end

	get ('/:username') do
		username = session[:user]
		league = open("https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{username}?api_key=RGAPI-f682ce01-381b-4485-8cc8-8bbd8eb30684")
		league_data = JSON.parse(league.read)
		summoner_name = league_data['name']
		summoner_level = league_data['summonerLevel']
		summoner_profile = league_data['profileIconId']
		slim(:index, locals:{ summoner_name:summoner_name, summoner_level:summoner_level, summoner_profile:summoner_profile })
	end


end           


