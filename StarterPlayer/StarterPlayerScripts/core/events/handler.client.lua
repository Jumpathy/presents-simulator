local modules = script.Parent:WaitForChild("modules");

local run = function(module)
	local func = require(module);
	local flag = game:GetService("ReplicatedStorage"):WaitForChild("flags"):WaitForChild(module.Name,math.huge);
	local changed = function(just)
		func(flag.Value,(just == true));
	end
	flag:GetPropertyChangedSignal("Value"):Connect(changed);
	changed();
	flag.AttributeChanged:Connect(function()
		game:GetService("RunService").Heartbeat:Wait();
		changed(flag:GetAttribute("JustHappened"));
	end)
end
modules.ChildAdded:Connect(run);
for _,child in pairs(modules:GetChildren()) do
	coroutine.wrap(run)(child);
end