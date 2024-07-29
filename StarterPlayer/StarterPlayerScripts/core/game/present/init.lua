local players = game:GetService("Players");
local debris = game:GetService("Debris");
local runService = game:GetService("RunService");

local present = {};
local tweening = require(script:WaitForChild("tweening"));
local style = Enum.EasingStyle.Linear;
local factor = 8; -- present size factor
local timeout = 15; -- destroy time internally if someth goes wrong
local response = 15; -- responsiveness to movement on the present when opening
local spinPower = 50; -- present spin power
local localPlayer = players.LocalPlayer;
local jumpathy = 1; -- 87424828
local testingAdmin = runService:IsStudio() and localPlayer.UserId == jumpathy;

local newProxyPart = function(parent)
	local proxyPart = Instance.new("Part");
	proxyPart.Parent = parent;
	proxyPart.Transparency = testingAdmin and 0.75 or 1;
	proxyPart.Anchored = false;
	proxyPart.CanCollide = false;
	return proxyPart;
end

local newAt = function(part)
	local attachment = Instance.new("Attachment");
	attachment.Parent = part;
	return attachment;
end

local align = function(part,toAlign)
	local alignPosition = Instance.new("AlignPosition");
	alignPosition.Parent = part;
	alignPosition.Attachment0 = newAt(part);
	alignPosition.Attachment1 = newAt(toAlign);
	alignPosition.Responsiveness = response;
end

local spin = function(part,power)
	local torque = Instance.new("Torque");
	torque.Parent = part;
	torque.Attachment0 = part:FindFirstChildOfClass("Attachment") or newAt(part);
	torque.Torque = Vector3.new(0,power or 10,0);
	torque.RelativeTo = Enum.ActuatorRelativeTo.World;
	return torque;
end

local spinSideways = function(part,power)
	spin(part,power).Torque = Vector3.new(power or 10,0,0);
end

local stop = function(part)
	part.Anchored = true;
end

local collect = function(timeOut,...)
	local arguments = {...};
	for _,part in pairs(arguments) do
		debris:AddItem(part,timeOut);
	end
end

local invis = function(model)
	for _,child in pairs(model:GetDescendants()) do
		if(child:IsA("BasePart")) then
			child.Transparency = 1;
			child.CanCollide = false;
		end
	end
end

local renderStepped = function(model,callback)
	local connection;
	connection = runService.RenderStepped:Connect(function()
		if(model:GetFullName() ~= model.Name) then
			callback();
		else
			connection:Disconnect();
		end
	end)
end

local particles = function(model)
	for _,child in pairs(model.inside:GetDescendants()) do
		if(child:IsA("ParticleEmitter")) then
			local x = (child:GetAttribute("Default") or 1/2);
			child.Transparency = NumberSequence.new(x,x);
		end
	end
end

local cached = {};

local playAnimation = function(player)
	local character = player.Character;
	local humanoid = character.Humanoid;
	local animator = humanoid:FindFirstChildOfClass("Animator");
	if(animator) then
		local array = cached[humanoid] or {};
		if(not array["rbxassetid://8365993290"]) then
		local animation = Instance.new("Animation");
			animation.AnimationId = "rbxassetid://8365993290";
			local loaded = animator:LoadAnimation(animation);
			loaded:Play()
			array[animation.AnimationId] = loaded;
		else
			array["rbxassetid://8365993290"]:Play();
		end
		cached[humanoid] = array;
	end
end

function present.new(raw,isNew)
	local methods = {};
	local lid;
	
	function methods:stop()
		if(lid) then
			lid:Destroy();
		end
	end
	
	function methods:fade(total)
		local total = total or {raw,lid}
		for _,model in pairs(total) do
			if(model ~= nil) then
				for _,descendant in pairs(model:GetDescendants()) do
					if(descendant:IsA("BasePart")) then
						descendant.CanCollide = false;
						if(descendant.Material == Enum.Material.Neon) then
							descendant.Transparency = 1;
						else
							tweening:tween(descendant,0.16,{["Transparency"] = 1},Enum.EasingStyle.Linear);
						end
					elseif(descendant:IsA("ParticleEmitter")) then
						descendant:Destroy();
					end
				end
			end
		end
	end
	
	function methods:begin()
		tweening:tweenModelSize(raw,(isNew and 0.5 or 0),factor);
	end
	
	function methods:open(cb)
		if(raw:GetAttribute("Region") == "area2") then
			for _,child in pairs(raw:GetChildren()) do
				if(child.Name == "Bottom" or child.Name == "Boxes") then
					child.Color = raw.BaseColor.Color;
				end
			end
		end
		
		local mainClone = raw:Clone();
		mainClone.Parent = workspace.Terrain;
		mainClone.Name = "Proxy";
		mainClone.Health:Destroy();
		invis(mainClone);
		
		local moving = mainClone.MovingPart;
		local part = newProxyPart(mainClone);
		part.CFrame = moving.CFrame;
		align(part,moving);
		
		local clone = part:Clone();
		local isMoving = false;
		local goalReached = false;
		collect(timeout,part,clone);
		spin(part,spinPower)
		
		renderStepped(raw,function()
			if((moving.Position.Y - raw.PrimaryPart.Position.Y) <= 0.1 and isMoving and not goalReached) then
				goalReached = true;
				part.Anchored = true;
			else
				raw:PivotTo(part.CFrame);
			end
		end)
		
		moving.CFrame = moving.CFrame + Vector3.new(0,1.75,0);
		isMoving = true;
		
		lid = raw.lid;
		local last = false;
		local ended = false;
		local coolClone;
		local pending = false;
		local lidMover;
		
		renderStepped(raw,function()
			if(pending) then
				return;
			end
			if(goalReached and not last) then
				local open = function()
					task.spawn(cb);
					particles(raw);
					lidMover = newProxyPart(mainClone.lid);
					lidMover.CFrame = lid.PrimaryPart.CFrame;
					coolClone = lid.PrimaryPart:Clone();
					coolClone.Parent = mainClone.lid;
					coolClone.Transparency = 1;
					align(lidMover,coolClone);
					coolClone.CFrame = coolClone.CFrame + Vector3.new(0,2,0);
					coolClone.Anchored = true
					last = true;
					playAnimation(localPlayer);
					task.spawn(function()
						task.wait(0.16)
						methods:fade({lid})
					end)
				end
				open()
			elseif(goalReached and last and not ended) then
				part.Anchored = true;
				lid:PivotTo(lidMover.CFrame);
				lid.Parent = workspace;
				local y1,y2 = lid.PrimaryPart.CFrame.Y,coolClone.CFrame.Y;
				if(y2-y1 <= 0.05) then
					ended = true;
					mainClone:Destroy();
				end
			end
		end)
	end
	
	return methods;
end

function present:getToyOffset()
	return Vector3.new(((math.random(100,225)/100)-1),((math.random(100,225)/100)-1),((math.random(100,225)/100)-1))
end

return present;