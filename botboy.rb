require 'discordrb'
# Require Gems
require 'json'
require 'urban_dict'
require 'htmlentities'
require 'securerandom'
require 'rest_client'
require 'rmagick'
# Create directories
dirs = ['cache','discards','discards/servers']
dirs.each do |dir|
	if Dir.exists?(dir)
		system 'mkdir '+dir
	end
end

token, app_id = File.read('bb-auth').lines

# ad88888ba   88888888888 888888888888 888888888888 88 888b      88   ,ad8888ba,   ad88888ba 
# d8"     "8b 88               88           88      88 8888b     88  d8"'    `"8b d8"     "8b
# Y8,         88               88           88      88 88 `8b    88 d8'           Y8,        
# `Y8aaaaa,   88aaaaa          88           88      88 88  `8b   88 88            `Y8aaaaa,  
#   `"""""8b, 88"""""          88           88      88 88   `8b  88 88      88888   `"""""8b,
#         `8b 88               88           88      88 88    `8b 88 Y8,        88         `8b
# Y8a     a8P 88               88           88      88 88     `8888  Y8a.    .a88 Y8a     a8P
#  "Y88888P"  88888888888      88           88      88 88      `888   `"Y88888P"   "Y88888P" 

# When turned on, every processed discard will stay in its directory "discards"
@savediscards = false

# When turned on, when processing a discard, will use the nickname of a user instead of the username.
@discardreplacename = false

# When turned on, when processing a discard, greys out avatars when that member is offline.
@discardgray = true

# These are API settings for Discord RPG API.
@drpguseragent = ""
@drpgapikey = ""

bot = Discordrb::Commands::CommandBot.new(token: token, application_id: app_id.to_i, prefix: ['^','<@!USER_ID> ','<@USER_ID> '])

def DRPGreq(apireq)
    RestClient.get("http://api.discorddungeons.me/"+apireq,:'User-Agent' => @drpguseragent, :'X-Api-Key' => @drpgapikey)
end

module Join
  extend Discordrb::EventContainer

  server_create do |event|
  event.bot.send_message(event.server.id,"Hello! I am BotBoy! Made by **Snazzah**
My purpose is to be entertaining and be useful!

If you have any other questions and need support, join this discord server: https://discord.gg/0vjTDaDsgOMlC5BB
To start, type `^help` in chat.

*Thanks!*")
  end
end

class Fixnum
  ROMAN_NUMBERS = {
    1000 => "M",  
     900 => "CM",  
     500 => "D",  
     400 => "CD",
     100 => "C",  
      90 => "XC",  
      50 => "L",  
      40 => "XL",  
      10 => "X",  
        9 => "IX",  
        5 => "V",  
        4 => "IV",  
        1 => "I",  
        0 => "",  
  }
  def roman
    return '' if self == 0
    ROMAN_NUMBERS.each do |value, letter|
      return ( letter * (self / value)) << (self % value).roman if value <= self
    end
    return (self % value).roman
  end
  
  def format
	return self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end
end

class Float
  def format
	return self.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  end
end

enterchar = "
"

bot.include! Join

bot.command :invite do |event, *args|
  event << "To invite me, use this link,"
  event << "     #{event.bot.invite_url}" + "&permissions=44094"
end

bot.command :lmgtfy do |event, *args|
  event << "#{event.user.mention} <http://lmgtfy.com/?q=" + args.join('+') + ">"
end

bot.command :atari do |event, *args|
  if args.join(" ") == "" 
  event << "Play Atari Breakout with Google images with this link:"
  event << "***https://www.google.com/search?q=atari+breakout&tbm=isch***"
  event << "You can also have custom images by doing the following command and the image keyword!"
  else
  event << "Play Atari Breakout with Google images of **#{args.join(' ')}** with this link:"
  event << "***https://www.google.com/search?q=" + args.join('+') + "&tbm=isch&tbs=boee:1***"
  end
end

bot.command :urban do |event, *args|
  defin = nil
  if args.join(' ') == ''
  defin = UrbanDict.random
  else
  defin = UrbanDict.define(args.join(' '))
  end
  event << "***#{defin['word']}***               *by #{defin['author']}*"
  event << ""
  event << "#{defin['definition']}"
  event << ""
  event << "*#{defin['example']}*"
  event << ""
  event << "#{defin['thumbs_up']} ? | #{defin['thumbs_down']} ??"
  event << "***<#{defin['permalink']}>***"
end
=begin
bot.command :weather do |event, *args|
  if args.join(' ') == ''
  "No argument!"
  else
  lookup = weather.lookup_by_location(args.join(' '))
  event << lookup
  end
end
=end

bot.command :mcserv do |event, *args|
	begin
		serv = JSON.parse(RestClient.get("https://mcapi.ca/query/"+args[0]+"/info"))
	rescue => e
		event.channel.send_message("BAD REQUEST!\n```\n"+e.inspect+"\n```")
	end
	if serv['status']
		event << "MOTD: "+serv['motd']
		event << "Version: "+serv['version']
		event << "Players: "+serv['players']['online']+"/"+serv['players']['max']
		event << "Ping: "+serv['ping']
	else
		"**Invalid Server!**"
	end
end

bot.command :pokemon do |event, *args|
	if args[0] == "name" && args.count > 1
		event.channel.start_typing()
		begin
		begin
			pkm = JSON.parse(RestClient.get("http://pokeapi.co/api/v2/pokemon/"+args[1].downcase))
			typs = []
			pkm['types'].each_index { |ty| typs[pkm['types'][ty]['slot']] = "`"+pkm['types'][ty]['type']['name'].upcase+"`" }
			event << "**Name**: **"+typs.join(" ")+"** "+pkm['name'].capitalize
			event << "**ID**: "+pkm['id'].to_s
			event << "**Height**: "+pkm['height'].to_s
			event << "**Weight**: "+pkm['weight'].to_s
			#event << "**Moves**:"
			#pkm['moves'].each {|ind| event << "   "+ind.to_json}
			#pkm['moves'].each do |ind|
				#move = JSON.parse(RestClient.get(ind['url']))
				#event << "   `#{move['type']['name']}` "+ind['name']
				#event << "   "+ind['name']
			#end
			event << "http://img.pokemondb.net/artwork/#{pkm['name']}.jpg"
		rescue RestClient::ResourceNotFound
			"**Unable to find a pokemon with that name!**"
		end
		rescue RestClient::GatewayTimeout
			"**The API request timed out!**"
		end
	elsif args[0] == "generation" && args.count > 1
		event.channel.start_typing()
		begin
		begin
			if args[1].downcase.include?("generation-")
				move = JSON.parse(RestClient.get("http://pokeapi.co/api/v2/generation/"+args[1].downcase.gsub(/generation-/, "")))
			else
				move = JSON.parse(RestClient.get("http://pokeapi.co/api/v2/generation/"+args[1].downcase))
			end

			typ = []
			move['types'].each { |ty| typ.insert(0,ty['name'].capitalize) }
			vers = []
			move['version_groups'].each do |ty|
				ver2 = ty['name'].split('-')
				ver2.each {|tr| vers[vers.count] = tr.capitalize }
			end
			event << "**Name**: "+move['name'].gsub(/generation-/, "").upcase+" (#{move['id'].to_s})"
			event << "**Main Region**: "+move['main_region']['name']
			event << move['pokemon_species'].count.to_s+" **Pokemon species**"
			event << move['moves'].count.to_s+" **Moves**"
			event << move['abilities'].count.to_s+" **Abilities**"
			event << move['types'].count.to_s+" **Types**"
			event << vers.count.to_s+" **Versions**: "+vers.join(", ")
		rescue RestClient::ResourceNotFound
			"**Unable to find a move with that name!**"
		end
		rescue RestClient::GatewayTimeout
			"**The API request timed out!**"
		end
	elsif args[0] == "move" && args.count > 1
		event.channel.start_typing()
		begin
		begin
			move = JSON.parse(RestClient.get("http://pokeapi.co/api/v2/move/"+args[1..args.limit].downcase.gsub(/[ ]/,"-")))
			event << "**Name**: "+move['name'].gsub(/-/," ").capitalize
			event << "**ID**: "+move['id'].to_s
			event << "**Type**: "+move['type']['name'].capitalize
			event << "**Accuracy**: "+move['accuracy'].to_s
			event << "**PP**: "+move['pp'].to_s
			event << "**Power**: "+move['power'].to_s
			move['effect_chance'] == nil ? event << "**Effect Chance**: None" : event << "**Effect Chance**: "+move['effect_chance'].to_s+"%"
		rescue RestClient::ResourceNotFound
			"**Unable to find a move with that name!**"
		end
		rescue RestClient::GatewayTimeout
			"**The API request timed out!**"
		end
	elsif args[0] == "version" && args.count > 1
		event.channel.start_typing()
		begin
		begin
			vers = JSON.parse(RestClient.get("http://pokeapi.co/api/v2/version/"+args[1].downcase))
			versg = JSON.parse(RestClient.get(vers['version_group']['url']))
			event << "**Name**: "+vers['name'].capitalize
			event << "**ID**: "+vers['id'].to_s
			event << "**Generation**: "+versg['generation']['name'].gsub(/generation-/, "").upcase
			if not vers['name'] == versg['name']
				event << "**Other versions accociated with version group `#{versg['name']}`**:"
				versg['versions'].each {|fr| if not fr['name'] == vers['name']; event << "   "+fr['name'].capitalize; end}
				event << ""
			end
		rescue RestClient::ResourceNotFound
			"**Unable to find a version with that name!**"
		end
		rescue RestClient::GatewayTimeout
			"**The API request timed out!**"
		end
	elsif args[0] == "wild"
		event.channel.start_typing()
		begin
		begin
			pkm = JSON.parse(RestClient.get("http://pokeapi.co/api/v2/pokemon/"+SecureRandom.random_number(JSON.parse(RestClient.get("http://pokeapi.co/api/v2/pokemon/"))['count'])))
			typs = []
			pkm['types'].each_index do |ty|
				typs[pkm['types'][ty]['slot']] = "`"+pkm['types'][ty]['type']['name']+"`"
			end
			event << "**Name**: "+typs.join(" ")+" "+pkm['name']
			event << "**ID**: "+pkm['id'].to_s
			event << "**Height**: "+pkm['height'].to_s
			event << "**Weight**: "+pkm['weight'].to_s
			#event << "**Moves**:"
			#pkm['moves'].each {|ind| event << "   "+ind.to_json}
			#pkm['moves'].each do |ind|
				#move = JSON.parse(RestClient.get(ind['url']))
				#event << "   `#{move['type']['name']}` "+ind['name']
				#event << "   "+ind['name']
			#end
			event << "http://img.pokemondb.net/artwork/#{pkm['name']}.jpg"
		rescue RestClient::ResourceNotFound
			"**Unable to find a pokemon with that name!**"
		end
		rescue RestClient::GatewayTimeout
			"**The API request timed out!**"
		end
	end
end

bot.command :roblox do |event, *args|
	cachetoken = SecureRandom.random_number(1000000)
	if args[0] == "user" && args.count > 1
		event.channel.start_typing()
		# Check if Username exists/arg is id?
		rid = 1
		success = true
		if args[1].to_i > 0
			rid = JSON.parse(RestClient.get("http://api.roblox.com/Users/"+args[1]))
			success = rid['success']==nil ? true : rid['success']
			rid = rid['Id']
		else
			rid = JSON.parse(RestClient.get("http://api.roblox.com/users/get-by-username?username="+args[1]))
			success = rid['success']==nil ? true : rid['success']
			rid = rid['Id']
		end
		if success
			parsed = true
			#begin
				badges = JSON.parse(RestClient.get("http://www.roblox.com/badges/roblox?userId="+rid.to_s+"&imgWidth=110&imgHeight=110&imgFormat=png"))
				thumb = JSON.parse(RestClient.get("http://www.roblox.com/bust-thumbnail/json?userId="+rid.to_s+"&height=180&width=180"))
				places = JSON.parse(RestClient.get("http://www.roblox.com/Contests/Handlers/Showcases.ashx?userId="+rid.to_s))
				usrname = +JSON.parse(RestClient.get("http://api.roblox.com/Users/"+rid.to_s))['Username']
			#rescue => e
			#	parsed = false
			#	err = e.inspect
			#end
			#if parsed
			event << "**ID**: "+rid.to_s
			event << "**Username**: "+usrname
			event << "**Avatar**: "+thumb['Url']
			event << "**Places**: "+places['Count']
			alls = []
			places['Showcase'][0..(places['Showcase'].count > 4 ? places['Showcase'].count : 5)].each {|u| alls[alls.length]=u['Name']}
			event << "**Places Showcase**: "+places['Showcase'].join(", ")
			alls2 = []
			badges['RobloxBadges'].each {|u| alls[alls.length]=u['Name']}
			event << "**Badges**: "+alls.join(", ")
			#else
			#	"**API Error!**\n```ruby\n"+err+"\n```"
			#end
		else
			"**User does not exist in ROBLOX!**"
		end
	end
end

bot.command :discard do |event, *args|
	cachetoken = SecureRandom.random_number(1000000)
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	event.channel.start_typing()
	# Avatar Retrieving
	u = event.author
	if args[0] == "-find" && args.count > 1
		cu = bot.find_user(args[1..args.count].join(" ")).first
		if cu
			u = cu
		end
	elsif args[0] == "-wild" || args[0] == "-random"
		u = bot.users.values.sample
	end
	clrs = ['9fade1','fb4c4c','faa61a','faa6ff','11dafa','11dafa','b94fff']
	begin
	if event.message.mentions[0]
		u = event.message.mentions[0]
		if not event.message.mentions[0].avatar_url == 'https://discordapp.com/api/users/'+u.id.to_s+'/avatars/.jpg'
			system 'wget -O cache/discard_'+cachetoken.to_s+'.png ' + event.message.mentions[0].avatar_url
		else
			Magick::Image.new(128, 128) { self.background_color = '#'+clrs.sample.upcase }.composite(Magick::Image.read('assets/dis-card/defaultavatar.png')[0], Magick::CenterGravity, Magick::OverCompositeOp).write('cache/discard_'+cachetoken.to_s+'.png')
		end
	else
		if not u.avatar_url == 'https://discordapp.com/api/users/'+u.id.to_s+'/avatars/.jpg'
			system 'wget -O cache/discard_'+cachetoken.to_s+'.png ' + u.avatar_url
		else
			Magick::Image.new(128, 128) { self.background_color = '#'+clrs.sample.upcase }.composite(Magick::Image.read('assets/dis-card/defaultavatar.png')[0], Magick::CenterGravity, Magick::OverCompositeOp).write('cache/discard_'+cachetoken.to_s+'.png')
		end
	end
	rescue => e
		event.channel.send_message("Bad error retrieveing icon!\n```\n"+e.inspect+"\n```")
	end
	# Image Loading
	bottag = Magick::Image.read('assets/dis-card/bottag.png')[0]
	avatar = Magick::Image.read('cache/discard_'+cachetoken.to_s+'.png')[0]
	avatar.change_geometry!("128x128") { |cols, rows| avatar.thumbnail! cols, rows }
	if @discardgray and u.status.to_s == "offline"
		avatar2 = avatar.channel(Magick::BlueChannel)
		avatar3 = avatar.channel(Magick::RedChannel)
		avatar4 = avatar.channel(Magick::GreenChannel)
		avatar5 = avatar2.dissolve(avatar3, 0.333)
		avatar = avatar5.dissolve(avatar4, 0.333)
	end
	avatar.add_compose_mask(Magick::Image.read('assets/dis-card/circlemask.png')[0])
	bg = Magick::Image.new(750, 140) { self.background_color = '#6F85D4' }
	aover = Magick::Image.read('assets/dis-card/circleoverlay_'+u.status.to_s+'.png')[0]
	test = Magick::Image.new(750, 140) { self.background_color = 'none' }
	File.delete('cache/discard_'+cachetoken.to_s+'.png')

	line = Magick::Draw.new
	line.stroke('white')
	line.line(0, 48, 750, 48)
	line.draw(bg)
	bg = bg.color_floodfill(150, 60, 'white')
	line2 = Magick::Draw.new
	line2.stroke('white')
	line2.line(0, 49, 800, 49)
	line2.draw(bg)
	bg = bg.color_floodfill(150, 60, 'white')

	# Layering
	bg = bg.composite(avatar, Magick::NorthWestGravity, 6, 6, Magick::OverCompositeOp)
	bg = bg.composite(aover, Magick::NorthWestGravity, Magick::OverCompositeOp)

	# Add Text
	uname = u.name
	#if @discardreplacename
	#	uname = u.display_name
	#end
	label = Magick::Draw.new
	label.font = "assets/dis-card/font.ttf"
	label.font_weight=Magick::NormalWeight
	label.gravity=Magick::NorthWestGravity
	label.pointsize = 40
	label.fill = 'white'
	label.text(0,0,uname)
	metrics = label.get_type_metrics(uname)

	if u.game and not u.game == ""
		label2 = Magick::Draw.new
		label2.font = "assets/dis-card/font.ttf"
		label2.font_weight=Magick::NormalWeight
		label2.gravity=Magick::NorthWestGravity
		label2.pointsize = 20
		label2.fill = '#6F85D4'
		label2.text(0,0,'Playing')
		metrics2 = label2.get_type_metrics('Playing')
	end

	# Name
	bg.annotate(label, 100, 40, 140, 0, uname)

	# Discrim
	bg.annotate(Magick::Draw.new, 100, 40, u.bot_account ? metrics.width+184 : metrics.width+140, 25, "#"+u.discrim) do
		self.font = 'assets/dis-card/font2.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = '#9FADE1'
		self.gravity = Magick::NorthWestGravity
	end

	# ID
	bg.annotate(Magick::Draw.new, 0, 0, 5, 0, u.id.to_s) do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = '#9FADE1'
		self.gravity = Magick::NorthEastGravity
	end

	# Credit
	bg.annotate(Magick::Draw.new, 0, 0, 5, 0, 'Generated with BotBoy') do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = 'black'
		self.gravity = Magick::SouthEastGravity
	end

	# Game Status
	if u.game and not u.game == ""
		bg.annotate(label2, 100, 40, 140, 45, 'Playing')
		bg.annotate(Magick::Draw.new, 100, 40, metrics2.width+145, 45, u.game) do
			self.font = 'assets/dis-card/font2.ttf'
			self.pointsize = 20
			self.font_weight = Magick::BoldWeight
			self.fill = '#6F85D4'
			self.gravity = Magick::NorthWestGravity
		end
	end

	# Join Date and Time
	bg.annotate(Magick::Draw.new, 100, 40, 140, u.game ? 70 : 45, "#{u.bot_account ? "Made" : "Joined Discord"} at "+u.creation_time.strftime("%b %e, %Y, %l:%M:%S %p")) do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Seen in servers
	srct = 0
	bot.servers.values.each{|s| if s.users.include?(u); srct+=1; end}
	bg.annotate(Magick::Draw.new, 100, 40, 140, u.game ? 95 : 70, "Seen in "+srct.to_s+" #{srct == 1 ? "server" : "servers"}") do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Bot Tag
	if u.bot_account?
		bg = bg.composite(bottag, Magick::NorthWestGravity, metrics.width+140, 0, Magick::OverCompositeOp)
	end

	cmask = Magick::Image.read('assets/dis-card/cardmask.png')[0]
	bg.add_compose_mask(cmask)
	bg = bg.composite(test, Magick::CenterGravity, Magick::OverCompositeOp)

	#IO.write('discards/'+uid.to_s+'.png', "")
	bg.write('discards/'+u.id.to_s+'.png')
	event.channel.send_file(File.new('discards/'+u.id.to_s+'.png'))
	if not @savediscards
		File.delete('discards/'+u.id.to_s+'.png')
	end
	nil
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
end

bot.command :sdiscard do |event, *args|
	cachetoken = SecureRandom.random_number(1000000)
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	event.channel.start_typing()
	# Avatar Retrieving
	u = event.server
	begin
	system 'wget -O cache/discard_'+cachetoken.to_s+'.png ' + u.icon_url
	rescue => e
		event.channel.send_message("Bad error retrieveing icon!\n```\n"+e.inspect+"\n```")
	end
	# Image Loading
	avatar = Magick::Image.read('cache/discard_'+cachetoken.to_s+'.png')[0]
	avatar.change_geometry!("128x128") { |cols, rows| avatar.thumbnail! cols, rows }
	avatar.add_compose_mask(Magick::Image.read('assets/dis-card/circlemask.png')[0])
	bg = Magick::Image.new(750, 250) { self.background_color = '#6F85D4' }
	aover = Magick::Image.read('assets/dis-card/circleoverlay.png')[0]
	lrge = Magick::Image.read('assets/dis-card/large_badge.png')[0]
	txt = Magick::Image.read('assets/dis-card/text_badge.png')[0]
	vse = Magick::Image.read('assets/dis-card/voice_badge.png')[0]
	map = Magick::Image.read('assets/dis-card/map_badge.png')[0]
	usr = Magick::Image.read('assets/dis-card/user_badge.png')[0]
	File.delete('cache/discard_'+cachetoken.to_s+'.png')

	line = Magick::Draw.new
	line.stroke('white')
	line.line(0, 48, 750, 48)
	line.draw(bg)
	bg = bg.color_floodfill(150, 60, 'white')
	line2 = Magick::Draw.new
	line2.stroke('white')
	line2.line(0, 49, 800, 49)
	line2.draw(bg)
	bg = bg.color_floodfill(150, 60, 'white')

	# Layering
	bg = bg.composite(avatar, Magick::NorthWestGravity, 6, 6, Magick::OverCompositeOp)
	bg = bg.composite(aover, Magick::NorthWestGravity, Magick::OverCompositeOp)
	bg = bg.composite(map, Magick::NorthWestGravity, 140, 95, Magick::OverCompositeOp)
	bg = bg.composite(usr, Magick::NorthWestGravity, 140, 125, Magick::OverCompositeOp)
	bg = bg.composite(txt, Magick::NorthWestGravity, 140, 155, Magick::OverCompositeOp)
	bg = bg.composite(vse, Magick::NorthWestGravity, 140, 185, Magick::OverCompositeOp)
	
	# Add Text
	uname = u.name
	label = Magick::Draw.new
	label.font = "assets/dis-card/font.ttf"
	label.font_weight=Magick::NormalWeight
	label.gravity=Magick::NorthWestGravity
	label.pointsize = 40
	label.fill = 'white'
	label.text(0,0,uname)
	metrics = label.get_type_metrics(uname)

	label2 = Magick::Draw.new
	label2.font = "assets/dis-card/font.ttf"
	label2.font_weight=Magick::NormalWeight
	label2.gravity=Magick::NorthWestGravity
	label2.pointsize = 20
	label2.fill = '#6F85D4'
	label2.text(0,0,'Created by')
	metrics2 = label2.get_type_metrics('Created by')

	# Name
	bg.annotate(label, 100, 40, 140, 0, uname)

	# Large Tag
	if u.large
		bg = bg.composite(lrge, Magick::NorthWestGravity, metrics.width+140, 16, Magick::OverCompositeOp)
	end

	# ID
	bg.annotate(Magick::Draw.new, 0, 0, 5, 0, u.id.to_s) do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = '#9FADE1'
		self.gravity = Magick::NorthEastGravity
	end

	# Credit
	bg.annotate(Magick::Draw.new, 0, 0, 5, 0, 'Generated with BotBoy') do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = 'black'
		self.gravity = Magick::SouthEastGravity
	end

	# Owner Username
	bg.annotate(label2, 100, 40, 140, 45, 'Created by')
	bg.annotate(Magick::Draw.new, 100, 40, metrics2.width+145, 45, @replaceusername ? u.owner.display_name : u.owner.name) do
		self.font = 'assets/dis-card/font2.ttf'
		self.pointsize = 20
		self.font_weight = Magick::BoldWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Creation Date and Time
	bg.annotate(Magick::Draw.new, 100, 40, 140, 70, "Created at "+u.creation_time.strftime("%b %e, %Y, %l:%M:%S %p")) do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Region
	srct = 0
	bot.servers.values.each{|s| if s.users.include?(u); srct+=1; end}
	bg.annotate(Magick::Draw.new, 100, 40, 170, 95, 'Hosted in '+u.region) do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Members
	bg.annotate(Magick::Draw.new, 100, 40, 170, 125, u.online_members.count.to_s+'/'+u.members.count.to_s+' members online') do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Text Channels
	bg.annotate(Magick::Draw.new, 100, 40, 170, 155, u.text_channels.count.to_s+' text channels') do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	# Voice Channels
	bg.annotate(Magick::Draw.new, 100, 40, 170, 185, u.voice_channels.count.to_s+' voice channels') do
		self.font = 'assets/dis-card/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#6F85D4'
		self.gravity = Magick::NorthWestGravity
	end

	bg.write('discards/servers/'+u.id.to_s+'.png')
	event.channel.send_file(File.new('discards/servers/'+u.id.to_s+'.png'))
	if not @savediscards
		File.delete('discards/servers/'+u.id.to_s+'.png')
	end
	nil
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
end

bot.command :drpg do |event, *args|
	cachetoken = SecureRandom.random_number(1000000)
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	event.channel.start_typing()
	# Account Checking/Avatar Retrieving
	u = event.author
	if args[0] == "-find" && args.count > 1
		cu = bot.find_user(args[1..args.count].join(" ")).first
		if cu
			u = cu
		end
	end
	if event.message.mentions[0]
		u = event.message.mentions[0]
	end
	noacc = false
	begin
		begin
			begin
				rpgdata = JSON.parse(DRPGreq("user/"+u.id.to_s))['user']['data']
				if not rpgdata['guild'].empty?
					gdata = JSON.parse(DRPGreq("guild/"+rpgdata['guild']))['data']
				else
					gdata = nil
				end
			rescue RestClient::BadRequest
				noacc = "**User has no DRPG account!**"
			end
		rescue RestClient::TooManyRequests
			noacc = "**BotBoy was ratelimited from the DRPG API! Try again later!**"
		end
	rescue Errno::ECONNREFUSED
		noacc = "**DRPG API is unavailable at the moment! Please try again**"
	end
	clrs = ['9fade1','fb4c4c','faa61a','faa6ff','11dafa','11dafa','b94fff']
	if not noacc
	begin
	if not u.avatar_url == 'https://discordapp.com/api/users/'+u.id.to_s+'/avatars/.jpg'
		system 'wget -O cache/discard_'+cachetoken.to_s+'.png ' + u.avatar_url
	else
		Magick::Image.new(128, 128) { self.background_color = '#'+clrs.sample.upcase }.composite(Magick::Image.read('assets/dis-card/defaultavatar.png')[0], Magick::CenterGravity, Magick::OverCompositeOp).write('cache/discard_'+cachetoken.to_s+'.png')
	end
	rescue => e
		event.channel.send_message("Bad error retrieveing icon!\n```\n"+e.inspect+"\n```")
	end
	# Get Guild Icon
	if gdata
		system 'wget -O cache/drpg_'+cachetoken.to_s+'.png http://res.discorddungeons.me/images/twemoji/'+gdata['icon'].gsub(/\u0026#x/, "").gsub(/[;]/, "").gsub(/\u0026amp/, "-").downcase+'.png'
		guildicon = Magick::Image.read('cache/drpg_'+cachetoken.to_s+'.png')[0]
		guildicon.change_geometry!("20x20") { |cols, rows| guildicon.thumbnail! cols, rows }
		File.delete('cache/drpg_'+cachetoken.to_s+'.png')
	end
	# Image Loading
	bottag = Magick::Image.read('assets/drpg/bottag.png')[0]
	gld = Magick::Image.read('assets/drpg/gold_badge.png')[0]
	gld.change_geometry!("20x20") { |cols, rows| gld.thumbnail! cols, rows }
	avatar = Magick::Image.read('cache/discard_'+cachetoken.to_s+'.png')[0]
	avatar.change_geometry!("128x128") { |cols, rows| avatar.thumbnail! cols, rows }
	if @discardgray and u.status.to_s == "offline"
		avatar2 = avatar.channel(Magick::BlueChannel)
		avatar3 = avatar.channel(Magick::RedChannel)
		avatar4 = avatar.channel(Magick::GreenChannel)
		avatar5 = avatar2.dissolve(avatar3, 0.333)
		avatar = avatar5.dissolve(avatar4, 0.333)
	end
	avatar.add_compose_mask(Magick::Image.read('assets/dis-card/circlemask.png')[0])
	bg = Magick::Image.new(750, 160) { self.background_color = '#313131'; self.texture= Magick::Image.read('assets/drpg/pattern.png')[0] }
	aover = Magick::Image.read('assets/drpg/circleoverlay_'+u.status.to_s+'.png')[0]
	test = Magick::Image.new(750, 160) { self.background_color = 'none' }
	File.delete('cache/discard_'+cachetoken.to_s+'.png')

	# Layering
	bg = bg.composite(avatar, Magick::NorthWestGravity, 6, 6, Magick::OverCompositeOp)
	bg = bg.composite(aover, Magick::NorthWestGravity, Magick::OverCompositeOp)
	bg = bg.composite(gld, Magick::NorthWestGravity, 145, 70, Magick::OverCompositeOp)
	

	# Add Text
	uname = u.name
	#if @discardreplacename
	#	uname = u.display_name
	#end
	label = Magick::Draw.new
	label.font = "assets/drpg/font.ttf"
	label.font_weight=Magick::NormalWeight
	label.gravity=Magick::NorthWestGravity
	label.pointsize = 40
	label.fill = rpgdata['donate'] ? '#f1a01f' : 'white'
	label.text(0,0,uname)
	metrics = label.get_type_metrics(uname)

	if not rpgdata['guild'].empty?
		label2 = Magick::Draw.new
		label2.font = "assets/drpg/font.ttf"
		label2.font_weight=Magick::NormalWeight
		label2.gravity=Magick::NorthWestGravity
		label2.pointsize = 20
		label2.fill = '#6F85D4'
		label2.text(0,0,"Guild: #{gdata ? gdata['name'] : "None"}")
		metrics2 = label2.get_type_metrics("Guild: #{gdata ? gdata['name'] : "None"}")
	end

	# Name
	bg.annotate(label, 100, 40, 145, 0, uname)

	# Discrim
	bg.annotate(Magick::Draw.new, 100, 40, u.bot_account ? metrics.width+185 : metrics.width+145, 25, "#"+u.discrim) do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::BoldWeight
		self.fill = '#6d6d6d'
		self.gravity = Magick::NorthWestGravity
	end

	# ID
	bg.annotate(Magick::Draw.new, 0, 0, 5, 0, u.id.to_s) do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = '#9FADE1'
		self.gravity = Magick::NorthEastGravity
	end

	# Credit
	bg.annotate(Magick::Draw.new, 0, 0, 5, 0, 'Generated with BotBoy') do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 15
		self.font_weight = Magick::NormalWeight
		self.fill = 'black'
		self.gravity = Magick::SouthEastGravity
	end

	# HP/XP
	hpbg = Magick::Draw.new
	hpbg.rectangle(145, 45, 545, 65)
	hpbg.fill = '#e30000'
	hpbg.draw(bg)
	hpbar = Magick::Draw.new
	hpbar.rectangle(145, 45, ((400 / rpgdata['maxhp'].to_f)*rpgdata['hp'].to_f).to_i.floor+145, 65)
	hpbar.fill = '#31cf00'
	hpbar.draw(bg)
	label3 = Magick::Draw.new
	label3.font = "assets/drpg/font.ttf"
	label3.font_weight=Magick::NormalWeight
	label3.gravity=Magick::NorthWestGravity
	label3.pointsize = 20
	label3.fill = 'white'
	label3.text(0,0,'HP: '+rpgdata['hp'].format+'/'+rpgdata['maxhp'].format)
	metrics3 = label.get_type_metrics('HP: '+rpgdata['hp'].format+'/'+rpgdata['maxhp'].format)
	bg.annotate(label3, 100, 40, 145, 45, 'HP: '+rpgdata['hp'].format+'/'+rpgdata['maxhp'].format)
	bg.annotate(Magick::Draw.new, 100, 40, 200, 35, 'XP: '+rpgdata['xp'].format) do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 10
		self.font_weight = Magick::NormalWeight
		self.fill = 'white'
		self.gravity = Magick::NorthWestGravity
	end

	# Level
	bg.annotate(Magick::Draw.new, 100, 40, 550, 45, "Lvl. "+rpgdata['level'].format) do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#797979'
		self.gravity = Magick::NorthWestGravity
	end

	# Gold
	bg.annotate(Magick::Draw.new, 100, 40, 170, 70, "Gold: "+rpgdata['gold'].format) do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#797979'
		self.gravity = Magick::NorthWestGravity
	end

	# Guild
	bg.annotate(Magick::Draw.new, 100, 40, 145, 90, "Guild: #{gdata ? gdata['name'] : "None"}") do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#797979'
		self.gravity = Magick::NorthWestGravity
	end
	if gdata
		bg = bg.composite(guildicon, Magick::NorthWestGravity, metrics2.width+145, 90, Magick::OverCompositeOp)
	end

	# Kills/Deaths
	bg.annotate(Magick::Draw.new, 100, 40, 145, 110, "Slain "+rpgdata['kills'].format+' monsters and died '+rpgdata['deaths'].format+" times.") do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#797979'
		self.gravity = Magick::NorthWestGravity
	end

	# Stats
	bg.annotate(Magick::Draw.new, 100, 40, 145, 130, "STR: "+rpgdata['stats']['strength'].format+", DEF: "+rpgdata['stats']['defense'].format+", LCK: "+rpgdata['stats']['luck'].format+", CHA: "+rpgdata['stats']['charisma'].format) do
		self.font = 'assets/drpg/font.ttf'
		self.pointsize = 20
		self.font_weight = Magick::NormalWeight
		self.fill = '#797979'
		self.gravity = Magick::NorthWestGravity
	end

	# Bot Tag
	if u.bot_account?
		bg = bg.composite(bottag, Magick::NorthWestGravity, metrics.width+140, 0, Magick::OverCompositeOp)
	end

	#cmask = Magick::Image.read('assets/dis-card/cardmask.png')[0]
	#bg.add_compose_mask(cmask)
	#bg = bg.composite(test, Magick::CenterGravity, Magick::OverCompositeOp)

	#IO.write('discards/'+uid.to_s+'.png', "")
	bg.write('discards/drpg/'+u.id.to_s+'.png')
	event.channel.send_file(File.new('discards/drpg/'+u.id.to_s+'.png'))
	if not @savediscards
		File.delete('discards/drpg/'+u.id.to_s+'.png')
	end
	nil
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
	else
	noacc
	end
end

bot.command %s(dis-card) do |event, *args|
	bot.execute_command(:discard, event, args)
end

bot.command %s(sdis-card) do |event, *args|
	bot.execute_command(:sdiscard, event, args)
end

bot.command :osusig do |event, *args|
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	if not args.join(" ") == ""
		event.channel.start_typing()
		cachetoken = SecureRandom.random_number(1000000)
		system 'wget -O cache/osusig_'+cachetoken.to_s+'.png http://lemmmy.pw/osusig/sig.php?uname=' + args.join('%20')
		event.channel.send_file(File.new('cache/osusig_'+cachetoken.to_s+'.png'))
		File.delete('cache/osusig_'+cachetoken.to_s+'.png')
	else
		"You didn't provide a username!"
	end
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
end

bot.command :meme do |event, *args|
	# Really bad way of enjoying memes
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	if not args[0] == ""
		event.channel.start_typing()
		m2 = args.join('-').sub(/[']/, "%27").sub(/[#]/, "").split("|")
		#'http://memegen.link/' + args[0] +'/' + m[0] +'/' + m[1] 
		system 'wget -O cache/meme.png http://memegen.link/' + m2[0] +'/' + m2[1] +'/' + m2[2] + '.jpeg'
		event.channel.send_file(File.new("cache/meme.png"))
	else
		"You didn't provide a argument!"
	end
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
end

bot.command :cat do |event, *args|
	cachetoken = SecureRandom.random_number(1000000)
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	event.channel.start_typing()
	begin
	cat = JSON.parse RestClient.get 'http://www.random.cat/meow'
	if cat['file'].include?(".gif")
		system 'wget -O cache/cat_'+cachetoken.to_s+'.gif ' + cat['file']
		if File.file?('cache/cat_'+cachetoken.to_s+'.gif')
			event.channel.send_file(File.new('cache/cat_'+cachetoken.to_s+'.gif'))
			File.delete('cache/cat_'+cachetoken.to_s+'.gif')
			nil
		else
			puts "Bad Cat API Request! " + cat['file']
			bot.execute_command(:cat, event, args)
			nil
		end
	else
		system 'wget -O cache/cat_'+cachetoken.to_s+'.png ' + cat['file']
		if File.file?('cache/cat_'+cachetoken.to_s+'.png')
			event.channel.send_file(File.new('cache/cat_'+cachetoken.to_s+'.png'))
			File.delete('cache/cat_'+cachetoken.to_s+'.png')
			nil
		else
			puts "Bad Cat API Request! " + cat['file']
			bot.execute_command(:cat, event, args)
			nil
		end
	end
	rescue => e
		event.channel.send_message("Error!\n```\n"+e.inspect+"\n```")
	end
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
end

bot.command :mcskin do |event, *args|
	# Taking advantage of https://mcapi.ca 
	#if event.bot.bot_user.on(event.server).permission?(:attach_files, event.channel)
	event.channel.start_typing()
	if not args[0] == ""
		cachetoken = SecureRandom.random_number(1000000)
		if args[1] == "raw" then
			system 'wget -O cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_raw.png https://mcapi.ca/skin/file/' + args[0]
			event.channel.send_file(File.new('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_raw.png'))
			File.delete('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_raw.png')
			nil
		elsif args[1] == "face" then
			system 'wget -O cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_face.png https://mcapi.ca/avatar/2d/' + args[0]
			event.channel.send_file(File.new('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_face.png'))
			File.delete('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_face.png')
			nil
		elsif args[1] == "face-nohat" || args[1] == "facenohat" then
			system 'wget -O cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_facenohat.png https://mcapi.ca/avatar/2d/' + args[0] + '/false'
			event.channel.send_file(File.new('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_facenohat.png'))
			File.delete('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'_facenohat.png')
			nil
		else
			system 'wget -O cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'.png https://mcapi.ca/skin/2d/' + args[0]
			event.channel.send_file(File.new('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'.png'))
			File.delete('cache/mcskin_'+args[0]+'_'+cachetoken.to_s+'.png')
			nil
		end
	else
		"You didn't provide a username!"
	end
	#else
	#	"**Failed to generate! Insuffecient permissions!**"
	#end
end

bot.command :eval do |event, *args|
  if event.user.id == 158049329150427136 then # Replace with your ID to use
  event << "```"
  begin
	event << eval(args.join(" "))
  rescue => e
	event << e.inspect
  end
  event << "```"
  end
end

bot.command :botinfo do |event, *args|
  lsc = 0
  ls = bot.servers.values.each {|s| if s.large; lsc+=1; end }
  ss = bot.servers.count - lsc
  event << "```diff"
  event << "! Bot Info"
  event << "-   #{bot.servers.count} servers"
  event << "+     #{lsc} large servers"
  event << "+     #{ss} small servers"
  event << "-   #{bot.users.count} unique users."
  event << "-   #{bot.servers.count} servers connected to."
  event << "```"
end

bot.command :srvrinfo do |event|
  if event.channel.private? then
  event << ":no_entry: This command cannot be used in a PM!"
  else
  event << "**#{event.server.name}** hosted in **#{event.server.region}** with **#{event.server.channels.count}** channels and **#{event.server.member_count}** members, owned by #{event.server.owner.mention}"
  event << "Icon: #{event.server.icon_url}"
  event << "```xl"
  event << "Server ID: #{event.server.id}, Owner ID: #{event.server.owner.id}```"
 end
end


bot.command :help do |event|
  event << "I sent you a list, #{event.user.mention} !"
  event.user.pm("Prefixes: `^` and `@mention`
  __**Available Commands**__
**ping** *~ AKA pong*
**invite** (invite link) *~ Invites bot to server with invite.*
**lmgtfy** *~ Makes a LMGTFY link.*
**osusig (osu username)** *~ Makes a Signature for a Osu! player.*
**mcskin (minecraft name) (tag)** *~ Shows a minecraft skin.* `Tags: raw, face`
**atari (keyword)** *~ Makes a google breakout page.*
**meme (keyword)|(line 1)|(line 2)** *~ Makes a memegen picture.*
**urban (keyword)** *~ Shows a word in the Urban dictionary. Use nothing as the key word for a random word.*

For more commands, go to http://snazzypine25.github.io/BotBoy/#commands

If you have any questions, join this discord server: https://discord.gg/0vjTDaDsgOQWUtlv")
end

bot.run :async

bot.game=("with Clyde")
#bot.send_message(167106306895773697,":desktop: Rebooted!")


bot.sync
