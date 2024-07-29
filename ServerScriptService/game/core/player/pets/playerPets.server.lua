local data = require(script.Parent.Parent.Parent.Parent:WaitForChild("data"));
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local petData = {};
local petKey = "player_pets";
local profiles = {};
local module = require(game:GetService("ReplicatedStorage"):WaitForChild("follow"));

local getModel = function(name,clone)
	local folder = game:GetService("ServerStorage"):WaitForChild("pets");
	for _,pet in pairs(folder:GetChildren()) do
		if(pet:GetAttribute("DisplayName") == name or pet.Name == name) then
			if(clone == false) then
				return pet;
			end
			return pet:Clone();
		end
	end
end

local selected = function(player,callback,signal)
	coroutine.wrap(callback)(player:WaitForChild("Selection").Value);
	local connection;
	connection = player:WaitForChild("Selection"):GetPropertyChangedSignal("Value"):Connect(function()
		if(signal.Disconnected == false) then
			callback(player:WaitForChild("Selection").Value);
		else
			connection:Disconnect();
		end
	end)
	return function()
		connection:Disconnect();
	end
end

local petManager = {internal = {},newSignal = function()
	return {
		Disconnected = false,
		Disconnect = function(self)
			self.Disconnected = true;
		end,
	}
end};

local walkspeedFrom = function(name)
	local model = getModel(name,false);
	local addon = model:GetAttribute("AddSpeed");
	local addonJump = model:GetAttribute("AddJump");
	local addonBoost = model:GetAttribute("AddBoost");
	local addonDamage = model:GetAttribute("AddDamage");
	return(addon or 0),(addonJump or 0),(addonBoost or 0),(addonDamage or 0);
end

function petManager:runPet(name,player,model)
	local new,new2,new3,new4 = walkspeedFrom(name);
	local defaultSpeed = player:GetAttribute("DefaultSpeed");
	local addSpeed = player:GetAttribute("AddSpeed");
	local addJump = player:GetAttribute("AddJump");
	local addBoost = player:GetAttribute("AddBoost");
	local addDamage = player:GetAttribute("AddDamage");
	player:SetAttribute("AddSpeed",(addSpeed + new));
	player:SetAttribute("AddJump",(addJump + new2));
	player:SetAttribute("AddBoost",(addBoost + new3));
	player:SetAttribute("AddDamage",(addDamage + new4));
	local signal = petManager.newSignal();
	petManager.internal[name.."_signals"] = signal;
	local stop;
	stop = selected(player,function(selection)
		local success,err = pcall(function()
			model.PrimaryPart.Beam.Attachment1 = selection;
		end)
		if(err and not success and stop ~= nil) then
			stop();
		end
	end,signal);
end

function petManager:disablePet(name,player)
	local new,new2,new3,new4 = walkspeedFrom(name);
	local addSpeed = player:GetAttribute("AddSpeed");
	local addJump = player:GetAttribute("AddJump");
	local addBoost = player:GetAttribute("AddBoost");
	local addDamage = player:GetAttribute("AddDamage");
	petManager.internal[name.."_signals"]:Disconnect();
	player:SetAttribute("AddSpeed",(addSpeed - new));
	player:SetAttribute("AddJump",(addJump - new2));
	player:SetAttribute("AddBoost",(addBoost - new3));
	player:SetAttribute("DamageBoost",(addDamage - new4))
end

--[[
network:createRemoteEvent("playerPetUpdate",function(player)
	player:Kick("stop firing random remotes");
end)
]]

network:createRemoteFunction("getPlayerPets",function(plr)
	return petData[plr];
end)

function petManager.new(player)
	if(petManager.internal[player]) then
		return petManager.internal[player];
	else
		local plr = {pets = {}};
		petManager.internal[player] = plr;
		
		function plr:addPet(pet,model)
			local modifier = {};
			local running = function()
				petManager:runPet(pet.name,player,model);
			end
			local stop = function()
				petManager:disablePet(pet.name,player);
			end
			function modifier:disconnect()
				stop();
			end
			table.insert(plr.pets,modifier);
			running();
		end
		
		function plr:unloadAll()
			for _,pet in pairs(plr.pets) do
				pet:disconnect();
			end
			plr.pets = {};
		end
		
		return plr;
	end
end

local load = function(player)
	local manager = petManager.new(player);
	manager:unloadAll();
	for _,pet in pairs(workspace:WaitForChild("pets"):WaitForChild(player.Name):GetChildren()) do
		local petName = pet.Name;
		module:removePet(player,petName);
	end
	local attrFolder = player:WaitForChild("CurrentPetsEquipped");
	for attributeName,_ in pairs(attrFolder:GetAttributes()) do
		attrFolder:SetAttribute(attributeName,nil);
	end
	for _,pet in pairs(profiles[player][petKey]["equipped"]) do
		attrFolder:SetAttribute(pet.name,true);
		local model = getModel(pet.name);
		manager:addPet(pet,module:addPet(player,model));
	end
end

data.profileLoaded:Connect(function(profile,player)
	petData[player.Name] = profile[petKey].equipped;
	profiles[player] = profile;
	load(player);
end)

shared.abuse = function(player)
	local tbl = game.ServerStorage.pets:GetChildren();
	for i = 1,#tbl do
		table.insert(petData[player.Name],tbl[i].Name);
	end
	load(player);
end

shared.remove_pets = function(player)
	for _,pet in pairs(workspace:WaitForChild("pets"):WaitForChild(player.Name):GetChildren()) do
		local petName = pet.Name;
		module:removePet(player,petName);
	end
	for petName,_ in pairs(player.CurrentPetsEquipped:GetAttributes()) do
		player.CurrentPetsEquipped:SetAttribute(petName,nil);
	end
	
	petManager.new(player):unloadAll();
	profiles[player][petKey]["equipped"] = {};
	profiles[player][petKey]["owned"] = {};
	petData[player.Name] = {};
end

-- petManager("equip",{name = "Sin"})

local limit = function(player)
	return player:GetAttribute("petLimit");
end

local equipLimit = function(player)
	return player:GetAttribute("equipLimit");
end

local hasPet = function(array,lookFor)
	for _,pet in pairs(array) do
		if(pet.displayName == lookFor) then
			return true;
		end
	end
end

shared.getLimit = limit;

local validIdentifier = function(pets,id,name)
	for _,pet in pairs(pets) do
		if(pet.identifier == id and pet.displayName == name) then
			return true;
		end
	end
end

network:createRemoteEvent("refreshPets");

local from = function(speed)
	return (speed < 0 and "" or "+"),(speed);
end

local round = function(number)
	return math.floor(number * 100);
end

network:createRemoteFunction("petManager",function(player,action,data)
	if(profiles[player]) then
		if(action == "equip") then
			if(type(data) == "table") then
				if(hasPet(profiles[player][petKey]["owned"],data.name)) then
					if(type(data.slot) == "number" and data.slot <= equipLimit(player)) then
						if(type(data.id) == "string" and validIdentifier(profiles[player][petKey]["owned"],data.id,data.name)) then
							local pets = profiles[player][petKey]["equipped"];
							for slot,pet in pairs(pets) do
								if(pet.id == data.id) then
									pets[slot] = nil;
								end
							end
							profiles[player][petKey]["equipped"][data.slot] = {
								name = data.name,
								id = data.id
							};
							load(player);
							return true,"Equipped";
						else
							return false,"Invalid identifier";
						end
					else
						return "You can't equip a pet over this slot number, nice try.";
					end
				else
					return false,"You do not own this pet!";
				end
			else
				return false,"If you're going to even try to make an exploit for my game, maybe try a little bit harder. Like seriously, it's not that difficult. 11/29/21"
			end
		elseif(action == "getPets") then
			return true,{
				owned = profiles[player][petKey]["owned"],
				equipped = profiles[player][petKey]["equipped"]
			}
		elseif(action == "unequip") then
			if(type(data) == "table") then
				if(type(data.id) == "string" and validIdentifier(profiles[player][petKey]["owned"],data.id,data.name)) then
					local pets = profiles[player][petKey]["equipped"];
					for slot,pet in pairs(pets) do
						if(pet.id == data.id) then
							pets[slot] = nil;
						end
					end
					load(player);
					return true,"Success!";
				else
					return false,"Invalid pet."
				end
			else
				return false,"Please, take more than 3 seconds to try to randomly assemble some broken exploit code lmao";
			end
		elseif(action == "sell") then
			if(type(data) == "table") then
				if(type(data.id) == "string" and validIdentifier(profiles[player][petKey]["owned"],data.id,data.name)) then
					local arr = {
						["Legendary"] = 25000,
						["Common"] = 3500,
						["Uncommon"] = 13500
					}
					local add = arr[getModel(data.name,false):GetAttribute("Tier")];
					for key,pet in pairs(profiles[player][petKey]["owned"]) do
						if(pet.identifier == data.id) then
							table.remove(profiles[player][petKey]["owned"],key);
						end
					end
					local pets = profiles[player][petKey]["equipped"];
					for slot,pet in pairs(pets) do
						if(pet.id == data.id) then
							pets[slot] = nil;
						end
					end
					load(player);
					if(add) then
						shared.add(player.leaderstats.Coins,add);
						network:fireClient("refreshPets",player);
						network:fireClient("onStatChange",player,add,"Coins","Coins")
					end
					return true,"Success!";
				else
					return false,"Invalid pet."
				end
			end
		elseif(action == "getPetInfo") then
			local model = getModel(data,false);
			if(model) then
				return true,{
					["Tier"] = model:GetAttribute("Tier"),
					["Image"] = model:GetAttribute("Image"),
					["Speed"] = ("%s%s Speed"):format(from(model:GetAttribute("AddSpeed"))),
					["Jump"] = ("%s%s Jump"):format(from(model:GetAttribute("AddJump"))),
					["Toys"] = ("+%s%% Toys"):format(round(model:GetAttribute("AddBoost"))),
					["Damage"] = ("+%s%% Damage"):format(round(model:GetAttribute("AddDamage"))),
				}
			end
		end
	else
		return false,"Wait for data to load.";
	end
end)