local func;
local last;
return function(color1,color2)
	if(func == nil) then
		func = script.Parent:WaitForChild("func"):Clone();
		script.Parent:WaitForChild("func"):Destroy();
	end
	if(last) then
		last:Destroy();
		last = nil;
	end
	local signal = Instance.new("BindableEvent");
	local main = func:Clone();
	last = main;
	main.Parent = script.Parent;
	main:SetAttribute("MainColor",color1);
	main:SetAttribute("Color",color2);
	coroutine.wrap(function()
		require(main.run)(signal);
	end)();
	return signal.Event;
end