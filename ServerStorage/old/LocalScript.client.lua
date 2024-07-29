local color = function(reward,color)
	for _,descendant in pairs(reward:GetDescendants()) do
		if(descendant:GetAttribute("DoColor")) then
			local properties = {"Color","ImageColor3","BackgroundColor3"};
			for _,property in pairs(properties) do
				pcall(function()
					descendant[property] = color;
				end)
			end
		end
	end
end

color(game.Selection:Get()[1],Color3.fromRGB(140, 73, 255))