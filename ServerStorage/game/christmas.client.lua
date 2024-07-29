local proximity = workspace:WaitForChild("NPCs"):WaitForChild("Santa Claus"):WaitForChild("HumanoidRootPart"):WaitForChild("ProximityPrompt")
local localPlayer = game:GetService("Players").LocalPlayer;
local done = false;

local change = function()
	if(localPlayer:GetAttribute("rudolph") and not done) then
		done = true
		proximity.Parent.Parent:WaitForChild("Head"):WaitForChild("ChatBubble"):WaitForChild("Bubble"):WaitForChild("Label").Text = "Enjoy the finest pet I have to offer!";
		proximity:Destroy();
	end
end

localPlayer.AttributeChanged:Connect(change);
change()