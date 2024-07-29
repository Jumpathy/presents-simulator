return function()
	-- Author: @Jumpathy
	-- Description: Sets up psuedo controller objects for developers to interact with
	-- Name: ControllerService.lua

	local container = script;
	local userInput = game:GetService("UserInputService");
	local runService = game:GetService("RunService");

	local controllerModule = container:WaitForChild("controller");
	local controller = require(controllerModule)();
	local signal = require(controllerModule:WaitForChild("signal"));

	local gamepads = {};
	local gamepadEnums = {
		-- https://developer.roblox.com/en-us/api-reference/enum/UserInputType
		Enum.UserInputType.Gamepad1,
		Enum.UserInputType.Gamepad2,
		Enum.UserInputType.Gamepad3,
		Enum.UserInputType.Gamepad4,
		Enum.UserInputType.Gamepad5,
		Enum.UserInputType.Gamepad6,
		Enum.UserInputType.Gamepad7,
		Enum.UserInputType.Gamepad8
	};

	local connectedSignal = signal.new();
	local disconnectedSignal = signal.new();

	-- Functions:

	local onConnected = function(enum)
		if(not gamepads[enum]) then
			gamepads[enum] = controller.new(enum);
			connectedSignal:Fire(gamepads[enum]);
		end
	end

	local onDisconnected = function(enum)
		if(gamepads[enum]) then
			gamepads[enum]:Destroy();
			disconnectedSignal:Fire(enum);
			gamepads[enum] = nil;
		end
	end

	-- Name: '.Connected' <signal>
	-- Arguments: (<function>)
	-- Description: Called when a controller is connected to the client
	-- Usage example: ControllerService.Connected:Connect(print) --> Controller object

	-- Name: '.Disconnected' <signal>
	-- Arguments: (<function>)
	-- Description: Called when a controller is disconnected from the client
	-- Usage example: ControllerService.Disconnected:Connect(print) --> Enum.UserInputType.Gamepad(...)

	-- Name ':Start()' <function>
	-- Arguments: (<void>)
	-- Description: Begins signal communications
	-- Usage example: ControllerService:Start()

	-- Name ':Stop()' <function>
	-- Arguments: (<void>)
	-- Description: Stops signal communications
	-- Usage example: ControllerService:Stop()

	-- Name ':Create(<Enum>)' <function>
	-- Arguments: (Enum.UserInputType.Gamepad[...])
	-- Usage example: ControllerService:Create(Enum.UserInputType.Gamepad1)
	-- Note: Is not supported if you use the start method.

	-- NOTE: Signals will only call when you do :Start() on the controller service module returned.

	local connections = {};
	return table.freeze({
		Connected = connectedSignal,
		Disconnected = disconnectedSignal,
		Start = function()
			table.insert(connections,userInput.GamepadConnected:Connect(onConnected));
			table.insert(connections,userInput.GamepadDisconnected:Connect(onDisconnected));
			if(userInput.GamepadEnabled) then
				for _,gamepad in pairs(gamepadEnums) do
					if(userInput:GetGamepadConnected(gamepad)) then 
						onConnected(gamepad);
					end
				end
			end
		end,
		Stop = function()
			for key,connection in pairs(connections) do
				connection:Disconnect();
				connections[key] = nil;
			end
			connections = {};
		end,
		Get = function(self,gamepad)
			return gamepads[gamepad];
		end,
		Create = function(self,gamepadEnum) -- Use with caution
			return controller.new(gamepadEnum);
		end,
	})
end