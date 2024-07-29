local handler = require(script.Parent.Parent.Parent:WaitForChild("data"));
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local integer = handler.integer;
local roll = handler.roll;
local timeRequired = 86400; --> 86,400
local a = "5";
local lastLoginDateKey = "lastLoginDate3"..a -- lastLoginDate
local loginStreak = "loginStreak3"..a;
local upcoming = "upcomingRewards"..a;
local lastWeek = "lastWeek";
local countdown;
local canClaim = {};
local pendingRequests = {};
local transmitting = {};

local limit = function(...)
	return math.clamp(...);
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

local percentFrom = function(raw,percent)
	return math.floor(tonumber(raw) * (percent / 100));
end

local callbacks = {
	["LegendaryEgg"] = function(player)
		hatchEgg(player,"Legendary");
	end,
	["UncommonEgg"] = function(player)
		hatchEgg(player,"Uncommon");
	end,
	["2xToys_15"] = function(player)
		shared.forge_boost(player,"2xT",15);
	end,
	["2xDamage_15"] = function(player)
		shared.forge_boost(player,"2xD",15);
	end,
	["10PercentCurrentCoins"] = function(player)
		local total = percentFrom(player.leaderstats.Coins.Real.Value,10);
		shared.add(player.leaderstats.Coins,total);
	end,
	["20PercentCurrentCoins"] = function(player)
		local total = percentFrom(player.leaderstats.Coins.Real.Value,20);
		shared.add(player.leaderstats.Coins,total);
	end,
}

local icons = {
	["10PercentCurrentCoins"] = "rbxassetid://8083205324",
	["20PercentCurrentCoins"] = "rbxassetid://8086434045",
	["2xToys_15"] = "rbxassetid://8108338553",
	["2xDamage_15"] = "rbxassetid://8108354884",
	["LegendaryEgg"] = "rbxassetid://8319444395",
	["UncommonEgg"] = "rbxassetid://8319444562",
	["CommonEgg"] = "rbxassetid://8319444698",
}

local texts = {
	["10PercentCurrentCoins"] = "10% coins",
	["20PercentCurrentCoins"] = "20% coins",
	["2xToys_15"] = "2x toys boost",
	["2xDamage_15"] = "2x dmg boost",
	["LegendaryEgg"] = "Legendary Egg",
	["UncommonEgg"] = "Uncommon Egg",
	["CommonEgg"] = "Common Egg"
}

local chances = {
	["LegendaryEgg"] = 10;
	["UncommonEgg"] =  20,
	["2xToys_15"] = 15,
	["2xDamage_15"] = 1,
	["10PercentCurrentCoins"] = 25,
	["20PercentCurrentCoins"] = 12
}

local calculate = function()	
	local peak = 120;
	local last = 0;
	local max = peak;
	local lucky = {};
	for i = 1,5 do
		local random = math.random(1,(peak/5)-2);
		last = last + random;
		table.insert(lucky,(math.random(last,max)));
	end	
	local week = {};
	local iter = 0;
	for i = 1,peak do
		local response = roll(chances);
		if(table.find(lucky,i)) then
			iter += 1;
			week[iter] = {
				reward = response,
				day = iter,
				icon = icons[response],
				text = texts[response]
			};
		end
	end
	
	return week;
end

-- callbacks:

local getWeek = function(streak)
	local original = streak;
	local week = 0;
	if(streak > 5) then
		repeat
			week += 1;
			streak += -5;
		until(streak <= 5);
	end
	return week;
end

local getDay = function(streak)
	local week = getWeek(streak);
	local offset = 5 * week;
	return streak - offset
end

local internalDailyRewardStreak = function(player,newStreak,rewards)
	network:fireClient("dailyRewardTransmitter",player,"playStreakSound");
	-- logic
	local day = getDay(newStreak);
	callbacks[rewards[day]["reward"]](player)
end

local profiles = {};

local isNew = function(profile)
	return getWeek(profile[loginStreak] or 0) ~= profile[lastWeek];
end

network:createRemoteFunction("nextRewards",function(player)
	if(profiles[player]) then
		local idx = profiles[player][upcoming];
		if(not idx or isNew(profiles[player])) then
			local profile = profiles[player];
			profile[lastWeek] = getWeek(profile[loginStreak] or 0);
			profiles[player][upcoming] = calculate((profiles[player][loginStreak] ~= nil and profiles[player][loginStreak]/3) or (1));
		end
		return(idx or profiles[player][upcoming]);
	end
end)

network:createRemoteEvent("dailyRewardTransmitter",function(player,arg)
	if(arg == "claimDaily") then
		if(canClaim[player] and os.time() <= canClaim[player]["expires"]) then
			canClaim[player]["run"]();
		end
	elseif(arg == "beginTransmissions") then
		transmitting[player] = true;
	end
end)

local waitFor = function(player,stamp)
	if(not transmitting[player]) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(transmitting[player] or player:GetFullName() == player.Name);
	end
	if(player:GetFullName() ~= player.Name) then
		pendingRequests[player] += -1;
		return((pendingRequests[player]+1) - stamp);
	else
		return false;
	end
end

local addRequest = function(player)
	pendingRequests[player] = pendingRequests[player] or 0;
	pendingRequests[player] += 1;
	return pendingRequests[player];
end

local limit = 35;

local newStreak = function(player,streak)
	coroutine.wrap(function()
		local current = addRequest(player);
		local difference = waitFor(player,current);
		if(difference and difference <= limit) then
			network:fireClient("dailyRewardTransmitter",player,"newStreak",streak);
		end
	end)();
end

local lostStreak = function(player)
	coroutine.wrap(function()
		local current = addRequest(player);
		local difference = waitFor(player,current);
		if(difference and difference <= limit) then
			network:fireClient("dailyRewardTransmitter",player,"lostStreak");
		end
	end)();
end

local timeRemaining = function(player,remaining)
	coroutine.wrap(function()
		local current = addRequest(player);
		local difference = waitFor(player,current);
		if(difference and difference <= limit) then
			network:fireClient("dailyRewardTransmitter",player,"countdown",remaining);
		end
	end)()
end

local claimIn = function(player,remaining)
	coroutine.wrap(function()
		local current = addRequest(player);
		local difference = waitFor(player,current);
		if(difference and difference <= limit) then
			network:fireClient("dailyRewardTransmitter",player,"claimBy",remaining);
		end
	end)()
end

local announceClaimStatus = function(player)
	coroutine.wrap(function()
		local current = addRequest(player);
		local difference = waitFor(player,current);
		if(difference and difference <= limit) then
			network:fireClient("dailyRewardTransmitter",player,"canClaim");
		end
	end)()
end

local renew = function(profile,timeNow,add)
	profile[lastLoginDateKey] = timeNow;
	if(not add) then
		profile[loginStreak] = 0;
	else
		profile[loginStreak] += 1;
		return profile[loginStreak];
	end
end

check = function(profile,player)
	local timeNow = os.time();
	local lastPlay = profile[lastLoginDateKey];
	newStreak(player,profile[loginStreak] or 0);
	if(lastPlay) then
		local timeSinceLastPlay = timeNow - lastPlay;
		if(timeSinceLastPlay >= timeRequired and (timeSinceLastPlay <= timeRequired * 2)) then
			local claimed = false;
			canClaim[player] = {
				expires = lastPlay + timeRequired * 2,
				run = function()
					canClaim[player] = nil;
					local reward = profile[upcoming];
					local streak = renew(profile,os.time(),true);
					newStreak(player,streak);
					countdown(profile,player);
					claimed = true;
					internalDailyRewardStreak(player,streak,reward);
				end,
			}
			local expires = canClaim[player]["expires"];
			announceClaimStatus(player)
			coroutine.wrap(function()
				while handler.yield(1) do
					if(player:GetFullName() ~= player.Name) then
						if(claimed) then
							break;
						else
							local remaining = (expires - os.time());
							if(remaining >= 1) then
								claimIn(player,remaining);
							else
								check(profile,player);
								break;
							end
						end
					else
						break;
					end
				end
			end)();
		elseif(timeSinceLastPlay >= timeRequired and (timeSinceLastPlay >= timeRequired * 2)) then
			lostStreak(player);
			renew(profile,timeNow);
			countdown(profile,player);
		elseif(timeSinceLastPlay <= timeRequired) then
			countdown(profile,player);
		end
	else
		renew(profile,timeNow);
		countdown(profile,player);
	end
end

countdown = function(profile,player)
	coroutine.wrap(function()
		while handler.yield(1) do
			if(player:GetFullName() ~= player.Name) then
				local timeSinceLastPlay = os.time() - profile[lastLoginDateKey];
				local remaining = (timeRequired - timeSinceLastPlay);
				timeRemaining(player,remaining);
				if(remaining < 1) then
					check(profile,player);
					break;
				end
			else
				break;
			end
		end
	end)();
end

handler.profileLoaded:Connect(function(profile,player)
	profiles[player] = profile;
	check(profile,player);
end)