local replicatedStorage = game:GetService("ReplicatedStorage");
local network = require(replicatedStorage:WaitForChild("shared"):WaitForChild("network"));
local vipServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0;

network:createRemoteFunction("contentCreatorPanel",function(player,query,...)
	if(player:GetAttribute("Youtuber")) then
		local admin = player:GetAttribute("AdminPanel") == true;
		local args = {...};
		if(query == "modifyGravity") then
			local setTo = args[1];
			if(type(setTo) == "number") then
				if(vipServer or admin) then
					workspace.Gravity = setTo;
					return true;
				else
					return false,"You can only use this in VIP servers!";
				end
			else
				return false,"Invalid type";
			end
		end
	end
end)