local debounces = {};
local players = game:GetService("Players");

script.Parent.Touched:Connect(function(hit)
	if(hit.Parent:FindFirstChildOfClass("Humanoid")) then
		if(not debounces[hit.Parent] or (tick() >= debounces[hit.Parent])) then
			local char = hit.Parent;
			local player = players:GetPlayerFromCharacter(char);
			if(player) then
				if(player:GetAttribute("Area5")) then
					debounces[char] = tick() + 1/2;
					shared.give_vulcan(player);
				end
			end
		end
	end
end)