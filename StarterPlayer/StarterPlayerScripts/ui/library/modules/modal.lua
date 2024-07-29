return function(ui,signal,env)
	local modal = {};
	local len = 1/4;
	local tArgs = {Enum.EasingDirection.Out,Enum.EasingStyle.Quad,len,true}
	local service = game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("controllerService");
	local controllerService = require(service)();
	local on = signal.new();
	local canJump = true;
	local controls = require(game:GetService("Players").LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();
		
	game:GetService("UserInputService").JumpRequest:Connect(function()
		if(not canJump) then
			local character = game:GetService("Players").LocalPlayer.Character;
			character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		end
	end)
	
	controllerService.Connected:Connect(function(controller)
		local temp = ui.Template.Modal;
		temp.Options.No.Label.TextXAlignment = Enum.TextXAlignment.Left;
		temp.Options.No.XboxB.Visible = true;
		temp.Options.Yes.Label.TextXAlignment = Enum.TextXAlignment.Left;
		temp.Options.Yes.XboxA.Visible = true;
		controller.PrimaryButtonPressed:Connect(function(...)
			on:Fire(...);
		end)
	end)

	controllerService.Disconnected:Connect(function()
		local temp = ui.Template.Modal;
		temp.Options.No.Label.TextXAlignment = Enum.TextXAlignment.Center;
		temp.Options.No.XboxB.Visible = false;
		temp.Options.Yes.Label.TextXAlignment = Enum.TextXAlignment.Center;
		temp.Options.Yes.XboxA.Visible = false;
	end)

	controllerService:Start();
	
	function modal.new(prompt,options)
		local ret = {};
		local connections = {};

		local interface = ui.Template.Modal:Clone();
		interface.Parent = ui;
		interface.Position = UDim2.fromScale(0.5,-1);
		interface.Canvas.Label.Text = prompt;
		interface:TweenPosition(UDim2.fromScale(0.5,0.5),unpack(tArgs));
		interface.Visible = true;
		
		if(options) then
			local a = interface.Options.No.Label;
			local b = interface.Options.Yes.Label;
			a.Text = options[1];
			b.Text = options[2];
		end
		
		local clicked = function(state)
			ret:out();
			ret.clicked:Fire(state);
			ret.called = true;
			coroutine.wrap(function()
				game:GetService("RunService").Heartbeat:Wait();
				canJump = true;
			end)();
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
			canJump = false;
			local temp = interface;
			temp.Options.No.Label.TextXAlignment = Enum.TextXAlignment.Left;
			temp.Options.No.XboxB.Visible = true;
			temp.Options.Yes.Label.TextXAlignment = Enum.TextXAlignment.Left;
			temp.Options.Yes.XboxA.Visible = true;
		end)
		
		local signal1 = controllerService.Disconnected:Connect(function()
			canJump = true;
			local temp = interface;
			temp.Options.No.Label.TextXAlignment = Enum.TextXAlignment.Center;
			temp.Options.No.XboxB.Visible = false;
			temp.Options.Yes.Label.TextXAlignment = Enum.TextXAlignment.Center;
			temp.Options.Yes.XboxA.Visible = false;
		end)
		
		if(env.last) then
			env.last:out();
			if(not env.last.called) then
				env.last.clicked:Fire(false);
			end
		end
		--controls:Disable();

		local options = {[interface.Options.No] = false,[interface.Options.Yes] = true,[interface.Close] = false};
		for button,state in pairs(options) do
			table.insert(connections,button.MouseButton1Click:Connect(function()
				clicked(state);
			end))
		end
		
		function ret:disconnect()
			for _,connection in pairs(connections) do
				connection:Disconnect();
			end
			signal1:Disconnect();
			signal2:Disconnect();
			signal3:Disconnect();
		end
		
		function ret:out()
			--controls:Enable();
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