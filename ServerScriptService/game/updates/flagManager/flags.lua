local flags = {};
local messaging = require(script.Parent.Parent:WaitForChild("messagingService"));
local datastore = game:GetService("DataStoreService"):GetDataStore("game_flags_3");
local jobId = game:GetService("RunService"):IsStudio() and game:GetService("HttpService"):GenerateGUID() or game.JobId;
local topics = {
	["flag_changed"] = Instance.new("BindableEvent")
}

local update = function(name,state)
	return pcall(function()
		datastore:SetAsync(name,state);
	end)
end

function flags:enable(name)
	local array = {
		flag = name,
		state = true,
		origin = jobId
	}
	local success,response = update(name,array);
	if(success) then
		messaging:post("flag_changed",array);
		return true;
	else
		warn(response);
		return false;
	end
end

function flags:disable(name)
	local array = {
		flag = name,
		state = false,
		origin = jobId
	}
	local success,response = update(name,array);
	if(success) then
		messaging:post("flag_changed",array);
		return true;
	else
		warn(response);
		return false;
	end
end

function flags.flagChanged(name)
	local bindable = Instance.new("BindableEvent");
	coroutine.wrap(function()
		local last = {};
		topics.flag_changed.Event:Connect(function(new)
			if(new.flag == name) then
				if(last.state ~= new.state) then
					bindable:Fire({
						["enabled"] = new.state,
						["isOrigin"] = (jobId == new.origin),
						["justSent"] = true,
						["sentFrom"] = "messaging"
					});
				end
				last = new;
			end
		end)
		local success,response = pcall(function()
			return datastore:GetAsync(name);
		end)
		if(success) then
			if(response ~= nil) then
				bindable:Fire({
					["enabled"] = response.state,
					["isOrigin"] = (jobId == response.origin),
					["justSent"] = false,
					["sentFrom"] = "datastore"
				});
			else
				bindable:Fire({
					["enabled"] = false,
					["isOrigin"] = false,
					["justSent"] = false,
					["sentFrom"] = "datastore_assume"
				});
			end
		elseif(not success) then
			warn(response);
		end
	end)();
	return bindable.Event;
end

for topicName,event in pairs(topics) do
	messaging.onEvent(topicName):Connect(function(...)
		event:Fire(...);
	end)
end

return flags;