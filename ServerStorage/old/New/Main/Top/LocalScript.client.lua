local container = script.Parent;
local buttons = {};

local on = function(new,callback)
	for _,button in pairs(buttons) do
		coroutine.wrap(callback)(button,(button == new));
	end
end

local tween = function(object,properties)
	local tweenInfo = TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut);
	local actualTween = game:GetService("TweenService"):Create(object,tweenInfo,properties);
	return actualTween:Play();
end

local handle = function(object)
	if(object.Name == "Button") then
		object.MouseButton1Click:Connect(function()
			on(object,function(button,isSelected)
				tween(button,{
					["BackgroundColor3"] = (isSelected and Color3.fromRGB(101, 188, 255) or Color3.fromRGB(247, 247, 247)),
					["TextColor3"] = (isSelected and Color3.fromRGB(255,255,255) or Color3.fromRGB(187,187,187))
				})
			end)
		end)
		table.insert(buttons,object);
	end
end

for _,child in pairs(container:GetChildren()) do
	coroutine.wrap(handle)(child);
end
container.ChildAdded:Connect(handle);