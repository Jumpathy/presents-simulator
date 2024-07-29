local Configuration = {
	
	GeneralDetection = {
		--[[
			Error Catching will allow the system to listen for unknown errors and if present will take action. 
			If you don't know what you're doing, don't enable this.

			The possible options are listed below:
			A) Set to 'false' to disable this option. (all errors will be ignored) (DEFAULT)
			B) Set to 'true' to enable this option. All untraced errors will be detected. (RECOMMENDED)
			C) Set to an array containing the whitelisted errors that you want ignored. All other errors will trigger this detection (ADVANCED).
		--]]
		ErrorCatching = false;
		EnvironmentDetection = true; -- Attempts to detect unprotected environments used by exploits.
	};
	
	GuiDetection = { 
		InfiniteYield = true; -- Detects InfiniteYield, a popular command line exploit.
		CMDX = true; -- Detects CMDX, another popular command line exploit.
		Dex = true; -- Detects Dex, a popular explorer script.
	};
	
	WorkspaceModificationDetection = {		
		Gravity = { Maximum = 196.2; Minimum = 196.2; }; -- Maximum & minimum Workspace.Gravity allowed by the game.		
	};
	
	HumanoidModificationDetection = {
		WalkSpeed     = { Maximum = 32;    Minimum = 0;   }; -- Maximum & minimum Humanoid.WalkSpeed allowed by the game.	
		JumpPower     = { Maximum = 50;    Minimum = 0;   }; -- Maximum & minimum Humanoid.JumpPower allowed by the game.	
		HipHeight     = { Maximum = 4;     Minimum = 0;    }; -- Maximum & minimum Humanoid.HipHeight allowed by the game.	
		Health        = { Maximum = 100;   Minimum = 0;    }; -- Maximum & minimum Humanoid.Health allowed by the game.		
		MaxHealth     = { Maximum = 100;   Minimum = 0;    }; -- Maximum & minimum Humanoid.MaxHealth allowed by the game.	
		MaxSlopeAngle = { Maximum = 89;    Minimum = 0;    }; -- Maximum & minimum Humanoid.MaxSlopeAngle allowed by the game.		 
		JumpHeight    = { Maximum = 7.2;   Minimum = 7.2;  }; -- Maximum & minimum Humanoid.JumpHeight allowed by the game.	
	};
	
	CharacterModificationDetection = {
		DetectNoClip           = false; -- Detects noclipping.
		DetectSecondaryNoClip  = false; -- Detects noclipping using a secondary method. [Depending on the game, this can falsely detect]
		DetectFly              = true; -- Detects flying.
		DetectSecondaryFly     = true; -- Detects flying using a secondary method.
		DetectSpinFling        = true; -- Detects spin flinging.
		DetectVelocity         = true; -- Detects velocity cheats.
		DetectInfiniteJump     = true; -- Detects infinite jump.
		DetectHatModification  = true; -- Detects hat modification.
		DetectToolModification = true; -- Detects tool modification. (crashing, etc)
	};

	TeleportDetection = { -- Detects teleporting
		Enabled = true; -- Is anti-teleport enabled?
		AutoAdjustToWalkSpeed = true; -- [Decreases Efficacy] Automatically scales MaxMagnitude based on your WalkSpeed to prevent rubberbanding.
		MaxMagnitude = 25; -- [Recommended] Maximum distance that can be traveled before triggering detection.
		Interval = .1; -- [Recommended] Interval in which character positions will be polled and checked.
	};
	
	HandshakeSettings = { -- Handshake will allow the anticheat to periodically make sure the client is running.
		Enabled = true; -- [Recommended] Is the handshake enabled?
		Interval = 5; -- How often (in seconds) the handshake runs.
		TimeoutPeriod = 10; -- Amount of time the client has to respond to handshake.
	};

	ModerationSettings = {
		InitialDetectedAction     = "Kick"; -- This will trigger when somebody has been detected. Options: log, kick, ban
		MaxDetections             = 5;      -- Maximum detections until MaxDetectionReachedActioon is triggered.
		MaxDetectionReachedAction = "Ban";  -- This will trigger when MaxDetections is reached.
		Warnings                  = true;   -- Logs warnings for detections that aren't 100% accurate or stable.
		BypassList                = {};		-- The anticheat will not run for players in this list. [Accepts UserID or Username]
	};
	
	MiscSettings = {
		WebhookSettings = { -- These settings allow you to modify webhook logging to your Discord server.
			Enabled = false;
			Link = "LINK_TO_WEBHOOK_HERE";
			LogTypes = {"log", "kick", "ban"};
		};
		SimpleAdminSettings = { -- Configure SimpleAdmin integration features like logging, admins, and more...
			Enabled = false; -- SimpleAdmin must be installed for this to work. You must also set ExposeEnvironment to true.
			AdministratorBypass = true; -- Disables the anticheat for admins. (mod+)
			UseExploitLogs = true; -- Uses SimpleAdmin's exploitlogs command for logging activity.
		};
		AdonisSettings = { -- Configure Adonis integration features like auto-bypass and more...
			Enabled = false; -- Adonis must be installed with for this to work. You must also set G_API and G_Access to true along with G_Access_Key to match below.
			AccessKey = "SimpleAnticheat_Access"; -- This key must match the G_Access_Key in your Adonis configuration.
			AdministratorBypass = true; -- Disables the anticheat for admins. (mod+)
			UseExploitLogs = true; -- Uses Adonis' native exploitlogs command for logging activity
		};
		Crashing = not game:GetService("RunService"):IsStudio()
	};
}

local function FixFloatingPointErrors(Table)
	for Index, Value in pairs(Table) do	
		if type(Value) == "table" then
			Table[Index] = FixFloatingPointErrors(Value)
		elseif type(Value) == "number" then	
			if math.floor(Value) ~= Value or math.ceil(Value) ~= Value then 			
				if Index == "Minimum" then
					Table[Index] = Value - 0.1
				elseif Index == "Maximum" then
					Table[Index] = Value + 0.1
				end			
			end		
		end	
	end

	return Table
end

return FixFloatingPointErrors(Configuration)