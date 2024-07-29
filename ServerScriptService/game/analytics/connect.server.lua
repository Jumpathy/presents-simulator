local data = require(script.Parent.Parent:WaitForChild("data"));
local api = require(script.Parent:WaitForChild("primary"));
local clientApi = api.PlayFabClient;
local serverApi = api.PlayFabServer;
local profiles = {};
local clients = {};

setup = function(dsProfile,player,retries)
	clientApi.LoginWithCustomID(player,{
		CreateAccount = true,
		CustomId = tostring(player.UserId)
	}):andThen(function(loginResult)
		local entityToken = loginResult.EntityToken.EntityToken;
		local sessionTicket = loginResult.SessionTicket;
		clientApi:UpdateUserTitleDisplayName(sessionTicket,{DisplayName = player.Name});
		clientApi:UpdateAvatarUrl(sessionTicket,{ImageUrl = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%s&width=420&height=420&format=png",player.UserId)});
		clients[player] = {
			api = clientApi,
			key = sessionTicket,
			server = serverApi,
			identifier = loginResult.PlayFabId
		}
	end):catch(function(err)
		if(retries <= 10) then
			warn(err);
			setup(dsProfile,player,retries + 1);
		end
	end)
end

local loginPlayer = function(profile,player)
	profiles[player] = profile;
	setup(profile,player,0);
end

shared.get_client = function(player)
	if(clients[player]) then
		return clients[player];
	else
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(clients[player]);
		return clients[player];
	end
end

data.profileLoaded:Connect(loginPlayer);