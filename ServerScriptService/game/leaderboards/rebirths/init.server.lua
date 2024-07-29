local coinLeaderboard = workspace:WaitForChild("areas"):WaitForChild("area1"):WaitForChild("leaderboards"):WaitForChild("RBLeaderboard"):WaitForChild("Main"):WaitForChild("UI");
local data = require(script.Parent.Parent:WaitForChild("data"));
local stat = "Rebirths";
local tracking = {};
local index = require(script.Parent.Parent:WaitForChild("config")).DataVersion;
local datastore = game:GetService("DataStoreService"):GetOrderedDataStore("rebirths_leaderboarld"..index.Boards);
local loadAmount = 10;
local ls = require(script.Parent.Parent:WaitForChild("stats"));

local update = function(player,value)
	pcall(datastore.SetAsync,datastore,player.UserId,value);
end

local format = function(number)
	return data.format.FormatCompact(number);
end

local clear = function()
	for _,child in pairs(coinLeaderboard:WaitForChild("Scroller"):GetChildren()) do
		if(child:IsA("Frame")) then
			child:Destroy();
		end
	end
end

shared.leaderboard_1 = {}

local loadBoard = function()
	clear();
	local success,value = pcall(function()
		return datastore:GetSortedAsync(false,loadAmount,1);
	end)
	if(success and value) then
		local users = {};
		local userDict = {};
		shared.leaderboard_1 = {}
		for key,data in pairs(value:GetCurrentPage() or {}) do
			table.insert(shared.leaderboard_1,tonumber(data.key));
			table.insert(users,tonumber(data.key));
			userDict[tonumber(data.key)] = true;
		end
		local success,info = pcall(function()
			return game:GetService("UserService"):GetUserInfosByUserIdsAsync(users);
		end)
		info = info or {};
		if(not success) then
			warn(info,"leaderboard");
			info = {};
		end
		for key,value in pairs(userDict) do
			if(not info[key]) then
				local success,user = pcall(function()
					return game:GetService("Players"):GetNameFromUserIdAsync(key);
				end)
				info[key] = {
					["Id"] = key,
					["DisplayName"] = user or "[FAILED]",
					["Username"] = user or "[FAILED]"
				};
			end
		end
		for key,data in pairs(value:GetCurrentPage() or {}) do
			coroutine.wrap(function()
				local template = script:WaitForChild("Place"):Clone();
				template.LayoutOrder = key;
				template.Parent = coinLeaderboard:WaitForChild("Scroller")
				require(template:WaitForChild("link"))(key,tonumber(data.key),format(tonumber(data.value)) .. " rebirths",info[tonumber(data.key)])
				template.Parent.CanvasSize = UDim2.new(0,0,0,template.Parent.UIListLayout.AbsoluteContentSize.Y);
			end)();
		end
	else
		warn(value);
	end
end

local handle = function(value)
	return tonumber(value.Value);
end

data.profileLoaded:Connect(function(profile,player)
	local leaderstat = player:WaitForChild("leaderstats"):WaitForChild(stat);
	tracking[player] = handle(leaderstat);
	leaderstat:GetPropertyChangedSignal("Value"):Connect(function()
		tracking[player] = handle(leaderstat:WaitForChild("Real"));
	end)
	update(player,tracking[player]);
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	if(tracking[player]) then update(player,tracking[player]) end;
end)

while true do
	loadBoard()
	wait(30);
	for player,stat in pairs(tracking) do
		if(player:GetFullName() ~= player.Name) then
			update(player,stat);
		else
			tracking[player] = nil;
		end
	end
end