return function(ui,signal,env)
	local modal = {};
	local len = 1/4;
	local tArgs = {Enum.EasingDirection.Out,Enum.EasingStyle.Quad,len,true}

	function modal.new(title)
		local ret = {};
		local connections = {};

		local interface = ui.Template.TimeModal:Clone();
		interface.Parent = ui;
		interface.Position = UDim2.fromScale(0.5,-1);
		interface:TweenPosition(UDim2.fromScale(0.5,0.5),unpack(tArgs));
		interface.Visible = true;
		interface.DescriptionHolder.Description.Text = title;
		interface.DescriptionHolder.Description.Shadow.Text = title;

		if(env.last) then
			env.last:out();
			if(not env.last.called) then
				env.last.clicked:Fire(false);
			end
		end
		
		local options = {};
		local dict = {
			[1] = 5,
			[2] = 10,
			[3] = 20,
			[4] = 30,
			[5] = 45,
			[6] = 60
		};
		
		for i = 1,6 do
			options[interface.Options:WaitForChild(tostring(i))] = dict[i];
		end
		
		options[interface.Close] = false;
		for button,name in pairs(options) do
			table.insert(connections,button.MouseButton1Click:Connect(function()
				ret:out();
				ret.clicked:Fire(name);
				ret.called = true;
			end))
		end

		function ret:disconnect()
			for _,connection in pairs(connections) do
				connection:Disconnect();
			end
		end

		function ret:out()
			ret:disconnect();
			interface:TweenPosition(UDim2.fromScale(0.5,1.5),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,len,true,function()
				interface:Destroy();
				for key,_ in pairs(ret) do
					ret[key] = nil;
				end
				if(env.last == ret) then
					env.last = nil;
				end
			end)
		end

		ret.clicked = signal.new();

		env.last = ret;
		return ret;
	end

	return modal;
end