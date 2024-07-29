local loaded = Instance.new("BindableEvent");
local localPlayer = game:GetService("Players").LocalPlayer;
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local attribute = "loaded";
local module = script:WaitForChild("init");

local init = function()
	require(module)(unpack({network:invokeServer("tutorial","get")}));
end

if(localPlayer:GetAttribute("loaded")) then
	init();
else
	local signal;
	signal = localPlayer.AttributeChanged:Connect(function()
		if(localPlayer:GetAttribute("loaded")) then
			signal:Disconnect();
			loaded:Fire();
		end
	end)
	loaded.Event:Wait();
	init();
end