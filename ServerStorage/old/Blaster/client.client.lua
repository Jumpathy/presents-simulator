local event = script.Parent:WaitForChild("server"):WaitForChild("function");
local localPlayer = game:GetService("Players").LocalPlayer;
local mouse = localPlayer:GetMouse();
local character = localPlayer.Character;
local userinputService = game:GetService("UserInputService");
local tweenService = game:GetService("TweenService");
local tool,equipped = script.Parent,false;

mouse.TargetFilter = character;

local click = function()
	if(mouse.Target) then
		if(mouse.Target:IsDescendantOf(workspace.gifts)) then
			event:InvokeServer("openGift",mouse.Target);
		end
	end
end

event.OnClientInvoke = function(action,...)
	local args = {...};
	if(action == "setSelection") then
		local selectedGift = args[1];
		for _,gift in pairs(workspace.gifts:GetChildren()) do
			gift.Selected.Position = gift.Bottom.Position - Vector3.new(0,gift.Bottom.Size.Y/2,0);
			tweenService:Create(
				gift.Selected.Image,
				TweenInfo.new(0.25),
				{Transparency = (selectedGift == gift and 0 or 1)}
			):Play();
		end
	end
end

userinputService.InputBegan:Connect(function(input)
	if(input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
		if(equipped and (not (localPlayer:GetAttribute("backpack") == localPlayer:GetAttribute("backpackSize")))) then
			click();
		end
	end
end)

tool.Equipped:Connect(function()
	equipped = true;
end)

tool.Unequipped:Connect(function()
	equipped = false;
end)