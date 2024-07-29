local leaderboard = {};
local value = require(script:WaitForChild("value"));
local services,util = {
	memory = require(script:WaitForChild("services"):WaitForChild("memoryStore")),
	--messaging = require(script:WaitForChild("services"):WaitForChild("messagingService"))
},{
	wait = require(script:WaitForChild("wait")),
	base64 = require(script:WaitForChild("services"):WaitForChild("memoryStore"):WaitForChild("base64"))
}

local handle = function(data,api)
	local ret = {};
	for k,pair in pairs(data) do
		if(#pair.key:split("_") == 2) then
			pair.key = util.base64.decode(pair.key:split("_")[2]);
		end
		table.insert(ret,{
			key = pair.key,
			value = pair.value.value;
		})
	end
	return ret;
end

function leaderboard.new(name)
	local api,internalApi,memoryStore = {},{},services.memory.new(name);
	local lastChange = {};

	function api:createValue(name,...)
		local psuedo = value.new(...);
		psuedo.Changed:Connect(function(value)
			local key = ((typeof(name) == "Instance" and name:IsA("Player") and name.UserId) or name);
			lastChange[key] = value;
		end)
		return psuedo;
	end

	function api:getPlaces(limit)
		return handle(
			memoryStore:getHighest(limit),
			internalApi
		)
	end

	function api.loop(len,limit)
		local psuedo = {};
		function psuedo:Connect(callback)
			coroutine.wrap(function()
				while util.wait(len) do
					coroutine.wrap(callback)(api:getPlaces(limit));
				end
			end)();
		end
		return psuedo;
	end

	local getThumbnail = function(userId)
		return game:GetService("Players"):GetUserThumbnailAsync(
			userId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
	end

	local getUsername = function(userId)
		local success,name = pcall(function()
			return game:GetService("Players"):GetNameFromUserIdAsync(userId);
		end)
		return(name or "[failed]");
	end

	function api.getUserData(leaderboard)
		assert(type(leaderboard) == "table","Expected type 'table'");
		local userIds,data,values = {},{},{};
		for i = 1,#leaderboard do
			if(leaderboard[i].value ~= "") then
				table.insert(userIds,tonumber(leaderboard[i].key));
				values[tonumber(leaderboard[i].key)] = leaderboard[i].value;
			end
		end
		local success,names = pcall(function()
			return game:GetService("UserService"):GetUserInfosByUserIdsAsync(userIds);
		end)
		if(names) then
			for i = 1,#names do
				table.insert(data,{
					displayName = names[i].DisplayName,
					userId = names[i].Id,
					username = names[i].Username,
					thumbnail = getThumbnail(names[i].Id),
					value = values[names[i].Id]
				});
			end
			for _,userId in pairs(userIds) do
				local found = false;
				for k,v in pairs(data) do
					if(v.userId == userId) then
						found = true;
						break;
					end
				end
				if(not found) then
					local name = getUsername(userId);
					table.insert(data,{
						displayName = name,
						userId = userId,
						username = name,
						thumbnail = getThumbnail(userId),
						value = values[userId]
					});
				end
			end
		end
		return data;
	end

	coroutine.wrap(function()
		while util.wait(1) do
			for key,value in pairs(lastChange) do
				coroutine.wrap(function()
					memoryStore:update(key,value);
				end)();
			end
		end
	end)();

	return api;
end

return leaderboard;