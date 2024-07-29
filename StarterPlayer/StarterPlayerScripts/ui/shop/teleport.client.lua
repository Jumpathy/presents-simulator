local topbar = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("topbar"));
local localPlayer = game:GetService("Players").LocalPlayer;
local event = Instance.new("BindableEvent");

local check = function()
	if(localPlayer:GetAttribute("CanTeleport")) then
		event:Fire();
	end
end
localPlayer:GetAttributeChangedSignal("CanTeleport"):Connect(check);
task.spawn(function()
	task.wait()
	check();
end)
event.Event:Wait();

local icon = topbar.new()
local network = require(game.ReplicatedStorage.shared:WaitForChild("network"));
icon:setLabel("Teleport");

local areas = {
	{name = "VIP", key = 0},
	{name = "Spawn", key = 1},
	{name = "Winter Wonderland", key = 2},
	{name = "Candyland", key = 3},
	{name = "Crystal Caves", key = 4},
	{name = "Volcanic Chaos", key = 5},
	{name = "Beach", key = 6},
	{name = "Frostland", key = 7}
}

local dropdown = {}
for key,area in pairs(areas) do
	local ico = topbar.new():setLabel("Locked");
	local locked = true;
	table.insert(dropdown,ico:setName(tostring(key)):bindEvent("selected",function(self)
		self:deselect();
		if(not locked or area.key == 1) then
			network:fireServer("teleport",area.key);
		end
	end))
	local attributeName = ("Area%s"):format(tostring(area.key));
	local enabled = function()
		local state = localPlayer:GetAttribute(attributeName);
		locked = not state;
		if(area.key == 1) then
			locked = false;
		end
		ico:setLabel(locked and "Locked" or area.name);
	end
	localPlayer:GetAttributeChangedSignal(attributeName):Connect(enabled);
	enabled();
end
icon:setDropdown(dropdown)