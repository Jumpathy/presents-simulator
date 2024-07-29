return function(tool)
	local event = tool:WaitForChild("server"):WaitForChild("function");
	local localPlayer = game:GetService("Players").LocalPlayer;
	local mouse = localPlayer:GetMouse();
	local character = localPlayer.Character;
	local userinputService = game:GetService("UserInputService");
	local tweenService = game:GetService("TweenService");
	local equipped = false;
	mouse.TargetFilter = character;

	local click = function(isFull)
		if(mouse.Target) then
			if(mouse.Target:IsDescendantOf(workspace.gifts)) then
				if(isFull and not (shared.backpackIsFull)) then
					shared.backpackfull()
					return
				end
				event:InvokeServer("openGift",mouse.Target);
			end
		end
	end
	
	local getY = function(gift)
		local area = workspace:WaitForChild("areas"):WaitForChild(gift:GetAttribute("Region"));
		local grass = area:WaitForChild(("S%sGrass"):format(area.Name:split("area")[2]));
		return grass.Position.Y + grass.Size.Y/2;
	end
	
	event.OnClientInvoke = function(action,...)
		local args = {...};
		if(action == "setSelection") then
			local selectedGift = args[1];
			for _,gift in pairs(workspace.gifts:GetChildren()) do
				pcall(function()
					local p = gift.Bottom.Position;
					gift.Selected.Position = Vector3.new(p.X,getY(gift),p.Z);
					tweenService:Create(
						gift.Selected.Image,
						TweenInfo.new(0.25),
						{Transparency = (selectedGift == gift and 0 or 1)}
					):Play();
				end)
			end
		end
	end

	userinputService.InputBegan:Connect(function(input)
		if(input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.ButtonR2 or input.KeyCode == Enum.KeyCode.ButtonR1) then
			if(equipped) then
				local isFull = (localPlayer:GetAttribute("backpack") == localPlayer:GetAttribute("backpackSize"))
				click(isFull);
			end
		end
	end)

	tool.Equipped:Connect(function()
		equipped = true;
	end)

	tool.Unequipped:Connect(function()
		equipped = false;
	end)
end