local badge = {};
local service = game:GetService("BadgeService");
badge.library = {
	["welcome"] = 2124878074,
	["metCreators"] = 2124878076,
	["social"] = 2124878077,
	["pets"] = 2124878078,
	["rebirther"] = 2124878080,
	["rudolph"] = 2124888148,
	["vulcan"] = 2124910983,
	["tutorial"] = 2126460359
}

function badge:award(player,name)
	coroutine.wrap(function()
		if(not service:UserHasBadgeAsync(player.UserId,badge.library[name])) then
			local success,awarded = pcall(function()
				service:AwardBadge(player.UserId,badge.library[name]);
			end)
			if(not success) then
				warn(awarded);
			end
		end
	end)();
end

return badge;