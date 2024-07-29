shared.cache_position = {};
local selected;

local cache = function(object)
	if(shared.cache_position[object]) then
		return shared.cache_position[object];
	else
		shared.cache_position[object] = object.Position;
		return object.Position;
	end
end

return function(model)
	local functions = {};
	local players = game:GetService("Players");
	local tweenService = game:GetService("TweenService");
	local goalCFrame = model:WaitForChild("parts"):WaitForChild("CameraPart").CFrame;
	local object = model:WaitForChild("model"):WaitForChild("Backpack"):WaitForChild("Part"):WaitForChild("GuiPart");
	local origin = cache(object);
	local key = tick();
	selected = key;

	local tween = function(object,len,goal)
		tweenService:Create(object,TweenInfo.new((len or 1/2),Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play();
	end

	local newPosition = function()
		return Vector3.new(
			origin.X,
			origin.Y + 1.25,
			origin.Z
		)
	end

	function functions.view()
		local camera = workspace.CurrentCamera;
		local old = camera.CameraType;
		camera.CameraType = Enum.CameraType.Scriptable;
		if((old == Enum.CameraType.Custom)) then
			camera.CFrame = goalCFrame;
		else
			tween(camera,1/4,{
				["CFrame"] = goalCFrame;
			})
		end
	end

	function functions.unview()

	end

	function functions.default()
		local camera = workspace.CurrentCamera;
		camera.CameraType = Enum.CameraType.Custom;
	end

	return functions;
end