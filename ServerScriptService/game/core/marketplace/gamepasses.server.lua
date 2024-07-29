local data = require(script.Parent.Parent.Parent:WaitForChild("data"));
local profiles = {};
local passes = {
	["VIP"] = 22632843,
	["Teleport"] = 24838197
}

local waitUntilLoaded = function(player)
	if(not profiles[player]) then
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(profiles[player])
	end
end

local getData = function(id)
	return ({
		[22632843] = {
			Annotation = "VIP",
			Id = "1",
			Amount = 399
		}
	})[id];
end

local errorHandle = function(err)
	warn(game:GetService("RunService"):IsStudio() and err or game:GetService("HttpService"):JSONEncode(err));
end

local handlePurchase = function(id,player,boughtInGame,done)
	local currency = "R$";
	if(not profiles[player]["gamepasses"][tostring(id)]) then
		local data = shared.get_client(player);
		data.server:AddUserVirtualCurrency({
			Amount = getData(id).Amount;
			PlayFabId = data.identifier,
			VirtualCurrency = currency,
		}):andThen(function(result)
			data.api:StartPurchase(data.key,{
				Items = {{
					Annotation = getData(id).Annotation,
					ItemId = getData(id).Id,
					Quantity = 1
				}}
			}):andThen(function(result)
				data.api:PayForPurchase(data.key,{
					Currency = currency,
					OrderId = result.OrderId,
					ProviderName = result.PaymentOptions[1]["ProviderName"]
				}):andThen(function(result)
					data.api:ConfirmPurchase(data.key,{
						OrderId = result.OrderId
					}):andThen(done):catch(errorHandle);
				end):catch(errorHandle)
			end):catch(errorHandle)
		end):catch(errorHandle)
	elseif(game:GetService("RunService"):IsStudio()) then
		--warn("DEBUG: [Already owns gamepass",id,"not logging in analytics]");
	end
end

data.marketplace.gamepassOwned(passes.VIP):Connect(function(player,boughtInGame)
	waitUntilLoaded(player);
	player:SetAttribute("VIP",true);
	player:SetAttribute("Area0",true);
	handlePurchase(passes.VIP,player,boughtInGame,function(result)
		profiles[player]["gamepasses"][passes.VIP] = true;
	end)
end)

data.marketplace.gamepassOwned(passes.Teleport):Connect(function(player)
	player:SetAttribute("CanTeleport",true);
end)

data.profileLoaded:Connect(function(profile,player)
	profiles[player] = profile;
end)