return function()
	-- Author: @Jumpathy
	-- Description: Object-oriented controller objects
	-- Name: controller.lua
	-- Note: You can just extract this module and use it, but I'd recommend using the manager module if you don't know what you're doing.

	local userInput = game:GetService("UserInputService");
	local players = game:GetService("Players");
	local haptics = game:GetService("HapticService");

	local localPlayer = players.LocalPlayer;
	local internalSignals = {};
	local internalControllers = {};
	local signals = {};

	local yield = require(script:WaitForChild("yield"));
	local signal = require(script:WaitForChild("signal"));

	-- Defaults:

	local defaultSensitivity = 0.5; -- Controller thumbstick signal sensitivity (can also be set for individual controllers) (lower means more sensitive ftr)

	-- Functions:

	local getMemoryAddress = function(tbl) --> used to identify custom bindable events and link them to controllers
		return tostring(tbl):sub(8,#tostring(tbl));
	end

	local disconnect = function(array)
		for key,signal in pairs((array ~= nil and array or {})) do
			signal:Disconnect();
			array[key] = nil;
		end
	end

	local getSupportedMotors = function(gamepad)
		local supported = {};
		for _,motor in pairs({Enum.VibrationMotor.Large,Enum.VibrationMotor.Small}) do
			if(haptics:IsMotorSupported(gamepad,motor)) then
				supported[motor] = true;
			end
		end
		return supported;
	end

	local link = function(signal)
		signals[getMemoryAddress(signal)] = signal;
		return signal;
	end

	local typeCheck = function(class,expected,message)
		assert((expected == type(class)),message:format(expected,type(class)));
	end

	-- Creating:

	local controller = {};

	function controller.new(enum)
		local newController = {};

		newController.Enum = enum;

		-- .ControllerNumber is the property
		newController.ControllerNumber = tonumber(tostring(enum):split(".")[3]:sub(8,9));

		if(haptics:IsVibrationSupported(enum)) then
			for supportedMotorEnum,_ in pairs(getSupportedMotors(enum)) do
				local name = tostring(supportedMotorEnum):split(".")[3]; --> get the motor name (eg: Small/Large)
				local functionName = ("Vibrate%s"):format(name);
				newController[functionName] = function(self,intensity)
					typeCheck(intensity,"number","Expected '%s' for 'intensity' but got '%s'");
					intensity = math.clamp(intensity,0,1);
					haptics:SetMotor(enum,supportedMotorEnum,intensity);
				end
			end
		end

		disconnect(internalSignals[enum]);
		internalSignals[enum] = {};
		if(internalControllers[enum]) then
			internalControllers[enum] = {};
		end

		local primaryButtons = {
			Enum.KeyCode.ButtonA,Enum.KeyCode.ButtonB,Enum.KeyCode.ButtonY,Enum.KeyCode.ButtonX
		}

		local joysticks = {
			Enum.KeyCode.Thumbstick1,Enum.KeyCode.Thumbstick2
		}

		local backButtons = {
			Enum.KeyCode.ButtonL2,Enum.KeyCode.ButtonR2,Enum.KeyCode.ButtonL1,Enum.KeyCode.ButtonR1
		}

		local dPad = {
			[Enum.KeyCode.DPadLeft] = "Left",
			[Enum.KeyCode.DPadRight] = "Right",
			[Enum.KeyCode.DPadDown] = "Down",
			[Enum.KeyCode.DPadUp] = "Up"
		}

		local cachedInputs = {};
		local isHeldDown = {};

		-- INTERNAL INPUTS:

		table.insert(internalSignals[enum],userInput.InputBegan:Connect(function(input,gameProcessed)
			if(input.UserInputType == enum) then
				isHeldDown[input.KeyCode] = true;
				if(table.find(primaryButtons,input.KeyCode)) then -- main controller buttons
					newController.PrimaryButtonPressed:Fire(input.KeyCode,gameProcessed);
				elseif(table.find(backButtons,input.KeyCode)) then -- back of controller buttons
					newController.TriggerButtonPressed:Fire(input.KeyCode,gameProcessed);
				elseif(dPad[input.KeyCode]) then -- dpad input
					newController.DPadInput:Fire(dPad[input.KeyCode],gameProcessed);
				end
				newController.ButtonPressed:Fire(input.KeyCode,gameProcessed);
			end
		end))


		table.insert(internalSignals[enum],userInput.InputEnded:Connect(function(input,gameProcessed)
			if(input.UserInputType == enum) then
				isHeldDown[input.KeyCode] = false;
			end
		end))

		local lastInput = {};
		local totals = {};
		local sensitivityRequired = defaultSensitivity;
		local new = {};

		table.insert(internalSignals[enum],userInput.InputChanged:Connect(function(input,gameProcessed)
			if(table.find(joysticks,input.KeyCode)) then
				if(input.UserInputType == enum) then
					new = {
						["X"] = input.Position.X,
						["Y"] = input.Position.Y
					};
					if(lastInput[input.KeyCode]) then 
						-- The thumbsticks are so annoyingly sensitive for my controller so I made a sensitivity function
						-- Like I'm not even kidding it was like as fast as RunService.Heartbeat if I barely even touched it
						local last = lastInput[input.KeyCode]["pos"];
						local xDiff = math.max(last.X,new.X) - math.min(last.X,new.X);
						local yDiff = math.max(last.Y,new.Y) - math.min(last.Y,new.Y);
						local average = (xDiff + yDiff)/2;
						if(average <= sensitivityRequired) then
							return;
						end
					end
					if(not lastInput[input.KeyCode]) then
						lastInput[input.KeyCode] = {};
					end
					lastInput[input.KeyCode]["pos"] = new;
					newController.ThumbstickMoved:Fire(input.KeyCode,new);	
				end
			end
		end))

		-- EVENTS:

		-- PrimaryButtonPressed:Connect(<function>)
		-- Detects when primary buttons like A,B,Y,X are clicked, calling the function passed with an Enum.KeyCode(...)

		newController.PrimaryButtonPressed = link(signal.new());

		-- ThumbstickMoved:Connect(<function>)
		-- Detects when either thumbsticks are moved and calls with the thumbsitkc enum and a table with X and Y's that go from -1 to 1 in intensity (1 being the strongest)
		-- Ex: Enum.KeyCode.Thumbstick1,{X = 0.01,Y = 1} --> thumbstick is moved to the bottom

		newController.ThumbstickMoved = link(signal.new());

		-- DPadInput:Connect(<function>)
		-- Detects DPad input for the controller

		newController.DPadInput = link(signal.new());

		-- TriggerButtonPressed:Connect(<function>)
		-- Detects presses of back buttons of controller like L1, R1

		newController.TriggerButtonPressed = link(signal.new());

		-- ButtonPressed:Connect(<function>)
		-- Detects the press of any button on the controller

		newController.ButtonPressed = link(signal.new());


		-- Destroyed:Connect(<function>)
		-- Binds to the removal of the controller object

		newController.Destroyed = link(signal.new());

		-- FUNCTIONS:

		function newController:SetThumbstickSensitivityRequired(newSensitivity:number)
			typeCheck(newSensitivity,"number","Expected '%s' for 'newSensitivity' but got '%s'");
			sensitivityRequired = newSensitivity;
		end

		-- :IsKeyDown(<ENUM keycode>)
		-- Returns a boolean value of whether or not the queried key is being held

		function newController:IsKeyDown(keyCode:Enum.KeyCode)
			-- I don't use ':IsKeyDown' internally because it may return the wrong value if the user
			-- has more than one controller and is holding it on one of them and not the one your code
			-- is referring to
			return(isHeldDown[keyCode] == true); --> == true check so it doesn't return nil
		end

		-- :Vibrate(<table> {<large (boolean)>,<small (boolean),<intensity (number)>}, <expireIn (number)>)
		-- Allows you to vibrate your controller's small and large motors and add a timeout parameter if needed.

		local motorNames = {"Large","Small"};
		local lastCalled;

		function newController:Vibrate(options:{Large:number,Small:number},expireIn:number,ignore)
			local key = tick();
			lastCalled = key;
			typeCheck(options,"table","Expected '%s' for 'options' but got '%s'");
			for _,name in pairs(motorNames) do
				if(options[name]) then
					typeCheck(options[name],"number","Expected '%s' for 'options."..name.."' but got '%s'");
					options[name] = math.clamp(options[name],0,1);
				end
			end
			local start = function(intensities)
				for _,name in pairs(motorNames) do
					if(options[name]) then
						if(newController["Vibrate"..name]) then
							newController["Vibrate"..name](newController,intensities[name]);
						elseif(not ignore) then
							warn(("[Failed to find '%s' motor for controller]"):format(name));
						end
					end
				end
			end
			start(options);
			if(expireIn) then
				typeCheck(expireIn,"number","Expected '%s' for 'expireIn' but got '%s'");
				task.spawn(function()
					yield(expireIn);
					if(lastCalled == key) then -- Make sure no other :Vibrate methods have been called yet
						start({ -- Note that if one of these isn't passed initially, it won't turn off that motor
							["Large"] = 0,
							["Small"] = 0
						});
					end
				end)
			end
		end

		-- :Destroy(<void>)
		-- Destroys the psuedo controller object and disconnects internal events

		local destroyed = false;
		function newController:Destroy()
			newController.Destroyed:Fire();
			local enum = newController.Enum;
			for key,value in pairs(newController) do -- disconnect signals
				if(type(value) == "table") then
					local address = getMemoryAddress(value);
					local linked = signals[address];
					if(linked) then
						linked:DisconnectAll();
						signals[address] = nil;
					end
				end
			end
			newController:Vibrate({
				["Small"] = 0,
				["Large"] = 0
			},nil,true);
			disconnect(internalSignals[enum]);
			internalSignals[enum] = nil;
			internalControllers[enum] = nil;
			destroyed = true;
		end

		-- :IsDestroyed(<void>)
		-- Returns a boolean representing whether or not if the controller object is still connected

		function newController:IsDestroyed()
			return destroyed;
		end

		-- Return to finalize

		return table.freeze(newController); --> readonly
	end

	return controller;
end