local create = {};

function create:beam()
	local partsWithId = {}
	local awaitRef = {}

	local root = {
		ID = 0;
		Type = "Beam";
		Properties = {
			Texture = "rbxassetid://8257983871";
			Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(1,0,0)});
			LightEmission = 0.1;
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,0)),ColorSequenceKeypoint.new(1,Color3.new(1,1,0))});
			TextureSpeed = 3;
			TextureMode = Enum.TextureMode.Static;
		};
		Children = {};
	};

	local function Scan(item, parent)
		local obj = Instance.new(item.Type)
		if (item.ID) then
			local awaiting = awaitRef[item.ID]
			if (awaiting) then
				awaiting[1][awaiting[2]] = obj
				awaitRef[item.ID] = nil
			else
				partsWithId[item.ID] = obj
			end
		end
		for p,v in pairs(item.Properties) do
			if (type(v) == "string") then
				local id = tonumber(v:match("^_R:(%w+)_$"))
				if (id) then
					if (partsWithId[id]) then
						v = partsWithId[id]
					else
						awaitRef[id] = {obj, p}
						v = nil
					end
				end
			end
			obj[p] = v
		end
		for _,c in pairs(item.Children) do
			Scan(c, obj)
		end
		obj.Parent = parent
		return obj
	end

	return Scan(root, nil);
end

return create;