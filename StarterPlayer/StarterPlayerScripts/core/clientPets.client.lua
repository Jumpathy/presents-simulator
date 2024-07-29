local state,change = true,Instance.new("BindableEvent");

shared.pet_state = function(new)
	state = new;
	change:Fire()
end

repeat
	game:GetService("RunService").Heartbeat:Wait();
until(shared.gameLoaded);

local module = require(game:GetService("ReplicatedStorage"):WaitForChild("follow"));
local hatchModuleVisual = require(workspace:WaitForChild("extra"):WaitForChild("lab"):WaitForChild("primary"));
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
local players,starterGui,guis = game:GetService("Players"),game:GetService("StarterGui"),game:GetService("GuiService");
local library = shared.gui_library;
local hatchNoise = library.sound.library.hatch;
local rewardNoise = library.sound.library.rewardUnlock;
local ambient = workspace:WaitForChild("MainMusic");

local localPlayer = players.LocalPlayer;
local controls = require(localPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule")):GetControls();
local youGot = localPlayer.PlayerGui.Overlay.YouGot;
game:GetService("TweenService"):Create(youGot:WaitForChild("Burst"),TweenInfo.new(
	6, -- The time the tween takes to complete
	Enum.EasingStyle.Linear, -- The tween style in this case it is Linear
	Enum.EasingDirection.Out, -- EasingDirection
	-1, -- How many times you want the tween to repeat. If you make it less than 0 it will repeat forever.
	false, -- Reverse?
	0 -- Delay
),{Rotation = 360}):Play();

local setControlsEnabled = function(state)
	starterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All,state);
	guis.TouchControlsEnabled = state;
	controls[state and "Enable" or "Disable"](controls);
	localPlayer.PlayerGui.UI.Enabled = state;
end

local cameraDefault = function()
	local cam = workspace.CurrentCamera;
	cam.CameraType = Enum.CameraType.Custom;
	cam.CameraSubject = localPlayer.Character.Humanoid;
end

local toLab = function()
	local cam = workspace.CurrentCamera;
	cam.CameraType = Enum.CameraType.Scriptable;
	cam.CFrame = workspace:WaitForChild("extra"):WaitForChild("lab"):WaitForChild("Camera").CFrame;
end

local blur = function(strength)
	library:tween(game:GetService("Lighting").Blur,{
		["Size"] = strength
	},0.16);
end

local discount = function(base)
	local model = base.Parent.Parent.Parent;
	local cost = model:GetAttribute("Price");
	return math.floor((cost * 3) * 0.75);
end

local hatch = function(state,base,pet,array)
	if(state == "init") then
		if(localPlayer:GetAttribute("HatchMorePets")) then
			library:modal(("Would you like to hatch 3 eggs instead of 1 for %s coins?"):format(discount(base)),function(response)
				network:fireServer("hatch",base,(response and 3 or 1));
			end)
		else 
			network:fireServer("hatch",base);
		end
	elseif(state == "doHatch") then
		setControlsEnabled(false);
		toLab();
		hatchModuleVisual(base:GetAttribute("BaseColor"),base:GetAttribute("CrystalColor")):Connect(function(status,len)
			if(status == "shaking") then
				shared.ambient_volume(0.1);
				library.util.wait(len * 3);
				library.sound.play(hatchNoise,2.35);
			end
			if(status == "opening") then
				local pointer = 1;
				if(#array >= 2) then
					youGot.Claim.Visible = false;
					youGot.Next.Visible = true;
					youGot.Next.Txt.Text = "Next (1/"..#array..")";
				else
					youGot.Claim.Visible = true;
					youGot.Next.Visible = false;
				end
				youGot.Tier["Gradient"].Color = youGot.Tier.Gradients[pet.tier].Color;
				youGot.Tier.Txt.Text = pet.displayName;
				youGot.Icon.Image = pet.image;
				youGot.Size = UDim2.new(0,0,0.424,0);
				youGot.Burst.Size = UDim2.new(0,0,0,0);
				youGot.Visible = false;
				library.util.wait(0.75);
				blur(20);
				youGot.Visible = true;
				youGot:TweenSize(UDim2.new(0.2,0,0.424,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.2,true);
				youGot.Burst:TweenSize(UDim2.new(2.857,0,2.373,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.3,true);
				library.util.wait(0.15);
				library.sound.play(rewardNoise);
				local connect = function()
					local signal;
					signal = youGot.Claim.MouseButton1Click:Connect(function()
						blur(0);
						youGot.Burst:TweenSize(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.16,true);
						youGot:TweenSize(UDim2.new(0,0,0.424,0),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.2,true,function()
							youGot.Visible = true;
						end)
						signal:Disconnect();
						shared.ambient_volume();
						cameraDefault();
						setControlsEnabled(true);
					end)
				end
				
				for _,pet in pairs(array) do
					local success,err = pcall(function()
						shared.just_unlocked(pet);
					end)
					if(err and not success) then
						warn("[pet error]",err)
					end
				end
				
				if(#array >= 2) then
					local signal;
					signal = youGot.Next.MouseButton1Click:Connect(function()
						if(pointer + 1 <= #array) then
							pointer += 1;
							local pet = array[pointer];
							youGot.Tier["Gradient"].Color = youGot.Tier.Gradients[pet.tier].Color;
							youGot.Tier.Txt.Text = pet.displayName;
							youGot.Icon.Image = pet.image;
							
							youGot.Next.Txt.Text = "Next ("..pointer.."/"..#array..")";
							if(pointer == #array) then
								youGot.Claim.Visible = true;
								youGot.Claim.Visible = false;
								youGot.Claim.Visible = true;
								youGot.Claim.Txt.Visible = false;
								youGot.Claim.Txt.Visible = true;
								youGot.Next.Visible = false;
							end
						end
					end)
				end
				connect();
			end
		end)
	elseif(state == "notEnough") then
		library:notify("You don't have enough coins to buy a pet!");
	elseif(state == "limit") then
		library:notify("You've reached your limit of pets!");
	end
end

network:bindRemoteEvent("hatch",hatch);

local try = function(state)
	if(state) then
		module:showOtherPets()
	else
		module:HideOthersPets()
	end
end
change.Event:Connect(function(new)
	try(state);
end)
try(state);