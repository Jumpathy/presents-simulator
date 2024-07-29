return {
	probability = {
		["Uncommon"] = 35,
		["Common"] = 55
	},
	pets = {},
	order = {
		["Legendary"] = 0,
		["Uncommon"] = 1,
		["Common"] = 2
	},
	colors = {
		["Legendary"] = Color3.fromRGB(232,62,47),
		["Uncommon"] = Color3.fromRGB(255,255,0),
		["Common"] = Color3.fromRGB(200,200,200)
	},
	setup = function(self)
		local ui = script.Parent:WaitForChild("Chances"):WaitForChild("Holder");
		for _,pet in pairs(self.pets) do
			local real = game:GetService("ServerStorage"):WaitForChild("pets"):WaitForChild(pet);
			local image = real:GetAttribute("Image");
			local template = game:GetService("ServerStorage"):WaitForChild("templates"):WaitForChild("Pet"):Clone();
			local chance = self.probability[real:GetAttribute("Tier")] .. "%";
			template.LayoutOrder = (self.order[real:GetAttribute("Tier")])
			template.Percent.TextColor3 = self.colors[real:GetAttribute("Tier")];
			template.Percent.Text = chance;
			template.Percent.Shadow.Text = chance;
			template.Parent = script.Parent:WaitForChild("Chances"):WaitForChild("Holder"):WaitForChild("Pets");
			template.Icon.Image = image;
			template.Icon.Shadow.Image = image;
		end
	end,
}