-- Author: @Jumpathy
-- Name: HDAdminAutofill.lua
-- Description: HD admin autofill system

local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local list;

local framework = require(game:GetService("ReplicatedStorage"):WaitForChild("HDAdminSetup")):GetMain()
local prefix = framework.pdata.Prefix

local autofill = {}
autofill.beginsWith = prefix
autofill.endsWith = nil
autofill.security = "internal"

local allowedPlayerArguments = {"me","all","random","others","admins","nonadmins","premium","friends","nonfriends","r6","r15","rthro","nonrthro"}

local searchAliases = function(command,name,strict)
	for _,alias in pairs(command.aliases) do
		if(alias:sub(1,#name) == name and (not strict)) then
			return alias
		elseif(strict and (alias == name)) then
			return alias
		end
	end
end

local getArguments = function(data)
	local toReturn = " "
	for _,name in pairs(data.args) do
		toReturn = toReturn .. "<" .. name:lower() .."> "
	end
	return toReturn:sub(1,#toReturn-1)
end

local canUse = function(command)
	local rank = framework.pdata.Rank
	if(command.rank == "Donor") then
		return framework.pdata.Donor
	else
		return rank >= command.rank
	end
end

autofill.onCapture = function(matches,environment)
	local network = environment.network
	list = list or network:invoke("getCommandsList")
	local gsub,fill = {},{}
	local add = function(command,match)
		if(canUse(command)) then
			local commandName = match.text
			local matched = command.name:sub(1,#commandName) == commandName and command.name or searchAliases(command,commandName)
			local base = prefix .. matched
			table.insert(fill,{
				text = prefix .. matched .. getArguments(command),
				autofillBar = prefix .. matched,
				gsub = {
					prefix .. match.text,
					base.." "
				}
			})
		end
	end
	local splice = function(data,commandName,arguments)
		if(canUse(data)) then
			for key,arg in pairs(data.args) do
				if(arguments[key] and (arg == "Player")) then
					if(not arguments[key + 1]) then
						local txt = arguments[key]
						local fillName = prefix .. commandName .. " " .. table.concat({unpack(arguments,0,math.clamp(key-1,0,math.huge)) or ""}," ")
						for _,playerArgument in pairs(allowedPlayerArguments) do
							if(playerArgument:sub(1,#txt) == txt and (#txt ~= #playerArgument)) then
								table.insert(fill,{
									text = playerArgument,
									autofillBar = fillName .. playerArgument,
									gsub = {
										fillName .. arguments[key],
										fillName..playerArgument
									}
								})
							end
						end
						if(#fill == 0) then
							for _,player in pairs(players:GetPlayers()) do
								if(player.Name:sub(1,#arguments[key]) == arguments[key]) then
									table.insert(fill,{
										text = player.Name,
										autofillBar = fillName .. player.Name,
										gsub = {
											fillName .. arguments[key],
											fillName.. player.Name
										}
									})
								end
							end
						end
					end
				end
			end
		end
	end
	if(matches[1]) then
		local commandName = matches[1]["text"]
		if(commandName:find(" ")) then
			local text = commandName
			commandName = text:split(" ")[1]

			local split = text:split(" ")
			local args = {unpack(split,2,#split)}
			local found = false
			
			for _,data in pairs(list) do
				if(data.name == commandName or searchAliases(data,commandName,true)) then
					splice(data,commandName,args)
					found = true
					break
				end
			end
			
			if(not found) then
			for _,data in pairs(list) do
				if(data.name:sub(1,#commandName) == commandName) then
					splice(data,commandName,args)
					break
				elseif(searchAliases(data,commandName)) then
					splice(data,commandName,args)
					break
				end
				end
			end
		else
			for _,data in pairs(list) do
				if(data.name:sub(1,#commandName) == commandName) then
					add(data,matches[1])
				elseif(searchAliases(data,commandName)) then
					add(data,matches[1])
				end
			end
		end
	end
	return gsub,fill
end

local loaded,signal = false,nil
local onChild = function(child)
	if(child.Name == "AE1 Prefix" and (not loaded)) then
		loaded = true
		local box = child:WaitForChild("SettingValue"):WaitForChild("TextBox")
		box.FocusLost:Connect(function()
			prefix = box.Text
			autofill.beginsWith = prefix
		end)
		if(signal) then
			signal:Disconnect()
			signal = nil
		end
	end
end

signal = localPlayer.PlayerGui.DescendantAdded:Connect(onChild)
for _,child in pairs(localPlayer.PlayerGui:GetDescendants()) do
	if(not loaded) then
		onChild(child)
	end
end

return autofill