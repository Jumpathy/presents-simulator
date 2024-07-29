local network = require(game.ReplicatedStorage:WaitForChild("shared"):WaitForChild("network"));

local logic = function(player)
	local get = function()
		return (player:GetAttribute("ClientLoaded"));
	end
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(get() == true);
	network:fireClient("scaleGui",player,script:WaitForChild("Scale"));
end

for _,player in pairs(game:GetService("Players"):GetPlayers()) do
	coroutine.wrap(logic)(player);
end

game:GetService("Players").PlayerAdded:Connect(logic);