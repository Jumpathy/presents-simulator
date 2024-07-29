local cb = "{\n";

local m = function(col)
	return math.floor(col * 255);
end

local c = function(v)
	return "Color3.fromRGB(" .. m(v.R) .. "," .. m(v.G) .. "," .. m(v.B) .. ")";
end

local name = "Candy";

for k,v in pairs(game.Selection:Get()[1]:GetChildren()) do
	if(v:FindFirstChild("lid"):FindFirstChild("LidColor")) then
		local a,b = c(v.lid.LidColor.Color),c(v.BaseColor.Color);
		local bro = v:FindFirstChild(name);
		local base;
		if(bro) then
			if(not v:GetAttribute("Extend")) then
				bro = nil;
			end
		end
		if(bro == nil) then
			base = "{\n[\"LidColor\"] = ".. a..",\n[\"BaseColor\"] = " .. b .. "\n}";
		else
			local lo;
			if(bro:IsA("Model") and bro.PrimaryPart) then
				lo = c(bro.PrimaryPart.Color);
			else
				lo = c(bro.Inside.Color);
			end
			base = "{\n[\"LidColor\"] = ".. a..",\n[\"BaseColor\"] = " .. b .. "\n[\""..name.."\"] = "..lo.."\n}";
		end
		cb = cb .. base .. ",\n";
	end
end

print(cb.."\n}")