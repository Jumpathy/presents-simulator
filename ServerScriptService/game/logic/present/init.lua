local module = {};
local scaleBar = require(script:WaitForChild("hpBarScaling"));

function module.load(script)
	local health = script.Parent:WaitForChild("Values"):WaitForChild("Health");
	local network = require(game.ReplicatedStorage:WaitForChild("shared"):WaitForChild("network"));
	local connected = false;
	shared.gift_data = shared.gift_data or {};
	local present = script.Parent;

	local destroyGift = function(gift)
		if(gift:GetAttribute("Destroyed") == false) then
			gift:SetAttribute("Destroyed",true);
			module:loadFx(gift)
			shared.rgd[gift:GetAttribute("Region")]:Fire(gift);
			shared.gift_data[gift] = nil;
		end
	end
	
	scaleBar(present);
	coroutine.wrap(function()
		local logic = function(player,state)
			local get = function()
				return (player:GetAttribute("ClientLoaded"));
			end
			repeat
				game:GetService("RunService").Heartbeat:Wait();
			until(get() == true);
			network:fireClient("size",player,script.Parent,8,state)
		end

		for _,player in pairs(game:GetService("Players"):GetPlayers()) do
			coroutine.wrap(logic)(player,true)
		end

		game:GetService("Players").PlayerAdded:Connect(logic);
	end)();

	health:GetPropertyChangedSignal("Value"):Connect(function()
		if(health.Value < 1) then
			if(not connected) then
				connected = true;
				game:GetService("RunService").Heartbeat:Wait();
				for player,amount in pairs(shared.gift_data[script.Parent]) do
					local percent = math.floor(math.clamp((amount / (script.Parent.Values:WaitForChild("MaxHealth").Value))*100,0,100))/100;
					local data = shared.player_rewards[player][script.Parent:GetAttribute("ID")];
					local verify = data["verify"];
					local proportional = (percent * (#verify));
					for i = 1,proportional do
						table.insert(data["check"],i);
					end
				end
				destroyGift(script.Parent);
			end
		end
	end)

	shared.gift_data[script.Parent] = {};
end

local destroyed = {}
function module.fx(script)
	if(not destroyed[script]) then
		destroyed[script] = true
		local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
		network:fireAllClients("giftAnimation",script.Parent,script.Parent.Values.Owner.Value);
		local owner = script.Parent.Values.Owner.Value;
		script.Parent.Health.Enabled = false;
		game:GetService("Debris"):AddItem(script.Parent,5);
	end
end

function module:loadFx(present)
	module.fx(present:WaitForChild("Health"))
end

return module;