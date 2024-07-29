local coinLeaderboard = workspace:WaitForChild("areas"):WaitForChild("area1"):WaitForChild("leaderboards"):WaitForChild("CLeaderboard"):WaitForChild("Main"):WaitForChild("UI");
local data = require(script.Parent.Parent:WaitForChild("data"));
local leaderboard = require(script.Parent:WaitForChild("func")).new("coins");
local stat = " Coins";
local tracking = {};
local loadAmount = 10;
local last;

local format = function(number)
	return data.format.FormatStandard(number);
end

local createPlace = function(place,userId,value,a,b)
	local template = script:WaitForChild("Place"):Clone();
	template.LayoutOrder = place;
	template.Parent = coinLeaderboard:WaitForChild("Scroller")
	require(template:WaitForChild("link"))(place,tonumber(userId),format(value) .. stat,a,b)
	template.Parent.CanvasSize = UDim2.new(0,0,0,template.Parent.UIListLayout.AbsoluteContentSize.Y);
end

local clear = function()
	for k,v in pairs(coinLeaderboard:WaitForChild("Scroller"):GetChildren()) do
		if(v:IsA("Frame")) then
			v:Destroy();
		end
	end
end

data.profileLoaded:Connect(function(_,player)
	leaderboard:createValue(player,player:WaitForChild("leaderstats"):WaitForChild("Coins"));
end)

leaderboard.loop(1,10):Connect(function(places)
	local key = tick();
	last = key;
	local p = leaderboard.getUserData(places);
	if(last == key and (#p >= 1)) then
		clear();
		for key,place in pairs(p) do
			coroutine.wrap(createPlace)(
				key,
				place.userId,
				place.value,
				place.thumbnail,
				place.displayName
			)
		end
	end
end)