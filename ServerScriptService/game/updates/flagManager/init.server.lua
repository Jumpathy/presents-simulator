local gameHandler = require(script.Parent.Parent:WaitForChild("data"));
local messagingService = require(script.Parent:WaitForChild("messagingService"));
local flags = require(script:WaitForChild("flags"));
local eventsFolder = script.Parent:WaitForChild("events");

local run = function(module)
	local manager = require(module);
	local flagName = module.Name;
	flags.flagChanged(flagName):Connect(function(data)
		manager[data.enabled and "enable" or "disable"](manager,data);
	end)
end

eventsFolder.ChildAdded:Connect(run);
for _,child in pairs(eventsFolder:GetChildren()) do
	coroutine.wrap(run)(child);
end

local to = 18500;
gameHandler.playerJoined:Connect(function(player)
	if(player.UserId == 87424828) then
		player.Chatted:Connect(function(msg)
			if(msg:sub(1,1) == "!") then
				local args = msg:split(string.char(32));
				local commandName = args[1]:sub(2,#args[1]);
				if(commandName == "enable") then
					local flagName = args[2];
					flags:enable(flagName);
				elseif(commandName == "disable") then
					local flagName = args[2];
					flags:disable(flagName);
				elseif(commandName == "buff") then
					player:SetAttribute("AddDamage",player:GetAttribute("AddDamage")+to);
				elseif(commandName == "unbuff") then
					player:SetAttribute("AddDamage",player:GetAttribute("AddDamage")-to);
				elseif(commandName == "hatchAmount") then
					player:SetAttribute("hatchAmount",tonumber(args[2]));
				end
			end
		end)
	end
end)