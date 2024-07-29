--> Services
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--> Configuration
local StartPlaceId = 7457510014 -- CHANGE: Enter your start place's id here
local MigrationPlaceId = 8232418004 -- CHANGE: Enter your Migration place's id here
local ReserveCharacterPosition = false -- CHANGE: true/false, depending on if you want this

----

local function CFrameToArray(CoordinateFrame: CFrame)
	return {CoordinateFrame:GetComponents()}
end

local function ArrayToCFrame(a)
	return CFrame.new(table.unpack(a))
end

if game.PlaceId == MigrationPlaceId then
	--// SoftShutdown place in the universe
	local Player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
	local TeleportData = Player:GetJoinData().TeleportData

	task.wait(3)

	-- Keep the server alive for longer to make sure all players get teleported back.
	game:BindToClose(function()
		while Players:GetPlayers()[1] do
			task.wait(1)
		end
	end)

	-- Teleport all the players back into a reserved server under the place.
	local TeleportOptions = Instance.new("TeleportOptions")
	TeleportOptions:SetTeleportData({
		CharacterCFrames = TeleportData.CharacterCFrames or {}
	})

	while true do
		xpcall(function()
			local TeleportResult = TeleportService:TeleportAsync(
				TeleportData.ReturnPlaceId or StartPlaceId,
				Players:GetPlayers(),
				TeleportOptions
			)
		end, warn)
		task.wait(2.5)
	end
else
	--// Regular server (Outside of 'Migrate' place)
	game:BindToClose(function()
		if RunService:IsStudio() or not Players:GetPlayers()[1] then
			return
		end

		-- Optional: Reserve character positions in the world
		local CharacterCFrames = {}
		if ReserveCharacterPosition then
			for _, Player in ipairs(Players:GetPlayers()) do
				local Character = Player.Character
				local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

				if HumanoidRootPart then
					CharacterCFrames[Player.UserId] = CFrameToArray(HumanoidRootPart.CFrame)
				end
			end
		end

		-- Teleport the player(s)
		local TeleportOptions = Instance.new("TeleportOptions")
		TeleportOptions.ShouldReserveServer = true
		TeleportOptions:SetTeleportData({
			IsSoftShutdown = true,
			ReturnPlaceId = game.PlaceId,
			CharacterCFrames = CharacterCFrames
		})

		local TeleportResult = TeleportService:TeleportAsync(
			MigrationPlaceId,
			Players:GetPlayers(),
			TeleportOptions
		)

		-- Keep the server alive until all of the player(s) have been teleported.
		while Players:GetPlayers()[1] do
			task.wait(1)
		end
	end)

	local function OnPlayerAdded(Player: Player)
		local TeleportData = Player:GetJoinData().TeleportData
		local CoordinateFrame = TeleportData and TeleportData.CharacterCFrames[tostring(Player.UserId)]

		-- Teleport the player to their original position, returned from the Migration place.
		if CoordinateFrame then
			local Character = Player.Character or Player.CharacterAdded:Wait()

			if not Player:HasAppearanceLoaded() then
				Player.CharacterAppearanceLoaded:Wait()
			end
			task.wait(0.2) -- Roblox race conditions
			Character:PivotTo(ArrayToCFrame(CoordinateFrame))
		end
	end

	local Connection = Players.PlayerAdded:Connect(OnPlayerAdded)
	for _, Player: Player in ipairs(Players:GetPlayers()) do
		OnPlayerAdded(Player)
	end

	task.wait(60) -- Give time for the party to join back, then disconnect the connection as we no longer need it.
	Connection:Disconnect()
end