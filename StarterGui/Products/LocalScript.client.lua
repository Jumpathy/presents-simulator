local holder = {}
local connected = {}
local localPlayer = game:GetService("Players").LocalPlayer
local gamepasses = localPlayer:WaitForChild("OwnedPasses",math.huge);
local ui = script:WaitForChild("Products")

local update = function()
	local pricing = shared.prices
	for _,cont in pairs(holder) do
		for i = 1,6 do
			local crate = cont:WaitForChild(tostring(i))
			if(pricing[i]) then
				local data = pricing[i]
				crate.Buy.Price.Text = data.price
				crate.Title.Amount.Text = data.giveAmount
				if(not connected[crate]) then
					connected[crate] = true
					
					local purchase = function()
						shared.buyCoins(i)
					end
					crate.Buy.MouseButton1Click:Connect(purchase)
					crate.Icon.MouseButton1Click:Connect(purchase)
				end
			end
		end
	end
end

local onChild = function(object)
	if(object:IsA("SurfaceGui")) then
		local container = object:WaitForChild("Container")
		local coins = container:WaitForChild("Coins")
		local passes = container:WaitForChild("Passes")
		table.insert(holder,coins)
		if(shared.prices) then
			update()
		end
		
		local on = function(child)
			if(child:IsA("Frame")) then
				local sig;
				local check = function()
					if(gamepasses:GetAttribute(child.Name)) then
						child:Destroy()
						sig:Disconnect()
					end
				end
				
				local id = tonumber(child.Name)

				local purchase = function()
					game:GetService("MarketplaceService"):PromptGamePassPurchase(localPlayer,id)
				end
				
				child.Buy.MouseButton1Click:Connect(purchase)
				child.Icon.MouseButton1Click:Connect(purchase)
				
				sig = gamepasses.AttributeChanged:Connect(check)
				check()
				if(child:GetFullName() ~= child.Name) then
					local price = game:GetService("MarketplaceService"):GetProductInfo(id,Enum.InfoType.GamePass)["PriceInRobux"]
					child:WaitForChild("Buy"):WaitForChild("Price").Text = price
				end
			end
		end
		
		passes.ChildAdded:Connect(on)
		for _,child in pairs(passes:GetChildren()) do
			task.spawn(on,child)
		end
	end
end

shared.priceUpdate = function()
	update()
end

script.Parent.ChildAdded:Connect(onChild)
for _,child in pairs(script.Parent:GetChildren()) do
	task.spawn(onChild,child)
end

local seps = workspace:WaitForChild("areas"):WaitForChild("separators")

local onSep = function(sep)
	local clone = ui:Clone()
	clone.Parent = script.Parent
	clone.Name = sep.Name
	clone.Adornee = sep
end

seps.ChildAdded:Connect(onSep)
for _,child in pairs(seps:GetChildren()) do
	task.spawn(onSep,child)
end