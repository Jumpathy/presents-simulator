local zoneModule = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("zone"));
local parent = workspace:WaitForChild("areas"):WaitForChild("zones");
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local regions = {"Area0","Area1","Area2","Area3","Area4","Area5","Area6","Area7"};

local handler = Instance.new("BindableEvent");
local last = {};

for i = 1,#regions do
	local zone = zoneModule.new(parent:WaitForChild(regions[i]));
	zone.playerEntered:Connect(function(player)
		handler:Fire(regions[i],player,true);
	end)
	zone.playerExited:Connect(function(player)
		handler:Fire(regions[i],player,false);
	end)
end

handler.Event:Connect(function(region,player,inRegion)
	local key = tick();
	last[player] = key;
	if(not player:GetAttribute("loaded")) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(player:GetAttribute("loaded"));
	end
	if(last[player] == key) then
		local bypass = (region == "Area1");
		if(not(player:GetAttribute(region) or bypass)) then
			pcall(player.Character.BreakJoints,player.Character);
		end
	end
end)

network:createRemoteEvent("enteredRegion");