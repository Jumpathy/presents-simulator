local manager = require(script.Parent.Parent.Parent:WaitForChild("data"));
local util = require(script.Parent.Parent:WaitForChild("util"));
local group = 12248057;

manager.profileLoaded:Connect(function(profile,player)
	player:SetAttribute("AdminPanel",false);
	if(player:GetRankInGroup(group) >= 200) then
		player:SetAttribute("AdminPanel",true);
		util:giveFreecam(player);
	end
end)