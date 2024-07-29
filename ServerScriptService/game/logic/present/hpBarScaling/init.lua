local scale = script:WaitForChild("scale");
scale.Parent = game:GetService("ReplicatedStorage"):WaitForChild("logic");

return function(present)
	local network = require(game.ReplicatedStorage:WaitForChild("shared"):WaitForChild("network"));

	local logic = function(player)
		local get = function()
			return (player:GetAttribute("ClientLoaded"));
		end
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(get() == true);
		if(present:GetFullName() ~= present.Name) then
			pcall(function()
				network:fireClient("scaleGui",player,scale,present.Health);
			end)
		end
	end

	for _,player in pairs(game:GetService("Players"):GetPlayers()) do
		coroutine.wrap(logic)(player);
	end

	game:GetService("Players").PlayerAdded:Connect(logic);
end