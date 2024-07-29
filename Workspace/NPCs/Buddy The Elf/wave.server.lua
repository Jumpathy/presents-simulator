local item = function(part)
	if(part:IsA("BasePart")) then
		local set = function()
			game:GetService("PhysicsService"):SetPartCollisionGroup(part,"players");
		end
		
		local success,err = pcall(set);
		if(err and not success) then
			repeat
				success,err = pcall(set);
				wait();
			until(not err);
		end
	end
end

local humanoid = script.Parent:WaitForChild("Humanoid");
local animation = humanoid:LoadAnimation(script:FindFirstChildOfClass("Animation"));
animation.Looped = true;
animation:Play();

script.Parent.DescendantAdded:Connect(item);
for k,v in pairs(script.Parent:GetDescendants()) do
	coroutine.wrap(item)(v);
end