local moduleNames,modules = {
	"modal","notification","timeModal"
},{};

local signal = require(script:WaitForChild("signal"));
local format = require(script:WaitForChild("format"));
local integer = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("integer"));
local util = require(script:WaitForChild("util"));
local starterGui = game:GetService("StarterGui");
local userInputService = game:GetService("UserInputService");
local players = game:GetService("Players");
local guis = game:GetService("GuiService");
local last;

local localPlayer = players.LocalPlayer;
local controls = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();

local setControlsEnabled = function(state)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,state);
	--guis.TouchControlsEnabled = state;
	--controls[state and "Enable" or "Disable"](controls);
end

local container = script:WaitForChild("modules");
local ui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("UI",math.huge);
local env = {};

for i = 1,#moduleNames do
	local name = moduleNames[i];
	modules[name] = require(
		container:WaitForChild(name)
	)(ui,signal,env)
end

local library = {};
shared.gui_library = library;

function library:ce(...)
	setControlsEnabled(...);
end

function library:timeModal(title,callback)
	callback = callback or function() end
	setControlsEnabled(false);
	local key = library:newKey("modalLol");
	for _,call in pairs(library.out) do
		coroutine.wrap(call)();
	end
	modules.timeModal.new(title).clicked:Connect(function(state)
		if(last == key) then
			setControlsEnabled(true);
		end
		callback(state);
	end);
end

function library:modal(text,callback,options)
	callback = callback or function() end
	setControlsEnabled(false);
	local key = library:newKey("modalPrompt");
	for _,call in pairs(library.out) do
		coroutine.wrap(call)();
	end
	modules.modal.new(text,options).clicked:Connect(function(bool)
		if(last == key) then
			setControlsEnabled(true);
		end
		callback(bool);
	end);
end

function library:moveOut()
	for key,call in pairs(library.out) do
		coroutine.wrap(call)();
	end
end

function library.doFormat(text,mark)
	local mark = integer.new(mark);
	local current = integer.new(text);
	if(current >= mark) then
		return format.FormatCompact(text);
	else
		return format.FormatStandard(text);
	end
end

function library:format(text)
	return format.FormatCompact(text);
end

function library:notify(text,callback)
	callback = callback or function() end
	setControlsEnabled(false);
	local key = library:newKey("notificationPrompt");
	for _,call in pairs(library.out) do
		coroutine.wrap(call)();
	end
	modules.notification.new(text).clicked:Connect(function(bool)
		if(last == key) then
			setControlsEnabled(true);
		end
		callback(bool);
	end);
end

local current = 0;
function library:newKey(from)
	current += 1;
	last = current;
	return current;
end

function library:controls(state)
	setControlsEnabled(state);
end

function library:setShadowedText(object,text)
	object.Text = text;
	object:FindFirstChildOfClass("TextLabel").Text = text;
end

function library.clickNoise()
	local sound = Instance.new("Sound",game:GetService("SoundService"));
	sound.SoundId = "rbxassetid://421058925";
	--sound.TimePosition = 0.95;
	sound:Play();
	sound.Volume = 1;
	sound.Stopped:Connect(function()
		sound:Destroy();
	end)
end

function library:setRawControls(state)
	controls[state and "Enable" or "Disable"](controls);
end

shared.click_noise = library.clickNoise;

function library.childOfClassLoaded(parent,classes,callback)
	local check = function(object)
		for _,class in pairs(classes) do
			if(object:IsA(class)) then
				return true;
			end
		end
	end
	for _,object in pairs(parent:GetChildren()) do
		if(check(object)) then
			coroutine.wrap(callback)(object);
		end
	end
	return parent.ChildAdded:Connect(function(object)
		if(check(object)) then
			callback(object)
		end
	end)
end

function library.descendantOfClassLoaded(parent,classes,callback)
	local check = function(object)
		for _,class in pairs(classes) do
			if(object:IsA(class)) then
				return true;
			end
		end
	end
	for _,object in pairs(parent:GetDescendants()) do
		if(check(object)) then
			coroutine.wrap(callback)(object);
		end
	end
	return parent.DescendantAdded:Connect(function(descendant)
		if(check(descendant)) then
			callback(descendant)
		end
	end)
end

function library:formatTime(seconds)
	return ("%02i:%02i:%02i"):format(seconds/60^2, seconds/60%60, seconds%60)
end

function library:formatTimeOther(seconds)
	return ("%02i:%02i:%02i"):format(seconds/60^2, seconds/60%60, seconds%60)
end

function library:notificationCount(button,new)
	if(new > 8) then
		button.Notifications.Amount.TextConstraint.MaxTextSize = 13;
	end
	button.Notifications.Amount.Text = (new < 9 and new or "9+");
	button.Notifications.Visible = (new > 0);
end

library.util = util;
library.gui = ui;
library.out = {};

local pf = "Desktop";
local uis = game:GetService("UserInputService");
local guis = game:GetService("GuiService");

if(uis.TouchEnabled) then 
	if(uis.GyroscopeEnabled or uis.AccelerometerEnabled) then  
		pf = "Mobile";
	end
	if(guis:IsTenFootInterface()) then 
		pf = "Console";
	end
end

library.platform = pf:lower();

function library:tween(object,properties,length)
	local info = TweenInfo.new(length or 0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out);
	local tween = game:GetService("TweenService"):Create(object,info,properties);
	tween:Play();
	return tween;
end

function library:autoScrollingFrameSize(scroller)
	local changed = function(contentSize)
		scroller.CanvasSize = UDim2.fromOffset(0,contentSize.Y);
	end
	local layout = scroller:WaitForChild("Layout");
	changed(layout.AbsoluteContentSize);
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		changed(layout.AbsoluteContentSize);
	end);
end

function library:scrollingFrameBar(scroller,width,ignore)
	local relativeFraction,depth = width/985,0;
	local expireLimit,last,inFrame,expired = 3,nil,false,false;
	local mouse = localPlayer:GetMouse();

	local expire = function()
		expired = true;
		last = tick();
		library:tween(scroller,{
			["ScrollBarImageTransparency"] = 1,
			["ScrollBarThickness"] = 0
		});
	end

	local moveIn = function()
		expired = false;
		library:tween(scroller,{
			["ScrollBarImageTransparency"] = 0,
			["ScrollBarThickness"] = (ignore and width or depth)
		});
	end

	local renewInput = function()
		local key = tick();
		last = key;
		moveIn();
		util.wait(expireLimit);
		if(last == key) then
			expire();
		end
	end

	util.ResolutionChanged:Connect(function(x,y)
		depth = x * relativeFraction;
		if(inFrame and (not expired)) then
			renewInput();
		end
	end)

	scroller.MouseLeave:Connect(function()
		inFrame = false;
		expire();
	end);

	scroller.MouseEnter:Connect(function()
		inFrame = true;
		renewInput();
	end);

	mouse.Move:Connect(function()
		if(inFrame and (expired)) then
			renewInput();
		end
	end)

	scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(renewInput);
end

function library.whenFrameVisibilityChanges(scroller,object,callback)
	-- gui1 maingui, gui2 is object trying to see if visible
	local last;
	local function inBounds(gui1,gui2) 
		local gui1_topLeft = gui1.AbsolutePosition;
		local gui1_bottomRight = gui1_topLeft + gui1.AbsoluteSize;
		local gui2_topLeft = gui2.AbsolutePosition;
		local gui2_bottomRight = gui2_topLeft + gui2.AbsoluteSize;
		return ((gui1_topLeft.x < gui2_bottomRight.x and gui1_bottomRight.x > gui2_topLeft.x) and (gui1_topLeft.y < gui2_bottomRight.y and gui1_bottomRight.y > gui2_topLeft.y));
	end
	
	local disconnect;

	local render = function()
		if(object:GetFullName() == object.Name) then
			if(disconnect) then
				disconnect();
			end
			return;
		end
		local state = (inBounds(scroller,object));
		if(state ~= last) then
			last = state;
			callback(state);
		end
	end
	local c1 = scroller.Changed:Connect(render);
	local c2 = object.Changed:Connect(render);
	disconnect = function()
		c1:Disconnect();
		c2:Disconnect();
	end
	render();
end

function library:dailyRewardObjectState(object,state)
	local colors = {
		text = {
			[true] = Color3.fromRGB(255,255,255),
			[false] = Color3.fromRGB(222,222,222)
		},bg = {
			[true] = Color3.fromRGB(255,255,255),
			[false] = Color3.fromRGB(163,163,163),
		},image = {
			[true] = Color3.fromRGB(255,255,255),
			[false] = Color3.fromRGB(193,193,193)
		}
	}
	object.BackgroundColor3 = colors.bg[state];
	object.Title.TextColor3 = colors.text[state];
	object.Reward.TextColor3 = colors.text[state];
	object.Icon.ImageColor3 = colors.image[state];
end

function library.mouseState(object,callback)
	object.MouseEnter:Connect(function()
		callback(true);
	end)
	object.MouseLeave:Connect(function()
		callback(false);
	end)
end

shared.lib = library;
library.sound = require(game:GetService("ReplicatedStorage"):WaitForChild("sounds"));
library.integer = integer;

return library;