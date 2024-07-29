local tween = game:GetService("TweenService")

tween:Create(script.Parent,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.In,-1,true),{
	["Position"] = UDim2.new(0.5,70,1,-5)
}):Play()