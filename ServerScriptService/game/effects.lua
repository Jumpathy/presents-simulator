local partsWithId = {}
local awaitRef = {}

local root = {
	ID = 0;
	Type = "Part";
	Properties = {
		Name = "Yes";
	};
	Children = {
		{
			ID = 1;
			Type = "Attachment";
			Properties = {};
			Children = {
				{
					ID = 2;
					Type = "ParticleEmitter";
					Properties = {
						LockedToPart = true;
						Rate = 8;
						Rotation = NumberRange.new(90,270);
						Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.40000000596046,0.30000001192093),NumberSequenceKeypoint.new(1,1,0)});
						Name = "Rays";
						Lifetime = NumberRange.new(1);
						Speed = NumberRange.new(0);
						Texture = "rbxassetid://1053548563";
						LightEmission = 1;
						Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.055500000715256,2.4836013317108,0),NumberSequenceKeypoint.new(0.11100000143051,4.4472413063049,0),NumberSequenceKeypoint.new(0.16650000214577,5.9772038459778,0),NumberSequenceKeypoint.new(0.22200000286102,7.1496515274048,0),NumberSequenceKeypoint.new(0.27750000357628,8.0312557220459,0),NumberSequenceKeypoint.new(0.33300000429153,8.6798324584961,0),NumberSequenceKeypoint.new(0.38850000500679,9.1449680328369,0),NumberSequenceKeypoint.new(0.44400000572205,9.4686584472656,0),NumberSequenceKeypoint.new(0.4995000064373,9.6859340667725,0),NumberSequenceKeypoint.new(0.55500000715256,9.8254985809326,0),NumberSequenceKeypoint.new(0.61049997806549,9.9103527069092,0),NumberSequenceKeypoint.new(0.66600000858307,9.9584341049194,0),NumberSequenceKeypoint.new(0.721499979496,9.9832458496094,0),NumberSequenceKeypoint.new(0.77700001001358,9.9944849014282,0),NumberSequenceKeypoint.new(0.83249998092651,9.9986810684204,0),NumberSequenceKeypoint.new(0.88800001144409,9.9998235702515,0),NumberSequenceKeypoint.new(0.94349998235703,9.9999942779541,0),NumberSequenceKeypoint.new(0.9990000128746,10,0),NumberSequenceKeypoint.new(1,10,0)});
					};
					Children = {};
				};
				{
					ID = 3;
					Type = "ParticleEmitter";
					Properties = {
						LockedToPart = true;
						ZOffset = 4;
						Texture = "rbxassetid://867619398";
						Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1,0),NumberSequenceKeypoint.new(0.098399996757507,1,0),NumberSequenceKeypoint.new(0.10199999809265,0.69999998807907,0),NumberSequenceKeypoint.new(1,1,0)});
						Name = "Flare";
						Lifetime = NumberRange.new(1);
						Speed = NumberRange.new(0);
						LightEmission = 1;
						Rate = 1;
						Size = NumberSequence.new({NumberSequenceKeypoint.new(0,7,0),NumberSequenceKeypoint.new(1,7,0)});
					};
					Children = {};
				};
				{
					ID = 4;
					Type = "ParticleEmitter";
					Properties = {
						RotSpeed = NumberRange.new(22.5);
						LockedToPart = true;
						Rate = 1;
						Rotation = NumberRange.new(-180,180);
						Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.30000001192093,0),NumberSequenceKeypoint.new(0.75,0.30000001192093,0),NumberSequenceKeypoint.new(1,1,0)});
						Name = "Rays";
						Lifetime = NumberRange.new(1.5);
						Speed = NumberRange.new(0);
						Texture = "rbxassetid://1084975295";
						LightEmission = 1;
						Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.10000000149012,9,0),NumberSequenceKeypoint.new(1,0,0)});
					};
					Children = {};
				};
			};
		};
		{
			ID = 5;
			Type = "ParticleEmitter";
			Properties = {
				Acceleration = Vector3.new(0,0.5,0);
				Drag = 3;
				ZOffset = 1;
				Texture = "rbxassetid://1084970835";
				LightEmission = 1;
				Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0,0),NumberSequenceKeypoint.new(0.22813037037849,0,0),NumberSequenceKeypoint.new(0.22984562814236,1,0),NumberSequenceKeypoint.new(0.52315610647202,1,0),NumberSequenceKeypoint.new(0.60034304857254,0,0),NumberSequenceKeypoint.new(0.61063468456268,0,0),NumberSequenceKeypoint.new(0.66723841428757,1,0),NumberSequenceKeypoint.new(0.68096059560776,1,0),NumberSequenceKeypoint.new(0.74614065885544,0,0),NumberSequenceKeypoint.new(0.75471699237823,0,0),NumberSequenceKeypoint.new(0.84562611579895,1,0),NumberSequenceKeypoint.new(0.85591769218445,1,0),NumberSequenceKeypoint.new(0.92281305789948,0,0),NumberSequenceKeypoint.new(0.92967414855957,0,0),NumberSequenceKeypoint.new(1,1,0)});
				Name = "Sparkles";
				Lifetime = NumberRange.new(4,6);
				Speed = NumberRange.new(1,10);
				Rate = 1;
				LockedToPart = true;
				Size = NumberSequence.new({NumberSequenceKeypoint.new(0,0.40000000596046,0.20000000298023),NumberSequenceKeypoint.new(0.5,0.40000000596046,0.20000000298023),NumberSequenceKeypoint.new(0.50999999046326,0.20000000298023,0.10000000149012),NumberSequenceKeypoint.new(1,0.20000000298023,0.10000000149012)});
			};
			Children = {};
		};
	};
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

local library = {};

library.rebirthEffect = function(parent,length)
	local container = Scan(root,parent);
	local emitters = {};
	for _,descendant in pairs(container:GetDescendants()) do
		if(descendant:IsA("ParticleEmitter")) then 
			table.insert(emitters,descendant);
		end
	end
	for _,child in pairs(container:GetChildren()) do
		child.Parent = parent;
	end
	for _,emitter in pairs(emitters) do
		emitter:Emit(1);
		game:GetService("Debris"):AddItem(emitter,length or 1);
	end
	container:Destroy();
end

return library;