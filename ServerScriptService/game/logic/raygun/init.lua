return function(tool,event,config)
	-- settings:

	local maxDistance = 15;
	local owner = tool.Parent.Parent;
	local handle = tool:WaitForChild("Handle");
	local beam = handle:WaitForChild("Beam");
	local wait = require(script:WaitForChild("betterWait"));
	local handler = require(script.Parent.Parent:WaitForChild("data"));
	local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
	local presentManager = require(script.Parent:WaitForChild("present"));
	local isEquipped = false;
	local debounce = false;
	local selectedGift;
	local lastConnection;
	local giftConnection;
	local maxRewards = {};
	local ownerProfile = handler:getProfile(owner);
	
	local setSelection = function(selection,attachment)
		if(attachment) then
			owner.Selection.Value = attachment;
		else
			owner.Selection.Value = selection;
		end
		selectedGift = selection;
		coroutine.wrap(function()
			event:InvokeClient(owner,"setSelection",selection);
		end)();
	end

	local disconnect = function()
		setSelection(nil);
		if(lastConnection) then
			lastConnection:Disconnect();
			lastConnection = nil;
		end
		if(giftConnection) then
			giftConnection:Disconnect();
			giftConnection = nil;
		end
		beam.Attachment1 = nil;
		selectedGift = nil;
	end
	
	local getMultiplier = function()
		return(ownerProfile.Data.boosts["2xD"] >= 1 and 2 or 1);
	end

	local linkReward = function(player,gift)
		local id = gift:GetAttribute("ID");
		shared.player_rewards[player][id] = {
			check = {},
			verify = {},
			max = gift:GetAttribute("Give"), -- (amount given)
			total = gift:GetAttribute("Amount") -- (what),
		};
		for i = 1,gift:GetAttribute("Reward") do
			table.insert(shared.player_rewards[player][id]["verify"],i);
		end
	end
	
	local getBaseDamage = function(base)
		return(base * (owner:GetAttribute("AddDamage") + 1));
	end

	local getDealtDamage = function(gift)
		gift.Values.Health.Value = math.clamp(
			gift.Values.Health.Value - (getBaseDamage(config.damage()) * getMultiplier()),
			0,
			math.huge
		);
		return math.clamp((getBaseDamage(config.damage())),0,gift.Values.MaxHealth.Value);
	end

	local destroyGift = function(gift)
		pcall(disconnect); -- disconnect signals
		if(gift:GetAttribute("Destroyed") == false) then -- make sure it's not still
			selectedGift = nil;
			gift:SetAttribute("Destroyed",true); -- link as destroyed so it can't be opened
			--gift.FX.Disabled = false; -- enable the destroy effect script previously disabled
			presentManager:loadFx(gift);
			beam.Attachment1 = nil; -- remove tool attachment
			shared.rgd[gift:GetAttribute("Region")]:Fire(gift); -- remove it from the area's index
		end
	end

	local unequipped = function()
		isEquipped = false;
		selectedGift = nil;
		disconnect();
	end
	
	local health = function(gift,reward)
		if(selectedGift == gift) then
			if(gift.Values.Health.Value < 1 and (not gift:GetAttribute("Destroyed"))) then
				if(reward) then
					linkReward(owner,gift);
				end
				destroyGift(gift);
			end
		else
			pcall(function()
				giftConnection:Disconnect();
			end)
		end
	end

	local handleDamage = function(gift,attachment)
		local distance = (handle.Position - gift.PrimaryPart.Position).magnitude;
		if(selectedGift ~= gift and distance <= maxDistance and gift:GetAttribute("Destroyed") == false) then
			if(not((tonumber(gift:GetAttribute("Region"):sub(5,8)) == 1) or owner:GetAttribute("Area"..(tonumber(gift:GetAttribute("Region"):sub(5,8)))) == true)) then
				return;
			end			
			linkReward(owner,gift);
			disconnect();
			setSelection(gift,attachment);
			beam.Attachment1 = attachment;
			coroutine.wrap(function()
				game:GetService("RunService").Heartbeat:Wait();
				while(selectedGift == gift and (gift.Values.Health.Value > 0) and isEquipped) do
					local damage = getDealtDamage(gift);
					shared.gift_data[gift][owner] = shared.gift_data[gift][owner] or 0;
					shared.gift_data[gift][owner] += damage;
					maxRewards[gift] = maxRewards[gift] or {limit = math.floor(gift.Values.MaxHealth.Value / (100)),current = 0,iter = 0};
					maxRewards[gift]["iter"] += 1;
					if(maxRewards[gift]["iter"] >= (maxRewards[gift]["limit"]*1.25)) then
						maxRewards[gift]["iter"] = 0;
						maxRewards[gift]["current"] = math.clamp(maxRewards[gift]["current"]+1,0,maxRewards[gift]["limit"]);
						if(maxRewards[gift]["current"] < maxRewards[gift]["limit"]) then
							shared.randomRewards[owner] = shared.randomRewards[owner] or {};
							shared.randomRewards[owner][gift] = shared.randomRewards[owner][gift] or {};
							table.insert(shared.randomRewards[owner][gift],{amount = math.floor(gift.Values.MaxHealth.Value / (55));});
							network:fireClient("randomReward",owner,gift);
						end
					end					
					wait(config.delay);
				end
				if(gift.Values.Health.Value < 1 and (selectedGift == gift)) then
					setSelection(nil);
					selectedGift = nil;
					beam.Attachment1 = nil;
				end
			end)();
			lastConnection = game:GetService("RunService").Heartbeat:Connect(function()
				local success = pcall(function()
					if((handle.Position - gift.PrimaryPart.Position).magnitude > maxDistance) then
						disconnect();
					end
				end)
				if(not success) then
					disconnect();
				end
			end)
		end
	end

	event.OnServerInvoke = function(player,...)
		if(owner == player) then
			if(not debounce or (tick() > debounce)) then
				debounce = tick() + 0.25;
				local args = {...};
				if(args[1] == "openGift" and args[2] ~= nil) then
					local target = args[2];
					if(type(target) ~= "table") then
						if(typeof(target) == "Instance") then
							if(target:IsDescendantOf(workspace.gifts)) then
								local parent,found = target.Parent,false;
								for i = 1,(4 * 2) do
									if(parent:GetAttribute("IsPresent")) then
										found = true;
										break;
									else
										parent = parent.Parent;
									end
								end
								if(found) then
									if(parent:FindFirstChild("BaseColor")) then
										if(parent:FindFirstChild("BaseColor"):FindFirstChildOfClass("Attachment")) then
											handleDamage(parent,parent:FindFirstChild("BaseColor"):FindFirstChildOfClass("Attachment"));
										end
									end
								end
							elseif(not target:GetAttribute("IsPresent")) then

							end
						else
							player:Kick("boi")
						end
					else
						player:Kick("WHY WOULD YOU SEND A TABLE? LOL")
					end
				end
			end
		else
			player:Kick();
		end
	end

	tool.Unequipped:Connect(unequipped);
	tool.Equipped:Connect(function()
		isEquipped = true;
	end)
end