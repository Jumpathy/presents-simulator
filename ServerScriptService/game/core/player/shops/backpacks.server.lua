local script = script.Parent;
local data = require(script.Parent.Parent.Parent:WaitForChild("data"));
local config = require(script.Parent.Parent.Parent:WaitForChild("config"));
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local profiles = {};
local backpacks = {};
local fullyLoaded = {};
local container = game:GetService("ServerStorage"):WaitForChild("Backpacks");
local conf = require(game:GetService("ReplicatedStorage"):WaitForChild("config"));
local up = conf.rebirth.multiplierPerObject;
local storageUp = conf.rebirth.backpackUpgrade;

local wrap = function(profile,player)
	local event = {};

	function event.link(character)
		local tbl = {};
		tbl.Connect = function(self,callback)
			coroutine.wrap(callback)(profile.selected.backpack);
			local connection,lastChange = nil,nil;
			connection = player.AttributeChanged:Connect(function(name)
				if(name == "SelectedBackpack") then
					local key = tick();
					lastChange = key;
					if(character == player.Character) then
						game:GetService("RunService").Heartbeat:Wait();
						if(lastChange == key) then
							coroutine.wrap(callback)(profile.selected.backpack);
						end
					else
						connection:Disconnect();
					end
				end
			end)
		end
		return tbl;
	end

	return event;
end

local getStorage = function(name)
	for _,bp in pairs(config.Backpacks) do
		if(bp.Model == name) then
			return tonumber(bp.Storage);
		end
	end
end

data.profileLoaded:Connect(function(profile,player)
	local owned = Instance.new("Folder");
	local s = tostring;
	owned.Parent = player;
	owned.Name = "OwnedBackpacks";
	profiles[player] = profile;
	player.AttributeChanged:Connect(function(name)
		if(name == "SelectedBackpack") then
			profile.selected.backpack = player:GetAttribute("SelectedBackpack") or "Backpack1";
		end
	end)
	if(not table.find(profile.owned_backpacks,"Backpack1")) then
		table.insert(profile.owned_backpacks,"Backpack1");
	end
	for _,backpack in pairs(profile.owned_backpacks) do
		owned:SetAttribute(backpack,true);
	end
	if(profile.selected.backpack == "Backpack") then
		profile.selected.backpack = "Backpack1";
	end
	local rb = tonumber(player:WaitForChild("leaderstats"):WaitForChild("Rebirths"):WaitForChild("Real").Value);
	local multiplier = (rb >= 1 and (rb * storageUp) or 1);
	player:SetAttribute("SelectedBackpack",profile.selected.backpack);
	player:SetAttribute("backpackSize",s(
		getStorage(profile.selected.backpack) * (multiplier)
	));
end)

local onChanged = function(stat,callback,object)
	coroutine.wrap(callback)(stat.Value);
	local conn;
	conn = stat:GetPropertyChangedSignal("Value"):Connect(function()
		if(object:GetFullName() ~= object.Name) then
			callback(stat.Value);
		else
			conn:Disconnect();
		end
	end)
end

local weld = function(backpack,character)
	local player = game:GetService("Players"):GetPlayerFromCharacter(character);
	local primary = backpack.PrimaryPart;
	local callback,connection = require(backpack:WaitForChild("Function")),nil;

	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(fullyLoaded[character]);
	
	local torso = character:WaitForChild("UpperTorso");
	backpack.Parent = character;
	
	local g = function(model,attribute)
		return model:GetAttribute(attribute);
	end
	
	local x,y,z = g(backpack,"X"),g(backpack,"Y"),g(backpack,"Z");
	
	local angle = CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
	primary.CFrame = torso.CFrame * CFrame.new(Vector3.new(0,0,0.85))*angle;

	local constraint = Instance.new("WeldConstraint")
	constraint.Parent = primary;
	constraint.Part0 = primary;
	constraint.Part1 = torso;

	local handle = function(int)
		if(tonumber(int) > (1000*100)) then
			return data.format.FormatCompact(int);
		else
			return data.format.FormatStandard(int);
		end
	end

	local link = function()
		if(character:GetFullName() ~= character.Name) then
			callback(
				handle(player.leaderstats.Toys.Real.Value) .. "/" .. handle(player:GetAttribute("backpackSize")) 
			)
		end
	end

	coroutine.wrap(function()
		if(player and player:GetAttribute("loaded") == false) then
			repeat
				game:GetService("RunService").Heartbeat:Wait();
			until(player:GetAttribute("loaded") or player:GetFullName() == player.Name);
		end
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(fullyLoaded[character]);
		if(player:GetFullName() ~= player.Name) then
			if(character:GetFullName() ~= character.Name) then
				if(player:GetAttribute("loaded")) then
					onChanged(player.leaderstats.Toys,link,backpack);
					connection = player.AttributeChanged:Connect(function(attr)
						if(attr == ("backpackSize") and character:GetFullName() ~= character.Name and (backpack:GetFullName() ~= backpack.Name)) then
							link();
						elseif(character:GetFullName() == character.Name or (backpack:GetFullName() == backpack.Name)) then
							connection:Disconnect();
						end
					end)
				end
			end
		end
	end)();
end

data.characterAdded.loaded:Connect(function(character,player)
	if(not profiles[player]) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(profiles[player] or player:GetFullName() == player.Name);
	end
	backpacks[player] = backpacks[player] or wrap(profiles[player],player);
	if(player.Character == character) then
		local last;
		backpacks[player].link(character):Connect(function(selected)
			if(last ~= nil) then
				last:Destroy();
				last = nil;
			end
			last = game.ServerStorage:WaitForChild("Character"):WaitForChild(selected):Clone();
			last.Parent = character;
			fullyLoaded[character] = true;
			weld(last,character);
		end)
	end
end)

local conf = require(game:GetService("ReplicatedStorage"):WaitForChild("config"));

network:createRemoteFunction("equipBackpack",function(player,object)
	if(object.Parent == workspace.stores.backpack.models) then
		if(type(object) ~= "table") then
			if(profiles[player]) then
				if(table.find(profiles[player].owned_backpacks,object:GetAttribute("ActualObject"))) then
					player:SetAttribute("SelectedBackpack",object:GetAttribute("ActualObject"));
					local storage = tonumber(object:GetAttribute("Storage"));
					local rc = tonumber(player.leaderstats.Rebirths.Real.Value);
					if(rc >= 1) then
						storage = storage * (rc * conf.rebirth.backpackUpgrade);
					end
					player:SetAttribute("backpackSize",tostring(storage));
				end
			end
		else
			player:Kick("no");
		end
	end
end)

data.marketplace.gamepassOwned(24838183):Connect(function(player)
	player:SetAttribute("OwnsInfiniteBackpack",true);
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(profiles[player] or player:GetFullName() == player.Name);
	if(profiles[player]) then
		local linked = "Backpack8";
		if(not table.find(profiles[player].owned_backpacks,linked)) then
			table.insert(profiles[player].owned_backpacks,linked);
			player.OwnedBackpacks:SetAttribute(linked,true);
			return true;
		end
	end
end)

local mps = game:GetService("MarketplaceService");

network:createRemoteFunction("buyBackpack",function(player,backpack)
	if(backpack.Parent == workspace.stores.backpack.models) then
		if(type(backpack) ~= "table") then
			local linked = backpack:GetAttribute("ActualObject");
			local price = backpack:GetAttribute("Price");
			if(backpack:GetAttribute("PassId")) then
				mps:PromptGamePassPurchase(player,backpack:GetAttribute("PassId"));
				return false,"purchase_pending";
			else
				if(linked and price) then
					local rebirths = tonumber(player.leaderstats.Rebirths.Real.Value);
					local cost = tonumber(price);
					if(rebirths >= 1) then
						cost = (tonumber(rebirths)*conf.rebirth.multiplierPerObject)*tonumber(cost);
					end
					if(shared.enough(player.leaderstats.Coins,cost)) then
						if(profiles[player]) then
							if(not table.find(profiles[player].owned_backpacks,linked)) then
								table.insert(profiles[player].owned_backpacks,linked);
								player.OwnedBackpacks:SetAttribute(linked,true);
								shared.add(player.leaderstats.Coins,(-cost));
								return true;
							else
								return false,"Already owns.";
							end
						else
							return false,"No profile loaded.";
						end
					else
						return false,"Not enough coins";
					end
				else
					return false,"No data found";
				end
			end
		else
			return false,"no";
		end
	else
		return false,"no lol";
	end
end)