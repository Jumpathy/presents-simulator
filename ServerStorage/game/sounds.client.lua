local zoneModule = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("zone"));
local parent = workspace:WaitForChild("areas"):WaitForChild("zones");
local regions = {"Area0","Area1","Area2","Area3","Area4","Area5","Area6"};
local localPlayer = game:GetService("Players").LocalPlayer;
local handler = Instance.new("BindableEvent");
local last,has = nil,false;
local sound = require(game:GetService("ReplicatedStorage"):WaitForChild("sounds"));
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local pointers = {};

local signal;
signal = localPlayer.AttributeChanged:Connect(function()
	if(localPlayer:GetAttribute("MusicEnabled") ~= nil) then
		signal:Disconnect();
		has = true;
	end
end)

repeat
	game:GetService("RunService").Heartbeat:Wait();
until(has);

local ambient = Instance.new("Sound",workspace);
ambient.Volume = 0.75;
ambient.Name = "MainMusic";

local music = localPlayer:GetAttribute("MusicEnabled");

shared.ambient_volume = function(new)
	new = new or 0.75;
	if(music) then
		ambient.Volume = (new);
	else
		ambient.Volume = 0;
	end
end

local signal;
signal = localPlayer.AttributeChanged:Connect(function()
	if(localPlayer:GetAttribute("MusicEnabled") ~= nil) then
		music = localPlayer:GetAttribute("MusicEnabled");
		if(not music) then
			ambient.Volume = 0;
		elseif(ambient.Volume == 0) then
			ambient.Volume = 0.75;
		end
	end
end)


local sounds,stored,selected = {
	["Area0"] = { -- VIP
		"rbxassetid://7518495966", -- Our custom song
		"rbxassetid://1845270162" -- VIP Guest
	},
	["Area1"] = { -- Beginning area
		"rbxassetid://1838680686", -- Daily
		"rbxassetid://1843206285", -- Autumn
		"rbxassetid://1836921721", -- Autumn Colours
		"rbxassetid://1836880186", -- In The Summer
		"rbxassetid://1841668957", -- Summer Summer,
		"rbxassetid://2626918502" -- Christmas
	},
	["Area2"] = { -- Snow area
		"rbxassetid://1837101327", -- Winter
		"rbxassetid://1840740877", -- A Christmas Fantasty (a)
		"rbxassetid://1845497774", -- Into The Forest
		"rbxassetid://1841545531", -- Sugar Plums
		"rbxassetid://1836281786" -- Nutcracker - Sugar Plum
	},
	["Area3"] = { -- Candyland
		"rbxassetid://7009455002", -- Eye Candy
		"rbxassetid://1836959476", -- Candy Pop
		"rbxassetid://1835712964", -- Candy Floss
		"rbxassetid://1836718378", -- Candy Crazy
	},
	["Area4"] = { -- Cave area
		"rbxassetid://1842909842", -- Cave of Wonder
		"rbxassetid://1846889946", -- Mystery cave
		"rbxassetid://1840607730", -- Crystal Caves
		"rbxassetid://1841386230", -- Crystallize
	},
	["Area5"] = { -- Volcano area
		"rbxassetid://1840035597", -- Volcano (b)
		"rbxassetid://3858846447", -- Chaotic Volcano OST
		"rbxassetid://1847008241", -- Volcanic Lava (a)
		"rbxassetid://1847844204" -- Lava
	},
	["Area6"] = { -- Beach
		"rbxassetid://1848227887", -- Tropical
		"rbxassetid://1845914236", -- Vacation(a)
		"rbxassetid://1836002503", -- Permanent Vacation
		"rbxassetid://144894560", -- Tropical (b)
		"rbxassetid://1845891180" -- On The Beach
	}
},{},"";

for i = 1,#regions do
	pointers[regions[i]] = math.random(1,#sounds[regions[i]]);
end

for i = 1,#regions do
	local zone = zoneModule.new(parent:WaitForChild(regions[i],math.huge));
	zone.localPlayerEntered:Connect(function(player)
		handler:Fire(regions[i],true);
	end)
	zone.localPlayerExited:Connect(function(player)
		handler:Fire(regions[i],false);
	end)
end

handler.Event:Connect(function(region,inside)
	if(selected) then
		stored[selected] = ambient.TimePosition;
	end
	selected = region;
	local key = tick();
	last = key;
	
	if(not localPlayer:GetAttribute("loaded")) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(localPlayer:GetAttribute("loaded"));
	end
	if(last == key and inside) then
		ambient.SoundId = (sounds[region][pointers[region]] or "");
		ambient.TimePosition = (stored[region] or 0);
		ambient:Play();
		ambient.Ended:Connect(function()
			if(last == key and inside) then
				stored[region] = 0;
				local array = sounds[region];
				local aKey = math.random(1,#array);
				pointers[region] = aKey;
				ambient.SoundId = array[aKey];
				handler:Fire(region,true);
			end
		end)
	end
end)

handler:Fire("Area1",true);
network:bindRemoteEvent("devProductPurchaseInteraction",function()
	sound.play(sound.library.purchaseDevProduct);
end)