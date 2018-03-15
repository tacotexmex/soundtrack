soundtrack = {}
soundtrack.registered = {}

soundtrack.register = function (name, def)
	if name and def then
		def.name = name
		soundtrack.registered[name] = def
	end
end

function soundtrack.registered_list()
	return soundtrack.registered
end

soundtrack.register("grass",{
	biome = "grassland",
	gain = 0.5,
	fadein = 1.0,
	fadeout = -1.0,
	pitch = 1.0,
	loop = false,
	duration = 60,
	y_min = 0,
	y_max = 64,
	priority = 1,
})

soundtrack.register("woods",{
	biome = "coniferous_forest",
	gain = 0.5,
	fadein = 1.0,
	fadeout = -1.0,
	pitch = 1.0,
	loop = false,
	duration = 60,
	y_min = 0,
	y_max = 64,
	priority = 1,
})

soundtrack.register("high",{
	biome = "coniferous_forest",
	gain = 0.5,
	fadein = 1.0,
	fadeout = -1.0,
	pitch = 1.0,
	loop = false,
	duration = 60,
	y_min = 65,
	y_max = 128,
	priority = 1,
})

minetest.register_on_joinplayer(function(player)
	local pos = player:getpos()
	pos.x = math.floor(pos.x)
	pos.y = math.floor(pos.y)
	pos.z = math.floor(pos.z)
	local biome_data = minetest.get_biome_data(pos)
	local biome_name = minetest.get_biome_name(biome_data.biome)

	player:set_attribute("soundtrack:playing", nil)
	player:set_attribute("soundtrack:playing_handle", nil)
	player:set_attribute("soundtrack:lastbiome", biome_name)
end)

local timer = 0
local onoff = false
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 2 then
		timer = 0
		for _, player in ipairs(minetest.get_connected_players()) do
			local pos = player:getpos()
			pos.x = math.floor(pos.x)
			pos.y = math.floor(pos.y)
			pos.z = math.floor(pos.z)
			local biome_data = minetest.get_biome_data(pos)
			local biome_name = minetest.get_biome_name(biome_data.biome)
			minetest.chat_send_all("Current: "..biome_name)
			for _, def in pairs(soundtrack.registered) do
				local starter = {}
				local starters = true
				local stopper = {}
				local stoppers = false
				if def.biome == biome_name then
					starter.biome = true
				else
					starter.biome = false
				end
				if player:get_attribute("soundtrack:playing") == nil then
					starter.silence = true
				else
					starter.silence = false
				end
				if player:get_attribute("soundtrack:lastbiome") ~= biome_name then
					player:set_attribute("soundtrack:lastbiome", biome_name)
					stopper.biome_change = true
				else
					stopper.biome_change = false
				end
				for i in pairs(starter) do
					if not starter[i] then
						starters = false
					end
				end
				for i in pairs(stopper) do
					if stopper[i] then
						stoppers = true
					end
				end
				local handle = player:get_attribute("soundtrack:playing_handle")
				if starters and not stoppers then
					-- minetest.chat_send_all("PLAY")
					handle = minetest.sound_play(def.name, {
						to_player = player,
						gain = def.gain,
						fade = def.fade,
						pitch = def.pitch,
						loop = def.loop,
					})
					player:set_attribute("soundtrack:playing", def.name)
					player:set_attribute("soundtrack:playing_handle", handle)
				end
				if stoppers then
					-- minetest.chat_send_all("STOP")
					if handle ~= nil then
						minetest.sound_fade(handle, def.fadeout, 0)
						minetest.sound_stop(handle)
						player:set_attribute("soundtrack:playing", nil)
						player:set_attribute("soundtrack:playing_handle", nil)
					end
				end
			end
		end
	end
end)
