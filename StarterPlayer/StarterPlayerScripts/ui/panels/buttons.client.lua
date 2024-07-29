local players = game:GetService("Players")
local localPlayer = players.LocalPlayer;
local playerGui = localPlayer:WaitForChild("PlayerGui");
local ui = playerGui:WaitForChild("UI",math.huge)
local args = {Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.4,true}
local attributes = {
	["Youtuber"] = ui:WaitForChild("Buttons"):WaitForChild("Youtuber"),
	["AdminPanel"] = ui:WaitForChild("Buttons"):WaitForChild("Admin"),
}

for name,value in pairs(localPlayer:GetAttributes()) do
	if(attributes[name]) then
		attributes[name].Visible = value == true;
	end
end

local toggle = function(name)
	if(name == "Youtuber") then
		shared.gui_library:moveOut();
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Backpack,false);
		playerGui.Youtuber.Menu:TweenPosition(UDim2.fromScale(0.5,0.5),unpack(args));
	end
end

for name,button in pairs(attributes) do
	localPlayer:GetAttributeChangedSignal(name):Connect(function()
		button.Visible = localPlayer:GetAttribute(name) == true;
	end)
	button:WaitForChild("Button").MouseButton1Click:Connect(function()
		toggle(button.Name);
	end)
end