local create = require(script:WaitForChild("create"));
local beam = create:beam();

local library = {};
local localPlayer = game:GetService("Players").LocalPlayer;
local name = "internal_tutorial";
local oldAttachments = {};
local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));		
local label = localPlayer.PlayerGui:WaitForChild("UI"):WaitForChild("Label")
local arrow = label.Parent:WaitForChild("BackpackArrow")

local getNextPlace = function()
	local seps = workspace:WaitForChild("areas"):WaitForChild("separators")
	for _,b in pairs(seps:GetChildren()) do
		local n = b.Name
		local s = "Area" .. (n:sub(5,#n))
		if(not localPlayer:GetAttribute(s) and (not n:find("10"))) then
			return b
		end
	end
	return false
end

function library:getPresentEvent()
	local bindable = Instance.new("BindableEvent");
	local presents = workspace.gifts;
	local grand = {};
	local lastSelected;

	local roll = function()
		repeat
			game:GetService("RunService").Heartbeat:Wait();
		until(#grand >= 5)
		local final = {};
		for _,present in pairs(grand) do
			if(present.PrimaryPart == nil) then
				repeat
					game:GetService("RunService").Heartbeat:Wait();
				until(present.PrimaryPart ~= nil);
			end
			final[present] = (present.PrimaryPart.Position - localPlayer.Character.HumanoidRootPart.Position).magnitude;
		end
		local array = {}
		for key,value in pairs(final) do
			array[#array+1] = {key = key,value = value}
		end
		table.sort(array,function(a,b)
			return a.value < b.value
		end)
		local new = array[1]["key"]
		if(lastSelected ~= new) then
			lastSelected = array[1]["key"];
			bindable:Fire(array[1]["key"]);
		end
	end

	local on = function(present)
		game:GetService("RunService").Heartbeat:Wait();
		if(present:GetAttribute("Region"):lower() == "area1") then
			repeat
				game:GetService("RunService").Heartbeat:Wait();
			until(present.PrimaryPart ~= nil);
			table.insert(grand,present);
			local signal,signal2
			local health = present:WaitForChild("Values"):WaitForChild("Health")
			local changed = function()
				if(present:GetAttribute("Destroyed") or (health.Value == 0)) then
					signal:Disconnect();
					signal2:Disconnect()
					table.remove(grand,table.find(grand,present));
					if(lastSelected == present) then
						roll();
					end
				end
			end
			signal = present.AttributeChanged:Connect(changed)
			signal2 = health.Changed:Connect(changed)
		end
	end
	presents.ChildAdded:Connect(on);
	for _,child in pairs(presents:GetChildren()) do
		coroutine.wrap(on)(child);
	end
	coroutine.wrap(roll)();
	return {
		Bindable = bindable.Event,
		Roll = function()
			roll();
		end,
	};
end

function library:attachment(parent)
	local att = Instance.new("Attachment");
	att.Name = name;
	att.Parent = parent;
	table.insert(oldAttachments,att);
	return att;
end

function library:setTarget(target)
	local root = localPlayer.Character.HumanoidRootPart;
	if(not target) then
		target = root;
	end
	local attachments = {};
	for _,old in pairs(oldAttachments) do
		old:Destroy();
	end
	oldAttachments = {};
	for key,part in pairs({root,target}) do
		if(not part:FindFirstChild(name)) then
			library:attachment(part);
		end
		attachments[key] = part:FindFirstChild(name);
	end
	beam.Parent = root;
	beam.Attachment0 = attachments[1];
	beam.Attachment1 = attachments[2];
end

local set = function(key,value)
	local success,res = network:invokeServer("tutorial","set",key,value);
	if(not success) then
		warn("writing error",res);
	end
end

function library.backpackFull()
	local last;
	local event = Instance.new("BindableEvent");
	localPlayer.AttributeChanged:Connect(function()
		local b,a = localPlayer:GetAttribute("backpackSize"),localPlayer:GetAttribute("backpack");
		event:Fire(a == b);
	end)
	return event.Event;
end

local priority = {"backpack","raygun"}
local stores = workspace:WaitForChild("stores")

local owns = function(class,name)
	return(localPlayer:WaitForChild("Owned" .. class .. "s"):GetAttribute(name) == true)
end

local getNextSellable = function()
	local data = {}
	for _,name in pairs(priority) do
		local models = stores:WaitForChild(name):WaitForChild("models")
		for _,model in pairs(models:GetChildren()) do 
			local object = model:GetAttributes()
			if(object.ActualObject) then
				object["Owns"] = owns((name == "backpack" and "Backpack" or "Tool"),object.ActualObject)
				object["Container"] = (name == "backpack" and "backpack" or "raygun")
				if(not object["Owns"] and (not object["PassId"])) then
					table.insert(data,object)
				end
			end
		end
	end
	table.sort(data,function(a,b)
		return(a.Price < b.Price)
	end)
	return data[1]
end

return function(success,values)
	if(values["first"]) then
		return
	end
	if(success) then
		if(not shared.menuClosedLol) then
			repeat
				game:GetService("RunService").Heartbeat:Wait()
			until(shared.menuClosedLol)
			task.wait(0.1)
			if(shared.backpackIsFull) then
				repeat
					game:GetService("RunService").Heartbeat:Wait()
				until(not shared.backpackIsFull)
			end
		end

		shared.promptTutorial(function(state)
			if(not state) then
				set("first",true,"ignore")
				return
			end
			local done = function()
				set("first",true);
			end
			local backpackFull = false;
			local hasTarget = false
			local ended = false
			local can = false

			local attempt;

			arrow.Visible = true
			local s;
			local on = function(char)
				if(char) then
					local m;
					m = char.ChildAdded:Connect(function(o)
						if(o:IsA("Tool")) then
							arrow.Visible = false
							s:Disconnect()
							can = true
							if(attempt) then
								m:Disconnect()
								library:setTarget(attempt)
								label.Text = "Click on a present to unwrap it"
							end
						end
					end)
				end
			end

			s = localPlayer.CharacterAdded:Connect(on)
			on(localPlayer.Character)

			local presentEvent = library:getPresentEvent();
			local connection = presentEvent.Bindable:Connect(function(present)
				if(backpackFull) then
					repeat 
						game:GetService("RunService").Heartbeat:Wait()
					until(not backpackFull);
				end
				if(present.PrimaryPart and not present:GetAttribute("Destroyed")) then
					hasTarget = true
					if(can) then
						attempt = present.PrimaryPart
						library:setTarget(present.PrimaryPart);
					else
						attempt = present.PrimaryPart
					end
				end
			end)

			local running;
			running = game:GetService("RunService").Heartbeat:Connect(function()
				presentEvent:Roll()
			end)
			
			local ss;

			local upd = function(state)
				if(hasTarget and (not ended)) then
					local data = getNextSellable()
					if(data) then
						if(tonumber(localPlayer.leaderstats.Coins.Real.Value) >= data.Price) then
							ended = true
							connection:Disconnect()
							label.Text = "Walk to the shop and buy an upgrade"
							running:Disconnect()
							library:setTarget(workspace:WaitForChild("areas"):WaitForChild("area1"):WaitForChild("shop"):WaitForChild("ShopPart"));
							local owned = {
								localPlayer:WaitForChild("OwnedTools"),
								localPlayer:WaitForChild("OwnedBackpacks")
							}
							local m = {}
							local endIt = function()
								done()
								label.Text = ""
								library:setTarget(nil)
							end
							local n = function()
								label.Text = "Keep it up and get to buying the next area!"
								local pointTo = getNextPlace()
								if(not pointTo) then
									label.Text = ""
									endIt()
								else
									library:setTarget(pointTo)
								end
								local c;
								c = localPlayer.AttributeChanged:Connect(function()
									if(getNextPlace() ~= pointTo) then
										c:Disconnect()
										endIt()
									end
								end)
							end
							for _,c in pairs(owned) do
								ss:Disconnect()
								m[c] = c.AttributeChanged:Connect(function()
									for _,conn in pairs(m) do
										conn:Disconnect()
									end
									n()
								end)
							end
						end
						--shared.hopto(data.Container,data.ActualObject)
					end
				end
			end
			
			ss = localPlayer:WaitForChild("leaderstats"):WaitForChild("Coins"):WaitForChild("Real").Changed:Connect(upd)
		end)
	end
end