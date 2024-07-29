--[[
	SimpleAnticheat | Loader	
--]]

local Config = {
	Settings = script.Parent.Parent:WaitForChild("Settings", 2);
	ModuleId = 6475396942;
	DebugMode = true;
}

local Module = require(Config.DebugMode and script:WaitForChild("MainModule") or Config.ModuleId)

if not Config.Settings then
	return warn("SimpleAnticheat | Unable to find settings!")
end

Module(Config.Settings)
