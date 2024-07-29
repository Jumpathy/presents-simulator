local ranges = {
	[0] = {
		health = {1000,4000},
		give = function(health)
			local max = health/1.195;
			local min = health/1.5;
			return {min,max};
		end,
	},
	[1] = {
		health = {100,800},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end,
	},
	[2] = {
		health = {1000,4000},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end,
	},
	[3] = {
		split = {10,20},
		health = {6000,15000},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end,
	},
	[4] = {
		health = {20000,50000},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end,
	},
	[5] = {
		health = {150000,500000},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end
	},
	[6] = {
		health = {1000000,1250000},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end
	},
	[7] = {
		health = {1000000,1250000},
		give = function(health)
			local max = health/1.5;
			local min = health/3;
			return {min,max};
		end,
	}
}

local default = {
	{
		["LidColor"] = Color3.fromRGB(255,89,89),
		["BaseColor"] = Color3.fromRGB(255,148,148)
	},
	{
		["LidColor"] = Color3.fromRGB(138,255,88),
		["BaseColor"] = Color3.fromRGB(139,255,139)
	},
	{
		["LidColor"] = Color3.fromRGB(9,137,207),
		["BaseColor"] = Color3.fromRGB(139,228,255)
	},
	{
		["LidColor"] = Color3.fromRGB(255,125,11),
		["BaseColor"] = Color3.fromRGB(255,164,52)
	},
	{
		["LidColor"] = Color3.fromRGB(255,0,191),
		["BaseColor"] = Color3.fromRGB(255,135,229)
	},
	{
		["LidColor"] = Color3.fromRGB(255,195,55),
		["BaseColor"] = Color3.fromRGB(248,239,102)
	},
	{
		["LidColor"] = Color3.fromRGB(255,12,77),
		["BaseColor"] = Color3.fromRGB(255,85,127)
	},
	{
		["LidColor"] = Color3.fromRGB(4,175,236),
		["BaseColor"] = Color3.fromRGB(59,248,201)
	}
}

local colors = {
	[0] = default,
	[1] = default,
	[2] = {
		{
			["LidColor"] = Color3.fromRGB(196,40,28),
			["BaseColor"] = Color3.fromRGB(255,0,0)
		},
		{
			["LidColor"] = Color3.fromRGB(13,105,172),
			["BaseColor"] = Color3.fromRGB(180,210,228)
		},
		{
			["LidColor"] = Color3.fromRGB(121,0,121),
			["BaseColor"] = Color3.fromRGB(170,0,170)
		},
		{
			["LidColor"] = Color3.fromRGB(214,97,58),
			["BaseColor"] = Color3.fromRGB(250,116,69)
		},
		{
			["LidColor"] = Color3.fromRGB(172,140,10),
			["BaseColor"] = Color3.fromRGB(241,196,15)
		},
		{
			["LidColor"] = Color3.fromRGB(60,120,60),
			["BaseColor"] = Color3.fromRGB(75,151,75)
		},
	},
	[3] = {
		{
			["LidColor"] = Color3.fromRGB(255,102,204),
			["BaseColor"] = Color3.fromRGB(255,152,220),
			["Candy"] = Color3.fromRGB(255,0,0)
		},
		{
			["LidColor"] = Color3.fromRGB(9,137,207),
			["BaseColor"] = Color3.fromRGB(128,187,219),
			["Candy"] = Color3.fromRGB(9,137,207)
		},
		{
			["LidColor"] = Color3.fromRGB(203,71,71),
			["BaseColor"] = Color3.fromRGB(255,89,89),
			["Candy"] = Color3.fromRGB(196,40,28)
		},
		{
			["LidColor"] = Color3.fromRGB(130,0,130),
			["BaseColor"] = Color3.fromRGB(170,0,170),
			["Candy"] = Color3.fromRGB(255,0,191)
		},
		{
			["LidColor"] = Color3.fromRGB(57,115,57),
			["BaseColor"] = Color3.fromRGB(75,151,75),
			["Candy"] = Color3.fromRGB(57,115,57)
		},
		{
			["LidColor"] = Color3.fromRGB(176,133,40),
			["BaseColor"] = Color3.fromRGB(239,184,56),
			["Candy"] = Color3.fromRGB(179,135,41)
		},
		{
			["LidColor"] = Color3.fromRGB(214,97,58),
			["BaseColor"] = Color3.fromRGB(250,116,69),
			["Candy"] = Color3.fromRGB(250,116,69)
		},
		{
			["LidColor"] = Color3.fromRGB(13,105,172),
			["BaseColor"] = Color3.fromRGB(116,134,157),
			["Candy"] = Color3.fromRGB(4,175,236)
		},
	},
	[4] = {
		{
			["LidColor"] = Color3.fromRGB(255,11,25),
			["BaseColor"] = Color3.fromRGB(248,248,248),
			["Crystal"] = Color3.fromRGB(255,11,25)
		},
		{
			["LidColor"] = Color3.fromRGB(9,137,207),
			["BaseColor"] = Color3.fromRGB(91,93,105)
		},
		{
			["LidColor"] = Color3.fromRGB(13,105,172),
			["BaseColor"] = Color3.fromRGB(27,42,53)
		},
		{
			["LidColor"] = Color3.fromRGB(170,0,170),
			["BaseColor"] = Color3.fromRGB(248,248,248),
			["Crystal"] = Color3.fromRGB(255,85,255)
		},
		{
			["LidColor"] = Color3.fromRGB(31,128,29),
			["BaseColor"] = Color3.fromRGB(248,248,248),
			["Crystal"] = Color3.fromRGB(31,128,29)
		},
		{
			["LidColor"] = Color3.fromRGB(250,116,69),
			["BaseColor"] = Color3.fromRGB(248,248,248),
			["Crystal"] = Color3.fromRGB(250,116,69)
		},
		{
			["LidColor"] = Color3.fromRGB(16,53,103),
			["BaseColor"] = Color3.fromRGB(13,105,172),
			["Crystal"] = Color3.fromRGB(16,53,103)
		},
	},
	[5] = {
		{
			["LidColor"] = Color3.fromRGB(27,42,53),
			["BaseColor"] = Color3.fromRGB(46,71,90),
			["MagmaticCrystal"] = Color3.fromRGB(213,115,61)
		},
		{
			["LidColor"] = Color3.fromRGB(235,81,33),
			["BaseColor"] = Color3.fromRGB(216,41,9),
			["MagmaticCrystal"] = Color3.fromRGB(252,185,48)
		},
		{
			["LidColor"] = Color3.fromRGB(17,17,17),
			["BaseColor"] = Color3.fromRGB(50,50,50),
			["MagmaticCrystal"] = Color3.fromRGB(41,41,41)
		},
		{
			["LidColor"] = Color3.fromRGB(252,185,48),
			["BaseColor"] = Color3.fromRGB(229,164,42),
			["MagmaticCrystal"] = Color3.fromRGB(252,185,48)
		},
	},
	[6] = {
		{
			["LidColor"] = Color3.fromRGB(58,125,21),
			["BaseColor"] = Color3.fromRGB(160,95,53)
		},
		{
			["LidColor"] = Color3.fromRGB(123,47,123),
			["BaseColor"] = Color3.fromRGB(147,56,147)
		},
		{
			["LidColor"] = Color3.fromRGB(153,122,92),
			["BaseColor"] = Color3.fromRGB(255,204,153)
		},
		{
			["LidColor"] = Color3.fromRGB(13,105,172),
			["BaseColor"] = Color3.fromRGB(236,217,131)
		},
		{
			["LidColor"] = Color3.fromRGB(39,70,45),
			["BaseColor"] = Color3.fromRGB(160,95,53)
		},
		{
			["LidColor"] = Color3.fromRGB(31,128,29),
			["BaseColor"] = Color3.fromRGB(236,217,131)
		},
		{
			["LidColor"] = Color3.fromRGB(13,105,172),
			["BaseColor"] = Color3.fromRGB(128,187,219)
		},
		{
			["LidColor"] = Color3.fromRGB(75,151,75),
			["BaseColor"] = Color3.fromRGB(128,187,219)
		},
		{
			["LidColor"] = Color3.fromRGB(255,89,89),
			["BaseColor"] = Color3.fromRGB(248,248,248)
		},
	},
	[7] = {}
}

local toyTypes = {
	[0] = "vip",
	[1] = "regular",
	[2] = "winter",
	[3] = "candyland",
	[4] = "crystal",
	[5] = "lava",
	[6] = "beach",
	[7] = "frost"
}

local presentsHandler = require(script.Parent.Parent:WaitForChild("logic"):WaitForChild("present"));

local getType = function(area)
	local data = toyTypes[area];
	if(not data) then
		data = toyTypes[1];
	end
	return data;
end

local round = function(health)
	return(math.floor((health/100) + 0.5) * 100);
end

local getRange = function(area)
	local data = ranges[area];
	if(not data) then
		data = ranges[1];
	end
	local health = round( math.random(unpack(data.health)));
	local split = math.random(unpack(data.split or {10,10}));
	local reward = math.random(unpack(data.give(health)));
	return health,reward,split;
end

local setHealth = function(present,health)
	local values = present:WaitForChild("Values");
	local a,b = values:WaitForChild("Health"),values:WaitForChild("MaxHealth");
	for _,obj in pairs({a,b}) do
		obj.Value = health;
	end
end

local spawns = {};
local rgd = {};
shared.rgd = rgd;
shared.present_index = {};
shared.randomRewards = {};

local get = function(region)
	return game.ReplicatedStorage.spawns:WaitForChild(region):GetChildren();
end

local ts = function(vector)
	return math.floor(vector.X) .. "." .. math.floor(vector.Y) .. "." .. math.floor(vector.Z);
end

local from = function(region)
	local presents = game:GetService("ServerStorage"):WaitForChild("Presents");
	local tbl = {
		["area0"] = "Present",
		["area1"] = "Present",
		["area2"] = "WinterPresent2",
		["area3"] = "CandyPresent1",
		["area4"] = "CavePresent1",
		["area5"] = "MagmaticPresent1",
		["area6"] = "BeachPresent2",
		["area7"] = ({"IcePresent1","IcePresent2"})[math.random(1,2)];
	}
	return presents[tbl[region]];
end

local newPresent = function(present)
	task.spawn(presentsHandler.load,present:WaitForChild("Health"));
end

local id = 0;
local spawnPresent = function(region,key)
	id += 1;
	local themes = colors[tonumber(region:sub(5,100))];
	local present = from(region):Clone();
	local health,reward,split = getRange(key);
	pcall(function()
		local theme = themes[math.random(1,#themes)];
		present.lid.LidColor.Color = theme.LidColor;
		present.BaseColor.Color = theme.BaseColor;
		for k,v in pairs(theme) do
			if(k ~= "LidColor" and k ~= "BaseColor") then
				for _,child in pairs(present:GetChildren()) do
					if(child.Name == k) then
						if(child:IsA("Model")) then
							if(child.PrimaryPart) then
								child.PrimaryPart.Color = v;
							else
								for _,sub in pairs(child:GetChildren()) do
									if(sub:IsA("BasePart")) then
										sub.Color = v;
									end
								end
							end
						elseif(child:IsA("BasePart")) then
							child.Color = v;
						end
					end
				end
			end
		end
	end)
	present.Parent = workspace.gifts;
	present:SetAttribute("Region",region);
	present:SetAttribute("ID",tostring(id));
	present:SetAttribute("Reward",split); --> amnt of toys split
	-- eq: give / amount
	present:SetAttribute("Amount",split);
	present:SetAttribute("Give",reward); --> what the f
	present:SetAttribute("ToyType",getType(key));
	present.Name = "Present" .. tostring(id)
	setHealth(present,health);
	newPresent(present);

	if(not spawns[region]) then
		spawns[region] = get(region);
	end
	if(#spawns[region] == 0) then
		spawns[region] = get(region);
	end

	local key = math.random(1,#spawns[region]);
	local object = spawns[region][key];
	local main = ts(object.Position);
	if(shared.present_index[main] ~= nil) then
		local existing = shared.present_index[main];
		if(existing:GetFullName() ~= existing.Name) then
			local found = true;
			local acceptable = {};
			for i = 1,#spawns[region] do
				local key = i;
				local newObject = spawns[region][key];
				local objKey = ts(newObject.Position);
				local present = shared.present_index[ts(spawns[region][key].Position)];
				if((not(present and present:GetFullName() ~= present.Name))) then
					table.insert(acceptable,i);
				end
			end
			if(#acceptable > 0) then
				key = acceptable[math.random(1,#acceptable)];
			else
				warn("[failed at",region,"]");
				return;
			end
		end
	end

	spawns[region][key].Orientation = Vector3.new(0,math.random(-180,360), 0);

	local position = spawns[region][key].CFrame;
	shared.present_index[ts(spawns[region][key].Position)] = present;
	table.remove(spawns[region],key);
	present:SetPrimaryPartCFrame(position);
end

local i = -1;
for _ = 1,(7+1) do
	i += 1;
	local count = 0;
	local regionName = "area"..tostring(i);
	local defaultSpawn = math.floor(game:GetService("ReplicatedStorage"):WaitForChild("spawns",math.huge):WaitForChild(regionName):GetAttribute("Amount") * 3/4);

	rgd[regionName] = Instance.new("BindableEvent");
	for i = 1,defaultSpawn do
		count += 1;
		spawnPresent(regionName,tonumber(regionName:sub(5,#regionName)));
	end
	rgd[regionName].Event:Connect(function()
		count += -1;
		if(count < math.floor(defaultSpawn * (3/4))) then
			spawns[regionName] = get(regionName);
			for i = 1,8 do
				spawnPresent(regionName,tonumber(regionName:sub(5,#regionName)));
				count += 1;
			end
		end
	end)
end

local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
network:createRemoteEvent("randomReward",function(player,gift)
	if(shared.randomRewards[player]) then
		if(shared.randomRewards[player][gift]) then
			local idx = shared.randomRewards[player][gift][1];
			if(idx) then
				local limit = shared.addNoChange(player.leaderstats.Toys,tostring(shared.toy_mult(idx.amount,player)));
				local v1 = tonumber(player.leaderstats.Toys.Real.Value);
				shared.set(player.leaderstats.Toys,shared.clamp(limit,0,player:GetAttribute("backpackSize")));
				local v2 = tonumber(player.leaderstats.Toys.Real.Value);
				if(v1 ~= v2) then
					network:fireClient("onStatChange",player,v2-v1,"Toys","Presents");
				end
				--	shared.add(player.leaderstats.Toys,shared.toy_mult(idx.amount,player))
				table.remove(shared.randomRewards[player][gift],1);
			end
		end
	end
end)