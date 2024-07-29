return function(ui,signal,env)
	local notification = {};
	local len = 1/4;
	local tArgs = {Enum.EasingDirection.Out,Enum.EasingStyle.Quad,len,true}
	local service = game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("controllerService");
	local controllerService = require(service)();
	local on = signal.new();
	
	local canJump = true;
	local controls = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();
	
	controllerService.Connected:Connect(function(controller)
		local temp = ui.Template.Notification;
		temp.Okay.XboxA.Visible = true;
		controller.PrimaryButtonPressed:Connect(function(...)
			on:Fire(...);
		end)
	end)
	
	controllerService.Disconnected:Connect(function()
		local temp = ui.Template.Notification;
		temp.Okay.XboxA.Visible = false;
	end)
	
	function notification.new(prompt)
		local ret = {};
		local connections = {};
		
		local interface = ui.Template.Notification:Clone();
		interface.Parent = ui;
		interface.Position = UDim2.fromScale(0.5,-1);
		interface.Canvas.Label.Text = prompt;
		interface:TweenPosition(UDim2.fromScale(0.5,0.5),unpack(tArgs));
		interface.Visible = true;
		
		if(env.last) then
			env.last:out();
			if(not env.last.called) then
				env.last.clicked:Fire(false);
			end
		end
		
		local clicked = function(state)
			ret:out();
			if(ret.clicked) then
				pcall(function()
					ret.clicked:Fire(state);
				end)
				ret.called = true;
			end
		end
		
		local options = {[interface.Okay] = false,[interface.Close] = false};
		for button,state in pairs(options) do
			table.insert(connections,button.MouseButton1Click:Connect(function()
				clicked(state);
			end))
		end
		
		local signal3 = on:Connect(function(button)
			if(button == Enum.KeyCode.ButtonB) then
				controls:Enable();
				clicked(false);
			elseif(button == Enum.KeyCode.ButtonA) then
				game:GetService("RunService").Heartbeat:Wait();
				controls:Enable();
				clicked(true);
			end
		end)

		local signal2 = controllerService.Connected:Connect(function()
			local temp = interface;
			temp.Okay.XboxA.Visible = true;
		end)

		local signal1 = controllerService.Disconnected:Connect(function()
			local temp = interface;
			temp.Okay.XboxA.Visible = false;
		end)
		controllerService:Start();

		function ret:disconnect()
			for _,connection in pairs(connections) do
				connection:Disconnect();
			end
			signal1:Disconnect();
			signal2:Disconnect();
			signal3:Disconnect();
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

	return notification;
end