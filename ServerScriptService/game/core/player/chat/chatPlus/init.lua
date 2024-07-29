--[[
	   _____ _           _     _____  _           
	  / ____| |         | |   |  __ \| |          
	 | |    | |__   __ _| |_  | |__) | |_   _ ___ 
	 | |    | '_ \ / _` | __| |  ___/| | | | / __|
	 | |____| | | | (_| | |_  | |    | | |_| \__ \
	  \_____|_| |_|\__,_|\__| |_|    |_|\__,_|___/
	                                              
	  Version: 1.0.0
	  Author: @Jumpathy
	  Description: Making modifications to the default chat system easier.
      Credit: 
	    - @stravant (custom signal module) https://devforum.roblox.com/t/lua-signal-class-comparison-optimal-goodsignal-class/1387063
	    - @TheCarbyneUniverse (rainbow gradient) https://devforum.roblox.com/t/4-uigradient-animations-including-rainbow/557922
]]


-- Module init

local chatPlus,internal,configuration = {},{
	services = {
		serverScripts = game:GetService("ServerScriptService"),
		players = game:GetService("Players"),
		replicatedFirst = game:GetService("ReplicatedFirst"),
		marketplace = require(script:WaitForChild("marketplace")) --> psuedo wrapper made by me
	},
	signal = require(script:WaitForChild("signal"))
},{
	doTypeCheck = true --> recommended for people who have no idea what they're doing
}

-- Initialize chat service

local primary = {};

-- don't change the variable below unless you know what you're doing
local placeholderImage = "😃"; -->  when you use an image in a tag, this is what the tag text is so there's space for the image itself

function chatPlus:onPlayer(callback)
	for _,player in pairs(internal.services.players:GetPlayers()) do
		coroutine.wrap(callback)(player);
	end
	internal.services.players.PlayerAdded:Connect(callback);
end

function chatPlus:setConfig(config:table)
	local clientScript = internal.services.replicatedFirst:WaitForChild("chatConfig");
	for k,v in pairs(config) do
		clientScript:SetAttribute(k,v);
	end
end

-- Functions

local yielding,state = internal.signal.new(),true;
local add = function()
	local runner = internal.services.serverScripts:WaitForChild("ChatServiceRunner",math.huge);
	local chatService = require(runner:WaitForChild("ChatService",math.huge));

	task.spawn(function()
		local tags = {};
		local requests = {};

		local requestChange = internal.signal.new();
		local onChange = internal.signal.new();

		function internal:connectTag(name,text,color,player,override,id,rainbow,image)
			table.insert(tags,{
				speaker = name,
				text = text,
				color = color,
				player = player,
				override = override,
				id = id,
				rainbow = rainbow,
				image = image
			});
			onChange:Fire(tags[#tags]);
		end

		function internal:request(query)
			table.insert(requests,query);
			requestChange:Fire(query);
		end

		function internal:getSpeaker(name,player)
			local signal = internal.signal.new();
			task.spawn(function()
				local speaker;
				repeat
					game:GetService("RunService").Heartbeat:Wait(); --> Also serves as a queue for when you set up multiple tags at once
					speaker = chatService:GetSpeaker(name);
				until(speaker);
				if(player and (speaker:GetPlayer() ~= player)) then
					return;
				end
				signal:Fire(speaker);
				signal:DisconnectAll();
			end)
			return signal;
		end

		function internal:setChatColor(player,chatColor,isRainbowTextColor)
			internal:getSpeaker(player.Name,player):Connect(function(speaker)
				speaker:SetExtraData("ChatColor",chatColor);
				speaker:SetExtraData("IsRainbowText",(isRainbowTextColor == true));
			end)
		end

		function internal:setNameColor(player,nameColor,isRainbowNameColor)
			internal:getSpeaker(player.Name,player):Connect(function(speaker)
				speaker:SetExtraData("NameColor",nameColor);
				speaker:SetExtraData("IsRainbowName",(isRainbowNameColor == true));
			end)
		end

		function internal:getSpeakers()
			return chatService:GetSpeakerList();
		end

		local sort = function(tags) -- > sorts by priority
			table.sort(tags,function(dict1,dict2)
				return dict1["Id"] < dict2["Id"];
			end)
		end

		local onRemove = {};
		local tagRequest = function(data)
			internal:getSpeaker(data.speaker,data.player):Connect(function(speaker)
				local doRemove = (onRemove[data.id] or {})[speaker:GetPlayer()];
				if(doRemove) then
					return;
				end
				local tagHolder = data.override and {} or speaker:GetExtraData("Tags");
				table.insert(tagHolder,{
					Id = data.id,
					TagText = data.text,
					TagColor = data.color,
					Rainbow = data.rainbow,
					Image = data.image
				});
				sort(tagHolder);
				speaker:SetExtraData("Tags",tagHolder);
			end)
		end

		internal.onPlayerSpeaker = {
			Connect = function(self,callback)
				local cached = {};
				local try = function()
					for _,speakerName in pairs(internal:getSpeakers()) do
						local speaker = chatService:GetSpeaker(speakerName);
						local plr = speaker:GetPlayer();
						if(plr and not cached[plr]) then
							cached[plr] = true;
							coroutine.wrap(callback)(speaker,plr);
						end
					end
				end
				chatService.SpeakerAdded:Connect(try);
				try();
			end,
		}

		local handleQuery = function(data)
			if(data.request == "clearTags") then
				internal:getSpeaker(data.name,data.player):Connect(function(speaker)
					speaker:SetExtraData("Tags",{});
				end)
			elseif(data.request == "clearTagsForIdentifier") then
				local idToRemove = data.id;
				internal.onPlayerSpeaker:Connect(function(speaker,player)
					if(data.check(player) == true) then
						onRemove[idToRemove] = onRemove[idToRemove] or {};
						onRemove[idToRemove][player] = true;
						local tags = speaker:GetExtraData("Tags") or {};
						for key,tag in pairs(tags) do
							if(tag.Id == idToRemove) then
								table.remove(tags,key);
							end
						end
						sort(tags);
						speaker:SetExtraData("Tags",tags);
					end
				end)
			elseif(data.request == "clearTagsForSpecific") then
				internal:getSpeaker(data.name,data.player):Connect(function(speaker)
					local tags = speaker:GetExtraData("Tags") or {};
					for key,tag in pairs(tags) do
						if(tag.Id == data.identifier) then
							table.remove(tags,key);
						end
					end
					sort(tags);
					speaker:SetExtraData("Tags",tags);
				end)
			end
		end

		for _,tag in pairs(tags) do
			tagRequest(tag);
		end

		for _,query in pairs(requests) do
			handleQuery(query);
		end

		requestChange:Connect(handleQuery);
		onChange:Connect(tagRequest);
	end)

	local typeCheck = function(object,expected,err)
		assert(typeof(object) == expected,(err .. " '%s'"):format(typeof(object)));
	end

	function internal.onPlayer(callback)
		internal.services.players.PlayerAdded:Connect(callback);
		for _,player in pairs(internal.services.players:GetPlayers()) do
			coroutine.wrap(callback)(player);
		end
	end

	local generateRequestReturn = function(identifier)
		local requests = {};

		function requests:getPriority()
			return identifier;
		end

		function requests:userExceptions(...)
			local users = {...};
			for i = 1,#users do
				typeCheck(users[i],"number","Expected 'number' for userId but got");
				internal:request({
					request = "clearTagsForIdentifier",
					id = identifier,
					check = function(player)
						return player.UserId == users[i];
					end,
				})
			end
			return requests; --> chainable
		end

		function requests:groupExceptions(...)
			local groups = {...};
			for i = 1,#groups do
				typeCheck(groups[i],"table","Expected 'table' for group but got");
				typeCheck(groups[i][1],"number","Expected 'number' for groupId but got");
				typeCheck(groups[i][2],"number","Expected 'number' for minimumRank but got");
				local groupId,groupRank = unpack(groups[i]);
				internal:request({
					request = "clearTagsForIdentifier",
					id = identifier,
					check = function(player)
						return player:GetRankInGroup(groupId) >= groupRank;
					end,
				})
			end
			return requests; --> chainable
		end

		table.freeze(requests);
		return requests;
	end

	local c = 0;
	local newId = function()
		c += 1;
		return c;
	end

	-- methods

	function chatPlus:setTextColor(player:Player,textColor:Color3,isRainbow:boolean)
		if(configuration.doTypeCheck) then
			if(not typeof(player) == "Instance" or (not player:IsA("Player"))) then
				error("Expected 'player' for player but got " .. type(player));
			end
			typeCheck(textColor,"Color3","Expected 'color3' for textColor but got");
		end
		internal:setChatColor(player,textColor,isRainbow);
	end

	function chatPlus:setNameColor(player:Player,nameColor:Color3,isRainbow:boolean)
		if(configuration.doTypeCheck) then
			if(not typeof(player) == "Instance" or (not player:IsA("Player"))) then
				error("Expected 'player' for player but got " .. type(player));
			end
			typeCheck(nameColor,"Color3","Expected 'color3' for nameColor but got");
		end
		internal:setNameColor(player,nameColor,isRainbow);
	end

	function chatPlus:removeTags(player)
		internal:request({
			request = "clearTags",
			player = player,
			name = player.Name
		})
	end

	function chatPlus:dataForPass(data:{passId:number,nameColor:Color3,textColor:Color3,rainbowText:boolean,rainbowName:boolean})
		if(data.nameColor ~= nil and configuration.doTypeCheck) then
			typeCheck(data.nameColor,"Color3","Expected 'color3' for nameColor but got");
		end
		if(data.textColor ~= nil and configuration.doTypeCheck) then
			typeCheck(data.textColor,"Color3","Expected 'color3' for textColor but got");
		end
		internal.services.marketplace.gamepassOwned(data.passId):Connect(function(player)
			if(data.nameColor) then
				internal:setNameColor(player,data.nameColor,data.rainbowName);
			elseif(data.rainbowName) then
				internal:setNameColor(player,Color3.fromRGB(255,255,255),true);
			end
			if(data.textColor) then
				internal:setChatColor(player,data.textColor,data.rainbowText);
			elseif(data.rainbowText) then
				internal:setChatColor(player,Color3.fromRGB(255,255,255),true);
			end
		end)
	end

	function chatPlus:dataForPremium(data:{nameColor:Color3,textColor:Color3,rainbowText:boolean,rainbowName:boolean})
		if(data.nameColor ~= nil and configuration.doTypeCheck) then
			typeCheck(data.nameColor,"Color3","Expected 'color3' for nameColor but got");
		end
		if(data.textColor ~= nil and configuration.doTypeCheck) then
			typeCheck(data.textColor,"Color3","Expected 'color3' for textColor but got");
		end
		internal.services.marketplace.premiumPlayerJoined:Connect(function(player)
			if(data.nameColor) then
				internal:setNameColor(player,data.nameColor,data.rainbowName);
			elseif(data.rainbowName) then
				internal:setNameColor(player,Color3.fromRGB(255,255,255),true);
			end
			if(data.textColor) then
				internal:setChatColor(player,data.textColor,data.rainbowText);
			elseif(data.rainbowText) then
				internal:setChatColor(player,Color3.fromRGB(255,255,255),true);
			end
		end)
	end

	function chatPlus:dataForGroup(data:{groupId:number,minimumRank:number,nameColor:Color3,textColor:Color3,rainbowText:boolean,rainbowName:boolean})
		if(data.nameColor ~= nil and configuration.doTypeCheck) then
			typeCheck(data.nameColor,"Color3","Expected 'color3' for nameColor but got");
		end
		if(data.textColor ~= nil and configuration.doTypeCheck) then
			typeCheck(data.textColor,"Color3","Expected 'color3' for textColor but got");
		end
		internal.onPlayer(function(player)
			if(player:GetRankInGroup(data.groupId) >= data.minimumRank) then
				if(data.nameColor) then
					internal:setNameColor(player,data.nameColor,data.rainbowName);
				elseif(data.rainbowName) then
					internal:setNameColor(player,Color3.fromRGB(255,255,255),true);
				end
				if(data.textColor) then
					internal:setChatColor(player,data.textColor,data.rainbowText);
				elseif(data.rainbowText) then
					internal:setChatColor(player,Color3.fromRGB(255,255,255),true);
				end
			end
		end)
	end

	function chatPlus:tagForGroup(data:{groupId:number,minimumRank:number,tagText:string,tagColor:Color3,override:boolean,rainbow:boolean,image:string})
		-- because some people can't just be civilized
		if(configuration.doTypeCheck) then
			typeCheck(data,"table","Expected 'table' for data but got");
			typeCheck(data.groupId,"number","Expected 'number' for groupId but got");
			typeCheck(data.minimumRank,"number","Expected 'number' for minimumRank but got");
			if(data.image) then
				typeCheck(data.image,"string","Expected 'string' for image but got");
			else
				typeCheck(data.tagText,"string","Expected 'string' for tagText but got");
				typeCheck(data.tagColor,"Color3","Expected 'color3' for tagColor but got");
			end
			if(data.override ~= nil) then
				typeCheck(data.override,"boolean","Expected 'boolean' for override but got");
			end
		end
		if(data.image) then
			data.tagText = placeholderImage;
		end

		local identifier = newId();
		internal.onPlayer(function(player)
			if(player:GetRankInGroup(data.groupId) >= data.minimumRank) then
				internal:connectTag(player.Name,data.tagText,data.tagColor,player,(data.override == true),identifier,data.rainbow,data.image);
			end
		end)

		return generateRequestReturn(identifier);
	end

	function chatPlus:newTag(data:{tagText:string,tagColor:Color3,override:boolean,rainbow:boolean,image:string})
		-- because some people can't just be civilized
		if(configuration.doTypeCheck) then
			typeCheck(data,"table","Expected 'table' for data but got");
			if(data.image) then
				typeCheck(data.image,"string","Expected 'string' for image but got");
			else
				typeCheck(data.tagText,"string","Expected 'string' for tagText but got");
				typeCheck(data.tagColor,"Color3","Expected 'color3' for tagColor but got");
			end
			if(data.override ~= nil) then
				typeCheck(data.override,"boolean","Expected 'boolean' for override but got");
			end
		end
		if(data.image) then
			data.tagText = placeholderImage;
		end

		local methods = {};
		local identifier = newId();

		function methods:assign(player)
			internal:connectTag(player.Name,data.tagText,data.tagColor,player,(data.override == true),identifier,data.rainbow,data.image);
		end

		function methods:unassign(player)
			internal:request({
				request = "clearTagsForSpecific",
				player = player,
				name = player.Name,
				identifier = identifier
			})
		end

		function methods:getPriority()
			return identifier;
		end

		return methods;
	end

	--[[
	function chatPlus:premiumNameColor(color:Color3)
		if(configuration.doTypeCheck) then
			typeCheck(color,"Color3","Expected 'Color3' for color but got");
		end
		internal.services.marketplace.premiumPlayerJoined:Connect(function(player)
			chatPlus:setNameColor(player,color)
		end)
	end

	function chatPlus:premiumTextColor(color:Color3)
		if(configuration.doTypeCheck) then
			typeCheck(color,"Color3","Expected 'Color3' for color but got");
		end
		internal.services.marketplace.premiumPlayerJoined:Connect(function(player)
			chatPlus:setTextColor(player,color)
		end)
	end
	]]

	function chatPlus:premiumTag(data:{tagText:string,tagColor:Color3,override:boolean})
		local methods = chatPlus:newTag(data);
		internal.services.marketplace.premiumPlayerJoined:Connect(function(player)
			methods:assign(player);
		end)
		return methods;
	end

	function chatPlus:tagFromPass(data:{passId:number,tagText:string,tagColor:Color3,override:boolean,image:string,rainbow:boolean})
		-- because some people can't just be civilized
		if(configuration.doTypeCheck) then
			typeCheck(data,"table","Expected 'table' for data but got");
			typeCheck(data.passId,"number","Expected 'number' for passId but got");
			if(data.image) then
				typeCheck(data.image,"string","Expected 'string' for image but got");
			else
				typeCheck(data.tagText,"string","Expected 'string' for tagText but got");
				typeCheck(data.tagColor,"Color3","Expected 'color3' for tagColor but got");
			end
			if(data.override ~= nil) then
				typeCheck(data.override,"boolean","Expected 'boolean' for override but got");
			end
		end
		if(data.image) then
			data.tagText = placeholderImage;
		end

		local identifier = newId();
		internal.services.marketplace.gamepassOwned(data.passId):Connect(function(player)
			internal:connectTag(player.Name,data.tagText,data.tagColor,player,(data.override == true),identifier,data.rainbow,data.image);
		end)

		return generateRequestReturn(identifier);
	end

	local channelWrapper = function(name,exists)
		local channelRaw = chatService[exists and "GetChannel" or "AddChannel"](chatService,name);
		local methods = {};

		local getSpeaker = function(player)
			return internal:getSpeaker(player.Name,player):Wait();
		end

		function methods:getRawChannel()
			return channelRaw;
		end

		function methods:remove()
			chatService:RemoveChannel(name);
			for methodName,_ in pairs(methods) do
				methods[methodName] = nil;
			end
		end

		function methods:assignUser(player:Player)
			local speaker = getSpeaker(player);
			if(speaker) then
				speaker:JoinChannel(name);
			end
		end

		function methods:systemMessage(message:string)
			channelRaw:SendSystemMessage(message);
		end

		function methods:setWelcomeMessage(message:string)
			channelRaw.WelcomeMessage = message;
		end

		function methods:removeUser(player:Player)
			local speaker = getSpeaker(player);
			if(speaker) then
				speaker:LeaveChannel(name);
			end
		end

		return methods;
	end

	function chatPlus:createChannel(name)
		if(configuration.doTypeCheck) then
			typeCheck(name,"string","Expected 'string' for name but got");
		end
		return channelWrapper(name,false);
	end

	function chatPlus:getChannel(name)
		name = name or "All";
		if(configuration.doTypeCheck) then
			typeCheck(name,"string","Expected 'string' for name but got");
		end
		return channelWrapper(name,true);
	end
	
	function chatPlus:cacheChannel(name)
		name = name or "All";
		if(chatService:GetChannel(name)) then
			return chatPlus:getChannel(name);
		else
			return chatPlus:createChannel(name);
		end
	end
	
	function chatPlus:sendFakeMessage(name:string,text:string,channel:string,nameColor:Color3)
		channel = channel or "all";
		if(configuration.doTypeCheck) then
			typeCheck(name,"string","Expected 'string' for name but got");
			typeCheck(channel,"string","Expected 'string' for channel but got");
			if(nameColor) then
				typeCheck(nameColor,"Color3","Expected 'Color3' for nameColor but got");
			end
		end
		local speaker = chatService:GetSpeaker(name);
		local player = game:GetService("Players"):FindFirstChild(name);
		if(not speaker) then
			speaker = chatService:AddSpeaker(name);
		end
		if(not speaker:IsInChannel(channel)) then
			speaker:JoinChannel(channel);
		end
		if(nameColor) then
			speaker:SetExtraData("NameColor",nameColor);
		end
		speaker:SayMessage(text,channel);
		if(not player) then
			chatService:RemoveSpeaker(name);
		end
	end

	state = false;
	yielding:Fire(false);
end

-- bruh moment
-- bc of the :setConfig function it needs to run before the actual chat backend loads so this
-- makes up for it

local methodsList = {
	"getChannel","createChannel","tagFromPass","premiumTag","premiumTextColor","premiumNameColor",
	"newTag","tagForGroup","dataForGroup","removeTags","setNameColor","setTextColor","sendFakeMessage",
	"dataForPass","dataForPremium","cacheChannel"
}

coroutine.wrap(add)();
setmetatable(chatPlus,{
	__index = function(t,k)
		if(state and table.find(methodsList,k)) then
			return function(...)
				yielding:Wait();
				return rawget(t,k)(...);
			end
		end
	end,
});

return chatPlus;