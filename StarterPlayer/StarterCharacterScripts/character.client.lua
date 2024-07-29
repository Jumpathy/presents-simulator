-- variables:

local localPlayer = game:GetService("Players").LocalPlayer;
local has = localPlayer:GetAttribute("RunningEnabled");
local default,add = 16,0;
local default2,add2 = 50,0;
local controllerService = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("controllerService"))();

local character = script.Parent;
local humanoid = character:WaitForChild("Humanoid",math.huge);
local last;

localPlayer.AttributeChanged:Connect(function()
	has = localPlayer:GetAttribute("runningEnabled");
	add = localPlayer:GetAttribute("AddSpeed");
	default = localPlayer:GetAttribute("DefaultSpeed");
	default2 = localPlayer:GetAttribute("DefaultJump");
	add2 = localPlayer:GetAttribute("AddJump");
	humanoid.JumpPower = (default2 + add2);
end)

repeat
	if(default..add ~= last) then
		last = default..add;
		humanoid.WalkSpeed = (default + add);
	end
	game:GetService("RunService").Heartbeat:Wait();
until(has);

local new = function(icon)
	if(shared.runIcon ~= nil) then
		return shared.runIcon;
	else
		local run = icon.new():setImage(6034754445);
		shared.runIcon = run;
		return run;
	end
end

local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));
local topbar = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("topbar"));
local tweenService = game:GetService("TweenService");
local userInputService = game:GetService("UserInputService");

local tweenInfo = TweenInfo.new(0.25,Enum.EasingStyle.Quad);
local currentCamera = workspace.CurrentCamera;

local runIcon = new(topbar);
local isActive = runIcon:getToggleState() == "selected";

local validInputs = {
	[Enum.KeyCode.LeftShift] = true,
	[Enum.KeyCode.RightShift] = true
}

-- functions:

local tween = function(array)
	for _,data in pairs(array) do
		local object,properties = unpack(data);
		tweenService:Create(object,tweenInfo,properties):Play();
	end
end

local state = false;
local handle = function(isRunning)
	network:fireServer("runningState",isRunning);
	local ds = localPlayer:GetAttribute("DefaultSpeed") or 16;
	local add = localPlayer:GetAttribute("AddSpeed");
	state = isRunning;
	tween({
		{currentCamera,{
			["FieldOfView"] = (isRunning and 82 or 70)
		}},{humanoid,{
			["WalkSpeed"] = (isRunning and (ds + 36 + add) or (ds + add));
		}}
	});
end

-- input:

userInputService.InputBegan:Connect(function(input,gameProcessed)
	if(validInputs[input.KeyCode] and (not gameProcessed)) then
		runIcon:select();
	end
end)

userInputService.InputEnded:Connect(function(input)
	if(validInputs[input.KeyCode]) then
		runIcon:deselect();
	end
end)

runIcon.selected:Connect(function()
	handle(true);
end)

runIcon.deselected:Connect(function()
	handle(false);
end)


handle(isActive);
localPlayer.AttributeChanged:Connect(function()
	if(last ~= default..add) then
		last = default..add;
		handle(state);
	end
end)

if(last ~= default..add) then
	last = default..add;
	handle(state);
end

controllerService.Connected:Connect(function(controller)
	controller.TriggerButtonPressed:Connect(function(button,gameProcessed)
		if(button == Enum.KeyCode.ButtonL2) then
			local opposite = (state and "deselect" or "select");
			runIcon[opposite](runIcon);
		end
	end)
end)

controllerService:Start();