-- Author: @Jumpathy
-- Description: Setting up chat config and allowing rainbow + image tags

local chatService = game:GetService("Chat");
local forked = script:WaitForChild("DefaultChatMessage");

chatService:RegisterChatCallback(Enum.ChatCallbackType.OnCreatingChatWindow,function()
	local config = {};
	for configName,value in pairs(script:GetAttributes()) do
		config[configName] = value;
	end
	return config;
end)

chatService.DescendantAdded:Connect(function(item)
	if(item.Name == "DefaultChatMessage" and item ~= forked) then
		forked.Parent = item.Parent;
		item.Name = game:GetService("HttpService"):GenerateGUID();
		game:GetService("RunService").Heartbeat:Wait(); -- if you destroy it as soon as it's added, it'll put a warning in the console and I don't like anything to be in the console LOL
		item:Destroy();
	end
end)