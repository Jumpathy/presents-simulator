local module = {};

function wrap(speaker)
	local wrapped = {};
	
	function wrapped:SetExtraData(parameter,data)
		if(parameter == "ChatColor") then
			speaker.player:SetAttribute("ChatColor",data)
		elseif(parameter == "Tags") then
			
		end
	end
	
	function wrapped:GetExtraData(name)
		
	end
	
	function wrapped:GetPlayer()
		return speaker.player
	end
	
	return wrapped;
end

function module:GetSpeaker(name)
	return wrap(
		shared.hd_admin_betterChat.speaker:getByName(
			name
		)
	);
end

return module;
