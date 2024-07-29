local handler = require(script.Parent.Parent.Parent.Parent:WaitForChild("data"));
local chatPlus = require(script.Parent:WaitForChild("chatPlus"));

local owners = {
	[111954405] = true,
	[87424828] = true
}

local status = {};

handler.profileLoaded:Connect(function(profile,player)
	local ownerTagForSky = chatPlus:newTag({
		["tagText"] = "Owner",
		["tagColor"] = Color3.fromRGB(0,0,0)
	});

	local ownerTagForJumpathy = chatPlus:newTag({
		["tagText"] = "Owner",
		["tagColor"] = Color3.fromRGB(137,68,206)
	})

	if(player.UserId == 111954405) then
		ownerTagForSky:assign(player);
		chatPlus:setNameColor(player,Color3.fromRGB(0,0,0));
	elseif(player.UserId == 87424828) then
		ownerTagForJumpathy:assign(player);
		chatPlus:setNameColor(player,Color3.fromRGB(137,68,206));
	end
end)

chatPlus:tagFromPass({
	["passId"] = 22632843,
	["tagText"] = "VIP",
	["tagColor"] = Color3.fromRGB(255,255,0);
})

local contentCreator = chatPlus:newTag({
	["tagText"] = "Content Creator",
	["tagColor"] = Color3.fromRGB(255,0,0)
})

shared.new_content_creator = function(player)
	if(not owners[player.UserId]) then
		contentCreator:assign(player);
	end
end