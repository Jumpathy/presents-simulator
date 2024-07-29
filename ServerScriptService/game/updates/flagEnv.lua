local chatPlus = require(script.Parent.Parent:WaitForChild("core"):WaitForChild("player"):WaitForChild("chat"):WaitForChild("chatPlus"));

return function(flagName)
	local link = function(state)
		local container = game:GetService("ReplicatedStorage"):WaitForChild("flags");
		local value = container:FindFirstChild(flagName);
		if(value) then
			value.Value = state;
			return value;
		else
			local bool = Instance.new("BoolValue");
			bool.Name = flagName;
			bool.Parent = container;
			return bool;
		end
	end
	link(false):SetAttribute("JustHappened",false);
	
	local methods = {};
	
	function methods:setState(bool,data)
		link(bool):SetAttribute("JustHappened",data.justSent);
	end
	
	methods.chatPlus = chatPlus;
	
	return methods;
end