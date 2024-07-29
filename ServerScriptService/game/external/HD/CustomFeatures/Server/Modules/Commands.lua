-- << RETRIEVE FRAMEWORK >>
local main = _G.HDAdminMain
local settings = main.settings



-- << COMMANDS >>
local module = {

	-----------------------------------
	{
		Name = "backpacksize";
		Aliases	= {};
		Prefixes = {settings.Prefix};
		Rank = 1;
		RankLock = false;
		Loopable = false;
		Tags = {};
		Description = "";
		Contributors = {};
		--
		Args = {"player","number"};
		Function = function(speaker, args)
			local plr = args[1];
			if(plr) then
				if(type(args[2]) == "number") then
					plr:SetAttribute("backpackSize",args[2]);
				end
			end
		end;
		UnFunction = function(speaker, args)

		end;
		--
	};
	
	{
		Name = "coins";
		Aliases	= {};
		Prefixes = {settings.Prefix};
		Rank = 5;
		RankLock = false;
		Loopable = false;
		Tags = {};
		Description = "";
		Contributors = {};
		--
		Args = {"player","string"};
		Function = function(speaker, args)
			args[1].leaderstats.Coins.Real.Value = args[2];
		end;
		UnFunction = function(speaker, args)
		end;
		--
	};

	{
		Name = "modifytool";
		Aliases	= {};
		Prefixes = {settings.Prefix};
		Rank = 1;
		RankLock = false;
		Loopable = false;
		Tags = {};
		Description = "";
		Contributors = {};
		--
		Args = {"player","number","number"};
		Function = function(speaker, args)
			local plr = args[1];
			local del = 0.5;
			if(args[3]) then
				del = tonumber(args[3]) or 0.5;
			end
			local tool = plr.Character:FindFirstChild("Raygun") or plr.Backpack:FindFirstChild("Raygun");
			if(tool) then
				tool:SetAttribute("Damage",args[2])
				tool:SetAttribute("Delay",del);
			end
		end;
		UnFunction = function(speaker, args)
		end;
		--
	};


	{
		Name = "pets_test";
		Aliases	= {};
		Prefixes = {settings.Prefix};
		Rank = 1;
		RankLock = false;
		Loopable = false;
		Tags = {};
		Description = "";
		Contributors = {};
		--
		Args = {"player"};
		Function = function(speaker, args)
			shared.abuse(args[1]);
		end;
		UnFunction = function(speaker, args)
			shared.wipe(args[1]);
		end;
		--
	};



	-----------------------------------
	{
		Name = "";
		Aliases	= {};
		Prefixes = {settings.Prefix};
		Rank = 1;
		RankLock = false;
		Loopable = false;
		Tags = {};
		Description = "";
		Contributors = {};
		--
		Args = {};
	--[[
	ClientCommand = true;
	FireAllClients = true;
	BlockWhenPunished = true;
	PreFunction = function(speaker, args)
		
	end;
	Function = function(speaker, args)
		wait(1)
	end;
	--]]
		--
	};




	-----------------------------------

};



return module
