	class App < Sinatra::Base
	enable :sessions
	require 'open-uri'
	require 'json'
	require 'addressable'
	
	get('/') do
		slim(:home)
	end
	
	post('/') do	
		username = params["username"]
		session[:user] = username
		redirect('/username')
	end
	
	get ('/username') do
		username = session[:user]
		dbcooper = SQLite3::Database.new("db/league.sqlite")
		summoner_name = Addressable::URI.dbcooper.execute("SELECT summoner_name from summoner_info where summoner_name = #{username}")
		if username == summoner_name
			dbcooper.execute("SELECT * from profilenumber")
			slim_data = []
			slim_data = slim_data.push(summoner_name, summoner_level, summoner_profile, league_rank_data, champ_name)
			slim(:index, locals:{ slim_data: slim_data})
		else
		league_url = Addressable::URI.parse("https://euw1.api.riotgames.com/lol/summoner/v3/summoners/by-name/#{username}?api_key=RGAPI-46a634d6-6091-4f78-a779-d342a7dfde77")
		league_url = league_url.normalize
		league = open(league_url)
		league_data = JSON.parse(league.read)
		summonerid = league_data['id']
		accountid = league_data['accountId']
		summoner_name = league_data['name']
		summoner_level = league_data['summonerLevel']
		summoner_profile = league_data['profileIconId']
		league_match = open("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/#{accountid}?api_key=RGAPI-46a634d6-6091-4f78-a779-d342a7dfde77")
		league_match_info = JSON.parse(league_match.read)
		match1 = league_match_info
		match_list = match1['matches']
		match2 = match_list[0]
		match2_champid = match2['champion']
		champion_list = open("https://euw1.api.riotgames.com/lol/static-data/v3/champions/#{match2_champid}?api_key=RGAPI-46a634d6-6091-4f78-a779-d342a7dfde77")
		championinfo_parse = JSON.parse(champion_list.read)
		champ_name = championinfo_parse["name"]
		league_rank = open("https://euw1.api.riotgames.com/lol/league/v3/positions/by-summoner/#{summonerid}?api_key=RGAPI-46a634d6-6091-4f78-a779-d342a7dfde77")
		league_rank_data = JSON.parse(league_rank.read)
		league_rank_data = league_rank_data[0]
		slim_data = []
		slim_data = slim_data.push(summoner_name, summoner_level, summoner_profile, league_rank_data, champ_name)
		dbcooper = SQLite3::Database.new("db/league.sqlite")
		dbcooper.execute("INSERT INTO summoner_info ('summoner_name', 'summoner_level', 'summoner_profile', 'league_rank_data', 'champ_name') VALUES(?,?,?,?,?)",[summoner_name, summoner_level, summoner_profile, league_rank_data, champ_name])
		if league_rank_data == nil
			slim(:index, locals:{ slim_data: slim_data})
		else
			summoner_wins = league_rank_data['wins']
			summoner_losses = league_rank_data['losses']
			summoner_tier = league_rank_data['tier']
			summoner_rank = league_rank_data['rank']
			slim_data = slim_data.push(summoner_wins, summoner_losses, summoner_tier, summoner_rank)
			slim(:index, locals:{ slim_data: slim_data })
		end
	end
	end
end          

