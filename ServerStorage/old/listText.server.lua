local loadList = {};
local handle = function(service)
	for k,v in pairs(service:GetDescendants()) do
		if(v:IsA("MeshPart")) then
			loadList[v.MeshId] = true;
			if(v.TextureID) then
				loadList[v.TextureID] = true;
			end
		elseif(v:IsA("Decal")) then
			--loadList[v.Texture] = true;
		end
	end
end
handle(game:GetService("ServerStorage"));
handle(workspace);

for k,v in pairs(game:GetService("StarterGui"):GetDescendants()) do
	if(v:IsA("ImageLabel") or v:IsA("ImageButton")) then
		--loadList[v.Image] = true;
	end
end

loadList[""] = nil;

local lua = "return {";

for id,_ in pairs(loadList) do
	lua = lua .. "\n" .. ('"%s",'):format(id);
end

lua = lua .. "\n}";
local rs = game:GetService("ReplicatedStorage")
rs.preload.Source = lua;