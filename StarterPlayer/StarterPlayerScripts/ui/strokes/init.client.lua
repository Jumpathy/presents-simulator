local localPlayer = game:GetService("Players").LocalPlayer;
local playerGui = localPlayer:WaitForChild("PlayerGui");
local ui = playerGui:WaitForChild("UI");
local strokeScale = require(script:WaitForChild("strokeScale"));

local wrap = function(child)
	if(child:IsA("UIStroke")) then
		strokeScale:scaleGuiObject(child,child.Thickness,978,child.Thickness);
	end
end

for _,descendant in pairs(ui:GetDescendants()) do
	coroutine.wrap(wrap)(descendant);
end
ui.DescendantAdded:Connect(wrap);