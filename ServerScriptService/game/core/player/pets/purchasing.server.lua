local areas = workspace:WaitForChild("areas");
local handler = require(script.Parent.Parent.Parent.Parent:WaitForChild("data"));
local roll = handler.roll;
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local petsList = require(game:GetService("ServerStorage"):WaitForChild("petBase"));
local eggCrates = {};

local tiered = {};
for area,pets in pairs(petsList) do
	tiered[area] = tiered[area] or {};
	for _,pet in pairs(pets) do
		tiered[area][pet.Tier] = tiered[area][pet.Tier] or {};
		table.insert(tiered[area][pet.Tier],pet.Name);
	end
end

-- 3 of class
-- 1 of other
-- 1 of other

local idx = {};
local preset = {
	[1] = {
		["Legendary"] = {
			["Legendary"] = 3, -- 3 total
			["Common"] = 1, -- 7 total
			["Uncommon"] = 1 -- 5 total
		},
		["Uncommon"] = {
			["Uncommon"] = 3,
			["Common"] = 3,
		},
		["Common"] = {
			["Common"] = 3,
			["Uncommon"] = 1
		}
	},
	[2] = {
		-- 6 common
		-- 4 legendary
		-- 5 uncommon
		["Legendary"] = {
			["Legendary"] = 3,
			["Uncommon"] = 1
		},
		["Uncommon"] = {
			["Uncommon"] = 3,
			["Common"] = 2,
			["Legendary"] = 1
		},
		["Common"] = {
			["Common"] = 4,
			["Uncommon"] = 2
		}
	}
}

for area,data in pairs(tiered) do
	eggCrates[area] = {["Legendary"] = {},["Uncommon"] = {},["Common"] = {}};
	local current = eggCrates[area];
	idx = {};
	if(preset[area]) then
		for crateTier,insert in pairs(current) do
			local main = (preset[area][crateTier]);
			for tier,addAmount in pairs(main) do
				for i = 1,addAmount do
					local key = idx[tier] or 0;
					idx[tier] = key + 1;
					table.insert(insert,(data[tier][key + 1]));
				end
			end
		end
	end
end

local prompts = {};

local logic = function(eggContainer,key)
	local tier = eggContainer.Name:split("Eggs")[1];
	local chances = require(eggContainer:WaitForChild("chances"));
	chances.pets = eggCrates[key][tier];
	chances:setup();
	
	local proximity = Instance.new("ProximityPrompt");
	proximity.Name = "Prompt";
	proximity.Parent = eggContainer.PrimaryPart;
	proximity.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally;
	proximity.ActionText = "Purchase";
	proximity.ObjectText = "Hold to purchase";
	proximity.KeyboardKeyCode = Enum.KeyCode.E;
	proximity.MaxActivationDistance = 7;
	proximity.RequiresLineOfSight = false;
	proximity.HoldDuration = 0.5;
	proximity.Triggered:Connect(function(player)
		player:RequestStreamAroundAsync(workspace:WaitForChild("extra"):WaitForChild("lab"):WaitForChild("Camera").Position,8);
		network:fireClient("hatch",player,"init",proximity)
	end)
	
	prompts[eggContainer] = {
		["prompt"] = proximity,
		["tier"] = tier
	};
end

local run = function(object)
	if(object:IsA("Model") and object.Name:find("Eggs") and object.Parent.Name == "interactables") then
		--if(object.Parent.Parent.Name == "area1") then
			local area = (object.Parent.Parent.Name == "area1" and 1 or 2);
			coroutine.wrap(logic)(object,area);
		--end
	end
end

areas.DescendantAdded:Connect(run);
for _,descendant in pairs(areas:GetDescendants()) do
	run(descendant);
end

local notEnoughMoney = function(player)
	network:fireClient("hatch",player,"notEnough");
end

local petLimit = function(player)
	network:fireClient("hatch",player,"limit");
end

local getTier = function(a)
	for _,pet in pairs(game:GetService("ServerStorage"):WaitForChild("pets"):GetChildren()) do
		if(pet.Name == a) then
			return pet:GetAttribute("Tier");
		end
	end
end

local has = function(current,name)
	for _,pet in pairs(current) do
		if(pet.name == name) then
			return true;
		end
	end
end

local from = function(options,tier,old)
	local final = {};
	for _,pet in pairs(options) do
		if(getTier(pet) == tier) then
			table.insert(final,pet);
		end
	end
	local new = function()
		return final[math.random(1,#final)];
	end
	local name = new();
	if(has(old,name)) then
		local attempts = 0;
		repeat
			attempts += 1;
			name = new();
		until(not has(old,name) or attempts > 500);
	end
	local folder = game:GetService("ServerStorage"):WaitForChild("pets");
	local real = folder:WaitForChild(name);
	return {
		name = name,
		displayName = real:GetAttribute("DisplayName"),
		image = real:GetAttribute("Image"),
		tier = real:GetAttribute("Tier"),
		identifier = game:GetService("HttpService"):GenerateGUID()
	};
end

local profiles = {};
handler.profileLoaded:Connect(function(profile,player)
	profiles[player] = profile;
end)

local limit = function(plr)
	return shared.getLimit(plr);
end

local last = {};

local load = function(model,plr,hatchCount,area,pets)
	local chanceTable = require(model:WaitForChild("chances"));
	local main = model.Name:split("Eggs")[1];
	local newPets = {};
	for i = 1,hatchCount do
		local tier = roll(chanceTable.probability);
		local pet = from(eggCrates[area][main],tier,newPets);
		table.insert(pets,pet);
		table.insert(newPets,pet);
	end
	network:fireClient("hatch",plr,"doHatch",model,newPets[1],newPets);
end

local rudolph = function(player)
	local rudolphModel = workspace:WaitForChild("RudolphEgg");
	local real = game:GetService("ServerStorage"):WaitForChild("pets"):WaitForChild("Rudolph");
	local arr = {{
		name = real.Name,
		displayName = real:GetAttribute("DisplayName"),
		image = real:GetAttribute("Image"),
		tier = real:GetAttribute("Tier"),
		identifier = game:GetService("HttpService"):GenerateGUID()
	}}
	local profile = profiles[player];
	local pets = profile.player_pets.owned;
	for _,pet in pairs(arr) do
		table.insert(pets,pet);
	end
	network:fireClient("hatch",player,"doHatch",rudolphModel,arr[1],arr);
end

local vulcan = function(player)
	local eggModel = workspace:WaitForChild("VulcanEgg");
	local real = game:GetService("ServerStorage"):WaitForChild("pets"):WaitForChild("Vulcan");
	local arr = {{
		name = real.Name,
		displayName = real:GetAttribute("DisplayName"),
		image = real:GetAttribute("Image"),
		tier = real:GetAttribute("Tier"),
		identifier = game:GetService("HttpService"):GenerateGUID()
	}}
	local profile = profiles[player];
	local pets = profile.player_pets.owned;
	for _,pet in pairs(arr) do
		table.insert(pets,pet);
	end
	network:fireClient("hatch",player,"doHatch",eggModel,arr[1],arr);
end

network:createRemoteEvent("createNotification")

local notify = function(player,text)
	network:fireClient("createNotification",player,text)
end

shared.give_rudolph = function(player)
	local profile = profiles[player];
	if(profile) then
		if(not profile.givenRudolph) then
			profile.givenRudolph = true;
			player:SetAttribute("rudolph",true)
			coroutine.wrap(rudolph)(player);
			handler.badge:award(player,"rudolph")			
		else
			notify(player,"You've already claimed your pet!");
		end
	end
end

shared.give_vulcan = function(player)
	local profile = profiles[player];
	if(profile) then
		if(not profile.givenVulcan) then
			profile.givenVulcan = true;
			player:SetAttribute("rudolph",true)
			coroutine.wrap(vulcan)(player);
			handler.badge:award(player,"vulcan")			
		end
	end
end

shared.egg_hatch = {};

function shared.egg_hatch:forge(player,prompt,amount)
	local model = prompt.Parent.Parent.Parent;
	local area = (model.Parent.Parent.Name == "area1" and 1 or 2);
	local profile = profiles[player];
	local pets = profile.player_pets.owned;
   	load(model,player,amount,area,pets);
end

function shared.egg_hatch:getPrompts()
	return prompts;
end

function shared.egg_hatch:hatch(plr,prompt)
	local profile = profiles[plr];
	if(profile) then
		local model = prompt.Parent.Parent.Parent;
		local area = (model.Parent.Parent.Name == "area1" and 1 or 2);
		local cost = model:GetAttribute("Price");
		local pets = profile.player_pets.owned;
		if(#pets + 1 <= limit(plr)) then
			load(model,plr,1,area,pets);
		else
			petLimit(plr);
		end
	end
end

network:createRemoteEvent("hatch",function(plr,prompt,amount)
	if(prompt and prompt:IsA("ProximityPrompt")) then
		if(last[plr]) then
			if(tick() - last[plr] <= 4) then
				return;
			end
		end
		local hatchCount = 1;
		if(amount ~= nil and type(amount) == "number") then
			if(plr:GetAttribute("HatchMorePets")) then
				hatchCount = math.floor(math.clamp(amount,1,3));
			end
		end
		last[plr] = tick();
		local model = prompt.Parent.Parent.Parent;
		local area = (model.Parent.Parent.Name == "area1" and 1 or 2);
		local cost = model:GetAttribute("Price");
		if(hatchCount >= 2) then
			cost = math.floor((cost * hatchCount) * 0.75);
		end
		if(plr:GetAttribute("hatchAmount")) then
			hatchCount += plr:GetAttribute("hatchAmount");
		end
		local profile = profiles[plr];
		if(cost and profile) then
			local stat = plr.leaderstats.Coins;
			local pets = profile.player_pets.owned;
			if(#pets + hatchCount <= limit(plr)) then
				if(shared.enough(stat,cost)) then
					shared.add(stat,-cost);
					handler.badge:award(plr,"pets");
					load(model,plr,hatchCount,area,pets);
				else
					notEnoughMoney(plr);
				end
			else
				petLimit(plr);
			end
		else
			warn(model,cost);
		end
	end
end)