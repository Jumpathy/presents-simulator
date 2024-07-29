local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));

function resizeModel(model, a)
	local base = model.PrimaryPart.Position
	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Position = base:Lerp(part.Position, a)
			part.Size *= a
		end
	end
end

local function tweenModelSize(model, duration, factor, easingStyle, easingDirection)
	repeat
	game:GetService("RunService").Heartbeat:Wait();
	until(model.PrimaryPart and model.PrimaryPart:GetFullName() ~= model.PrimaryPart.Name);
	local s = factor - 1
	local i = 0
	local oldAlpha = 0
	while i < 1 do
		local dt = RunService.Heartbeat:Wait()
		i = math.min(i + dt/duration, 1)
		local alpha = TweenService:GetValue(i, easingStyle, easingDirection)
		resizeModel(model, (alpha*s + 1)/(oldAlpha*s + 1))
		oldAlpha = alpha
	end

	local bindable = Instance.new("BindableEvent");

	coroutine.wrap(function()
		wait(duration);
		bindable:Fire();
	end)();

	local tbl = {};

	tbl.Completed = bindable.Event;

	return tbl;
end

coroutine.wrap(function()
	local coreCall do
		local MAX_RETRIES = 8

		local StarterGui = game:GetService('StarterGui')
		local RunService = game:GetService('RunService')

		function coreCall(method, ...)
			local result = {}
			for retries = 1, MAX_RETRIES do
				result = {pcall(StarterGui[method], StarterGui, ...)}
				if result[1] then
					break
				end
				RunService.Stepped:Wait()
			end
			return unpack(result)
		end
	end

	assert(coreCall('SetCore', 'ResetButtonCallback', false))
end)();

local coins = function(humanoidRootPart)
	local spawnCoin = function()
		local baseOffset = Vector3.new(
			((math.random(100,225)/100)-1),
			((math.random(100,225)/100)-1),
			((math.random(100,225)/100)-1)
		)

		local rootOffset = Vector3.new(8,0,0)
		local inFront = workspace.NPCs["Buddy The Elf"].UpperTorso.CFrame;

		local mesh = game:GetService("ReplicatedStorage"):WaitForChild("meshes"):WaitForChild("coin"):Clone();
		local mesh,connection,heartbeat = mesh:Clone(),nil,0;
		local f = 3/4;
		local begin = tick();
		mesh.Parent = workspace.particles;
		mesh.CFrame = inFront;

		local f = 45000;

		local bodyPosition = Instance.new("BodyPosition",mesh);
		bodyPosition.Position = humanoidRootPart.Position;
		bodyPosition.MaxForce = Vector3.new(f,f,f);
		bodyPosition.D = (800);

		local collect = function()
			heartbeat:Disconnect();
			mesh:Destroy();
			local sound = Instance.new("Sound",humanoidRootPart);
			sound.RollOffMaxDistance = 250;
			sound.SoundId = "rbxassetid://5217941277";
			sound.Volume = 0.35;
			sound:Play();
		end

		local signal;
		signal = mesh.Touched:Connect(function(hit)
			if(hit.Parent == humanoidRootPart.Parent) then
				collect();
				signal:Disconnect();
			end
		end)

		heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
			if(bodyPosition:GetFullName() ~= bodyPosition.Name) then
				bodyPosition.Position = humanoidRootPart.Position;
				if((tick()-begin) > 2) then
					collect();
				end
			else
				heartbeat:Disconnect();
			end
		end)
	end
	spawnCoin();
end

local linkSound = function(part,id)
	if(not game:GetService("Players").LocalPlayer:GetAttribute("Sfx")) then
		return;
	end
	local sound = Instance.new("Sound",part);
	sound.RollOffMaxDistance = 250;
	sound.SoundId = id;
	sound:Play();
	sound.Stopped:Connect(function()
		sound:Destroy();
	end)
end

local general = function(class,...)
	if(class == "cashNoise") then
		local part = ({...})[1];
		linkSound(part,"rbxassetid://6658761720");
	elseif(class == "giveCoins") then
		local root = ({...})[1];
		coins(root);
	end
end

local size = function(model,factor,state)
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	tweenModelSize(model,(state and 0.35 or 0),factor,Enum.EasingStyle.Bounce,Enum.EasingDirection.InOut).Completed:Connect(function()
		model:WaitForChild("Health",math.huge).Enabled = true;
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

	local baseOffset = Vector3.new(
		((math.random(100,225)/100)-1),
		((math.random(100,225)/100)-1),
		((math.random(100,225)/100)-1)
	)

	local toy = toys[math.random(1,#toys)];
	local toy,connection,heartbeat = toy:Clone(),nil,0;
	local f = 3/4;
	local begin = tick();
	toy.Parent = workspace.particles;
	toy.Position = positions[math.random(1,#positions)] + baseOffset;
	toy.Size = Vector3.new(
		toy.Size.X * (f),
		toy.Size.Y * (f),
		toy.Size.Z * (f)
	)

	local origin = toy.Position;
	local f = 48000;

	local bodyPosition = Instance.new("BodyPosition",toy);
	bodyPosition.Position = base.Position;
	bodyPosition.MaxForce = Vector3.new(f,f,f);
	bodyPosition.D = (935);

	local collect = function()
		heartbeat:Disconnect();
		toy:Destroy();
		local sound = Instance.new("Sound",base);
		sound.RollOffMaxDistance = 250;
		sound.SoundId = "rbxassetid://5217941277";
		sound:Play();
		sound.Volume = 0.3;
		network:fireServer("randomReward",gift);
	end

	local signal;
	signal = toy.Touched:Connect(function(hit)
		if(hit.Parent == character) then
			collect();
			signal:Disconnect();
		end
	end)

	heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
		if(bodyPosition:GetFullName() ~= bodyPosition.Name) then
			bodyPosition.Position = base.Position + baseOffset;
			if((tick()-begin) > (2) or (toy.Position - origin).magnitude >= 13) then
				collect();
			end
		else
			heartbeat:Disconnect();
		end
	end)
end

local gift = function(parent,player)
	parent.Health.Enabled = false;

	pcall(function()
		parent.Selected.Image.Texture = "";
	end)	
	
	local begin = tick();
	local connection;
	local completed = false;
	local rootBase = Instance.new("Part")
	rootBase.TopSurface = "Smooth"
	rootBase.BottomSurface = "Smooth"
	rootBase.Anchored = true
	rootBase.Size = Vector3.new(2, 2, 2)
	rootBase.Transparency = 1
	rootBase.CanCollide = false
	rootBase.Name = "Root"

	local function setupJoints(model)
		local base = model.PrimaryPart
		local root = rootBase:Clone()
		model:BreakJoints()
		for _, part in next, model:GetDescendants() do
			if part:IsA("BasePart") and part ~= base then
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = base
				weld.Part1 = part
				weld.Parent = part
				part.Anchored = false
			end
		end
		base.Anchored = false
		root.CFrame = base.CFrame
		root.Parent = model
		local anchorWeld = Instance.new("Motor6D")
		anchorWeld.Part0 = root
		anchorWeld.Part1 = base
		anchorWeld.Parent = root
		return root
	end

	local roots = {}
	for _, model in next,{parent} do
		local rootPart = setupJoints(model)
		roots[#roots + 1] = {rootPart, rootPart.CFrame}
	end

	local begin = tick()
	local rate = 360*1.25

	local tweenService = game:GetService("TweenService")
	local info = TweenInfo.new(0.35);

	local function tweenModel(model, CF)
		local CFrameValue = Instance.new("CFrameValue")
		CFrameValue.Value = model:GetPrimaryPartCFrame()

		CFrameValue:GetPropertyChangedSignal("Value"):Connect(function()
			model:SetPrimaryPartCFrame(CFrameValue.Value)
		end)

		local tween = tweenService:Create(CFrameValue, info, {Value = CF})
		tween:Play()

		tween.Completed:Connect(function()
			CFrameValue:Destroy()
		end)
	end

	local toys = function(owner)
		local positions = {};
		for _,part in pairs(parent.toySpawns:GetChildren()) do
			table.insert(positions,part.Position);
		end

		local character = owner.Character;
		local toys = game:GetService("ReplicatedStorage"):WaitForChild("toys"):WaitForChild(parent:GetAttribute("ToyType")):GetChildren();
		local id = parent:GetAttribute("ID");
		
		for key,toy in pairs(toys) do
			if(toy:GetAttribute("Chance") ~= nil) then
				local num = math.random(1,50);
				if(num ~= toy:GetAttribute("Chance")) then
					table.remove(toys,key);
				end
			end
		end

		local linkToy = function(base)
			local baseOffset = Vector3.new(
				((math.random(100,225)/100)-1),
				((math.random(100,225)/100)-1),
				((math.random(100,225)/100)-1)
			)

			local toy = toys[math.random(1,#toys)];
			local toy,connection,heartbeat = toy:Clone(),nil,0;
			local f = 3/4;
			local begin = tick();
			toy.Parent = workspace.particles;
			toy.Position = positions[math.random(1,#positions)] + baseOffset;
			toy.Size = Vector3.new(
				toy.Size.X * (f),
				toy.Size.Y * (f),
				toy.Size.Z * (f)
			)
			
			local origin = toy.Position;
			local f = 48000;

			local bodyPosition = Instance.new("BodyPosition",toy);
			bodyPosition.Position = base.Position;
			bodyPosition.MaxForce = Vector3.new(f,f,f);
			bodyPosition.D = (935);

			local collect = function()
				heartbeat:Disconnect();
				toy:Destroy();
				local sound = Instance.new("Sound",base);
				sound.RollOffMaxDistance = 250;
				sound.SoundId = "rbxassetid://5217941277";
				sound:Play();
				sound.Volume = 0.3;
				network:invokeServer("giveToys",parent);
			end

			local signal;
			signal = toy.Touched:Connect(function(hit)
				if(hit.Parent == character) then
					collect();
					signal:Disconnect();
				end
			end)

			heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
				if(bodyPosition:GetFullName() ~= bodyPosition.Name) then
					bodyPosition.Position = base.Position + baseOffset;
					if((tick()-begin) > (2) or (toy.Position - origin).magnitude >= 13 or (toy.Position - base.Position).magnitude <= 3) then
						collect();
					end
				else
					heartbeat:Disconnect();
				end
			end)
		end

		local limit = (parent:GetAttribute("Reward"));
		for i = 1,limit do
			wait(1.25/limit);
			linkToy(character.HumanoidRootPart);
		end
	end

	local stopped,toysOut = false,false;
	local stopit_getsomehelp = function()
		if(not stopped) then
			stopped = true;
			local linked = (network:invokeServer("getLinked",parent:GetAttribute("ID")));
			if(table.find(linked,game.Players.LocalPlayer)) then
				local sound = Instance.new("Sound",parent.inside);
				sound.SoundId = "rbxassetid://662290183";
				sound:Play();
			end
			connection:Disconnect();
			for k,v in pairs(parent:GetDescendants()) do
				if(v:IsA("WeldConstraint") or v:IsA("Motor6D")) then
					v:Destroy();
				end
			end
			for k,v in pairs(parent:GetDescendants()) do
				if(v:IsA("BasePart")) then
					v.Anchored = true;
					if(v.Parent == parent.lid) then
						v.CanCollide = false;
					end
				end
			end

			tweenModel(parent.lid,parent.lid.Base.CFrame + Vector3.new(0,2,0));
			coroutine.wrap(function()
				for _,child in pairs(parent.inside:GetDescendants()) do
					if(child:IsA("ParticleEmitter")) then
						local x = (child:GetAttribute("Default") or 1/2);
						child.Transparency = NumberSequence.new(x,x);
					end
				end
			end)();
			for k,v in pairs(parent.lid:GetChildren()) do
				local tween = tweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1});
				tween:Play();
				tween.Completed:Connect(function()
					local linked = (network:invokeServer("getLinked",parent:GetAttribute("ID")));
					if(table.find(linked,game.Players.LocalPlayer)) then
						if(not toysOut) then
							toysOut = true;
							toys(game.Players.LocalPlayer);
						end
					end
				end)
			end
			wait(2.5);
			for k,v in pairs(parent:GetDescendants()) do
				if(v:IsA("BasePart")) then
					coroutine.wrap(function()
						wait(0.15);
						for _,child in pairs(parent.inside:GetDescendants()) do
							if(child:IsA("ParticleEmitter")) then
								child.Transparency = NumberSequence.new(1,1);
							end
						end
					end)();
					v.CanCollide = false;
					local tween = tweenService:Create(v, TweenInfo.new(0.5), {Transparency = 1});
					tween:Play();
				end
			end
		end
	end

	local roof = 1.5;

	local getVector = function()
		local begin = ((tick()-begin) * 15);
		if(math.clamp(begin/5,0,roof) == roof) then
			stopit_getsomehelp();
		end
		return(Vector3.new(0,math.clamp(begin/4.5,0,roof),0));
	end

	connection = game:GetService("RunService").Stepped:Connect(function(dt)
		local since = tick() - begin
		local degrees = since*rate
		local wrapped = degrees%360
		local radians = math.rad(wrapped)
		local rotation = CFrame.Angles(0, radians, 0)
		for i = 1, #roots do
			local info = roots[i]
			info[1].CFrame = info[2]*rotation + getVector();
		end
	end)
end

local scale = function(module,...)
	require(module)(...)["function"]();
end

local queue = function(...)
	local args = {...};
	for i = 1,math.random(3,5) do
		game:GetService("RunService").Heartbeat:Wait();
	end
	gift(unpack(args));
end

network:bindRemoteEvent("randomReward",reward);
network:bindRemoteEvent("size",size);
network:bindRemoteEvent("giftAnimation",queue);
network:bindRemoteEvent("generalAnimation",general);
network:bindRemoteEvent("scaleGui",scale);
network:fireServer("clientLoaded");

local areas = workspace:WaitForChild("areas");
local area1 = areas:WaitForChild("area1");

--[[
local spinningObjects = {
	area1:WaitForChild("sell"):WaitForChild("SellPart"):WaitForChild("Rounded");
	area1:WaitForChild("shop"):WaitForChild("ShopPart"):WaitForChild("Rounded");
}

for _,v in pairs(spinningObjects) do
	game:GetService("TweenService"):Create(v,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut,-1),{CFrame = v.CFrame * CFrame.Angles(math.rad(8),0,0)}):Play();
end
]]

local getClass = function(parent,class,object)
	repeat
		object = parent:FindFirstChildOfClass(class);
		game:GetService("RunService").Heartbeat:Wait();
	until(object ~= nil);
	return object;
end

local cached = {};
local ts = game:GetService("TweenService");
local info = TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut);

local wrap = function(child)
	if(child.Name == "FlyingOrbs" and (not cached[child]) and child:IsA("Tool")) then
		cached[child] = true;
		local smaller = child:WaitForChild("Handle");
		local orbs = getClass(smaller,"MeshPart");
		if(orbs) then
			local new = function()
				local arguments = {orbs,info,{Orientation = orbs.Orientation + Vector3.new(180,360,180)}}
				return ts:Create(
					unpack(arguments)
				)
			end
			
			local play;
			play = function()
				local tween = new();
				tween:Play();
				tween.Completed:Connect(function()
					if(child:GetFullName() ~= child.Name) then
						play();
					end
				end)
			end
			play();
		end
	end
end

workspace.DescendantAdded:Connect(wrap);
for _,child in pairs(workspace:GetDescendants()) do
	coroutine.wrap(wrap)(child);
end