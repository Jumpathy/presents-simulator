if(not game:IsLoaded()) then
	game.Loaded:Wait();
end

local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));
local currentPets = network:invokeServer("getPlayerPets");
local changed = Instance.new("BindableEvent");
local binded = {};
local linkedPets = {};
local lowest = {};
local count = {};
local idleAnim = {};
local petId = 0;
local cacheSize = {};
local sizes = {};

local getAmountPets = function(plr)
	if(linkedPets[plr]) then
		return #linkedPets[plr];
	else
		return 0;
	end
end

local idle = function(iter)
	local limits = {0.8,1.5};
	local point = limits[2] - limits[1];
	idleAnim[iter] = idleAnim[iter] or {
		maxFluctuations = 85,
		floor = limits[1],
		roof = limits[2],
		fluctuations = 0,
		add = 1
	}
	idleAnim[iter].fluctuations += (idleAnim[iter].add);
	if(idleAnim[iter].fluctuations > idleAnim[iter].maxFluctuations) then
		idleAnim[iter].add = -1;
	elseif(idleAnim[iter].fluctuations < 1) then
		idleAnim[iter].add = 1;
	end
	
	return math.clamp(
		point + (idleAnim[iter].fluctuations * (0.01)),
		idleAnim[iter].floor,
		idleAnim[iter].roof
	);
end

local getSize = function(model)
	if(not cacheSize[model]) then
		local _,size = model:GetBoundingBox();
		cacheSize[model] = size.X;
	end
	return cacheSize[model];
end

local get = function(upTo)
	local total = 0;
	for k,v in pairs(sizes) do
		if(k <= upTo) then
			total += v;
		end
	end
	return total;
end

local linkPet = function(character,pet,player,iter)
	petId += 1;
	local key = petId;
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(character:GetFullName() ~= character.Name);
	local realPet = game:GetService("ReplicatedStorage"):WaitForChild("pets"):WaitForChild(pet,math.huge):Clone();
	linkedPets[player] = linkedPets[player] or {};
	lowest[player] = lowest[player] or {character,0};

	if(lowest[player][1] ~= character) then
		lowest[player] = {character,0};
	end

	table.insert(linkedPets[player],realPet);
	realPet.Parent = workspace:WaitForChild("pets");

	local root = character:WaitForChild("HumanoidRootPart");
	local bodyPos = Instance.new("BodyPosition",realPet.PrimaryPart);
	bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyPos.D = 750;

	local bodyGyro = Instance.new("BodyGyro",realPet.PrimaryPart)
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	realPet.Name = (player.Name .. iter);

	local signal;
	signal = game:GetService("RunService").Heartbeat:Connect(function()
		local s,e = pcall(function()
			local sx = realPet.PrimaryPart.Size.X;
			local xAxis = sx*iter-(getAmountPets(player)*sx);
			local x = ((xAxis + (xAxis/2))*1);

			if(x <= lowest[player][2]) then
				lowest[player][2] = x;
			end
			
			local cf = root.CFrame:ToWorldSpace(
				CFrame.new(x - (lowest[player][2]/2),idle(key),5)
			);

			bodyPos.Position = Vector3.new(cf.X,cf.Y,cf.Z);
			bodyGyro.CFrame = root.CFrame
		end)
		if(e and not s or (character:GetFullName() == character.Name)) then
			if(e and game:GetService("RunService"):IsStudio()) then
				warn(e);
			end
			signal:Disconnect();
		end
	end);
end

local unlinkPets = function(player)
	for p,linked in pairs(linkedPets) do
		if(p == player) then
			for _,pet in pairs(linked) do
				pet:Destroy();
			end
		end
	end
	linkedPets[player] = {};
	lowest[player] = nil;
	count[player] = 0;
end

local player = function(plr)
	local bindable,callbacks,args = {},{},{};

	function bindable:Fire(...)
		args = {...};
		for _,callback in pairs(callbacks) do
			coroutine.wrap(callback)(unpack(args));
		end
	end

	function bindable:Connect(callback)
		table.insert(callbacks,callback);
		if(#args > 0) then
			callback(unpack(args));
		end
	end

	binded[plr] = bindable;
	local character = function(char)
		bindable:Connect(function(pets)
			unlinkPets(plr);
			for iter,pet in pairs(pets) do
				count[plr] += 1;
				coroutine.wrap(function(i)
					linkPet(char,pet,plr,i);
				end)(count[plr]);
			end
		end)
	end

	plr.CharacterAdded:Connect(character);
	plr.CharacterRemoving:Connect(function()
		unlinkPets(plr);
	end)
	if(plr.Character) then
		character(plr.Character);
	end
end

network:bindRemoteEvent("playerPetUpdate",function(pets)
	currentPets = pets;
	changed:Fire(pets);
end)

changed.Event:Connect(function()
	for plr,data in pairs(currentPets) do
		coroutine.wrap(function()
			plr = game:GetService("Players"):WaitForChild(plr,math.huge);
			if(not binded[plr]) then
				repeat
					game:GetService("RunService").Heartbeat:Wait();
				until(binded[plr]);
			end
			binded[plr]:Fire(data);
		end)();
	end
end)

changed:Fire();

game:GetService("Players").PlayerAdded:Connect(player)
for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
	coroutine.wrap(player)(plr);
end
game:GetService("Players").PlayerRemoving:Connect(function(plr)
	unlinkPets(plr);
end)