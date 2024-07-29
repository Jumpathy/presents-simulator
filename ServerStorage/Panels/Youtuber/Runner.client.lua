repeat
	game:GetService("RunService").Heartbeat:Wait();
until(shared.gameLoaded and shared.menuClosedLol)

local players = game:GetService("Players");
local localPlayer = players.LocalPlayer;
local blank = function() end
local gui = script.Parent;
local args = {Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.4,true}

-- services:

local uis = game:GetService("UserInputService");
local replicatedStorage = game:GetService("ReplicatedStorage");
local runService = game:GetService("RunService");
local starterGui = game:GetService("StarterGui");

-- network:

local network = require(replicatedStorage:WaitForChild("shared"):WaitForChild("network"));

-- yes

local library;

local states = {};
local buttons = {};
local currentOverhead = true;
local currentHealth = true;
local changed = Instance.new("BindableEvent");

local boxes = {
	["Gravity"] = function(input)
		local new = tonumber(input) or 196.2;
		local success,response = network:invokeServer("contentCreatorPanel","modifyGravity",new);
		if(not success) then
			library:notify(response);
		end
	end,
}

local billboard = function(gui)
	if(gui.Name == "Overhead") then
		gui.Enabled = currentOverhead;
		local signal;
		signal = changed.Event:Connect(function()
			if(gui:GetFullName() ~= gui.Name) then
				gui.Enabled = currentOverhead;
			else
				signal:Disconnect();
			end
		end)
	elseif(gui.Name == "Health") then
		gui.Enabled = currentHealth;
		local signal;
		signal = changed.Event:Connect(function()
			if(gui:GetFullName() ~= gui.Name) then
				gui.Enabled = currentHealth;
			else
				signal:Disconnect();
			end
		end)
	end
end

local toggles = {
	["UI"] = function(state)
		local button = buttons["UI"];
		button.Image = button:GetAttribute(state and "On" or "Off");
		for _,gui in pairs(localPlayer.PlayerGui:GetChildren()) do
			pcall(function()
				gui.Enabled = state;
			end)
		end
		starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,state);
	end,
	["Freecam"] = function(state)
		local freecam = shared.freecam;
		local button = buttons["Freecam"];
		button.Image = button:GetAttribute(state and "On" or "Off");
		if(freecam) then
			local current = freecam:get();
			if(state and current) then
				return;
			elseif((not state) and (not current)) then
				return;
			else
				freecam:toggle()
			end
		end
	end,
	["Overheads"] = function(state)
		local button = buttons["Overheads"];
		button.Image = button:GetAttribute(state and "On" or "Off");
		currentOverhead = state;
		changed:Fire();
	end,
	["Presents"] = function(state)
		local button = buttons["Presents"];
		button.Image = button:GetAttribute(state and "On" or "Off");
		currentHealth = state;
		changed:Fire();
	end,
}

local sliders = {
	["Blur"] = function(raw)
		local max = 30;
		local effect = game:GetService("Lighting").Blur;
		effect.Size = (max*(raw/100))
	end,
}

local tweenSize = function(object,size)
	object:TweenSize(size,Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.05,true);
end

local onChild = function(child)
	if(child:IsA("Frame") and child:GetAttribute("Type")) then
		local class = child:GetAttribute("Type");
		if(class == "Toggle") then
			local state = false;
			local button = child:WaitForChild("Toggle");
			local default = child:GetAttribute("Default");
			buttons[child.Name] = button;
			local change = function()
				state = not state;
				toggles[child.Name](state);
				states[child.Name] = state;
			end
			button.MouseButton1Click:Connect(change);
			(default and change or blank)();
		elseif(class == "Slider") then
			local back = child:WaitForChild("SliderBack");
			local button = back:WaitForChild("Button");
			local progress = back:WaitForChild("Progress");
			local shadow = button:WaitForChild("Shadow");
			local extend = back:WaitForChild("Extender");
			local down = false;
			local connected;

			local disconnect = function()
				if(connected) then
					connected:Disconnect();
					connected = nil;
				end
			end			

			local step = 1;
			local percentage = 0;

			local snap = function(number,factor)
				return(factor == 0 and number or math.floor(number/factor+0.5)*factor);
			end

			button.MouseEnter:Connect(function()
				shadow.Visible = true;
			end)

			button.MouseLeave:Connect(function()
				if(not down) then
					shadow.Visible = false;
				end
			end)

			button.MouseButton1Down:Connect(function()
				shadow.Visible = true;
				down = true;
			end)

			uis.InputEnded:Connect(function(input)
				if(input.UserInputType == Enum.UserInputType.MouseButton1) then
					shadow.Visible = false;
					down = false;
					disconnect();
				end
			end)

			local handle = function(percent)
				sliders[child.Name](percent);
			end

			runService.Heartbeat:Connect(function()
				if(down) then
					local pos = snap((uis:GetMouseLocation().X-back.AbsolutePosition.X)/back.AbsoluteSize.X,0)
					local new = math.clamp(pos,0,1);
					extend.Size = UDim2.new(0,button.AbsoluteSize.X,1,0);
					if(percentage ~= new) then
						percentage = math.clamp(pos,0,1)
						local x = button.AbsoluteSize.X;
						button.Position = UDim2.new(percentage,x,button.Position.Y.Scale, button.Position.Y.Offset)
						tweenSize(progress,UDim2.new(percentage,0,1,0));
						handle(math.floor(percentage * 100));
					end
				end
			end)

			button.Position = UDim2.new(0,button.AbsoluteSize.X,0.5,0);
		elseif(class == "Box") then
			child:WaitForChild("Box").FocusLost:Connect(function(_,enterPressed)
				if(enterPressed) then
					boxes[child.Name](child.Box.Text);
				end
			end)
		end
	elseif(child:IsA("ImageButton") or child:IsA("TextButton")) then
		child.MouseButton1Click:Connect(function()
			if(localPlayer:GetAttribute("Sfx")) then
				local sound = Instance.new("Sound",game:GetService("SoundService"));
				sound.SoundId = "rbxassetid://421058925";
				--sound.TimePosition = 0.95;
				sound:Play();
				sound.Volume = 1;
				sound.Stopped:Connect(function()
					sound:Destroy();
				end)
			end
		end)
	end
end

for _,child in pairs(gui:GetDescendants()) do
	task.spawn(onChild,child);
end
gui.DescendantAdded:Connect(onChild);

gui:WaitForChild("Menu"):WaitForChild("Close").MouseButton1Click:Connect(function()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,true);
	gui.Menu:TweenPosition(UDim2.fromScale(0.5,-1.5),unpack(args));
end)

if(not shared.gui_library) then
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(shared.gui_library)
end

library = shared.gui_library;
table.insert(library.out,function()
	gui.Menu:TweenPosition(UDim2.fromScale(0.5,-1.5),unpack(args));
end)

local binds = {
	[1] = {
		keys = {Enum.KeyCode.LeftShift,Enum.KeyCode.U},
		callback = function()
			local opp = not states["UI"];
			states["UI"] = opp;
			toggles["UI"](opp);
		end,
	}
}

uis.InputBegan:Connect(function()
	local pressed =	uis:GetKeysPressed();
	for k,v in pairs(pressed) do
		pressed[k] = v.KeyCode;
	end
	for _,bind in pairs(binds) do
		local checks = 0;
		for i = 1,#bind["keys"] do
			if(table.find(pressed,bind["keys"][i])) then
				checks += 1;
			end
		end
		if(checks == #bind["keys"]) then
			bind.callback()
		end
	end
	game:GetService("RunService").Heartbeat:Wait()
	if(shared.freecam) then
		if(shared.freecam:get() ~= states["Freecam"]) then
			toggles["Freecam"](shared.freecam:get());
		end
	end
end)

workspace.DescendantAdded:Connect(function(child)
	if(child:IsA("BillboardGui")) then
		task.spawn(billboard,child);
	end
end)
for _,child in pairs(workspace:GetDescendants()) do
	if(child:IsA("BillboardGui")) then
		task.spawn(billboard,child);
	end
end

local canvas = gui.Menu.Canvas;
local pages = {
	["Camera"] = canvas:WaitForChild("Camera"),
	["Server"] = canvas:WaitForChild("Server"),
	["NewCode"] = canvas:WaitForChild("NewCode")
};

local back = true;
local navigation = canvas.Navigation:WaitForChild("Options");
local backfunctions = {};

for _,page in pairs(pages) do
	backfunctions[page.Name] = function()
		navigation.Parent:TweenPosition(UDim2.fromScale(0.5,0.967),unpack(args));
		page:TweenPosition(UDim2.new(1.5,0,0.967,0),unpack(args));
		back = true;
	end
	page:WaitForChild("Back").MouseButton1Click:Connect(backfunctions[page.Name])
end

-- codes:

local newCode = canvas:WaitForChild("NewCode");
local options = newCode:WaitForChild("Options");

local name = options:WaitForChild("CodeName"):WaitForChild("Box");
local expiresIn = options:WaitForChild("Expires"):WaitForChild("Box");
local amount = options:WaitForChild("Amount"):WaitForChild("Box");
local class = options:WaitForChild("Type");

local next1 = options:WaitForChild("Next");
local next2 = options:WaitForChild("Next2");
local done = options:WaitForChild("Submit");
local selected = "";

local resetDropdown = function()
	class:SetAttribute("Picked","")
	class.Label.Text = "Type";
	name.Text = "";
	amount.Text = "";
end

local setVisible = function(...)
	local total = {name.Parent,amount.Parent,class,next1,next2,done,expiresIn.Parent};
	local visible = {...};
	for k,v in pairs(total) do
		if(not table.find(visible,v)) then
			v.Visible = false;
		else
			v.Visible = true;
		end
	end
end

local opened = false;
local clicked = function()
	opened = not opened;
	class.Dropdown.Visible = opened;
	class.Icon.Image = (opened and class.Icon:GetAttribute("Close") or class.Icon:GetAttribute("Open"));
end
class:WaitForChild("Icon").MouseButton1Click:Connect(clicked)

local added = function(child)
	if(child:IsA("TextButton")) then
		child.MouseButton1Click:Connect(function()
			selected = child.Name;
			class.Label.Text = ("Type: %s"):format(child.Label.Text);
			clicked();
			if(selected:find("Boost")) then
				amount.Parent.Label.Text = "Length";
				amount.PlaceholderText = "Minutes";
			else
				amount.Parent.Label.Text = "Amount";
				amount.PlaceholderText = "Amount";
			end
			if(selected:find("Egg")) then
				next2.Visible = false;
				done.Visible = true;
			else
				next2.Visible = true;
				done.Visible = false;
			end
		end)
	end
end

local dropdownOptions = class:WaitForChild("Dropdown"):WaitForChild("Pad"):WaitForChild("Canvas");
for _,child in pairs(dropdownOptions:GetChildren()) do
	task.spawn(added,child);
end
dropdownOptions.ChildAdded:Connect(added);

next1.MouseButton1Click:Connect(function()
	setVisible(class);
end)

next2.MouseButton1Click:Connect(function()		
	setVisible(amount.Parent,done);
end)

done.MouseButton1Click:Connect(function()
	local amountOf = tonumber(amount.Text);
	local name = tostring(name.Text):sub(1,20);
	local expiresIn = tonumber(expiresIn.Text);
	local class = selected;
	backfunctions["NewCode"]()
	local format = {name,class,amountOf,expiresIn};
	local success,response = network:invokeServer("createCode",unpack(format));
	library:notify(response);
end)

-- nav:

local on = function(object)
	if(object:IsA("TextButton")) then
		object.MouseButton1Click:Connect(function()
			if(back) then
				setVisible(next1,name.Parent,expiresIn.Parent);
				resetDropdown()
				navigation.Parent:TweenPosition(UDim2.fromScale(-1.5,0.967),unpack(args));
				for pageName,page in pairs(pages) do
					page.Position = UDim2.new(1.5,0,0.967, 0);
					page.Visible = true;
					if(pageName == object.Name) then
						back = false;
						page:TweenPosition(UDim2.new(0.5,0,0.967,0),unpack(args));
					end
				end
			end
		end)
	end
end

navigation.ChildAdded:Connect(on);
for _,child in pairs(navigation:GetChildren()) do
	coroutine.wrap(on)(child);
end