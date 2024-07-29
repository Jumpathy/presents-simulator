-- Author: @PysephDEV
-- Modified by: @Jumpathy
-- Name: yield.lua
-- Description: Custom yielding solution

local internalClock = os.clock;
local yieldThread = coroutine.yield;
local resumeThread = coroutine.resume;
local isRunning = coroutine.running;

local yields = {};
game:GetService("RunService").Stepped:Connect(function()
	local currentTime = internalClock();
	for index,data in next,yields do -- check all yields passed at the bottom of this function
		local spentTime = currentTime - data[1]; -- get the time passed
		if(spentTime >= data[2]) then -- if the time passed is more than the time that needs to wait
			yields[index] = nil;
			resumeThread(data[3],spentTime,currentTime); -- restart the thread (stopping the wait) and call it with the amount of time spent + the current time
		end
	end
end)

return function(toWaitFor)
	toWaitFor = (type(toWaitFor) ~= "number" or toWaitFor < 0) and 0 or toWaitFor;
	table.insert(yields,{
		internalClock(), -- time when started
		toWaitFor, -- time to wait for before continuing
		isRunning() -- current thread
	});
	return yieldThread(); -- pause the thread to simulate waiting
end