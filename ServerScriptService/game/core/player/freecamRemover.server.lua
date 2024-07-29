local players = game:GetService("Players");
local heartbeat = game:GetService("RunService").Heartbeat;

local onPlayer = function(player)
	local playerGui = player.PlayerGui;
	if(playerGui:FindFirstChild("Freecam")) then
		playerGui.Freecam:Destroy();
	end
	playerGui.ChildAdded:Connect(function(gui)
		if(gui.Name == "Freecam") then
			heartbeat:Wait();
			gui:Destroy();
		end
	end)
end

players.PlayerAdded:Connect(onPlayer);
for _,player in pairs(players:GetPlayers()) do
	task.spawn(onPlayer,player);
end