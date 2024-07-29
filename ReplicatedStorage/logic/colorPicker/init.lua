local init = function(object,callback)
	local wheel = require(script:WaitForChild("controller"))(callback);
	local colorWheel = wheel(object);
	return colorWheel:init();
end

return {
	start = function(self,object,callback)
		return init(object,callback)
	end,
}