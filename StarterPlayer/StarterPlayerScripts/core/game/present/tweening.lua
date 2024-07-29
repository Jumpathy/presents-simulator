local tweening = {};

local runService = game:GetService("RunService");
local tweenService = game:GetService("TweenService");
local heartbeat = runService.Heartbeat;

function resizeModel(model,a)
	local base = model.PrimaryPart.Position
	for _,part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Position = base:Lerp(part.Position,a)
			part.Size *= a
		end
	end
end

local tweenModelSize = function(model,duration,factor,easingStyle,easingDirection)
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(model.PrimaryPart and model.PrimaryPart:GetFullName() ~= model.PrimaryPart.Name);
	local s = factor - 1;
	local i = 0;
	local oldAlpha = 0;
	while(i < 1) do
		local dt = heartbeat:Wait()
		i = math.min(i + dt/duration,1)
		local alpha = tweenService:GetValue(i,easingStyle,easingDirection)
		resizeModel(model,(alpha*s + 1)/(oldAlpha*s + 1))
		oldAlpha = alpha
	end

	local bindable = Instance.new("BindableEvent");

	task.spawn(function()
		task.wait(duration);
		bindable:Fire();
	end)

	local tbl = {};

	tbl.Completed = bindable.Event;

	return tbl;
end

-- methods:

function tweening:tweenModelSize(model,duration,factor)
	local easingStyle,easingDirection = Enum.EasingStyle.Bounce,Enum.EasingDirection.InOut;
	return tweenModelSize(model,duration,factor,easingStyle,easingDirection);
end

function tweening:tween(part,length,properties,style)
	tweenService:Create(part,TweenInfo.new(length,style,Enum.EasingDirection.InOut),properties):Play();
end

return tweening;