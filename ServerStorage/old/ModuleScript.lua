local pets = "";
local container = game.Selection:Get()[1];
local arr = container:GetChildren();
local areas = {};

for _,object in pairs(arr) do
	local area = object:GetAttribute("Part1") and 1 or 2;
	areas[area] = areas[area] or {};
	local tbl = "{\n[\"Name\"] = \"" .. object.Name .. "\",";
	tbl = tbl .. "\n[\"Tier\"] = \"" .. object:GetAttribute("Tier") .. "\",";
	tbl = tbl .. "\n[\"Image\"] = \"" .. object:GetAttribute("Image") .. "\"\n},";
	table.insert(areas[area],tbl);
end

local pets = "return {[1] = {"..table.concat(areas[1],"\n").."[2] = {"..table.concat(areas[2],"\n").."}}";
local m = Instance.new("Script",workspace);
m.Source = pets;