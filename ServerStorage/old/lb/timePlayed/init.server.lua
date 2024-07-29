local timeLeaderboard = workspace:WaitForChild("areas"):WaitForChild("area1"):WaitForChild("leaderboards"):WaitForChild("TPLeaderboard"):WaitForChild("Main"):WaitForChild("UI");
local data = require(script.Parent.Parent:WaitForChild("data"));
local leaderboard = require(script.Parent:WaitForChild("func")).new("time");
local stat = "TimePlayed";
local tracking = {};
local loadAmount = 10;
local last;

local format = function(Seconds)
	local function divmod(x, y)
		return x / y, x % y; 
	end;

	local function Format(Int)
		return string.format("%2i", Int)
	end

	local Days, Hours, Minutes;
	Minutes, Seconds = divmod(Seconds, 60);
	Hours, Minutes = divmod(Minutes, 60);
	Days, Hours = divmod(Hours, 24);

	local addon = function(n)
		return(n < 1 and "s" or n < 2 and "" or "s")
	end

	return Format(Days).." day" .. addon(Days) .. "".. Format(Hours).." hour" .. addon(Hours) .. Format(Minutes).." minute"..addon(Minutes);
end

print(format(55),format(86000))


local createPlace = function(place,userId,value,a,b)
	local template = script:WaitForChild("Place"):Clone();
	template.LayoutOrder = place;
	template.Parent = timeLeaderboard:WaitForChild("Scroller")
	require(template:WaitForChild("link"))(place,tonumber(userId),format(value),a,b)
	template.Parent.CanvasSize = UDim2.new(0,0,0,template.Parent.UIListLayout.AbsoluteContentSize.Y);
end

local clear = function()
	for k,v in pairs(timeLeaderboard:WaitForChild("Scroller"):GetChildren()) do
		if(v:IsA("Frame")) then
			v:Destroy();
		end
	end
end

data.profileLoaded:Connect(function(_,player)
	local value = leaderboard:createValue(player,"time");
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(player:GetAttribute(stat) ~= nil or player:GetFullName() == player.Name);
	value:Change(tonumber(player:GetAttribute(stat)));
	player.AttributeChanged:Connect(function(name)
		if(name == stat) then
			value:Change(tonumber(player:GetAttribute(stat)));
		end
	end)
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