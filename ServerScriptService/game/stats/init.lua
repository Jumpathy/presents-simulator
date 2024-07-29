local dataSaveKey = "user-data";
local integer = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("integer"));
local profiles = require(script:WaitForChild("profiles"));
local methods = require(script.Parent:WaitForChild("data"));
local leaderstats = {}
local mark = integer.new("1000000");

local new = function(container)
	local callbacks = {};
	return {
		Fire = function(self,...)
			for _,callback in pairs(callbacks) do
				coroutine.wrap(callback)(...);
			end
		end,
		Event = {
			Connect = function(self,callback)
				table.insert(callbacks,callback);
				return container;
			end,
		}
	}
end

function leaderstats:setup(default)	
	local events = {};
	local loaded = new(events);
	local changed = new(events);
	methods.profileLoaded:Connect(function(profile,player)
		local leaderstatsFolder = Instance.new("Folder");
		leaderstatsFolder.Parent = player;
		leaderstatsFolder.Name = "leaderstats";
		local format = function(value)
			local key = integer.new(value) > mark and "FormatCompact" or "FormatStandard";			
			return integer.format[key](value);
		end
		local from = function(name,value)
			if(type(value) == "number") then
				local class = Instance.new("StringValue");
				class.Name = name;
				class.Value = tostring(value);
				local actual = Instance.new("StringValue");
				actual.Parent = class;
				actual.Value = tostring(value);
				actual.Name = "Real";
				return class,actual;
			else
				local class = Instance.new("StringValue");
				class.Name = name;
				class.Value = value;
				return class,class;
			end
		end
		for priority,stat in pairs(default) do
			local value,toSave = from(unpack(stat));
			value.Parent = leaderstatsFolder;
			if(profile.leaderstats[priority]) then
				toSave.Value = profile.leaderstats[priority][2];
				if(type(stat[2]) == "number") then
					value.Value = format(profile.leaderstats[priority][2]);
				end
			end
			local save = function()
				profile.leaderstats[priority] = {
					stat[1],toSave.Value
				}
				if(type(stat[2]) == "number") then
					value.Value = format(profile.leaderstats[priority][2]);
				end
				changed:Fire(player,stat[1],toSave.Value);
			end
			toSave:GetPropertyChangedSignal("Value"):Connect(save);
		end
		loaded:Fire(player,leaderstats,profile)
	end)
	events.loaded = loaded.Event;
	events.changed = changed.Event;
	return events;
end

function leaderstats:psuedoAdd(player,valueName,amount)
	local real = player["leaderstats"][valueName]["Real"];
	local new = tostring(integer.new(real.Value) + integer.new(tostring(amount)));
	return new;
end

function leaderstats:add(player,valueName,amount)
	local real = player["leaderstats"][valueName]["Real"];
	local new = tostring(integer.new(real.Value) + integer.new(tostring(amount)));
	real.Value = new;
	return new;
end

function leaderstats:set(player,valueName,new)
	local value = player["leaderstats"][valueName];
	if(value:FindFirstChild("Real")) then
		value.Real.Value = tostring(new);
	else
		value.Value = new;
	end
end

function leaderstats:get(player,valueName)
	local value = player["leaderstats"][valueName];
	if(value:FindFirstChild("Real")) then
		return value.Real.Value;
	else
		return value.Value;
	end
end	

function leaderstats:formatInteger(value)
	local key = integer.new(value) > mark and "FormatCompact" or "FormatStandard";			
	return integer.format[key](value);
end

function leaderstats:getSortableValue(value)
	local value = (tostring(integer.new(value)));
	local rough = (tonumber(integer.format.FormatScientific(value)));
	local storedValue = rough ~= 0 and math.floor(math.log(rough) / math.log(1.0000001)) or 0;
	return storedValue;
end

function leaderstats:toRoughValue(value)
	local function round(num, numDecimalPlaces)
		local mult = 10^(numDecimalPlaces or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	local retrievedValue = value ~= 0 and (1.0000001^value) or 0;
	return tostring(integer.new(math.floor(round(retrievedValue,2))));
end

shared.set = function(stat,new)
	stat.Real.Value = tostring(integer.new(new));
end

shared.addNoChange = function(stat,new)
	return leaderstats:psuedoAdd(
		stat.Parent.Parent,
		stat.Name,
		new
	)
end

shared.clamp = function(start,min,max)
	if(max == "inf") then
		return tostring(start);
	end
	local current = integer.new(start);
	local min = integer.new(tostring(min));
	local max = integer.new(tostring(max));
	if(current <= min) then
		return tostring(min);
	elseif(current >= min and current <= max) then
		return tostring(current);
	elseif(current >= max) then
		return tostring(max);
	end
end

shared.enough_raw = function(current,new)
	return(integer.new(current) >= integer.new(tostring(new)));
end

shared.enough = function(current,new)
	local real = current.Real.Value;
	return(integer.new(real) >= integer.new(tostring(new)));
end

shared.add = function(stat,add)
	leaderstats:add(
		stat.Parent.Parent,
		stat.Name,
		add
	)
end

function shared.multiply(a,b)
	return integer.new(a) * integer.new(b);
end

return leaderstats;