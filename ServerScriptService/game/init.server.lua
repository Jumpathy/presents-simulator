local physicsService = game:GetService("PhysicsService");
physicsService:CreateCollisionGroup("players");
physicsService:CollisionGroupSetCollidable("players","players",false);

local sellZone = workspace:WaitForChild("areas"):WaitForChild("area1"):WaitForChild("sell"):WaitForChild("Zone");
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local dataModule = require(script:WaitForChild("data"));
local ls = require(script:WaitForChild("stats"));
local int = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("integer"));
local format = dataModule.format;
local fullyLoaded = {};
local profiles = {};
local multipliersTbl = {};
local baseMultipliers = {};
local infiniteBackpack = {};
local effects = require(script:WaitForChild("effects"));
local moneyCap = 1*10^72;

local globalBoosts = {
	{
		power = 2,
		expiresAt = 1640607877
	}
}

local getBoost = function()
	local total = 0;
	for _,boost in pairs(globalBoosts) do
		if(os.time() <= boost.expiresAt) then
			total += boost.power;
		end
	end
	return(total <= 0 and 1 or total)
end

shared.getBoost = getBoost;

local noDecimals = function(num)
	return(string.format("%.f",num)):split(".")[1];
end

dataModule.playerJoined:Connect(function(plr)
	plr:SetAttribute("equipLimit",3);
end)

local multipliers = function(player)
	if(profiles[player]) then
		local rebirthCount = tonumber(ls:get(player,"Rebirths"));
		local vip = player:GetAttribute("VIP");
		
		local base = {
			coins = 1,
			toys = 1
		}
		
		if(rebirthCount > 0) then
			base.coins = base.coins * (rebirthCount * 2);
			base.coins = base.coins * (vip and 2 or 1);
			base.toys = base.toys * (rebirthCount * 1.25);
			base.toys = base.toys * (vip and 2 or 1);
		end
		
		if(baseMultipliers[player]) then
			if(baseMultipliers[player]["toys"]) then
				base.toys = base.toys * 2;
			end
			if(baseMultipliers[player]["coins"]) then
				base.coins = base.coins * 2;
			end
		end
		
		if(vip) then
			base.toys *= 1.5;
		end
				
		multipliersTbl[player] = base;
		
		return base;
	else
		return "n/a";
	end
end

shared.toy_mult = function(num,player)
	local boost = player:GetAttribute("AddBoost");
	return tostring(int.new(num)*int.new(multipliersTbl[player].toys))*int.new(boost <= 1 and 1 or boost)*int.new(getBoost())
end

shared.player_rewards = {};
shared.coin_rewards = {};

local onChanged = function(stat,callback)
	coroutine.wrap(callback)(stat.Value);
	stat:GetPropertyChangedSignal("Value"):Connect(function()
		callback(stat.Value);
	end)
end

game:GetService("Players").PlayerRemoving:Connect(function(player)
	for _,gift in pairs(workspace.gifts:GetChildren()) do
		if(gift.Values.Owner.Value == player) then
			gift.Values.Owner.Value = nil;
		end
	end
end)

dataModule.characterAdded.partAdded:Connect(function(part)
	physicsService:SetPartCollisionGroup(part,"players");
end)

dataModule.characterAdded.loaded:Connect(function(character)
	fullyLoaded[character] = true;
end)

dataModule.characterAdded:Connect(function(character)
	local rp = character:WaitForChild("HumanoidRootPart");
	game:GetService("RunService").Heartbeat:Wait();
	rp.CFrame = workspace.areas.Spawn.CFrame + Vector3.new(0,5,0);
end)

local getIncrease = function(value,player)
	local add = (multipliersTbl[player]["coins"]);
	local raw = tonumber(tonumber(value) * tonumber(add > 1 and add or 2));
	local group =  (player:IsInGroup(12248057) and 1.25 or 1);
	raw = raw * group
	raw = raw * getBoost();
	return raw;
end

local touched = function(hit)
	local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent);
	if(player and hit:IsA("BasePart") and (hit.Position - sellZone.Position).magnitude < 15) then
		if(player:GetAttribute("loaded") == true) then
			if(shared.enough(player.leaderstats.Toys,1) and (#shared.coin_rewards[player]["toGive"] == 0)) then
				local v1 = tonumber(player.leaderstats.Coins.Real.Value);
				local new = shared.addNoChange(player.leaderstats.Coins,tostring(getIncrease(player.leaderstats.Toys.Real.Value,player)));
				shared.set(player.leaderstats.Coins,shared.clamp(new,0,noDecimals(moneyCap)));
				local v2 = tonumber(player.leaderstats.Coins.Real.Value);
				shared.set(player.leaderstats.Toys,0);
				network:fireClient("generalAnimation",player,"cashNoise",hit);
				network:fireClient("onStatChange",player,v2-v1,"Coins","Coins");
			end
		end
	end
end

dataModule.playerJoined:Connect(function(player)
	shared.player_rewards[player] = {};
	shared.coin_rewards[player] = {toTake = {},toGive = {}};
	player:SetAttribute("loaded",false);
	player:SetAttribute("backpack","0");
	player:SetAttribute("backpackSize","0");
	multipliers(player);
	
--[[
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(shared.get_speaker(player.Name));
	local extraData = (shared.get_speaker(player.Name))["ExtraData"];
	local tag,color = getTag(player.UserId);
	if(tag) then
		table.insert(extraData.Tags,tag);
	end
	if(color) then
		extraData.NameColor = color;
	end
	]]
end)

ls:setup({
	{"Coins",0},
	{"Toys",0},
	{"Rebirths",0}
}).loaded:Connect(function(player,methods,profile)
	onChanged(player.leaderstats["Toys"]["Real"],function(new)
		player:SetAttribute("backpack",new);
		profile.backpack.amount = new;
	end)
end)

local handleChatColor = function(player)
	local colors = profiles[player]["colors"]
	local chatColor = colors["chatColor"]
	local nameColor = colors["nameColor"]
	if(nameColor) then
		player:SetAttribute("DisplayNameColor",Color3.fromHex(nameColor))
		player:SetAttribute("NameColor",Color3.fromHex(nameColor))
	elseif(nameColor == false) then
		player:SetAttribute("RefreshColors",true)
		colors["nameColor"] = nil
	end
	if(chatColor) then
		player:SetAttribute("ChatColor",Color3.fromHex(chatColor))
	elseif(chatColor == false) then
		player:SetAttribute("RefreshColors",true)
		colors["chatColor"] = nil
	end
end

dataModule.profileLoaded:Connect(function(profile,player)
	player:SetAttribute("rudolph",profile.givenRudolph)
	local currentPets = Instance.new("Folder");
	currentPets.Name = "CurrentPetsEquipped";
	currentPets.Parent = player;
	
	player:SetAttribute("petLimit",profile.petLimit);
	if(player:GetRankInGroup(game.CreatorId) >= 200) then
		player:SetAttribute("Tester",true);
		player:SetAttribute("petLimit",2000);
	end
	profiles[player] = profile;
	player:SetAttribute("loaded",true);
	player:SetAttribute("backpack",profile.backpack.amount);
	local handle = function()
		if(player:GetAttribute("infinite")) then
			player:SetAttribute("backpackSize","inf");
		else
			player:SetAttribute("backpackSize",profile.backpack.limit);
		end
	end

	player.AttributeChanged:Connect(function(name)
		if(name == "backpackSize" and(not player:GetAttribute("infinite"))) then
			profile.backpack.limit = player:GetAttribute("backpackSize");
		elseif(name == "infinite") then
			handle();
		end
	end)
	handle();

	for key,stat in pairs(profile.areas) do
		player:SetAttribute(unpack(stat));
		player.AttributeChanged:Connect(function(name)
			if(name == stat[1]) then
				profile.areas[key][2] = player:GetAttribute(name);
			end
		end)
	end

	--[[
		local leaderstats = Instance.new("Folder",player);
	local ls = {};
	leaderstats.Name = "leaderstats";

	player:SetAttribute("backpack",profile.backpack.amount);
	player:SetAttribute("backpackSize",profile.backpack.limit);
	
	player.AttributeChanged:Connect(function(name)
		if(name == "backpackSize") then
			profile.backpack.limit = player:GetAttribute("backpackSize");
		end
	end)
	
	for key,stat in pairs(profile.leaderstats) do
		local statName,statValue = unpack(stat);
		local value = Instance.new((type(statValue) == "string" and "StringValue" or "IntValue"),leaderstats);
		value.Name = statName;
		value.Value = statValue;
		value:GetPropertyChangedSignal("Value"):Connect(function()
			profile.leaderstats[key] = {statName,value.Value};
		end)
		ls[statName] = value;
	end

	for key,stat in pairs(profile.areas) do
		player:SetAttribute(unpack(stat));
		player.AttributeChanged:Connect(function(name)
			if(name == stat[1]) then
				profile.areas[key][2] = player:GetAttribute(name);
			end
		end)
	end

	onChanged(ls["Toys"],function(new)
		player:SetAttribute("backpack",new);
		profile.backpack.amount = new;
	end)
	]]
	handleChatColor(player)
end)

dataModule.onSecond:Connect(function(profile,player)
	player:SetAttribute("TimePlayed",profile.timePlayed+1);
	profile.timePlayed += 1;
end)

network:createRemoteEvent("giftAnimation");
network:createRemoteEvent("size");
network:createRemoteEvent("scaleGui");
network:createRemoteEvent("generalAnimation");

local calculate = function(zone,player)
	local rebirths = tonumber(player.leaderstats.Rebirths.Real.Value);
	if(rebirths < 1) then
		return zone:GetAttribute("Cost");
	else
		return zone:GetAttribute("Cost") * (rebirths * 3);
	end
end

local log = function(...)
	
end

network:createRemoteFunction("unlockRegion",function(player,zone,clientCost)
	if(zone and zone.Parent == workspace.areas.separators) then
		if(type(zone) ~= "table") then
			local cost = calculate(zone,player);
			if(clientCost ~= cost) then
				player:Kick("Something went wrong.");
				return false;
			end
			if(player:GetAttribute("loaded")) then
				local stat = player.leaderstats.Coins;
				if(shared.enough(stat,cost)) then
					if(player:GetAttribute(zone.Name) == false) then
						player:SetAttribute(zone.Name,true);
						shared.add(stat,(-cost));
						return true;
					else
						log("Attribute not loaded")
					end
				else
					log("Invalid funds")
				end
			else 
				log("Player not loaded");
			end
		else
			player:Kick("pls dont send fake objects lol");
		end
	else
		player:Kick();
	end
	return false;
end)

--[[
network:createRemoteFunction("giveCoins",function(player)
	if(player and (player.Character.HumanoidRootPart.Position - sellZone.Position).magnitude < 15) then
		if(player:GetAttribute("loaded") == true) then
			local toGive = shared.coin_rewards[player];
			if(toGive) then
				if(#toGive["toGive"] > 0) then
					local amount = toGive["toGive"][1];
					local take = toGive["toTake"][1];
					for _,v in pairs(toGive) do
						table.remove(v,1);
					end
					player.leaderstats.Coins.Value += getIncrease(amount);
					player.leaderstats.Toys.Value += -take;
				end
			else
				return "no free coins for you, please do something better with your life :)";
			end
		end
	end
end)
]]

network:createRemoteFunction("giveToys",function(player,gift)
	if(gift.Parent == workspace.gifts) then
		local reward = shared.player_rewards[player][gift:GetAttribute("ID")];
		if(reward and gift:GetAttribute("Destroyed")) then
			if(#reward.check > 0) then
				table.remove(reward.check,1);
				local twoTimesToys = (profiles[player]["boosts"]["2xT"] >= 1 and 2 or 1);
				local boost = player:GetAttribute("AddBoost");
				local increment = (((math.floor(((reward.max / reward.total) + 1/2)))*(multipliersTbl[player].toys))*twoTimesToys)*(1 + boost)*getBoost()
				local limit = shared.addNoChange(player.leaderstats.Toys,tostring(increment));
				local val1 = player.leaderstats.Toys.Real.Value;
				local current = shared.clamp(limit,0,player:GetAttribute("backpackSize"));
				shared.set(player.leaderstats.Toys,
					shared.clamp(current,0,noDecimals(moneyCap/1.1)
				));
				local val2 = player.leaderstats.Toys.Real.Value;
				if(val1 ~= val2) then
					network:fireClient("onStatChange",player,tonumber(val2)-tonumber(val1),"Toys","Presents");
				end
				if(#reward.check == 0) then
					shared.player_rewards[player][gift:GetAttribute("ID")] = nil;
				end
			end
		else
			return "if only my remote security was that bad lmao (don't you have anything better to do with your life?)";
		end
	end
end)

local requested = {};

network:createRemoteFunction("getObjects",function(player)
	if(not requested[player]) then
		requested[player] = true;
		local a = workspace:WaitForChild("areas"):WaitForChild("area0"):GetDescendants();
		local b = workspace:WaitForChild("areas"):WaitForChild("area1"):GetDescendants();
		local c = workspace:WaitForChild("areas"):WaitForChild("area2"):GetDescendants();
		return {a,b,c};
	end
end)

network:createRemoteEvent("clientLoaded",function(player)
	player:SetAttribute("ClientLoaded",true);
end)

network:createRemoteFunction("openAdminPanel",function(player)
	player:Kick("boi did you actually think??");
end)

network:createRemoteFunction("getLinked",function(player,id)
	local linked = {};
	for plr,data in pairs(shared.player_rewards) do
		if(data[id]) then
			table.insert(linked,plr);
		end
	end
	return linked;
end)

sellZone.Touched:Connect(touched);

function duplicate(t, deep, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end

	local nt = {}
	for k, v in pairs(t) do
		if deep and type(v) == 'table' then
			nt[k] = duplicate(v, deep, seen)
		else
			nt[k] = v
		end
	end
	seen[t] = nt
	return nt
end

local rebirth = function(player)
	dataModule.badge:award(player,"rebirther");
	ls:add(player,"Rebirths",1);
	ls:set(player,"Coins","0");
	ls:set(player,"Toys","0");
	local newCount = tonumber(player.leaderstats.Rebirths.Real.Value);

	local profile = profiles[player];
	local hasRudolph = profile.givenRudolph;
	local hasVulcan = profile.givenVulcan;
	profile.backpack = duplicate(dataModule.template.backpack);
	profile.areas = duplicate(dataModule.template.areas);
	profile.owned_backpacks = duplicate(dataModule.template.owned_backpacks);
	profile.owned_rayguns = duplicate(dataModule.template.owned_rayguns);
	profile.selected = duplicate(dataModule.template.selected);
	profile.player_pets = duplicate(dataModule.template.player_pets);
	shared.remove_pets(player);
	if(hasRudolph) then
		local real = game:GetService("ServerStorage"):WaitForChild("pets"):WaitForChild("Rudolph");
		local arr = {{
			name = real.Name,
			displayName = real:GetAttribute("DisplayName"),
			image = real:GetAttribute("Image"),
			tier = real:GetAttribute("Tier"),
			identifier = game:GetService("HttpService"):GenerateGUID()
		}}
		table.insert(profile.player_pets.owned,arr[1])
	end
	if(hasVulcan) then
		local real = game:GetService("ServerStorage"):WaitForChild("pets"):WaitForChild("Vulcan");
		local arr = {{
			name = real.Name,
			displayName = real:GetAttribute("DisplayName"),
			image = real:GetAttribute("Image"),
			tier = real:GetAttribute("Tier"),
			identifier = game:GetService("HttpService"):GenerateGUID()
		}}
		table.insert(profile.player_pets.owned,arr[1])
	end
	local linked = "Backpack8";
	for name,_ in pairs(player.OwnedBackpacks:GetAttributes()) do
		player.OwnedBackpacks:SetAttribute(name,nil);
	end
	for name,_ in pairs(player.OwnedTools:GetAttributes()) do
		player.OwnedTools:SetAttribute(name,nil);
	end
	if(not table.find(profiles[player].owned_backpacks,linked)) then
		if(player:GetAttribute("OwnsInfiniteBackpack")) then
			table.insert(profiles[player].owned_backpacks,linked);
			player.OwnedBackpacks:SetAttribute(linked,true);
		end
	end
	player.OwnedBackpacks:SetAttribute("Backpack1",true);
	player.OwnedTools:SetAttribute("Raygun",true);
	
	local newSize = 100;
	if(newCount >= 1) then
		newSize *= (newCount * 3);
	end
	
	player:SetAttribute("SelectedRaygun","Raygun");
	player:SetAttribute("SelectedBackpack","Backpack1");
	player:SetAttribute("backpack",profile.backpack.amount);
	player:SetAttribute("backpackSize",tostring(newSize));
	for key,stat in pairs(dataModule.template.areas) do
		player:SetAttribute(unpack(stat));
	end
	
	local signal;
	signal = player.CharacterAppearanceLoaded:Connect(function(character)
		signal:Disconnect();
		effects.rebirthEffect(character:WaitForChild("HumanoidRootPart"),3);
		local sound = Instance.new("Sound");
		sound.SoundId = "rbxassetid://5736400107";
		sound.RollOffMaxDistance = 200;
		sound.Parent = character:WaitForChild("Head");
		sound:Play();
		sound.Ended:Connect(function()
			sound:Destroy();
		end)
	end)
	
	player:LoadCharacter();
	network:fireClient("refreshPets",player);
end

local getPriceOfRebirth = function(currentRebirths)
	local basePrices = {
		[1] = 1000000,[10] = 10000000,[100] = 100000000,
		[1000] = 1000000000,[10000] = 10000000000,[100000] = 100000000000,
		[1000000] = 1000000000000
	}

	local halfNumber = 100;
	local currentMultiplier = 1;
	local currentPrice = 1000000;

	for i = 0,currentRebirths do
		if(i == halfNumber) then
			currentMultiplier /= 2;
			halfNumber *= 2;
		end
		currentPrice *= (1 + currentMultiplier);
	end

	for numOfRebirths,_ in pairs(basePrices) do
		basePrices[numOfRebirths] = currentPrice * numOfRebirths
	end

	return tostring(basePrices[1]);
end

local from = function(player)
	if(profiles[player]) then
		local currentAmount = tonumber(ls:get(player,"Rebirths"));
		return true,getPriceOfRebirth(currentAmount)
		
	else
		return false,"Data not loaded yet.";
	end
end

network:createRemoteFunction("tutorial",function(player,state,key,value,opt)
	if(state == "get") then 
		local profile = profiles[player];
		if(profile) then
			return true,profile["tutorial"];
		else
			return false,"data not loaded";
		end
	elseif(state == "set") then
		local profile = profiles[player];
		if(profile) then
			local tutorial = profile["tutorial"];
			if(tutorial) then
				if(tutorial[key] ~= nil) then
					if(type(value) == "boolean") then
						profile["tutorial"][key] = value;
						if(value and (opt == nil)) then
							dataModule.badge:award(player,"tutorial")
						end
						return true,profile["tutorial"];
					else
						return false,"could you dont"
					end
				else
					return false,"invalid keyset";
				end
			end
		else
			return false,"data not loaded";
		end
	end
end)

network:createRemoteFunction("getRebirthPrice",from);
network:createRemoteFunction("rebirth",function(player)
	local success,response = from(player);
	if(success) then
		local can = (shared.enough_raw(ls:get(player,"Coins"),response));
		if(can) then
			rebirth(player);
			multipliers(player);
			local _,cost = from(player);
			return true,cost;
		else
			return false,"Not enough coins.";
		end
	else
		return false,response;
	end
end)

network:createRemoteFunction("uiSettings",function(player,option,key)
	if(option == "retrieve") then
		local profile = profiles[player];
		if(profile) then
			return true,profile["uiData"];
		else
			return false,"wait";
		end
	else
		local conf = require(game:GetService("ReplicatedStorage"):WaitForChild("config")).ui_data;
		for _,pair in pairs(conf) do
			if(pair[1] == option and type(key) == pair[2]) then
				if(type(key) == "string") then
					key = key:sub(1,1000);
				end
				local profile = profiles[player];
				if(profile) then
					profile["uiData"][option] = key;
					return true,profile["uiData"];
				else
					return false,"wait";
				end
			end
		end
	end
end)
network:createRemoteFunction("getMultipliers",function(player)
	return multipliers(player);
end)

network:createRemoteFunction("ping",function()
	return "pong";
end)

network:createRemoteFunction("getColor",function(player,name)
	return(profiles[player]["colors"][name])
end)

local colorAbility = {}
network:createRemoteFunction("changeChatColor",function(player,option,new)
	if((typeof(new) == "Color3" and colorAbility[player]) or (typeof(new) == "boolean")) then
		local colors = profiles[player]["colors"]
		if(option == "chatColor") then
			if(typeof(new) == "boolean") then
				if(not new) then
					colors["chatColor"] = false
				end
				handleChatColor(player)
				return
			end
			colors["chatColor"] = new:ToHex()
		else
			if(typeof(new) == "boolean") then
				if(not new) then
					colors["nameColor"] = false
				end
				handleChatColor(player)
				return
			end
			profiles[player]["colors"]["nameColor"] = new:ToHex()
		end
		handleChatColor(player)
		return true
	else
		return ":kekw:"
	end
end)

network:createRemoteEvent("onStatChange");

network:createRemoteEvent("onPurchase");
game:GetService("MarketplaceService").PromptGamePassPurchaseFinished:Connect(function(p,id,wp)
	wait(0.1);
	network:fireClient("onPurchase",p,wp);
end)

-- passes:

dataModule.marketplace.gamepassOwned(45343802):Connect(function(plr)
	colorAbility[plr] = true
	plr:SetAttribute("Colors",true)
end)

dataModule.marketplace.gamepassOwned(24838183):Connect(function(plr)
	infiniteBackpack[plr] = true;
end)

dataModule.marketplace.gamepassOwned(24838119):Connect(function(plr) -- 2x coins
	baseMultipliers[plr] = baseMultipliers[plr] or {};
	baseMultipliers[plr]["coins"] = true;
end)

dataModule.marketplace.gamepassOwned(24838132):Connect(function(plr) -- 2x toys
	baseMultipliers[plr] = baseMultipliers[plr] or {};
	baseMultipliers[plr]["toys"] = true;
end)

dataModule.marketplace.gamepassOwned(24838174):Connect(function(plr) -- more pets
	plr:SetAttribute("equipLimit",6);
	plr:SetAttribute("MorePets",true);
end)

dataModule.marketplace.gamepassOwned(24838206):Connect(function(plr)
	plr:SetAttribute("HatchMorePets",true);
end)

local canSprint,trailManager = {},{};

dataModule.marketplace.gamepassOwned(24838145):Connect(function(plr) -- sprint
	plr:SetAttribute("runningEnabled",true);
	canSprint[plr] = true;
end)

local base = {};
local trails = game:GetService("ServerStorage"):WaitForChild("trails");

network:createRemoteEvent("runningState",function(player,state)
	if(type(state) == "boolean") then
		if(canSprint[player]) then
			local runningTrail = trails:WaitForChild("Running");
			base:cache(player);
			local trail = trailManager[player.Character]:cacheTrail(runningTrail);
			trail.Enabled = state;
		else
			player:Kick("");
		end
	end
end)

local newAttachment = function(part)
	local attachment = Instance.new("Attachment");
	attachment.Parent = part;
	attachment.Name = "TrailAttachment";
	return attachment;
end

function base:cache(player)
	if(not trailManager[player.Character]) then
		base:setup(player);
	end
end

function base:setup(player)
	local character = player.Character;
	local upper = character:WaitForChild("Head");
	local lower = character:WaitForChild("HumanoidRootPart");
	local at0 = newAttachment(upper);
	local at1 = newAttachment(lower);
	trailManager[character] = {
		currentTrail = nil,
		baseTrail = nil,
		addTrail = function(self,trail,base)
			trail = trail:Clone();
			if(self.currentTrail) then
				self.currentTrail:Destroy();
			end
			trail.Parent = character;
			trail.Attachment0 = at1;
			trail.Attachment1 = at0;
			self.currentTrail = trail;
			self.baseTrail = base;
			return trail;
		end,
		removeTrail = function(self)
			self.currentTrail:Destroy();
			self.currentTrail = nil;
			self.baseTrail = nil;
		end,
		cacheTrail = function(self,trail)
			if(self.baseTrail ~= trail) then
				return self:addTrail(trail,trail)
			else
				return self.currentTrail;
			end
		end,
	};
end

dataModule.playerJoined:Connect(function(player)
	player.CharacterRemoving:Connect(function(character)
		trailManager[character] = nil;
	end)
end)

dataModule.playerJoined:Connect(function(player)
	player:SetAttribute("DefaultSpeed",16);
	player:SetAttribute("AddSpeed",0);

	player:SetAttribute("DefaultJump",50);
	player:SetAttribute("AddJump",0);
	player:SetAttribute("AddBoost",0);
	player:SetAttribute("AddDamage",0);
	
	local selection = Instance.new("ObjectValue");
	selection.Name = "Selection";
	selection.Parent = player;
end)

local setShadowedText = function(label,text)
	label.Text = text;
	label.Shadow.Text = text;
end

dataModule.characterAdded.loaded:Connect(function(character,player)
	local name = player.DisplayName;
	local overhead = game:GetService("ServerStorage"):WaitForChild("Overhead"):Clone();
	setShadowedText(overhead:FindFirstChild("Username"),name);
	if(player.Name == "Jumpathy" or player.UserId == 111954405) then
		setShadowedText(overhead.Rank,"Developer");
		overhead.Rank.Visible = true;
	end
	overhead.Parent = character:WaitForChild("Head");
end)

local limit = 300;

local getCount = function(profile)
	return profile["friends"]["count"];
end

local addToList = function(profile,userId)
	if(getCount(profile) <= limit) then
		if(not profile["friends"]["joined"][userId]) then
			profile["friends"]["joined"][userId] = true;
			profile["friends"]["count"] += 1;
			return true,getCount(profile);
		else
			return false,getCount(profile);
		end
	else
		return false,getCount(profile);
	end
end

local disconnects = {};

local playerJoined = function()
	local bindable = {
		callbacks = {},
		Connect = function(self,callback)
			table.insert(self.callbacks,callback);
			local on = function(...)
				coroutine.wrap(callback)(...);
			end
			local signal = game:GetService("Players").PlayerAdded:Connect(on);
			for _,player in pairs(game:GetService("Players"):GetPlayers()) do
				on(player);
			end
			return {
				Disconnect = function(s2)
					signal:Disconnect();
					for key,cb in pairs(self.callbacks) do
						if(cb == callback) then
							table.remove(self.callbacks,key);
						end
					end
					s2 = {};
					self = {};
				end,
			}
		end
	}	
	return bindable;
end

local creators = {87424828,111954405};

local friendsJoined = function(player)
	local cached = {};
	local bindable = {
		callbacks = {},
		Connect = function(self,callback)
			table.insert(self.callbacks,callback);
		end,
		Fire = function(self,...)
			for _,cb in pairs(self.callbacks) do
				coroutine.wrap(cb)(...);
			end
		end,
	};
	local event = playerJoined():Connect(function(newPlayer)
		if(newPlayer:IsFriendsWith(player.UserId)) then
			bindable:Fire(newPlayer);
		end
	end)
	disconnects[player] = {main = {},call = function(self)
		for _,event in pairs(self.main) do
			event:Disconnect();
		end
		disconnects[player] = nil;
		bindable.callbacks = {};
		bindable = {};
		cached = {};
		event:Disconnect();
	end};
	return bindable;
end

dataModule.profileLoaded:Connect(function(profile,player)
	dataModule.badge:award(player,"welcome");
	friendsJoined(player):Connect(function(plr)
		local success,newCount = addToList(profile,plr.UserId);
		if(newCount >= 5) then
			dataModule.badge:award(player,"social");
		end
	end)
	table.insert(disconnects[player]["main"],playerJoined(player):Connect(function(plr)
		if(table.find(creators,plr.UserId)) then
			dataModule.badge:award(player,"metCreators");
		end
	end))
end)

network:createRemoteEvent("teleport",function(player,key)
	if(player:GetAttribute("CanTeleport")) then
		local tp = workspace:WaitForChild("teleports"):FindFirstChild(tostring(key));
		if(tp) then
			player.Character.HumanoidRootPart.CFrame = tp.CFrame;
		end
	end
end)

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	if(disconnects[plr]) then
		disconnects[plr]:call();
	end
end)

local boards;
local grand = {};
while task.wait(1) do
	boards = {shared.leaderboard_1,shared.leaderboard_2,shared.leaderboard_3};
	grand = {};
	for i = 1,#boards do
		boards[i] = boards[i] or {};
		for _,userId in pairs(boards[i]) do
			grand[userId] = true;
		end
	end
	for _,player in pairs(game:GetService("Players"):GetPlayers()) do
		if(grand[player.UserId]) then
			player:SetAttribute("Leaderboard",true);
		else
			player:SetAttribute("Leaderboard",false);
		end
	end
end