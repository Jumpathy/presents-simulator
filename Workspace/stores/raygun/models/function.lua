shared.cache_position = {};
shared.origins = {};

local selected;
local offset = function(gun)
	return(gun:GetAttribute("Offset") or 1.25);
end;

local cache = function(object)
	if(shared.cache_position[object]) then
		return shared.cache_position[object];
	else
		shared.cache_position[object] = object.Position;
		return object.Position;
	end
end

local newPositionFrom = function(object,getOrigin)
	if(getOrigin) then
		return shared.origins[object];
	end
	if(shared.cache_position[object]) then
		return shared.cache_position[object];
	else
		shared.origins[object] = object.Position;
		shared.cache_position[object] = object.Position + Vector3.new(0,offset(object.Parent),0);
		return shared.cache_position[object];
	end
end

return function(model)
	local functions = {};
	local players = game:GetService("Players");
	local tweenService = game:GetService("TweenService");
	local goalCFrame = model:WaitForChild("parts"):WaitForChild("CameraPart").CFrame;
	local object = model:WaitForChild("model"):WaitForChild("Gun");
	local origin = cache(object);
	local key = tick();
	selected = key;

	local tween = function(object,len,goal)
		tweenService:Create(object,TweenInfo.new((len or 1/2),Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal):Play();
	end

	local newPosition = function()
		local new = offset(object);
		return object:GetAttribute("GoalPosition") or Vector3.new(
			origin.X,
			origin.Y + new,
			origin.Z
		)
	end
	
	local get = function(parent)
		local ret = {};
		for _,child in pairs(parent:GetChildren()) do
			if(child.Name == "TweenWith") then
				table.insert(ret,child);
			end
		end
		return ret;
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

		coroutine.wrap(function()
			wait(0.15);
			if(selected == key) then
				object.Beam.Attachment1 = object.PsuedoPresent:FindFirstChildOfClass("Attachment");
				tween(object,0.25,{
					Position = newPosition(),
					Orientation = object:GetAttribute("NewOrientation");
				});
				if(object:FindFirstChild("TweenWith")) then
					newPositionFrom(object);
					for _,o in pairs(get(object)) do
						tween(o,0.25,{
							Position = o:GetAttribute("GoalPosition") or newPositionFrom(o),
							Orientation = o:GetAttribute("GoalOrientation")
						});
					end
				end
			end
		end)();
	end

	function functions.unview()
		object.Beam.Attachment1 = nil;
		tween(object,0.25,{
			Position = origin,
			Orientation = object:GetAttribute("OriginalOrientation");
		});
		if(object:FindFirstChild("TweenWith")) then
			for _,o in pairs(get(object)) do
				tween(o,0.25,{
					Position = newPositionFrom(o,true),
					Orientation = o:GetAttribute("OriginalOrientation")
				});
			end
		end
	end

	function functions.default()
		local camera = workspace.CurrentCamera;
		camera.CameraType = Enum.CameraType.Custom;
	end

	return functions;
end