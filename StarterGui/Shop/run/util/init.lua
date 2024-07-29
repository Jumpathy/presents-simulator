local util = {};
local uis = game:GetService("UserInputService");
local guis = game:GetService("GuiService");
local pf = "Desktop";
local localPlayer = game:GetService("Players").LocalPlayer;
local format = require(script:WaitForChild("format"));

local wrapper = {};

wrapper.Connect = function(self,callback)
	local link = function()
		game:GetService("RunService").Heartbeat:Wait();
		coroutine.wrap(callback)(
			workspace.CurrentCamera.ViewportSize.X,
			workspace.CurrentCamera.ViewportSize.Y
		);
	end
	
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(link);
	coroutine.wrap(link)();
end

util.ResolutionChanged = wrapper;

if(uis.TouchEnabled) then 
	if(uis.GyroscopeEnabled or uis.AccelerometerEnabled) then  
		pf = "Mobile";
	end
else
	if(guis:IsTenFootInterface()) then 
		pf = "Console";
	end
end

util.Platform = pf;

function util.loaded(callback)
	coroutine.wrap(function()
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until localPlayer:GetAttribute("loaded")
		callback();
	end)();
end

util.attributeChanged = function(attribute)
	local bind = {};
	
	bind.Connect = function(self,callback)
		coroutine.wrap(callback)(localPlayer:GetAttribute(attribute));
		localPlayer.AttributeChanged:Connect(function(name)
			if(name == attribute) then
				callback();
			end
		end)
	end
	
	return bind;
end

util.leaderstatChanged = function(statName)
	local bind = {};
	local stat = localPlayer:WaitForChild("leaderstats"):WaitForChild(statName);

	bind.Connect = function(self,callback)
		coroutine.wrap(callback)(stat.Value);
		stat:GetPropertyChangedSignal("Value"):Connect(function()
			callback(stat.Value);
		end)
	end

	return bind;
end

util.formatNumber = function(number)
	return format.FormatCompact(number);
end

util.formatNumberStandard = function(number)
	return format.FormatStandard(number);
end

util.wait = require(script:WaitForChild("betterWait"));

return util;