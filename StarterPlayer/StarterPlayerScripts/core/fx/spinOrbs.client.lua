local getClass = function(parent,class,object)
	repeat
		object = parent:FindFirstChildOfClass(class);
		game:GetService("RunService").Heartbeat:Wait();
	until(object ~= nil);
	return object;
end

local cached = {};
local ts = game:GetService("TweenService");
local info = TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut);

local wrap = function(child)
	if(child.Name == "FlyingOrbs" and (not cached[child]) and child:IsA("Tool")) then
		cached[child] = true;
		local smaller = child:WaitForChild("Handle");
		local orbs = getClass(smaller,"MeshPart");
		if(orbs) then
			local new = function()
				local arguments = {orbs,info,{Orientation = orbs.Orientation + Vector3.new(180,360,180)}}
				return ts:Create(
					unpack(arguments)
				)
			end

			local play;
			play = function()
				local tween = new();
				tween:Play();
				tween.Completed:Connect(function()
					if(child:GetFullName() ~= child.Name) then
						play();
					end
				end)
			end
			play();
		end
	end
end

workspace.DescendantAdded:Connect(wrap);
for _,child in pairs(workspace:GetDescendants()) do
	coroutine.wrap(wrap)(child);
end