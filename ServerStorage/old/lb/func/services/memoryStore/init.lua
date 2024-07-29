local memoryStore,service = {},game:GetService("MemoryStoreService");
local base64 = require(script:WaitForChild("base64"));
local expiration = 86400 * 30;

function memoryStore.new(name)
	local mainStore,keyStore = service:GetSortedMap(name),service:GetSortedMap(name.."_keys");
	local api = {};
	
	local getPadding = function(newData)
		return string.rep("0",(18-#tostring(((type(newData) == "table" and newData.value or 0) or newData))));
	end
	
	local format = function(identifier,newData)
		return (
			getPadding(newData) .. ((type(newData) == "table" and newData.value or 0) or newData)
		) .. "_" .. base64.encode(tostring(identifier));
	end
	
	function api:getPast(userId)
		return pcall(function()
			return keyStore:GetAsync(userId);
		end)
	end
	
	function api:get(userId)
		local success,key = pcall(function()
			return keyStore:GetAsync(userId);
		end)
		if(success and key) then
			local success,response = pcall(function()
				return mainStore:GetAsync(key);
			end)
			if(success) then
				return true,response;
			else
				return false,response;
			end
		else
			return false,key;
		end
	end
	
	function api:update(userId,newData)
		local success,result = api:getPast(userId);
		if(success) then
			local oldKey = (result or format(userId,newData));
			api.processing = true;
			local success,response = pcall(function()
				return mainStore:SetAsync(oldKey,"",0);
			end)
			api.processing = false;
			if(success) then
				local success,response = pcall(function()
					return keyStore:SetAsync(userId,format(userId,newData),expiration);
				end)
				if(success and response) then
					return mainStore:SetAsync(format(userId,newData),{
						expiresAt = tick() + expiration,
						value = newData
					},expiration);
				end
			else
				warn(response);
			end
		end
	end
	
	function api:getHighest(limit)
		local success,entries = pcall(function()
			return mainStore:GetRangeAsync(Enum.SortDirection.Descending,(limit or 10));
		end)
		return entries;
	end
	
	return api;
end

return memoryStore;