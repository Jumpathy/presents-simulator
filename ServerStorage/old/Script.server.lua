local apply = function(present,color)
	for _,child in pairs(present:GetChildren()) do
		if(child.Name == "Crystal" or child.Name == "Extra") then
			child.Inside.Color = color;
			child.Outside.Color = color;
		end
	end
end

apply(game.Selection:Get()[1],Color3.fromRGB(255, 85, 255))