local manager = require(script.Parent.Parent.Parent:WaitForChild("data"));
local starCreators = 4199740;
local ds = game:GetService("DataStoreService"):GetDataStore("youtubers_internal");
local util = require(script.Parent.Parent:WaitForChild("util"));

local on = function(player)
	player:SetAttribute("Youtuber",true);
	--shared.new_content_creator(player);
	ds:SetAsync(player.UserId,true);
	util:giveFreecam(player);
	game:GetService("ServerStorage"):WaitForChild("Panels"):WaitForChild("Youtuber"):Clone().Parent = player.PlayerGui;
end

manager.profileLoaded:Connect(function(profile,player)
	player:SetAttribute("Youtuber",false);
	if(player:IsInGroup(starCreators)) then
		on(player);
	else
		local success,response = pcall(function()
			return ds:GetAsync(player.UserId)
		end)
		if(response and success) then
			if(response == true) then
				on(player);
			end
		end
	end
	player:GetAttributeChangedSignal("Youtuber"):Connect(function()
		if(player:GetAttribute("Youtuber") == true) then
			on(player);
		else
			ds:SetAsync(player.UserId,false);
		end
	end)
end)

task.wait()

local rbxProxy = shared.proxy_client:get();
