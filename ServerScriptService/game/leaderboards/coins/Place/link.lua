local info = {
	username = script.Parent:WaitForChild("Info"):WaitForChild("Username"),
	stat = script.Parent:WaitForChild("Info"):WaitForChild("Stat"),
	place = script.Parent:WaitForChild("Place"),
	thumbnail = script.Parent:WaitForChild("Thumbnail")
};

local getData = function(userId,data)
	local players,userService = game:GetService("Players"),game:GetService("UserService");
	local thumbType = Enum.ThumbnailType.HeadShot;
	local thumbSize = Enum.ThumbnailSize.Size420x420;
	local content,isReady = game:GetService("Players"):GetUserThumbnailAsync(userId,thumbType,thumbSize);
	local displayName;
	
	--[[
		local success,userDataResult = pcall(function()
		return userService:GetUserInfosByUserIdsAsync({userId});
	end)
	if(not success or (#userDataResult ~= 1)) then
		local success,name = pcall(function()
			return players:GetNameFromUserIdAsync(userId);
		end)
		if(success and name) then
			displayName = name;
		end
	else
		displayName = userDataResult[1]["DisplayName"];
	end
	]]
	
	return content,data["DisplayName"],data["Username"];
end

return function(place,id,stat,data)
	info.place.Text = ("#"..place);
	info.stat.Text = stat;
	local thumbnail,name,real = getData(id,data);
	local displayFormat = ("%s <font color='rgb(200,200,200)'>(@%s)</font>"):format(name,real);
	if(name ~= real) then
		name = displayFormat;
	end
	info.username.Text = name;
	info.username.RichText = true;
	info.thumbnail.Image = thumbnail;
end