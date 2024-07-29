local event = {};
local flagName = script.Name;
local env = require(script.Parent.Parent:WaitForChild("flagEnv"))(flagName);
local channel = env.chatPlus:getChannel("All");

function event:enable(data)
	env:setState(true,data)
end

function event:disable(data)
	env:setState(false,data);
end

return event;