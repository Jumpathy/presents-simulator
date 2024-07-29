return function(signal)
	local real = script.Parent:WaitForChild("Real");
	local open = script.Parent:WaitForChild("OpenableEgg");
	
	local tweenModel = function(model,len,CF)
		local event = Instance.new("BindableEvent");
		local CFrameValue = Instance.new("CFrameValue");
		CFrameValue.Value = model:GetPrimaryPartCFrame();

		CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			model:SetPrimaryPartCFrame(CFrameValue.Value);
		end)

		local tween = game:GetService("TweenService"):Create(CFrameValue,TweenInfo.new(len,Enum.EasingStyle.Linear),{Value = CF});
		tween:Play();

		tween.Completed:Connect(function()
			CFrameValue:Destroy();
			event:Fire();
		end)

		return event.Event;
	end
	
	local fired = false;
	
	local len = 0.38;
	local shake = function(egg)
		game:GetService("RunService").Heartbeat:Wait();
		local try = function(angle,length)
			tweenModel(egg,length/3,(egg:GetPrimaryPartCFrame()*CFrame.fromEulerAnglesXYZ(angle,0,0))):Wait();
			tweenModel(egg,length/3,(egg:GetPrimaryPartCFrame()*CFrame.fromEulerAnglesXYZ(-(angle*2),0,0))):Wait()
			tweenModel(egg,length/3,(egg:GetPrimaryPartCFrame()*CFrame.fromEulerAnglesXYZ(angle,0,0))):Wait();
		end
		for _,v in pairs(shared.controllers) do
			v:Vibrate({
				["Large"] = 0,
				["Small"] = 0.1
			},len*3)
		end
		for i = 1,3 do
			if(not fired) then
				fired = true;
				signal:Fire("shaking",len);
			end
			try((0.5),len);
		end
	end
	

	local set = function(attachment,color)
		local b = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(2/3,2/3,2/3)),ColorSequenceKeypoint.new(1,color)});
		local a = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,color)});
		attachment.a.Color = a;
		attachment.b.Color = b;
	end
	
	local co = script.Parent:GetAttribute("Color");
	local mc = script.Parent:GetAttribute("MainColor");
	set(open.FX.Attachment,co);
	
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(real.PrimaryPart)
	
	open:SetAttribute("Main",mc);
	open:SetAttribute("Color",co);
	real.PrimaryPart.Color = co;
	real.Main.Color = mc;
	
	local og = open.PrimaryPart.CFrame;
	open:SetPrimaryPartCFrame(og + Vector3.new(0,10,0));
	shake(real);
	real:Destroy();
	open:SetPrimaryPartCFrame(og);
	
	local module = require(open:WaitForChild("open"));
	module(signal);
end