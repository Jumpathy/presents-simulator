local keys = {
	datastore = "codes_store_3",
	datastore_key = "codes2",
	messaging_topic = "onNewCode2"
}

local groupId = 12248057;
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local datastoreService = game:GetService("DataStoreService");
local handler = require(script.Parent.Parent.Parent:WaitForChild("data"));
local datastore = datastoreService:GetDataStore(keys.datastore);
local chatService = game:GetService("Chat");
local profiles = {};

handler.profileLoaded:Connect(function(profile,player)
	profiles[player] = profile;
end)

local success,codes = pcall(function()
	return datastore:GetAsync(keys.datastore_key);
end)
codes = codes or {};

local messaging = require(script.Parent.Parent.Parent:WaitForChild("updates"):WaitForChild("messagingService"));
local rbxProxy;

local cooldowns = {};
local find = {
	["common"] = "Common",
	["uncommon"] = "Uncommon",
	["legendary"] = "Legendary"
}

local refresh = function()
	messaging:post(keys.messaging_topic,"refresh")
end

local getEggFromTier = function(tier)
	local final = {};
	for _,prompt in pairs(shared.egg_hatch:getPrompts()) do
		if(prompt.tier == tier) then
			table.insert(final,prompt);
		end
	end
	return final[math.random(1,#final)]["prompt"];
end

local hatchEgg = function(player,tier)
	local proximity = getEggFromTier(tier);
	shared.egg_hatch:hatch(player,proximity);
end

local boosts = {
	["toy"] = function(player,length)
		shared.forge_boost(player,"2xT",length);
	end,
	["damage"] = function(player,length)
		shared.forge_boost(player,"2xD",length);
	end,
}

network:createRemoteFunction("redeemCode",function(player,codeName)
	if(profiles[player] and not profiles[player]["redeemed"][codeName]) then
		if(codes[codeName] and os.time() <= codes[codeName]["expires"]) then
			local profile,code = profiles[player],codes[codeName];
			if(code.reward == "coins") then
				profile.redeemed[codeName] = true;
				local new = shared.addNoChange(player.leaderstats.Coins,tostring(code.rewardAmount));
				shared.set(player.leaderstats.Coins,new);
				return true,"Redeemed!";
			elseif(code.reward:find("Egg")) then
				local replace = code.reward:split("Egg")[1]:lower():gsub(string.char(32),"");
				local tier = find[replace];
				if(tier) then
					profile.redeemed[codeName] = true;
					hatchEgg(player,tier);
					return true,"Enjoy!";
				else
					warn("[invalid egg",tier)
					return false,"Something went wrong!";
				end
			elseif(code.reward:find("Boost")) then
				local tier = code.reward:split("Boost")[1]:lower();
				if(boosts[tier]) then 
					profile.redeemed[codeName] = true;
					boosts[tier](player,code.rewardAmount);
					return true,"Boosted!";
				else
					warn("[invalid boost tier",tier)
					return false,"Something went wrong!";
				end
			else
				return false,"Something went wrong!";
			end
		else
			return false,"Invalid code!";
		end
	else
		return false,"Already claimed!";
	end
end)

local filter = function(text,from)
	if(from:GetAttribute("AdminPanel")) then
		return true,text;
	else
		local success,response = pcall(function()
			return chatService:FilterStringForBroadcast(text,from)
		end)
		if(success) then
			if(response ~= text) then
				return false,"Your code name has been filtered by server!";
			else
				return true,response;
			end
		else
			warn(response);
			return false,"Failed to filter code name.";
		end
	end
end

network:createRemoteFunction("createCode",function(player,codeName,rewardType,rewardAmount,days)
	codeName = codeName:sub(1,20);
	if(player:GetAttribute("Youtuber") == true) then
		if(not cooldowns[player] or tick() >= cooldowns[player]) then
			local success,code = filter(codeName,player);
			if(not success) then
				cooldowns[player] = tick();
				return false,code;
			end
			cooldowns[player] = tick() + (player:GetRankInGroup(groupId) >= 200 and 0 or 500);
			local success,failed = pcall(function()
				return datastore:UpdateAsync(keys.datastore_key,function(old)
					old = old or {};
					old[code] = {
						reward = rewardType,
						rewardAmount = rewardType:find("Egg") and 1 or math.floor(math.clamp(rewardAmount,1,(rewardType:find("Boost") and 60 or 5*10^6))),
						expires = os.time() + (days * 86400)
					};
					return old;
				end)
			end)
			if(not success and failed) then
				cooldowns[player] = tick();
				warn(failed);
				return false,"Something went wrong on the server.";
			else
				task.spawn(refresh);
				return true,("Created code '%s'"):format(code);
			end
		else
			return false,("Please wait %s more seconds before creating a new code!"):format(tostring(math.floor(cooldowns[player] - tick())))
		end
	end
end)

messaging.onEvent(keys.messaging_topic):Connect(function(data)
	local success,newCodes = pcall(function()
		return datastore:GetAsync(keys.datastore_key);
	end)
	codes = newCodes or {};
end)

rbxProxy = shared.proxy_client:get();