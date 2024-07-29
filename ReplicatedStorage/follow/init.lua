local PetFollowModule = {}
local ModuleFunctions = {}

local Folders = {}

local Settings = require(script:WaitForChild("config"))
local LocalPlayer = game.Players.LocalPlayer

local YPoint = 0
local Addition = Settings.YDriftSpeed
local FullCircle = 2 * math.pi

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer();

local MasterFolder
local ReplicatedStorageFolder

MasterFolder =Settings.PetFolder
if(IsServer) then
	ReplicatedStorageFolder = Instance.new("Folder",game.ReplicatedStorage)
	ReplicatedStorageFolder.Name = "HiddenPets";
else
	ReplicatedStorageFolder = game:GetService("ReplicatedStorage"):WaitForChild("HiddenPets");
end

function SetPetCollisions(Model)
	for _, Part in pairs(Model:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part.CanCollide = false
			Part.Anchored = true
		end
	end
end

function getXAndZPositions(Angle, Radius)
	local x = math.cos(Angle) * Radius
	local z = math.sin(Angle) * Radius

	return x, z
end

function UpdatePetPositions()
	YPoint = YPoint + Addition
	if YPoint > Settings.YDrift or YPoint < -1 * Settings.YDrift then Addition = -1 * Addition end 

	for _, Folder in pairs(MasterFolder:GetChildren()) do
		local Player = game.Players[Folder.Name]
		local Character = Player.Character

		if Character  then
			local PetTable = Folder:GetChildren()
			local PetTableLength = #PetTable
			local Count = 0

			for _, Pet in pairs(PetTable) do
				Count += 1
				
				pcall(function()
					local Angle = Count * (FullCircle / PetTableLength)
					local X, Z = getXAndZPositions(Angle, Settings.Radius + (PetTableLength / 2))
					local Position = (Character.PrimaryPart.CFrame * CFrame.new(X, YPoint, Z)).p
					local LookAt = Character.PrimaryPart.Position
					local TargetCFrame = CFrame.new(Position, LookAt)

					local NewCFrame = Pet.PrimaryPart.CFrame:Lerp(TargetCFrame, Settings.Responsivness)
					Pet:SetPrimaryPartCFrame(NewCFrame)
				end)
			end
		end
	end
end

function ModuleFunctions:HideOthersPets()
	Settings.OtherPetsVisible = false

	for Id, Folder in pairs(MasterFolder:GetChildren()) do
		if Folder.Name ~= LocalPlayer.Name then
			Folder.Parent = ReplicatedStorageFolder
		end
	end
end

function ModuleFunctions:hidePets()
	Settings.AllPetsVisible = false

	for Id, Folder in pairs(MasterFolder:GetChildren()) do
		Folder.Parent = ReplicatedStorageFolder
	end
end

function ModuleFunctions:showPets(Player)
	if ReplicatedStorageFolder:FindFirstChild(Player.Name) then
		ReplicatedStorageFolder[Player.Name].Parent = game.Workspace
	end
end

function ModuleFunctions:showOtherPets()
	Settings.OtherPetsVisible = true

	for Id, Folder in pairs(ReplicatedStorageFolder:GetChildren()) do
		if Id ~= LocalPlayer.UserId then
			Folder.Parent = MasterFolder
		end
	end
end

function ModuleFunctions:showAllPets()
	Settings.AllPetsVisible = true

	for Id, Folder in pairs(ReplicatedStorageFolder:GetChildren()) do
		Folder.Parent = MasterFolder
	end
end

function ModuleFunctions:addPet(Player, Pet, Key)
	Key = Key and Key or Pet.Name

	local ClonedPet = Pet:Clone()
	ClonedPet.Name = Key
	local char = Player.Character;
	if(char) then
		ClonedPet:SetPrimaryPartCFrame(char.Head.CFrame);
	end
	SetPetCollisions(ClonedPet)

	ClonedPet.Parent = MasterFolder[Player.Name]
	return ClonedPet;
end

function ModuleFunctions:removePet(Player, Key)
	local Pet = MasterFolder[Player.Name]:FindFirstChild(Key)

	if Pet then
		Pet:Destroy()
	end
end

function AddPlayer(Player)
	if(IsServer) then
		Folders[Player.UserId] = Instance.new("Folder")
		Folders[Player.UserId].Name = Player.Name
		Folders[Player.UserId].Parent = MasterFolder
	end
end

function RemovePlayer(Player)
	MasterFolder[Player.Name]:Destroy()
end


if(IsServer) then
	game.Players.PlayerAdded:Connect(AddPlayer)
	game.Players.PlayerRemoving:Connect(RemovePlayer)

	for _, Player in pairs(game.Players:GetChildren()) do
		AddPlayer(Player)
	end
end

RunService:BindToRenderStep('Update', 1, UpdatePetPositions)

setmetatable(PetFollowModule, {__index = ModuleFunctions})
return PetFollowModule