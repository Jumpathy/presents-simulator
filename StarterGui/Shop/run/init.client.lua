local area = workspace:WaitForChild("areas"):WaitForChild("area1"):WaitForChild("shop");
local zone = area:WaitForChild("Zone");
local players = game:GetService("Players");
local localPlayer = players.LocalPlayer;
local shopUi = localPlayer.PlayerGui:WaitForChild("Shop",math.huge);
local otherUi = localPlayer.PlayerGui:WaitForChild("UI",math.huge);
local sound = require(game.ReplicatedStorage:WaitForChild("sounds"));
local conf = require(game:GetService("ReplicatedStorage"):WaitForChild("config"));
local controllerService = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("controllerService"))();

local util = require(script:WaitForChild("util"));
local linkedStore = workspace:WaitForChild("stores"):WaitForChild("raygun"):WaitForChild("models");
local linkedStore2 = workspace:WaitForChild("stores"):WaitForChild("backpack"):WaitForChild("models");
local callback = require(linkedStore:WaitForChild("function"));
local callback2 = require(linkedStore2:WaitForChild("function"));
local connections = {};
local shopOpened = false;
local num = 1;
local num2 = 1;
local selectedModel = linkedStore:WaitForChild(tostring(num));
local selectedModel2 = linkedStore2:WaitForChild(tostring(num2));
local max = linkedStore:GetAttribute("count");
local max2 = linkedStore2:GetAttribute("count");
local uis = game:GetService("UserInputService");
local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));
local last;
local currentStore;

local exit = shopUi:WaitForChild("Options"):WaitForChild("ExitShop",math.huge);
local transitionUi = shopUi:WaitForChild("Transition",math.huge);
local selections = shopUi:WaitForChild("Selections",math.huge);
local selections2 = shopUi:WaitForChild("BackpackSelections",math.huge);
local statUi = selections:WaitForChild("Stats"):WaitForChild("Real");
local statUi2 = selections2:WaitForChild("Stats"):WaitForChild("Real");

local sounds = require(game:GetService("ReplicatedStorage"):WaitForChild("sounds"));

local toggleVisiblity = {
}

local handle = function(callback)
	callback = callback or function() end;
	return function(completed)
		if(completed) then
			callback();
		end
	end
end

local controlsEnabled = function(bool)
	game:GetService("GuiService").TouchControlsEnabled = bool;
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,bool);
end

local toggleVis = function(state)
	otherUi.Enabled = state;
end

local transition = function(state,callback)
	local size = (state and UDim2.new(1,0,1,0) or UDim2.new(1,0,0,0));
	local direction = (state and Enum.EasingDirection.In or Enum.EasingDirection.Out);
	local properties = {direction,Enum.EasingStyle.Quad,0.16,true,handle(callback)};
	transitionUi:TweenSize(size,unpack(properties));
end

local oldConn;

local hasRaygun = function(model)
	return localPlayer:WaitForChild("OwnedTools",math.huge):GetAttribute(model:GetAttribute("ActualObject"));
end

local hasBackpack = function(model)
	return localPlayer:WaitForChild("OwnedBackpacks",math.huge):GetAttribute(model:GetAttribute("ActualObject"));
end

local getStatus = function(model)
	local selected = localPlayer:GetAttribute("SelectedRaygun");
	local actual = model:GetAttribute("ActualObject");
	return(selected == actual and "Equipped" or "Equip");
end

local getStatus2 = function(model)
	local selected = localPlayer:GetAttribute("SelectedBackpack");
	local actual = model:GetAttribute("ActualObject");
	return(selected == actual and "Equipped" or "Equip");
end

local getColor = function(model)
	return Color3.fromRGB(255,255,255);
end

local getColor2 = function(model)
	return Color3.fromRGB(255,255,255);
end

local cached = {};
local callbacks = {};

local setRaygunStats = function(model)
	last = tick();
	if(oldConn) then
		oldConn:Disconnect();
		oldConn = nil;
	end

	local rebirths = localPlayer:WaitForChild("leaderstats"):WaitForChild("Rebirths"):WaitForChild("Real").Value;
	if(not cached[model]) then
		cached[model] = model:GetAttribute("Price");
	end
	if(tonumber(rebirths) >= 1) then
		model:SetAttribute("Price",(tonumber(rebirths)*conf.rebirth.multiplierPerObject)*tonumber(cached[model]));
	end
	local options = {
		reload = model:GetAttribute("Reload"),
		damage = model:GetAttribute("Damage"),
		price = model:GetAttribute("Price")
	};
	statUi.Reload.Stat.Text = "Reload: " .. tostring(options.reload).."s";
	statUi.Damage.Stat.Text = "Damage: " .. util.formatNumberStandard(options.damage);
	statUi.Price.Stat.Text = "Price: " .. util.formatNumber(options.price);

	if(not hasRaygun(model)) then
		statUi.Button.Stat.Text = "Purchase";
		statUi.Button.BackgroundColor3 = Color3.fromRGB(0,225,97);
	else
		statUi.Button.Stat.Text = getStatus(model);
		statUi.Button.BackgroundColor3 = getColor(model);
	end

	local clicked = function()
		if(not hasRaygun(model)) then
			if(network:invokeServer("buyRaygun",model)) then
				statUi.Button.Stat.Text = getStatus(model);
				statUi.Button.BackgroundColor3 = getColor(model);
				if(statUi.Button.Stat.Text == "Equip") then
					network:invokeServer("equipTool",model);
				end
			else
				local key = tick();
				last = key;
				statUi.Button.Stat.Text = "Insufficient funds";
				util.wait(3/4);
				if(last == key) then
					statUi.Button.Stat.Text = "Purchase";
					statUi.Button.BackgroundColor3 = Color3.fromRGB(0,225,97);
				end
			end
		else
			network:invokeServer("equipTool",model);
			sounds.play(sounds.library.equip,0.5,0.05);
			statUi.Button.Stat.Text = getStatus(model);
			statUi.Button.BackgroundColor3 = getColor(model);
		end
	end
	oldConn = statUi.Button.MouseButton1Click:Connect(clicked)
	callbacks[statUi.Button] = clicked;
end

local on = Instance.new("BindableEvent");
local setBackpackStats = function(model)
	on:Fire();
	last = tick();
	if(oldConn) then
		oldConn:Disconnect();
		oldConn = nil;
	end

	local rebirths = localPlayer:WaitForChild("leaderstats"):WaitForChild("Rebirths"):WaitForChild("Real").Value;
	if(not cached[model]) then
		cached[model] = {
			price = model:GetAttribute("Price"),
			storage = model:GetAttribute("Storage")
		};
	end
	if(tonumber(rebirths) >= 1) then
		if(not model:GetAttribute("PassId")) then
			model:SetAttribute("Price",(tonumber(rebirths)*conf.rebirth.multiplierPerObject)*tonumber(cached[model].price));
		end
		model:SetAttribute("Storage",tonumber(cached[model].storage * (rebirths * conf.rebirth.backpackUpgrade)))
	end
	local key = "formatNumberStandard"
	if(model:GetAttribute("Storage") > (1*10^6)) then
		key = "formatNumber";
	end

	local options = {storage = model:GetAttribute("Storage"),price = model:GetAttribute("Price"),passId = model:GetAttribute("PassId")};
	local yuh = options.passId ~= nil and ("R$ %s"):format(util.formatNumber(options.price)) or util.formatNumber(options.price);
	statUi2.Storage.Stat.Text = "Storage: " .. util[key](options.storage);
	statUi2.Price.Stat.Text = "Price: " .. yuh;

	if(not hasBackpack(model)) then
		statUi2.Button.Stat.Text = "Purchase";
		statUi2.Button.BackgroundColor3 = Color3.fromRGB(0,225,97);
	else
		statUi2.Button.Stat.Text = getStatus2(model);
		statUi2.Button.BackgroundColor3 = getColor2(model);
	end

	require(model.model:GetChildren()[1].Function)("0/"..util[key](options.storage));

	local clicked = function()
		if(not hasBackpack(model)) then
			local key = tick();
			last = key;
			local response = network:invokeServer("buyBackpack",model);
			if(response) then
				statUi2.Button.Stat.Text = getStatus2(model);
				statUi2.Button.BackgroundColor3 = getColor2(model);
				if(statUi2.Button.Stat.Text == "Equip") then
					network:invokeServer("equipBackpack",model);
				end
			else
				if(not options.passId) then
					statUi2.Button.Stat.Text = "Insufficient funds";
					util.wait(3/4);
					if(last == key) then
						statUi2.Button.Stat.Text = "Purchase";
						statUi2.Button.BackgroundColor3 = Color3.fromRGB(0,225,97);
					end
				else
					statUi2.Button.Stat.Text = "Pending...";
					local signal;
					signal = on.Event:Connect(function(response)
						signal:Disconnect();
						if(last == key) then
							if(response) then
								statUi2.Button.Stat.Text = getStatus2(model);
								statUi2.Button.BackgroundColor3 = getColor2(model);
								if(statUi2.Button.Stat.Text == "Equip") then
									network:invokeServer("equipBackpack",model);
								end
							else
								statUi2.Button.Stat.Text = "Purchase";
								statUi2.Button.BackgroundColor3 = Color3.fromRGB(0,225,97);
							end
						end
					end)
				end
			end
		else
			network:invokeServer("equipBackpack",model);
			sounds.play(sounds.library.equip,0.5,0.05);
			statUi2.Button.Stat.Text = getStatus2(model);
			statUi2.Button.BackgroundColor3 = getColor2(model);
		end
	end
	oldConn = statUi2.Button.MouseButton1Click:Connect(clicked);
	callbacks[statUi2.Button] = clicked;
end

local call;

local getObject = function(models,name)
	for _,child in pairs(models:GetChildren()) do
		if(child:GetAttributes()["ActualObject"] == name) then
			return child
		end
	end
end

shared.hopto = function(container,name)
	call = function()
		local store = workspace:WaitForChild("stores"):WaitForChild(container:lower() == "backpack" and "backpack" or "raygun")
		local models = store:WaitForChild("models")
		local obj = getObject(models,name)
		selectedModel = obj

		if(store.Name == "backpack") then
			setBackpackStats(obj)
		else
			setRaygunStats(obj)
		end
		call =  nil
		callback(selectedModel).view();

		return store.Name
	end
end

network:bindRemoteEvent("onPurchase",function(success)
	if(success) then
		sound.play(sound.library.unlocked);
	end
	on:Fire(success);
end)

local move = function()
	warn("[no assigned callback]")
end

local connectSelections = function(callback,parent)
	local opposite = (parent == selections and selections2 or selections);
	opposite.Visible = false;
	parent.Visible = true;
	exit.Parent.Visible = true;
	for _,connection in pairs(connections) do
		connection:Disconnect();
	end
	connections = {};
	table.insert(connections,parent.Next.MouseButton1Click:Connect(function()
		shared.click_noise();
		callback(1);
	end))
	table.insert(connections,parent.Previous.MouseButton1Click:Connect(function()
		shared.click_noise();
		callback(-1);
	end))
	move = function(int)
		if(shopOpened) then
			shared.click_noise();
			callback(int);
		end
	end
end

local exitShop = function()
	shared.click_noise();
	for _,connection in pairs(connections) do
		connection:Disconnect();
	end
	connections = {};
	transition(true,function()
		callback(selectedModel).default();
		util.wait(1/4);
		selections.Visible = false;
		selections2.Visible = false;
		exit.Parent.Visible = false;
		toggleVis(true);
		controlsEnabled(true);
		util.wait(1/4);
		transition(false);
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true);
		util.wait(0.85);
		shopOpened = false;
	end)
end

exit:WaitForChild("Button").MouseButton1Click:Connect(exitShop)

local backpackStore = function()
	callback2(selectedModel2).default();
	currentStore = "Backpack";
	setBackpackStats(selectedModel2);
	connectSelections(function(int)
		num2 = math.clamp(num2+(int),1,max2);
		local old = selectedModel2;
		selectedModel2 = linkedStore2:WaitForChild(tostring(num2));
		setBackpackStats(selectedModel2);
		if(old ~= selectedModel2) then
			callback2(old).unview();
			callback2(selectedModel2).view();
		end
	end,selections2)
	callback2(selectedModel2).view();
end

local raygunStore = function()
	callback(selectedModel).default();
	currentStore = "Raygun";
	connectSelections(function(int)
		num = math.clamp(num+(int),1,max);
		local old = selectedModel;
		selectedModel = linkedStore:WaitForChild(tostring(num));
		setRaygunStats(selectedModel);
		if(old ~= selectedModel) then
			callback(old).unview();
			callback(selectedModel).view();
		end
	end,selections)
	callback(selectedModel).view();
end

exit.Parent:WaitForChild("Backpacks"):WaitForChild("Button").MouseButton1Click:Connect(backpackStore);
exit.Parent:WaitForChild("Rayguns"):WaitForChild("Button").MouseButton1Click:Connect(raygunStore);

zone.Touched:Connect(function(hit)
	if(hit.Parent:FindFirstChildOfClass("Humanoid")) then
		if(players:GetPlayerFromCharacter(hit.Parent) == localPlayer) then
			if(not shopOpened) then
				shopOpened = true;
				transition(true,function()
					game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false);
					controlsEnabled(false);
					toggleVis(false);

					setRaygunStats(selectedModel);
					raygunStore();

					util.wait(1/2);
					transition(false);
				end)
			end
		end
	end
end)

controllerService.Connected:Connect(function(controller)
	controller.DPadInput:Connect(function(direction)
		if(shopOpened) then
			if(direction == "Left") then
				move(-1);
			elseif(direction == "Right") then
				move(1);
			elseif(direction == "Up") then
				if(currentStore ~= "Backpack") then
					backpackStore();
				end
			elseif(direction == "Down") then
				if(currentStore ~= "Raygun") then
					raygunStore();
				end
			end
		end
	end)
	controller.PrimaryButtonPressed:Connect(function(button)
		if(button == Enum.KeyCode.ButtonA) then
			if(shopOpened) then
				for _,v in pairs({selections,selections2}) do
					if(v.Visible) then
						local buttonToPress = v.Stats.Real.Button;
						callbacks[buttonToPress]();
						break;
					end
				end
			end
		elseif(button == Enum.KeyCode.ButtonB) then
			if(shopOpened) then
				exitShop();
			end
		end
	end)
	for _,m in pairs({selections,selections2}) do
		m:WaitForChild("Next"):WaitForChild("Dpad").Visible = true;
		m:WaitForChild("Previous"):WaitForChild("Dpad").Visible = true;
		m:WaitForChild("Stats"):WaitForChild("Real"):WaitForChild("Button").XboxA.Visible = true;
	end
	exit.Parent.Backpacks.DPad.Visible = true;
	exit.Button.XboxB.Visible = true;
end)

controllerService.Disconnected:Connect(function(controller)
	for _,m in pairs({selections,selections2}) do
		m:WaitForChild("Next"):WaitForChild("Dpad").Visible = false;
		m:WaitForChild("Previous"):WaitForChild("Dpad").Visible = false;
		m:WaitForChild("Stats"):WaitForChild("Real"):WaitForChild("Button").XboxA.Visible = false;
	end
	exit.Parent.Backpacks.DPad.Visible = false;
	exit.Button.XboxB.Visible = false;
end)

controllerService:Start();