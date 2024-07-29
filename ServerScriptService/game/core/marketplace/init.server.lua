local handler = require(script.Parent.Parent:WaitForChild("data"));
local statModule = require(script.Parent.Parent:WaitForChild("stats"));
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local integer = handler.integer;
local passes = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("config")).passes;
local uiReady = {};
local profiles = {};

local products = {
	[1] = 1225555891,
	[2] = 1225555918,
	[3] = 1225555947,
	[4] = 1225555990,
	[5] = 1225556425,
	[6] = 1225556461
}

local prices;
coroutine.wrap(function()
	local tbl = {};
	for key,productId in pairs(products) do
		local price = game:GetService("MarketplaceService"):GetProductInfo(productId,Enum.InfoType.Product)["PriceInRobux"];
		tbl[key] = price;
	end
	prices = tbl;
end)();

local milestones = {
	[100] = {
		[1] = 10,
		[2] = 50,
		[3] = 100,
		[4] = 300,
		[5] = 500,
		[6] = 1000
	}
}

local base = {};
local first = 100;
for key,value in pairs(milestones[first]) do
	base[key] = value / first;
end

local multiply = function(a,b)
	local r = tostring(integer.new(a) * integer.new(b));
	return r;
end

local lessThanOrEqualTo = function(a,b)
	return integer.new(a) <= integer.new(b);
end

for i = 1,56 do
	local goal = tostring("10000" .. (string.rep("0",i)));
	milestones[goal] = {};
	for i = 1,6 do
		if(base[i] >= 1) then
			milestones[goal][i] = multiply(goal,base[i]);
		else
			milestones[goal][i] = tostring(tonumber(goal * base[i]));
		end
	end
end

milestones[first] = nil;

local linkRelativeLs = function(leaderstats,callback)
	local coins = leaderstats:WaitForChild("Coins"):WaitForChild("Real");
	local change = function()
		local value = coins.Value;
		local highest = integer.new(-5);
		for milestone,coinAmounts in pairs(milestones) do
			if(not lessThanOrEqualTo(value,milestone)) then
				if(integer.new(milestone) >= highest) then
					highest = integer.new(milestone);
				end
			end
		end
		if(highest <= integer.new(1)) then
			highest = "100000";
		end
		callback(milestones[tostring(highest)]);
	end
	coins:GetPropertyChangedSignal("Value"):Connect(change);
	change();
end

local playerProducts = {};
handler.profileLoaded:Connect(function(profile,player)
	local owned = Instance.new("Folder");
	owned.Name = "OwnedPasses";
	owned.Parent = player;

	local lastYield;
	linkRelativeLs(player:WaitForChild("leaderstats"),function(products)
		local key = tick();
		playerProducts[player] = products;
		lastYield = key;
		if(not uiReady[player]) then
			repeat
				game:GetService("RunService").Heartbeat:Wait();
			until(uiReady[player] and (lastYield == key) or (player:GetFullName() == player.Name));
		end
		if(lastYield == key and (player:GetFullName() ~= player.Name)) then
			if(not prices) then
				repeat
					game:GetService("RunService").Heartbeat:Wait();
				until(prices);
			end
			network:fireClient("products",player,products,prices);
		end
	end)
end)

network:createRemoteEvent("products");
network:createRemoteEvent("uiReady",function(player)
	if(not uiReady[player]) then
		uiReady[player] = true;
	end
end)

network:createRemoteEvent("buyCoins",function(player,id)
	if(products[id]) then
		game:GetService("MarketplaceService"):PromptProductPurchase(player,products[id]);
	end
end)

network:createRemoteEvent("devProductPurchaseInteraction");

local productPurchase = function(player)
	network:fireClient("devProductPurchaseInteraction",player);
end

for key,productId in pairs(products) do
	handler.marketplace.onDeveloperProductPurchase(productId):Connect(function(player)
		if(not playerProducts[player]) then
			repeat
				game:GetService("RunService").Heartbeat:Wait();
			until(playerProducts[player]);
		end
		local productData = playerProducts[player];
		statModule:add(player,"Coins",productData[key]);
		productPurchase(player);
	end)
end

for _,passId in pairs(passes) do
	handler.marketplace.gamepassOwned(passId):Connect(function(player)
		player:WaitForChild("OwnedPasses",math.huge):SetAttribute(tostring(passId),true);
	end)
end

local tbl = {
	[60] = true,
	[45] = true,
	[30] = true,
	[20] = true,
	[10] = true,
	[5] = true
}

local products = {
	["2xD"] = {
		[60] = 1226442654,
		[45] = 1226442855,
		[30] = 1226443003,
		[20] = 1226443186,
		[10] = 1226443759,
		[5] = 1226443935
	},
	["2xT"] = {
		[60] = 1226457545,
		[45] = 1226457718,
		[30] = 1226457831,
		[20] = 1226458288,
		[10] = 1226458424,
		[5] = 1226458744
	}
}

local purchase = function(player,boostName,length)
	local profile = handler:getProfile(player);
	if(profile) then
		productPurchase(player);
		profile = profile.Data;
		profile.boosts[boostName] += (length * 60);
	end
end

shared.forge_boost = function(player,boostName,length)
	purchase(player,boostName,length);
end

for boostName,list in pairs(products) do
	for length,id in pairs(list) do
		handler.marketplace.onDeveloperProductPurchase(id):Connect(function(player)
			purchase(player,boostName,length)
		end);
	end
end

network:createRemoteFunction("purchaseProduct",function(player,name,length)
	if(tbl[length] and products[name]) then
		game:GetService("MarketplaceService"):PromptProductPurchase(player,products[name][length]);
	end
end)

handler.profileLoaded:Connect(function(profile,player)
	local boosts = Instance.new("Folder");
	boosts.Parent = player;
	boosts.Name = "Boosts";
	profiles[player] = profile;
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
	profiles[player] = nil;
end)

while true do
	for player,profile in pairs(profiles) do
		local boosts = profile.boosts;
		for boostName,remainingInSeconds in pairs(boosts) do
			if(remainingInSeconds >= 1) then
				boosts[boostName] += -1;
			end
			player.Boosts:SetAttribute(boostName,remainingInSeconds);
		end
	end
	task.wait(1)
end