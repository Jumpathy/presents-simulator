local runService = game:GetService("RunService")
local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));
local present = require(script:WaitForChild("present"));
local localPlayer = game:GetService("Players").LocalPlayer;
local presents = {};

local newSound = function(part,id)
	if(not game:GetService("Players").LocalPlayer:GetAttribute("Sfx")) then
		return {};
	end
	local sound = Instance.new("Sound",part);
	sound.RollOffMaxDistance = 250;
	sound.SoundId = id;
	sound:Play();
	sound.Stopped:Connect(function()
		sound:Destroy();
	end)
	return sound;
end

local sfxCallback = function(class,...)
	if(class == "cashNoise") then
		local part = ({...})[1];
		newSound(part,"rbxassetid://6658761720");
	end
end

local size = function(model,factor,state)
	if(model ~= nil) then
		presents[model] = present.new(model,state);
		presents[model]:begin();
	end
end

local linkToyToPart = function(root,toys,gift,callback)
	local character = root.Parent;
	local positions = {};
	for _,part in pairs(gift.toySpawns:GetChildren()) do
		table.insert(positions,part.Position);
	end
	
	local toy,heartbeat = toys[math.random(1,#toys)]:Clone(),0;
	local beganAt = tick();
	toy.Parent = workspace.particles;
	toy.Position = positions[math.random(1,#positions)] + present:getToyOffset();
	toy.Size = Vector3.new(toy.Size.X * 0.75,toy.Size.Y * 0.75,toy.Size.Z * 0.75);

	local origin = toy.Position;			
	local align = Instance.new("AlignPosition");
	align.Parent = toy;

	local at1 = Instance.new("Attachment");
	local at2 = Instance.new("Attachment");
	at1.Parent = root;
	at2.Parent = toy;

	align.Attachment0 = at2;
	align.Attachment1 = at1;

	local collect = function()
		heartbeat:Disconnect();
		toy:Destroy();
		newSound(root,"rbxassetid://5217941277").Volume = 0.3;
		callback()
	end

	local signal;
	signal = toy.Touched:Connect(function(hit)
		if(hit.Parent == character) then
			collect();
			signal:Disconnect();
		end
	end)

	heartbeat = runService.Heartbeat:Connect(function()
		if(align:GetFullName() ~= align.Name) then
			if((tick() - beganAt) > 4.5 or (toy.Position - origin).magnitude >= 13 or (toy.Position - root.Position).magnitude <= 1.5) then
				collect();
			end
		else
			heartbeat:Disconnect();
		end
	end)
end

local reward = function(gift)
	local base = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart;
	local positions = {};
	for _,part in pairs(gift.toySpawns:GetChildren()) do
		table.insert(positions,part.Position);
	end

	local character = base.Parent;
	local toys = game:GetService("ReplicatedStorage"):WaitForChild("toys"):WaitForChild(gift:GetAttribute("ToyType")):GetChildren();
	local id = gift:GetAttribute("ID");

	for key,toy in pairs(toys) do
		if(toy:GetAttribute("Chance") ~= nil) then
			local num = math.random(1,50);
			if(num ~= toy:GetAttribute("Chance")) then
				table.remove(toys,key);
			end
		end
	end
	
	linkToyToPart(base,toys,gift,function()
		network:fireServer("randomReward",gift);
	end)
end

local onGiftOpened = function(gift,player)
	local manager = presents[gift];
	pcall(function()
		gift.Health.Enabled = false;
		gift.Selected.Image.Texture = "";
	end)	

	local toys = function(owner)
		local positions = {};
		for _,part in pairs(gift.toySpawns:GetChildren()) do
			table.insert(positions,part.Position);
		end

		local character = owner.Character;
		local toys = game:GetService("ReplicatedStorage"):WaitForChild("toys"):WaitForChild(gift:GetAttribute("ToyType")):GetChildren();
		local id = gift:GetAttribute("ID");

		for key,toy in pairs(toys) do
			if(toy:GetAttribute("Chance") ~= nil) then
				local num = math.random(1,50);
				if(num ~= toy:GetAttribute("Chance")) then
					table.remove(toys,key);
				end
			end
		end
		
		local repeatCount = gift:GetAttribute("Reward");
		for i = 1,repeatCount do
			task.wait(1.25/repeatCount);
			linkToyToPart(character.HumanoidRootPart,toys,gift,function()
				network:invokeServer("giveToys",gift);
			end);
		end
		manager:fade();
	end

	local onLidOpened = function()
		local associatedPlayers = (network:invokeServer("getLinked",gift:GetAttribute("ID")));
		if(table.find(associatedPlayers,localPlayer)) then
			if(localPlayer:GetAttribute("Sfx")) then
				local sound = Instance.new("Sound",gift.inside);
				sound.SoundId = "rbxassetid://662290183";
				sound:Play();
			end
			toys(localPlayer);
		end
	end

	manager:open(onLidOpened);
	local removedSignal;
	removedSignal = gift.Parent.ChildRemoved:Connect(function(child)
		if(child == gift) then
			manager:stop();
			removedSignal:Disconnect();
			presents[present] = nil;
		end
	end)
end

local scale = function(module,...)
	require(module)(...)["function"]();
end

local queue = function(...)
	onGiftOpened(...);
end

network:bindRemoteEvent("randomReward",reward);
network:bindRemoteEvent("size",size);
network:bindRemoteEvent("giftAnimation",queue);
network:bindRemoteEvent("generalAnimation",sfxCallback);
network:bindRemoteEvent("scaleGui",scale);
network:fireServer("clientLoaded");

local areas = workspace:WaitForChild("areas");
local area1 = areas:WaitForChild("area1");


