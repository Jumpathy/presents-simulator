local egg = script.Parent;
local top,bottom = egg:WaitForChild("Top"),egg:WaitForChild("Bottom");
local color = egg:GetAttribute("Color");
local mc = egg:GetAttribute("Main");

top:WaitForChild("color").Color = color;
bottom:WaitForChild("color").Color = color;

local tweenModel = function(model,len,CF)
	local event = Instance.new("BindableEvent");
	local CFrameValue = Instance.new("CFrameValue");
	CFrameValue.Value = model:GetPrimaryPartCFrame();

	CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
		model:SetPrimaryPartCFrame(CFrameValue.Value);
	end)

	local tween = game:GetService("TweenService"):Create(CFrameValue,TweenInfo.new(len),{Value = CF});
	tween:Play();

	tween.Completed:Connect(function()
		CFrameValue:Destroy();
		event:Fire();
	end)
	
	return event.Event;
end

return function(signal)
	--[[
		local try = function(angle,length)
		tweenModel(egg,length/3,(egg:GetPrimaryPartCFrame()*CFrame.fromEulerAnglesXYZ(angle,0,0))):Wait();
		tweenModel(egg,length/3,(egg:GetPrimaryPartCFrame()*CFrame.fromEulerAnglesXYZ(-(angle*2),0,0))):Wait()
		tweenModel(egg,length/3,(egg:GetPrimaryPartCFrame()*CFrame.fromEulerAnglesXYZ(angle,0,0))):Wait();
	end
	for i = 1,3 do
		try((0.5),0.55);
	end
	
	]]
	local enableAttachments = function()
		local emitters = egg.FX.Attachment;
		for _,emitter in pairs(emitters:GetChildren()) do
			emitter:Emit(1);
			emitter.Enabled = true;
		end
	end
	
	top.color.Color = color;
	bottom.color.Color = color;
	
	top.egg.Color = mc;
	bottom.egg.Color = mc;
	tweenModel(top,1,top.PrimaryPart.CFrame + Vector3.new(0,3/1.85,0));
	enableAttachments();
	
	for _,v in pairs(shared.controllers) do
		v:Vibrate({
			["Large"] = 0.5,
			["Small"] = 0.325
		},0.65)
	end
	
	signal:Fire("opening");
end