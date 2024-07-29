local utility = {};
local given = {};

function utility:giveFreecam(player)
	if(not given[player]) then
		script:WaitForChild("CustomFreecam"):Clone().Parent = player.PlayerGui;
		given[player] = true;
	end
end

return utility;