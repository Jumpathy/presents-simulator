return function(api)
	-- inject
	
	shared.hd_admin_betterChat = api
	script:WaitForChild("ChatServiceRunner"):Clone().Parent = game:GetService("ServerScriptService")
	
	-- continue:
	
	local modules = game:GetService("ServerStorage"):WaitForChild("HDAdminServer"):WaitForChild("Modules")
	local list = {}
	
	local loadCommands = function(module)
		for _,command in pairs(require(module)) do
			if(command.Name ~= "") then
				table.insert(list,{
					name = command.Name,
					aliases = command.Aliases or {},
					rank = command.Rank,
					args = command.Args
				})
			end
		end
	end

	-- 2 command modules for some reason

	for _,module in pairs(modules:GetChildren()) do
		if(module.Name == "Commands") then
			loadCommands(module)
		end
	end

	modules.ChildAdded:Connect(function(obj)
		if(obj.Name == "Commands") then
			loadCommands(obj)
		end
	end)
	
	-- insert
	
	local hdMain = require(game:GetService("ReplicatedStorage"):WaitForChild("HDAdminSetup")):GetMain()
	local hd = hdMain:GetModule("API")
	
	api.network:newFunction("getCommandsList",function()
		return list
	end)
	
	api.network:newFunction("getHdAdminRank",function(player)
		return hd:GetRank(player)
	end)
	
	-- talk cmd
	
	repeat 
		game:GetService("RunService").Heartbeat:Wait() 
	until 
	_G.HDAdminMain ~= nil 
		and _G.HDAdminMain.commands ~= nil 
		and _G.HDAdminMain.commands.talk ~= nil

	_G.HDAdminMain.commands["talk"].Function = function(speaker,args)
		local text = args[2]
		if(text ~= nil) then
			api.speaker:getByName(args[1].Name):say("Main",text)
		end
	end
end