local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local holder = network:invokeServer("getObjects");
local contentProvider = game:GetService("ContentProvider");
local startGui = game:GetService("StarterGui");
local localPlayer = game:GetService("Players").LocalPlayer;
local playerGui = localPlayer:WaitForChild("PlayerGui");
local gradient = playerGui:WaitForChild("Loading"):WaitForChild("Loading"):WaitForChild("Icon"):WaitForChild("Gradient");
local label = gradient.Parent.Parent:WaitForChild("Label");
local skip = label.Parent:WaitForChild("Skip");
label.Parent.Parent.Enabled = true;

local info = TweenInfo.new(0.16,Enum.EasingStyle.Quad);
local ts = game:GetService("TweenService");

local total,num,loaded = 0,0,false;
script.Parent:RemoveDefaultLoadingScreen();
startGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,false);

ts:Create(label.Parent:WaitForChild("Burst"),TweenInfo.new(
	6, -- The time the tween takes to complete
	Enum.EasingStyle.Linear, -- The tween style in this case it is Linear
	Enum.EasingDirection.Out, -- EasingDirection
	-1, -- How many times you want the tween to repeat. If you make it less than 0 it will repeat forever.
	false, -- Reverse?
	0 -- Delay
),{Rotation = 360}):Play();

coroutine.wrap(function()
	local controls = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();
	controls:Disable();
	game:GetService("GuiService").TouchControlsEnabled = false;
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(loaded);
	controls:Enable();
	game:GetService("GuiService").TouchControlsEnabled = true;
end)();

local setState = function(new)
	label.Text = new;
end

local floor = function(value)
	value *= 100;
	value = math.floor(value);
	value = value / 100;
	return value;
end

local handle = function(percent)
	label.Percent.Text = ("(%s%% loaded)"):format(floor(percent*100));
	ts:Create(gradient,info,{
		Offset = Vector2.new(0,-percent);
	}):Play();
end

for _,objects in pairs(holder) do
	num += #objects;
end

local controllerService = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("controllerService"))();

local doSkip = false;
skip.Visible = true;
skip.MouseButton1Click:Connect(function()
	doSkip = true;
end)

controllerService.Connected:Connect(function(controller)
	skip.XboxB.Visible = true;
	controller.PrimaryButtonPressed:Connect(function(button)
		if(button == Enum.KeyCode.ButtonB) then
			doSkip = true;
		end
	end)
end)

controllerService.Disconnected:Connect(function()
	skip.XboxB.Visible = false;
end)

controllerService:Start();

setState("Loading textures...")
local preload = require(game:GetService("ReplicatedStorage"):WaitForChild("preload"));
local later = {};
local loadLst = {};
for key,tex in pairs(preload) do
	loadLst[tex] = false;
end
for i = 1,#preload do
	later[i] = preload[i];
end
for key,tex in pairs(preload) do
	table.remove(later,table.find(later,tex));
	loadLst[tex] = true;
	contentProvider:PreloadAsync({tex});
	handle((key/#preload));
	if(doSkip) then
		break;
	end
end

setState("Loading player data...");
repeat
	game:GetService("RunService").Heartbeat:Wait();
until(localPlayer:GetAttribute("loaded"));

--startGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true);
loaded = true;
shared.gameLoaded = true;

label.Parent:TweenPosition(UDim2.new(0,0,-1.5,0,Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true,function(done)
	label.Parent.Parent:Destroy();
end))

--[[
label.Parent.Parent.Detail:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,0.45,true,function()
	
end)

local start = function(mode)
	if(mode == "Low") then
		local lbl = label.Parent.Parent.Detail.Percent;
		lbl.Visible = true;
		for key,tex in pairs(later) do
			contentProvider:PreloadAsync({tex});
			local percent = math.floor(((key/#preload))*100);
			lbl.Text = (tostring(percent) .. "%");
		end
		localPlayer:WaitForChild("PlayerScripts"):WaitForChild("FX"):WaitForChild("lowDetail").Disabled = false;
	end
	label.Parent.Parent.Detail:TweenPosition(UDim2.new(0,0,-1,0),Enum.EasingDirection.In,Enum.EasingStyle.Quad,0.45,true,function()
		startGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,true);
		loaded = true;
		label.Parent.Parent:Destroy();
	end)
end

local options = label.Parent.Parent.Detail.Options;
options.High.MouseButton1Click:Connect(function()
	start("High");
end)
options.Low.MouseButton1Click:Connect(function()
	start("Low");
end)
]]