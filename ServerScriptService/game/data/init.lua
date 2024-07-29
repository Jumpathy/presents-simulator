local profileTemplate = {
	leaderstats = {
		{"Coins",0},
		{"Toys",0},
		{"Rebirths",0}
	},
	areas = {
		{"Area2",false},
		{"Area3",false},
		{"Area4",false},
		{"Area5",false},
		{"Area6",false},
		{"Area7",false}
	},
	backpack = {
		amount = "0",
		limit = "50"
	},
	player_pets = {
		equipped = {},
		owned = {}
	},
	owned_rayguns = {"Raygun"},
	owned_backpacks = {"Backpack"},
	gamepasses = {},
	logins = 0,
	timePlayed = 0,
	dailyLogin = 0,
	selected = {
		raygun = "Raygun",
		backpack = "Backpack1"
	},
	boosts = {
		["2xD"] = 0,
		["2xT"] = 0
	},
	uiData = {

	},
	petLimit = 100,
	equipLimit = 6,
	friends = {
		joined = {},
		count = 0
	},
	redeemed = {},
	givenRudolph = false,
	colors = {},
	tutorial = {
		first = false
	}
};

local index = require(script.Parent:WaitForChild("config")).DataVersion;

local keys = {
	["studio"] = "plr_data_studio"..index.Studio,
	["live"] = "plr_data_live"..index.Live
}

local profileService = require(script:WaitForChild("profiles"));
local players = game:GetService("Players")
local wait = require(script:WaitForChild("customWait"));
local key = game:GetService("RunService"):IsStudio() and keys.studio or keys.live;

local data = profileService.GetProfileStore(
	key,
	profileTemplate
)

local profiles,wrappers = {},{};

local createWrapper = function()
	local fakeBindable,callbacks,args = {},{},{};

	function fakeBindable:Connect(callback)
		if(fakeBindable.loaded) then
			coroutine.wrap(callback)(unpack(args));
		else
			table.insert(callbacks,callback);
		end
	end

	function fakeBindable:SetArgs(...)
		args = {...};
	end

	function fakeBindable:Fire()
		fakeBindable.loaded = true;
		for _,callback in pairs(callbacks) do
			coroutine.wrap(callback)(unpack(args));
		end
	end

	return fakeBindable;
end

local playerProfileApi,oneSecondLoop,playerJoined,characterAdded = {callbacks = {}},{},{callbacks = {}},{loaded = {},partAdded = {}};

function playerProfileApi:LinkPlayer(callback)
	table.insert(playerProfileApi.callbacks,callback);
	for _,player in pairs(game:GetService("Players"):GetPlayers()) do
		if(profiles[player]) then
			coroutine.wrap(callback)(player);
		end
	end
end

function playerProfileApi:Connect(callback)
	playerProfileApi:LinkPlayer(function(player)
		wrappers[player]:Connect(function(profile)
			coroutine.wrap(callback)(profile.Data,player);
		end)
	end)
end

function oneSecondLoop:Connect(callback)
	coroutine.wrap(function()
		while true do
			wait(1);
			for player,profile in pairs(profiles) do
				coroutine.wrap(callback)(profile.Data,player);
			end
		end
	end)();
end

function playerJoined:LinkPlayer(callback)
	table.insert(playerProfileApi.callbacks,callback);
	for _,player in pairs(game:GetService("Players"):GetPlayers()) do
		coroutine.wrap(callback)(player);
	end
end

function playerJoined:Connect(callback)
	playerJoined:LinkPlayer(function(player)
		callback(player);
	end)
end

function characterAdded:Connect(callback)
	playerJoined:Connect(function(player)
		if(player.Character) then
			coroutine.wrap(callback)(player.Character,player);
		end
		player.CharacterAdded:Connect(callback);
	end)
end

function characterAdded.loaded:Connect(callback)
	playerJoined:Connect(function(player)
		player.CharacterAppearanceLoaded:Connect(function(char)
			callback(char,player)
		end);
	end)
end

function characterAdded.partAdded:Connect(callback)
	characterAdded:Connect(function(char)
		for _,part in pairs(char:GetDescendants()) do
			if(part:IsA("BasePart")) then
				coroutine.wrap(callback)(part);
			end
		end
		char.DescendantAdded:Connect(function(object)
			if(object:IsA("BasePart")) then
				callback(object);
			end
		end)
	end)
end

local function playerAdded(player)
	local wrapped = createWrapper();
	wrappers[player] = wrapped;
	for _,callback in pairs(playerProfileApi.callbacks) do coroutine.wrap(callback)(player); end
	for _,callback in pairs(playerJoined.callbacks) do coroutine.wrap(callback)(player); end
	local profile = data:LoadProfileAsync("plr-" .. player.UserId);
	if(profile ~= nil) then
		profile:AddUserId(player.UserId);
		profile:Reconcile();
		profile:ListenToRelease(function()
			profiles[player] = nil;
			player:Kick("[DATA LOADED ON OTHER SERVER]");
		end)
		if(player:IsDescendantOf(players) == true) then
			local dta = profile.Data;
			for i = 1,#profileTemplate.areas do
				if(not dta.areas[i]) then
					dta.areas[i] = {profileTemplate.areas[i][1],profileTemplate.areas[i][2]};
				end
			end
			profiles[player] = profile;
			profile.Data.logins += 1;
			wrapped:SetArgs(profile);
			wrapped:Fire();
		else
			profile:Release();
		end
	else
		player:Kick("[FAILED TO LOAD DATA]");
	end
end

for _,player in ipairs(players:GetPlayers()) do
	coroutine.wrap(playerAdded)(player)
end

players.PlayerAdded:Connect(playerAdded);
players.PlayerRemoving:Connect(function(player)
	local profile = profiles[player];
	if(profile ~= nil) then
		profile:Release();
	end
end)

local api = {};

api.roll = require(script:WaitForChild("roll"));
api.profileLoaded = playerProfileApi;
api.onSecond = oneSecondLoop;
api.playerJoined = playerJoined;
api.characterAdded = characterAdded;
api.marketplace = require(script:WaitForChild("marktplace"));
api.format = require(script:WaitForChild("format"));
api.template = profileTemplate;
api.integer = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("integer"));
api.yield = wait;
api.badge = require(script:WaitForChild("badge"));

function api:getProfile(player)
	if(not profiles[player]) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(profiles[player] or player:GetFullName() == player.Name);
	end
	return profiles[player];
end

return api;