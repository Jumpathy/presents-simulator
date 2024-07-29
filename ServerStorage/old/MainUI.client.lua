local utility = require(script:WaitForChild("Util"));

local localPlayer = game:GetService("Players").LocalPlayer;
local ui = localPlayer.PlayerGui:WaitForChild("Interface");

shared.click_noise = function()
	local sound = Instance.new("Sound",game:GetService("SoundService"));
	sound.SoundId = "rbxassetid://7518248209";
	sound.TimePosition = 0.95;
	sound:Play();
	sound.Volume = 0.2;
	sound.Stopped:Connect(function()
		sound:Destroy();
	end)
end

-- menu scaling:

local maxIncrease = 1.15;
local menu = ui:WaitForChild("Menu");
local minimumSize = Vector2.new(130,150);
local maximumSize = Vector2.new(130*maxIncrease,150*maxIncrease);
local ratio = {130/1083,150/517,8/517};

local backpackLabel = menu:WaitForChild("Backpack"):WaitForChild("Label");
local coinLabel = menu:WaitForChild("Coins"):WaitForChild("Label");
local full = menu:WaitForChild("Backpack"):WaitForChild("Full");
local fullBackpackMenu = ui:WaitForChild("BackpackFull");
local rightMenu = ui:WaitForChild("RightMenu");
local areaBuy = ui:WaitForChild("BuyArea");
local oldConnections = {};
local last;

local disconnect = function()
	for _,connection in pairs(oldConnections) do
		connection:Disconnect();
	end
	oldConnections = {};
end

local buyArea = function(price,cb)
	disconnect();
	price = price or 1;
	cb = cb or function() end;
	
	local callback = function(...)
		disconnect();
		cb(...);
	end
	
	local out = function()
		areaBuy:TweenPosition(UDim2.new(0.5,0,-0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true);
	end
	
	local textFormat = string.format("Are you sure you want to buy this area for %s coins?",utility.formatNumberStandard(price));
	areaBuy:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.25,true);
	areaBuy:WaitForChild("Container"):WaitForChild("Label").Text = textFormat;
	
	table.insert(oldConnections,areaBuy:WaitForChild("Container"):WaitForChild("Options"):WaitForChild("Ok").MouseButton1Click:Connect(function()
		out();
		callback(true);
	end))
	
	table.insert(oldConnections,areaBuy:WaitForChild("Container"):WaitForChild("Options"):WaitForChild("Close").MouseButton1Click:Connect(function()
		out();
		callback(false);
	end))
	
	table.insert(oldConnections,areaBuy:WaitForChild("Container"):WaitForChild("Close"):WaitForChild("Interact").MouseButton1Click:Connect(function()
		
		out();
		callback(false);
	end))
end

local backpackText = function()
	local b,a = localPlayer:GetAttribute("backpackSize"),localPlayer:GetAttribute("backpack");
	backpackLabel.Text = utility.formatNumber(a) .. " / " .. utility.formatNumber(b);
	full.Visible = (a == b);
	if((a == b) ~= last) then
		local state = (a == b);
		local position = (state and UDim2.fromScale(0.5,0.5) or UDim2.fromScale(0.5,-0.5));
		fullBackpackMenu:TweenPosition(
			position,
			(state and Enum.EasingDirection.In or Enum.EasingDirection.Out),
			Enum.EasingStyle.Bounce,
			1/2,
			true
		)
	end
	last = (a == b);
end

local coinText = function(amount)
	coinLabel.Text = utility.formatNumber(amount);
end

utility.ResolutionChanged:Connect(function(x,y)
	menu.Size = UDim2.fromOffset(
		math.clamp(x * ratio[1],minimumSize.X,maximumSize.Y),
		math.clamp(y * ratio[2],minimumSize.Y,maximumSize.Y)
	)
	menu.Layout.Padding = UDim.new(0,math.clamp(y * ratio[3],8,8*maxIncrease));
end)

utility.loaded(function()
	utility.attributeChanged("backpackSize"):Connect(backpackText);
	utility.attributeChanged("backpack"):Connect(backpackText);
	utility.leaderstatChanged("Coins"):Connect(coinText);
end)

fullBackpackMenu:WaitForChild("Container"):WaitForChild("Options"):WaitForChild("Close").MouseButton1Click:Connect(function()
	shared.click_noise();
	fullBackpackMenu:TweenPosition(
		UDim2.fromScale(0.5,-0.5),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Bounce,
		1/2,
		true
	)
end)

fullBackpackMenu:WaitForChild("Container"):WaitForChild("Close"):WaitForChild("Interact").MouseButton1Click:Connect(function()
	shared.click_noise();
	fullBackpackMenu:TweenPosition(
		UDim2.fromScale(0.5,-0.5),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Bounce,
		1/2,
		true
	)
end)

shared.sell = function()
	pcall(function()
		localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-84.043, 2.534, -52.168) + Vector3.new(0,10,0);
	end)
	fullBackpackMenu:TweenPosition(
		UDim2.fromScale(0.5,-0.5),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Bounce,
		1/2,
		true
	)
end

fullBackpackMenu:WaitForChild("Container"):WaitForChild("Options"):WaitForChild("Sell").MouseButton1Click:Connect(function()
	shared.click_noise();
	shared.sell();
end)

fullBackpackMenu:WaitForChild("Container"):WaitForChild("Options"):WaitForChild("Close").MouseButton1Click:Connect(function()
	shared.click_noise();
end)

fullBackpackMenu:WaitForChild("Container"):WaitForChild("Close"):WaitForChild("Interact").MouseButton1Click:Connect(function()
	shared.click_noise();
end)

utility.ResolutionChanged:Connect(function(x)
	rightMenu.Position = UDim2.new(1,(math.clamp(-(x*0.02834008097166),-28,0)),0.5,0);
end)

--shared.prompt_buy_area = buyArea;