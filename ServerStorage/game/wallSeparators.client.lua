local localPlayer = game:GetService("Players").LocalPlayer;
local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));
local tweenService = game:GetService("TweenService");
local marketplaceService = game:GetService("MarketplaceService");
local unlocked = {};
local purchased = {};
local noPrompts = true;
local sound = require(game.ReplicatedStorage:WaitForChild("sounds"));
local int = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("integer"));

local compare = function(a,b)
	return int.new(tostring(a)) >= int.new(tostring(b));
end

repeat
	game:GetService("RunService").Heartbeat:Wait();
until(localPlayer:GetAttribute("loaded") == true);

local has = function(amount)
	return compare(localPlayer.leaderstats.Coins.Real.Value,amount);
end

local tween = function(obj,len,properties)
	tweenService:Create(obj,TweenInfo.new(len),properties):Play();
end

local calculate = function(zone,player)
	player = player or localPlayer;
	local rebirths = tonumber(player.leaderstats.Rebirths.Real.Value);
	if(rebirths < 1) then
		return zone:GetAttribute("Cost");
	else
		return zone:GetAttribute("Cost") * (rebirths * 3);
	end
end

local lock = function(zone)
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(zone:FindFirstChildOfClass("SurfaceGui"));
	tween(zone,0.16,{Transparency = 0.15});
	unlocked[zone] = false;
	
	local surfaceGui = zone:FindFirstChildOfClass("SurfaceGui");
	local elements = {"Locked","Price","TouchToPurchase"};
	local change = {
		["Locked"] = {["Text"] = "Area is locked."},
		["Price"] = {["Text"] = int.format.FormatStandard(calculate(zone)) .. " Coins"},
		["TouchToPurchase"] = {["Text"] = "(touch to purchase)"};
	}

	local add = function()
		change["LockPNG"] = {["Image"] = "http://www.roblox.com/asset/?id=6031082533"};
		table.insert(elements,"LockPNG");
	end

	if(zone:GetAttribute("ChangeImage") == true) then
		add();
	end

	for i = 1,#elements do
		local element = surfaceGui:WaitForChild(elements[i]);
		pcall(function()
			for p,v in pairs(change[element.Name]) do
				element[p] = v;
			end
		end)
	end
	zone.CanCollide = true;
end

local unlock = function(zone)
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(zone:FindFirstChildOfClass("SurfaceGui"));
	tween(zone,0.16,{Transparency = 0.8});
	unlocked[zone] = true;

	local surfaceGui = zone:FindFirstChildOfClass("SurfaceGui");

	local elements = {"Locked","Price","TouchToPurchase"};
	local change = {
		["Locked"] = {["Text"] = "Area is unlocked!"},
		["Price"] = {["Text"] = ""},
		["TouchToPurchase"] = {["Text"] = ""};
	}
	
	local add = function()
		change["LockPNG"] = {["Image"] = "http://www.roblox.com/asset/?id=6026568220"};
		table.insert(elements,"LockPNG");
	end
	
	if(zone:GetAttribute("ChangeImage") == true) then
		add();
	end

	for i = 1,#elements do
		local element = surfaceGui:WaitForChild(elements[i]);
		pcall(function()
			for p,v in pairs(change[element.Name]) do
				element[p] = v;
			end
		end)
	end
	
	local key = zone.Name;
	zone.CanCollide = false;
	local signal;
	signal = localPlayer.AttributeChanged:Connect(function(name)
		if(name == key) then
			if(not localPlayer:GetAttribute(key)) then
				lock(zone);
				signal:Disconnect();
			end
		end
	end)
end

local invoke = function(separator)
	return network:invokeServer("unlockRegion",separator,calculate(separator));
end

local linkAttribute = function(name,callback)
	localPlayer.AttributeChanged:Connect(function(attribute)
		if(attribute == name and localPlayer:GetAttribute(name)) then
			callback(localPlayer:GetAttribute(name));
		end
	end)
	coroutine.wrap(callback)(localPlayer:GetAttribute(name),true);
end

local num = -1;
for i = 1,(7+1) do
	num += 1;
	if(num ~= 1) then
		local separator = workspace:WaitForChild("areas"):WaitForChild("separators"):WaitForChild("Area"..num,math.huge);
		local n = num;
		if(separator:GetAttribute("Cost") ~= nil) then
			lock(separator);
			local waiting = false;
			local connection,cost = nil,nil;
			local re = function()
				cost = calculate(separator)
			end
			re();
			connection = separator.Touched:Connect(function(hit)
				re();
				if(hit.Parent == localPlayer.Character and (not localPlayer:GetAttribute("Area" .. n))) then
					if(has(cost)) then
						if(waiting == false) then
							waiting = true;
							shared.prompt_buy_area(cost,function(state)
								if(state) then
									local response = invoke(separator);
									if(response) then
										sound.play(sound.library.unlocked);
										coroutine.wrap(unlock)(separator);
										wait(1);
										waiting = false;
									else
										waiting = false;
										return false,"Insufficient funds.";
									end
								else
									coroutine.wrap(function()
										wait(1);
										waiting = false;
									end)();
								end
							end)
						end
					end
				end
			end)
			if(localPlayer:GetAttribute("Area" .. num) == true) then
				coroutine.wrap(unlock)(separator);
			end
		elseif(separator:GetAttribute("AttributeLocked") ~= nil) then
			linkAttribute(separator:GetAttribute("AttributeLocked"),function(value,isDefault)
				if(value == true) then
					if(not unlocked[separator]) then
						if(not isDefault) then
							sound.play(sound.library.unlocked);
						end
						coroutine.wrap(unlock)(separator);
					end
				end
			end)
		end
		if(separator:GetAttribute("PromptPurchase")) then
			local id = separator:GetAttribute("PromptPurchase");
			separator.Touched:Connect(function(hit)
				if(hit.Parent == localPlayer.Character) then
					if(not unlocked[separator] and noPrompts and (not purchased[id])) then
						noPrompts = false;
						marketplaceService:PromptGamePassPurchase(localPlayer,id);
					end
				end
			end)
		end
	end
end

marketplaceService.PromptGamePassPurchaseFinished:Connect(function(p,id,wasPurchased)
	if(p == localPlayer) then
		noPrompts = true;
		if(wasPurchased) then
			purchased[id] = true;
		end
	end
end)