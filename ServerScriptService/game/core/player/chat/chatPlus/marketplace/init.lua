--[[
	// Author: Jumpathy
	// Description: A "MarketplaceService" wrapper to make coding faster for developers.

	This module is pretty simple but it gets the job done for the time being. I'll update this as-needed.

	------------ premiumPlayerJoined usage:
	This is fired when a player joins with premium, when someone purchases it, & if any player ingame already has it.

	marketplace.premiumPlayerJoined:Connect(function(player) --> player [instance]
		print(player,"has premium!");
	end)

	------------ gamepassPurchased usage:
	This is fired when a player purchases the specified gamepass ingame.

	marketplace.gamepassPurchased(123456):Connect(function(player)
		print(player,"bought the gamer gamepass")
	end)

	------------ gamepassOwned usage:
	This is fired when a player who has the gamepass is ingame or a player buys it ingame. I'd recommend using this over the previous function.

	marketplace.gamepassOwned(123456):Connect(function(player)
		print(player,"has the epic gamepass")
	end)
]]


local service,datastore,players = game:GetService("MarketplaceService"),game:GetService("DataStoreService"):GetDataStore("PreviousPurchases"),game:GetService("Players");
local module,internal = {},{developerProducts = {},gamepassPurchases = {},onOwned = {},util = require(script:WaitForChild("util"))};

service.PromptGamePassPurchaseFinished:Connect(function(player,gamepassId,wasPurchased)
	if(wasPurchased) then
		for _,gamepass in pairs(internal.gamepassPurchases) do
			if(gamepass[1] == gamepassId) then
				coroutine.wrap(gamepass[2])(player);
			end
		end
	end
end)

-- Fake bindable to change the connect function (used with premium)

local customEvent = {callbacks = {}};

function customEvent:Connect(callback) --> This is used for running a function each time that this function is connected to.
	table.insert(customEvent.callbacks,callback);
	internal.util.playerAdded:Connect(function(user)
		if(user.MembershipType == Enum.MembershipType.Premium) then
			callback(user);
		end
	end)
end

function customEvent:Fire(...)
	for _,func in pairs(customEvent.callbacks) do
		func(...);
	end
end

players.PlayerMembershipChanged:Connect(function(user)
	if(user.MembershipType == Enum.MembershipType.Premium) then
		customEvent:Fire(user);
	end
end)

-- // Module functions:

module.premiumPlayerJoined = customEvent;

function module.gamepassPurchased(id)
	local bindable = Instance.new("BindableEvent");
	table.insert(internal.gamepassPurchases,{
		id,function(player)
			bindable:Fire(player);
		end,
	});
	return bindable.Event;
end

function module.gamepassOwned(id)
	local bindable = Instance.new("BindableEvent");
	table.insert(internal.gamepassPurchases,{id,function(player) bindable:Fire(player); end});
	internal.util.playerAdded:Connect(function(plr)
		local success,owns = pcall(function()
			return service:UserOwnsGamePassAsync(plr.UserId,id);
		end)
		if(success and owns) then
			bindable:Fire(plr);
		end
	end)
	return bindable.Event;
end

-- Return:

return module;