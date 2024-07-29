local script = script.Parent;
local data = require(script.Parent.Parent.Parent:WaitForChild("data"));
local shop = workspace:WaitForChild("stores"):WaitForChild("raygun"):WaitForChild("models");
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local profiles = {};
local rayguns = {};
local conf = require(game:GetService("ReplicatedStorage"):WaitForChild("config"));
local up = conf.rebirth.multiplierPerObject;

local wrap = function(profile,player)
	local event = {};
	
	function event.link(character)
		local tbl = {};
		tbl.Connect = function(self,callback)
			coroutine.wrap(callback)(profile.selected.raygun);
			local connection,lastChange = nil,nil;
			connection = player.AttributeChanged:Connect(function(name)
				if(name == "SelectedRaygun") then
					local key = tick();
					lastChange = key;
					if(character == player.Character) then
						game:GetService("RunService").Heartbeat:Wait();
						if(lastChange == key) then
							coroutine.wrap(callback)(profile.selected.raygun);
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

data.profileLoaded:Connect(function(profile,player)
	local owned = Instance.new("Folder");
	owned.Parent = player;
	owned.Name = "OwnedTools";
	
	profiles[player] = profile;
	player:SetAttribute("SelectedRaygun",profile.selected.raygun or "Raygun1");
	rayguns[player] = wrap(profile,player);
	player.AttributeChanged:Connect(function(name)
		if(name == "SelectedRaygun") then
			profile.selected.raygun = player:GetAttribute("SelectedRaygun") or "Raygun1";
		end
	end)
	
	for _,tool in pairs(profile.owned_rayguns) do
		owned:SetAttribute(tool,true);
	end
end)

data.characterAdded.loaded:Connect(function(character,player)
	if(not profiles[player]) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(profiles[player] or player:GetFullName() == player.Name);
	end
	if(player.Character == character) then
		local last;
		rayguns[player].link(character):Connect(function(selected)
			if(last ~= nil) then
				last:Destroy();
				last = nil;
			end
			last = game.ServerStorage:WaitForChild("Tools"):WaitForChild("Rayguns"):WaitForChild(selected):Clone();
			last.Parent = player.Backpack;
		end)
	end
end)

network:createRemoteFunction("equipTool",function(player,gun)
	if(gun.Parent == workspace.stores.raygun.models) then
		if(type(gun) ~= "table") then
			if(profiles[player]) then
				if(table.find(profiles[player].owned_rayguns,gun:GetAttribute("ActualObject"))) then
					player:SetAttribute("SelectedRaygun",gun:GetAttribute("ActualObject"));
				end
			end
		else
			player:Kick("no");
		end
	end
end)

network:createRemoteFunction("buyRaygun",function(player,gun)
	if(gun.Parent == workspace.stores.raygun.models) then
		if(type(gun) ~= "table") then
			local linked = gun:GetAttribute("ActualObject");
			local price = gun:GetAttribute("Price");
			if(linked and price) then
				local rebirths = tonumber(player.leaderstats.Rebirths.Real.Value);
				local cost = tonumber(price);
				if(rebirths >= 1) then
					cost = (tonumber(rebirths)*conf.rebirth.multiplierPerObject)*tonumber(cost);
				end
				if(shared.enough(player.leaderstats.Coins,cost)) then
					if(profiles[player]) then
						if(not table.find(profiles[player].owned_rayguns,linked)) then
							table.insert(profiles[player].owned_rayguns,linked);
							player.OwnedTools:SetAttribute(linked,true);
							shared.add(player.leaderstats.Coins,(-cost));
							return true;
						else
							return false,"Already owns.";
						end
					else
						return false,"No profile loaded.";
					end
				else
					return false,"Not enough coins.";
				end
			else
				return false,"Failed to load both data points.";
			end
		else
			player:Kick("lol no");
		end
	end
end)

local add = function(model)
	if(model:IsA("Folder")) then
		local actual = game:GetService("ServerStorage"):WaitForChild("Tools"):WaitForChild("Rayguns"):WaitForChild(model:GetAttribute("ActualObject"));
		actual:SetAttribute("Damage",model:GetAttribute("Damage"));
		actual:SetAttribute("Delay",model:GetAttribute("Reload"));
	end
end

shop.ChildAdded:Connect(add);
for _,child in pairs(shop:GetChildren()) do
	coroutine.wrap(add)(child);
end