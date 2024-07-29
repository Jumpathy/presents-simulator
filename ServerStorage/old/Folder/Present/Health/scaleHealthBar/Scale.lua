local scale = {};
scale.gui = script.Parent.Parent;
scale.healthBar = script.Parent.Parent:WaitForChild("Status"):WaitForChild("Health");
scale.label = script.Parent.Parent:WaitForChild("Label");

scale.health = {
	script.Parent.Parent.Parent:WaitForChild("Values"):WaitForChild("Health"),
	script.Parent.Parent.Parent:WaitForChild("Values"):WaitForChild("MaxHealth"),
}

scale.getPercent = function()
	return(scale.health[1].Value / scale.health[2].Value);
end

scale.getText = function()
	return(scale.health[1].Value .. " / " .. scale.health[2].Value);
end

scale.scaling = {
	{
		scale.gui:WaitForChild("Status"):WaitForChild("Stroke"),
		"Thickness",
		function()
			return scale.gui.Status.AbsoluteSize.X * (20 / 417);
		end,
	}
}

scale["function"] = function()
	local funcs = {};
	
	function funcs.scale1()
		for _,element in pairs(scale.scaling) do
			element[1][element[2]] = element[3]();
		end
	end
	
	function funcs.scale2()
		scale.label.Text = scale.getText();
		scale.healthBar:TweenSize(UDim2.new(scale.getPercent(),0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true);
	end
	
	scale.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(funcs.scale1);
	scale.health[1]:GetPropertyChangedSignal("Value"):Connect(funcs.scale2);
	for _,func in pairs(funcs) do
		func();
	end
end

return scale;