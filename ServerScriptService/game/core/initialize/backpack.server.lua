local config = require(script.Parent.Parent.Parent:WaitForChild("config"));
local data = require(script.Parent.Parent.Parent:WaitForChild("data"));
local backpacks = config.Backpacks;

local holder = game:GetService("ServerStorage"):WaitForChild("Backpacks");
local store = workspace:WaitForChild("stores"):WaitForChild("backpack");
local models = store:WaitForChild("models");

models:SetAttribute("count",#backpacks);

local g = function(m,a)
	return m:GetAttribute(a) or 0;
end

local calculatePosition = function(base,offset,model)
	local x,y,z = g(model,"X"),g(model,"Y"),g(model,"Z")
	--local orientation = {0,CFrame.Angles(90),0};
	--local position = {base.Position.X,(base.Position.Y + (offset or 3)),base.Position.Z};
	--return CFrame.new(position[1],position[2],position[3],unpack(orientation));
	local angle = CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
	return model.PrimaryPart.CFrame * CFrame.new(Vector3.new(0,1,0))*angle;
end

local formatText = function(amount)
	return("0/" .. data.format.FormatStandard(amount));
end

local handle = function(p)
	if(p:IsA("BasePart")) then
		p.Anchored = true;
	end
end

for i = 1,#backpacks do
	local backpack = backpacks[i];
	if(backpack.Display) then
		local parent = models:WaitForChild(tostring(i));
		local model = holder:WaitForChild(backpack.Model):Clone();
		model.Parent = parent:WaitForChild("model");
		model.Name = "Backpack";
		model.DescendantAdded:Connect(handle);
		for _,o in pairs(model:GetDescendants()) do
			handle(o);
		end
		local cframe = calculatePosition(parent:WaitForChild("parts"):WaitForChild("Crate"),3,model);
		if(not backpack.Change) then
			model:SetPrimaryPartCFrame(cframe);	
		end
		if(backpack.PassId) then
			parent:SetAttribute("PassId",backpack.PassId);
			coroutine.wrap(function()
				local success,cost = pcall(function()
					return game:GetService("MarketplaceService"):GetProductInfo(backpack.PassId,Enum.InfoType.GamePass)["PriceInRobux"];
				end)
				parent:SetAttribute("Price",cost or 0);
			end)();
		else
			parent:SetAttribute("Price",backpack.Price);
		end
		parent:SetAttribute("Storage",backpack.Storage);
		parent:SetAttribute("ActualObject",backpack.Model);
		require(model:WaitForChild("Function"))(formatText(backpack.Storage));
	end
end

models:SetAttribute("loaded",true);