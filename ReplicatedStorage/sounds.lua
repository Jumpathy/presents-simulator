local sounds = {};
local localPlayer = game:GetService("Players").LocalPlayer;

sounds.library = {
	equip = "rbxassetid://169310310", --> equip noise
	unlocked = "rbxassetid://2789429656", --> stage unlock
	daily = "rbxassetid://2789429097", --> daily reward thing
	hatch = "rbxassetid://4050540792",
	rewardUnlock = "rbxassetid://4612378086",
	levelUp = "rbxassetid://6079105785",
	purchaseDevProduct = "rbxassetid://5736400107",
	hover = "rbxassetid://6333717580"
}

function sounds.play(id,volume,startAt)
	if(localPlayer:GetAttribute("Sfx")) then
		local sound = Instance.new("Sound",workspace:WaitForChild("sounds"));
		sound.Volume = (volume or 1);
		sound.SoundId = id;
		sound.TimePosition = (startAt or 0);
		sound:Play();
		sound.Ended:Connect(function()
			sound:Destroy();
		end)
	end
end

return sounds;