--[[
  ____  _                 _           _          _   _      _                _   
 / ___|(_)_ __ ___  _ __ | | ___     / \   _ __ | |_(_) ___| |__   ___  __ _| |_ 
 \___ \| | '_ ` _ \| '_ \| |/ _ \   / _ \ | '_ \| __| |/ __| '_ \ / _ \/ _` | __|
  ___) | | | | | | | |_) | |  __/  / ___ \| | | | |_| | (__| | | |  __/ (_| | |_ 
 |____/|_|_| |_| |_| .__/|_|\___| /_/   \_\_| |_|\__|_|\___|_| |_|\___|\__,_|\__|
                   |_|                                                           
--]]

return function(Settings)
	local Source = script:WaitForChild("Source", 2)

	if not Source then
		return warn("SimpleAnticheat | Unable to find dependencies!")
	end

	local Server = Source:WaitForChild("Server", 2)
	local Client = Source:FindFirstChild("Client Override", 2) or Source:WaitForChild("Client", 2)

	Settings.Parent = Server

	Server.Name = "SimpleAnticheat_Server"
	Client.Name = "SimpleAnticheat_Client"

	Server.Parent = game:GetService("ServerScriptService")
	Server.Disabled = false

	Client.Parent = game:GetService("ReplicatedFirst")
	Client.Disabled = false
end