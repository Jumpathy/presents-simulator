local egg = script.Parent;
local top,bottom = egg:WaitForChild("Top"),egg:WaitForChild("Bottom");
local color = egg:GetAttribute("Color");

top:WaitForChild("color").Color = color;
bottom:WaitForChild("color").Color = color;

return function()
	local enableAttachments = function()
		local emitters = egg.FX.Attachment;
		for _,emitter in pairs(emitters:GetChildren()) do
			emitter:Emit(1);
		end
	end
	
	local tweenModel = function(model,len,CF)
		local CFrameValue = Instance.new("CFrameValue");
		CFrameValue.Value = model:GetPrimaryPartCFrame();

		CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			model:SetPrimaryPartCFrame(CFrameValue.Value);
		end)

		local tween = game:GetService("TweenService"):Create(CFrameValue,TweenInfo.new(len),{Value = CF});
		tween:Play();

		tween.Completed:Connect(function()
			CFrameValue:Destroy();
		end)
	end
	
	tweenModel(top,1,top.PrimaryPart.CFrame + Vector3.new(0,3/1.85,0));
	enableAttachments();
end