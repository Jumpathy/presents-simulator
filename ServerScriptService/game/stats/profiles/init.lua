local profileService,players,module = require(script:WaitForChild("service")),game:GetService("Players"),{};

function module.new(key,template)
	local store = profileService.GetProfileStore(key,template or {});
	local profiles,rawProfiles,cached,cachedInfo = {},{},{},{};
	local events = {};

	local newEvent = function()
		local raw = {};
		local callbacks = {};
		local current = {};
		local fired = {};
		
		local doHandle = function(arr)
			if(type(arr) == "table") then
				return unpack(arr);
			else
				return arr;
			end
		end

		local fire = function()
			for _,cb in pairs(callbacks) do
				fired[cb] = fired[cb] or {};
				for _,c in pairs(current) do
					if(not fired[cb][c]) then
						fired[cb][c] = true;
						coroutine.wrap(cb)(doHandle(c));
					end
				end
			end
		end

		local insert = function(callback)
			table.insert(callbacks,callback);
			fire();
		end

		raw.Connect = function(self,callback)
			assert((type(callback))=="function","Expected type 'function'");
			insert(callback);
			local disconnect = {};
			function disconnect.Disconnect()
				local key = table.find(callbacks,callback);
				if(key) then
					table.remove(callbacks,key);
					disconnect.Disconnect = nil;
				end
			end
			return disconnect;
		end
		table.freeze(raw);

		return raw,function(tbl)
			table.insert(current,tbl);
			fire();
		end,function(tbl)
			local key = table.find(current,tbl);
			if(key) then
				table.remove(current,key);
			end
		end
	end
	
	local loadedEvent,loadedEventFire,loadedEventDisconnect = newEvent();
	local unloadedEvent,unloadedEventFire,unloadedEventDisconnect = newEvent();
	
	local onRelease = function(player)
		if(not cached[player] and cachedInfo[player]) then
			cached[player] = true;
			loadedEventDisconnect(cachedInfo[player]);
			unloadedEventFire(player);
			unloadedEventDisconnect(player);
		end
	end

	local onLoad = function(player,profile)
		cachedInfo[player] = {player,profile.Data};
		loadedEventFire(cachedInfo[player]);
	end

	local playerAdded = function(player)
		local profile = store:LoadProfileAsync("plr_"..player.UserId);
		if(profile ~= nil) then
			profile:AddUserId(player.UserId);
			profile:Reconcile();
			profile:ListenToRelease(function()
				onRelease(player,profile);
				profiles[player] = nil;
				rawProfiles[player] = nil;
			end)
			if(player:IsDescendantOf(players) == true) then
				onLoad(player,profile);
				rawProfiles[player] = profile;
			else
				rawProfiles[player] = nil;
				onRelease(player,profile);
				profile:Release();
			end
		end
	end
	
	for _,player in ipairs(players:GetPlayers()) do
		coroutine.wrap(playerAdded)(player)
	end
	players.PlayerAdded:Connect(playerAdded);
	players.PlayerRemoving:Connect(function(player)
		local profile = rawProfiles[player];
		if(profile ~= nil) then
			onRelease(player,profile);
			profile:Release();
		end
	end)
	
	events.ProfileLoaded = loadedEvent;
	events.ProfileUnloaded = unloadedEvent;
	
	local heartbeat = game:GetService("RunService").Heartbeat;
	
	function events:getProfile(player,callback)
		coroutine.wrap(function()
			repeat
				heartbeat:Wait();
			until(rawProfiles[player] or (player:GetFullName() == player.Name));
			if(rawProfiles[player]) then
				callback(rawProfiles[player]["Data"]);
			end
		end)();
	end
	
	table.freeze(events);
	return events;
end

return module;