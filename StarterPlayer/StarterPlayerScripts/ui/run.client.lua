local library = require(script.Parent:WaitForChild("library"));
shared.gui_library = library;

local topbar = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("topbar"));
local statUi = library.gui:WaitForChild("Container"):WaitForChild("Bottom"):WaitForChild("Menu");
local localPlayer = game:GetService("Players").LocalPlayer;
local network = require(game:GetService("ReplicatedStorage").shared:WaitForChild("network"));
local bindables = game:GetService("ReplicatedStorage"):WaitForChild("client");
local marketplaceService = game:GetService("MarketplaceService");
local passes = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("config")).passes;
local pageIndexes = {};
local controllerService = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("controllerService"))();
local pageCloseCallbacks = {};
local connectedController;

shared.promptTutorial = function(callback)
	library:modal("Would you like to take the tutorial?",callback)
end

shared.prompt_buy_area = function(cost,callback)
	library:modal(("Are you sure you want to buy this area for %s coins?"):format(library:format(cost)),function(state)
		local success,response = callback(state);
		if(not success and response) then
			library:notify(response);
		end
	end);
end

shared.backpackfull = function()
	task.spawn(function()
		if(not shared.menuClosedLol) then
			repeat
				game:GetService("RunService").Heartbeat:Wait()
			until(shared.menuClosedLol)
		end
		shared.backpackIsFull = true
		library:modal("Your backpack is full!",function(response)
			shared.backpackIsFull = false
			if(response) then
				localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(-84.025, 0.995, -52.295) + Vector3.new(0,8,0));
			end
		end,{"Close","Sell"});
	end)
end

local last;
local backpack = function()
	local b,a = localPlayer:GetAttribute("backpackSize"),localPlayer:GetAttribute("backpack");
	if((a == b) ~= last) then
		local state = (a == b);
		if(state) then
			shared.backpackfull()
		end
	end
	last = (a == b);
end

local toys = function(new)
	statUi.Presents.Label.Text = new;
end

local coins = function(new)
	statUi.Coins.Label.Text = new;
end

library.util.leaderstatChanged("Coins"):Connect(coins);
library.util.leaderstatChanged("Toys"):Connect(toys);
library.util.attributeChanged("backpackSize"):Connect(backpack);
library.util.attributeChanged("backpack"):Connect(backpack);

local pageIndex = library.gui:WaitForChild("Container"):WaitForChild("LeftContainer");
local existingPages = {"Shop","Rebirth","Pets","Settings"};
local pages = {};
local args = {Enum.EasingDirection.InOut,Enum.EasingStyle.Quad,0.4,true}
local inPos,outPos = UDim2.fromScale(0.5,0.5),UDim2.fromScale(0.5,-1.5);

local clicked = function(page)
	library:controls(false);
	library:newKey("menuClicked");
	for _,otherPage in pairs(pages) do
		local same = (otherPage == page);
		local position = (same and inPos or outPos);
		otherPage:TweenPosition(position,unpack(args));
	end
end

-- rebirth page:

if(not localPlayer:GetAttribute("loaded")) then
	repeat
		game:GetService("RunService").Heartbeat:Wait();
	until(localPlayer:GetAttribute("loaded"));
end

shared.write = function(t,k,v)
	network:invokeServer("uiSettings",k,v);
end

local _,uid = network:invokeServer("uiSettings","retrieve");
local uiData = {};
setmetatable(uiData,{
	__newindex = function(t,k,v)
		rawset(uid,k,v);
		coroutine.wrap(function()
			shared.write(t,k,v);
		end)();
	end,
	__index = function(self,k)
		return rawget(uid,k);
	end,
})

local add = {};
local co = require(game:GetService("ReplicatedStorage"):WaitForChild("config"));
for _,pageName in pairs(existingPages) do
	local page = library.gui:WaitForChild(pageName);
	local button = pageIndex:WaitForChild(pageName):WaitForChild("Button");
	local btn = button.Parent;
	local inside = false;
	library:notificationCount(btn,uiData[pageName] or 0);
	table.insert(pages,page);
	button.MouseButton1Click:Connect(function()
		library:moveOut();
		clicked(page);
		inside = true;
	end)
	add[pageName] = function()
		uiData[pageName] = uiData[pageName] or 0;
		uiData[pageName] += 1;
		library:notificationCount(btn,uiData[pageName]);
	end
	button.MouseEnter:Connect(function()
		library.sound.play(library.sound.library.hover,0.25);
	end)
	button.MouseButton1Click:Connect(function()
		for _,pair in pairs(co.ui_data) do
			if(pair[1] == pageName) then
				uiData[pageName] = 0;
				library:notificationCount(btn,0);
			end
		end
	end)
	local close = function()
		library:controls(true);
		library:newKey("menuClosed");
		page:TweenPosition(outPos,unpack(args));
		inside = false;
	end
	page:WaitForChild("Close").MouseButton1Click:Connect(close);
	table.insert(library.out,function()
		inside = false;
		page:TweenPosition(outPos,unpack(args));
	end)
	pageIndexes[page.Name] = page;
end

local responseStates = {
	["Yes"] = true,["No"] = false,["Next"] = true
}

local connectButtons = function(container,callback)
	container = container:WaitForChild("Buttons");
	local wrap = function(object)
		if(object:IsA("TextButton")) then
			object.MouseButton1Click:Connect(function()
				callback(responseStates[object.Name]);
			end)
		end
	end
	container.ChildAdded:Connect(wrap);
	for _,child in pairs(container:GetChildren()) do
		coroutine.wrap(wrap)(child);
	end
end

local _,rebirthCost = network:invokeServer("getRebirthPrice");
local page = library.gui:WaitForChild("Rebirth"):WaitForChild("Holder");
local initPage,confirmPage = page:WaitForChild("Page1"),page:WaitForChild("Page2");
local pages = {initPage,confirmPage};

local toPage = function(new)
	for _,page in pairs(pages) do
		local position = ((page == new) and UDim2.fromScale(0.5,0.5) or UDim2.fromScale(0.5,1.5));
		page:TweenPosition(position,unpack(args));
	end
end

local initChoice = function(response)
	toPage(confirmPage);
end

local handleNewPrice = function(price,multipliers)
	local formatted = library:format(price);
	pages[1].Canvas.Requirements.Coins.Label.Text = ("%s coins"):format(formatted);
	local currentSetup = function(frame)
		frame.CurrentCoins.Text = library:format(multipliers.coins).."x coins";
		frame.CurrentToys.Text = library:format(multipliers.toys).."x toys";
	end
	currentSetup(pages[1].Canvas.Rewards);
	currentSetup(pages[2].Prompt.Rewards);
end

local confirmChoice = function(response)
	if(response) then
		local success,result = network:invokeServer("rebirth");
		if(success) then
			library:ce(true);
			library:moveOut();
			handleNewPrice(result,network:invokeServer("getMultipliers"));
		else
			library:notify(result);
		end
	end
	toPage(initPage);
end

connectButtons(initPage,initChoice);
connectButtons(confirmPage,confirmChoice);
handleNewPrice(rebirthCost,network:invokeServer("getMultipliers"));

library.descendantOfClassLoaded(library.gui,{"TextButton","ImageButton"},function(object)
	if(localPlayer:GetAttribute("Sfx")) then
		object.MouseButton1Click:Connect(library.clickNoise);
	end
end)

bindables:WaitForChild("notification").Event:Connect(function(...)
	library:notify(...);
end)

bindables:WaitForChild("modal").Event:Connect(function(...)
	library:modal(...);
end)

bindables:WaitForChild("timeModal").Event:Connect(function(...)
	library:timeModal(...);
end)

network:bindRemoteEvent("createNotification",function(...)
	library:notify(...)
end)

if(library.platform == "mobile") then
	library.gui.Container.Position = UDim2.fromScale(0,0.75);
end

-- shop

local options,call = {"Coins","Passes","Boosts"},{};

for i = 1,#options do
	options[i] = {
		name = options[i],
		button = library.gui:WaitForChild("Shop"):WaitForChild("Buttons"):WaitForChild(options[i]),
		page = library.gui:WaitForChild("Shop"):WaitForChild("Pages"):WaitForChild(options[i])
	}
end

local selected;
local key;
for _,index in pairs(options) do
	local page = index.page;
	local button = index.button;
	call[index.name] = function()
		if(selected ~= index.name) then
			local current = tick();
			key = current;
			selected = index.name;
			local tweenLength = 1/4;
			for _,idx in pairs(options) do
				local isCurrent = (idx.name == index.name);
				local page = idx.page;
				if(page:FindFirstChild("Canvas") and page.Name == "Coins") then
					coroutine.wrap(function()
						library.util.wait(tweenLength/3);
						page.Canvas.Scroller.Visible = false;
						library.util.wait(tweenLength/2.5);
						if(key == current and (isCurrent)) then
							page.Canvas.Scroller.Visible = true;
						end
					end)();
				end
				if(isCurrent) then
					page.Position = UDim2.fromScale(0.5,1.5);
				end
				local y = 0.534;
				page:TweenPosition(
					isCurrent and UDim2.fromScale(0.5,y) or UDim2.fromScale(0.5,-1.5),
					Enum.EasingDirection.In,
					Enum.EasingStyle.Quad,
					tweenLength,
					true
				)
			end
		end
	end
	button.MouseButton1Click:Connect(call[index.name]);
end

call["Passes"]();

-- coin purchase

local getScroller = function(object)
	local parent = object.Parent;
	repeat
		parent = parent.Parent;
	until(parent:IsA("ScrollingFrame"));
	return parent;
end

local coinProducts = {};
library.descendantOfClassLoaded(library.gui,{"Frame","ScrollingFrame"},function(object)
	if(object.Name == "Popular" and object:IsA("Frame")) then
		library.whenFrameVisibilityChanges(getScroller(object),object,function(state)
			object.Visible = state;
		end)
	elseif(object:IsA("ScrollingFrame")) then
		local master = object.Parent.Parent.Parent.Parent;
		if(object.Parent.Name == "Canvas" and (master.Name == "Shop" or master.Name == "Boosts" or master.Name == "Pets")) then
			if(object.Name == "Scroller") then
				library:scrollingFrameBar(object,0);
				library:autoScrollingFrameSize(object);
			end
		end
	elseif(object:IsA("Frame") and object.Name == "Row") then
		library.childOfClassLoaded(object,{"Frame"},function(object)
			coinProducts[object.LayoutOrder] = object;
		end)
	end
end)

local connected = {};
local prices = {}

shared.prices = prices

network:fireServer("uiReady");
network:bindRemoteEvent("products",function(relativeAmount,pricing)
	for i = 1,6 do
		local productAmount = relativeAmount[i];
		local formatted = library.doFormat(productAmount,"5000");
		coinProducts[i]["Title"]["Amount"].Text = formatted;
		coinProducts[i]["Buy"]["Price"].Text = library.doFormat(pricing[i],"1000");
		prices[i] = {
			giveAmount = formatted,
			price = library.doFormat(pricing[i],"1000")
		}

		if(not connected[coinProducts[i]]) then
			local product = coinProducts[i];
			local purchase = function()
				network:fireServer("buyCoins",i);
			end
			connected[product] = product.Buy.MouseButton1Click:Connect(purchase);
			product.Icon.MouseButton1Click:Connect(purchase);
		end
		if(shared.priceUpdate) then
			shared.priceUpdate()
		end
	end
end)

shared.buyCoins = function(i)
	network:fireServer("buyCoins",i)
end

statUi:WaitForChild("Coins"):WaitForChild("Add").MouseButton1Click:Connect(function()
	clicked(pageIndexes["Shop"]);
	call["Coins"]();
end)

-- passes:

local passPage = library.gui:WaitForChild("Shop"):WaitForChild("Pages"):WaitForChild("Passes"):WaitForChild("Canvas"):WaitForChild("Scroller2");
--local passTemplate = script.Parent:WaitForChild("templates"):WaitForChild("Pass");

local passOwned = function(id,callback)
	local holder = localPlayer:WaitForChild("OwnedPasses",math.huge);
	local connection;
	local try = function()
		if(holder:GetAttribute(tostring(id))) then
			connection:Disconnect();
			callback();
		end
	end
	connection = holder.AttributeChanged:Connect(try);
	try();
end

local onChild = function(child)
	if(child:IsA("Frame")) then
		passOwned(child.Name,function()
			child.Buy.Visible = false;
			child.Owned.Visible = true;
		end)
		child:WaitForChild("Buy").MouseButton1Click:Connect(function()
			marketplaceService:PromptGamePassPurchase(localPlayer,tonumber(child.Name));
		end)
	end
end

passPage.ChildAdded:Connect(onChild);
for _,child in pairs(passPage:GetChildren()) do
	task.spawn(onChild,child);
end

--[[
for order,passId in pairs(passes) do
	coroutine.wrap(function()
		local success,info = pcall(function()
			return marketplaceService:GetProductInfo(passId,Enum.InfoType.GamePass);
		end)
		if(success and info) then
			local template = passTemplate:Clone();
			template.Parent = passPage;
			template.LayoutOrder = order;
			template.Icon.Image = ("rbxassetid://%s"):format(tostring(info.IconImageAssetId));
			template.Title.Text = info.Name;
			template.Title.Description.Text = info.Description;
			template.Buy.Price.Text = info.PriceInRobux;
			passOwned(passId,function()
				template.Owned.Visible = true;
				template.Buy.Visible = false;
			end)
			template.Buy.MouseButton1Click:Connect(function()
				marketplaceService:PromptGamePassPurchase(localPlayer,passId);
			end)
		end
	end)();
end
]]

-- boosts:

local boosts = library.gui:WaitForChild("Shop"):WaitForChild("Pages"):WaitForChild("Boosts");
local timeRemainings = localPlayer:WaitForChild("Boosts",math.huge);
local options = {"2xD","2xT"};

for i = 1,#options do
	local name = options[i];
	local option = 	boosts:WaitForChild("Canvas"):WaitForChild("Scroller"):WaitForChild(name);
	local add = option:WaitForChild("Add");
	local base = add.Size;
	local basePos = add.Position;
	local offset = 3;
	local colors = {
		[true] = Color3.fromRGB(6, 179, 69),
		[false] = Color3.fromRGB(10, 231, 87),
	}
	library.mouseState(add,function(state)
		local length = 1/4;
		--add:TweenSize(
		--(state and UDim2.new(base.X.Scale,offset,base.Y.Scale,offset) or base),
		---(state and Enum.EasingDirection.Out or Enum.EasingDirection.In),Enum.EasingStyle.Quad,length,true
		---)
		library:tween(add,{
			["ImageColor3"] = colors[state]
		},length)
	end)
	add.MouseButton1Click:Connect(function()
		library:timeModal(option.Title.Text,function(response)
			network:invokeServer("purchaseProduct",name,response)
		end)
	end)
end

local images,icons,tips = {
	["2xD"] = "rbxassetid://8108354884",
	["2xT"] = "rbxassetid://8108364046"
},{},{
	["2xD"] = "Time remaining for 2x damage boost",
	["2xT"] = "Time remaining for 2x toys boost"
}

local signal = function()
	for boostName,remaining in pairs(timeRemainings:GetAttributes()) do
		if(images[boostName]) then
			if(not icons[boostName]) then
				local icon = topbar.new():setImage(images[boostName]);
				icon:setTip(tips[boostName]);
				icon.selected:Connect(function()
					icon:deselect();
				end)
				icons[boostName] = icon;
			end
			icons[boostName]:setLabel(library:formatTimeOther(remaining));
			icons[boostName]:setEnabled(remaining >= 1);
		end
	end
end

timeRemainings.AttributeChanged:Connect(signal);
signal();


-- pets:

local success,result = network:invokeServer("petManager","getPets");
local myPets = (success and result.owned or {});
local ui = library.gui.Pets;
local template = script.Parent:WaitForChild("templates"):WaitForChild("Pet");
local petCache = {};
local states = {};
local signals = {};
local equip = library.gui:WaitForChild("Equip");
local connections = {};
local duplicates = {};

local getIcon = function(name,owned)
	for _,pet in pairs(owned) do
		if(pet.displayName == name) then
			return pet.image;
		end
	end
end

equip:WaitForChild("Close").MouseButton1Click:Connect(function()
	library:ce(true);
	library:moveOut();
end)

local lastClicked = tick();
local about = library.gui:WaitForChild("About");
table.insert(library.out,function()
	about:TweenPosition(UDim2.new(0.5,0,-1.5,0),unpack(args));
end)
about:WaitForChild("Close").MouseButton1Click:Connect(function()
	library:controls(true);
	library:moveOut();
end)

local setPet = function(pet)
	local success,response = network:invokeServer("petManager","getPetInfo",pet.displayName);
	about:TweenPosition(UDim2.new(0.5,0,0.5,0),unpack(args));
	library:controls(false);
	about["Container"]["Tier"]["Txt"]["Text"] = pet.displayName;
	for name,value in pairs(response) do
		if(name ~= "Tier" and name ~= "Image") then
			about["Container"][name]["Txt"]["Text"] = value;
		elseif(name == "Tier") then
			local tierCon = about["Container"]["Tier"];
			tierCon["Gradient"]["Color"] = tierCon["Gradients"][value]["Color"];
		elseif(name == "Image") then
			about["Container"]["Icon"]["Image"] = value;
		end
	end
end

local clicked = function(pet,action)
	local key = tick();
	lastClicked = key;
	if(action == "Equip") then
		local success,response = network:invokeServer("petManager","getPets");
		if(success) then
			for _,conn in pairs(connections) do
				conn:Disconnect();
			end
			local on = {};
			connections = {};
			equip:TweenPosition(UDim2.new(0.5,0,0.5,0),unpack(args));
			for i = 1,6 do
				equip.Options[tostring(i)].Icon.Image = "";
				local overlay = equip.Options[tostring(i)]:FindFirstChild("LockedOverlay");
				if(overlay) then
					if(localPlayer:GetAttribute("MorePets")) then
						overlay.Visible = false;
					end
				end
				table.insert(connections,equip.Options[tostring(i)].MouseButton1Click:Connect(function()
					if(overlay and overlay.Visible == true) then
						if(not localPlayer:GetAttribute("MorePets")) then
							marketplaceService:PromptGamePassPurchase(localPlayer,24838174);
							repeat
								game:GetService("RunService").Heartbeat:Wait();
							until((key ~= lastClicked) or (localPlayer:GetAttribute("MorePets")));
							if(localPlayer:GetAttribute("MorePets") and (key == lastClicked)) then
								for i = 1,6 do
									local main = equip.Options[tostring(i)];
									if(main:FindFirstChild("LockedOverlay")) then
										main:FindFirstChild("LockedOverlay").Visible = false;
									end
								end
							end
						else
							overlay.Visible = false;
							on[i]();
						end
					else
						on[i]();
					end
				end))
				on[i] = function()
					local data = pet;
					library:moveOut();
					local id;
					local cantUse = {};
					if(duplicates[pet.name]) then
						for _,dupId in pairs(duplicates[pet.name]) do
							for _,equipped in pairs(response.equipped) do
								if(equipped.id == dupId) then
									cantUse[dupId] = true;
								end
							end
							if(not cantUse[dupId]) then
								cantUse[dupId] = false;
							end
						end
						local found = false;
						for k,v in pairs(cantUse) do
							if(not v) then
								found = true;
								id = k;
								break;
							end
						end
						if(not found) then
							for k,v in pairs(cantUse) do
								id = k;
								break;
							end
						end
					else
						id = pet.identifier;
					end
					local success,response = network:invokeServer("petManager","equip",{
						name = data.displayName,
						slot = i,
						id = id
					});
					library:ce(true);
					if(not success) then
						library:notify(response);
					end
				end
			end
			for slot,data in pairs(response.equipped) do
				local main = equip.Options[tostring(slot)];
				main.Icon.Image = getIcon(data.name,response.owned);
				if(main:FindFirstChild("LockedOverlay")) then
					main.LockedOverlay.Visible = not(localPlayer:GetAttribute("MorePets") == true);
				end
			end
		else
			library:notify(response);
		end
	elseif(action == "Unequip") then
		local success,response = network:invokeServer("petManager","getPets");
		if(success and response) then
			library:ce(true);
			for _,data in pairs(response["equipped"]) do
				if(data.name == pet.displayName) then
					local success,response = network:invokeServer("petManager","unequip",{
						name = pet.displayName,
						id = data.id
					});
					if(not success) then
						library:notify(response);
					end
				end
			end
		end
	elseif(action == "Sell") then
		local getPriceForPet = function(pet)
			local arr = {
				["Legendary"] = 25000,
				["Common"] = 3500,
				["Uncommon"] = 13500
			}
			return arr[pet.tier];
		end
		library:modal(("Are you sure you want to sell \"%s\" for %s coins?"):format(pet.displayName,getPriceForPet(pet)),function(response)
			if(response) then
				local success,response = network:invokeServer("petManager","sell",{
					name = pet.displayName,
					id = pet.identifier
				});
				if(not success) then
					library:notify(response);
				end
			end
		end)
	elseif(action == "Info") then
		setPet(pet);
	end
end

table.insert(library.out,function()
	equip:TweenPosition(UDim2.new(0.5,0,-1.5,0),unpack(args));
end)

local count = 0;
local ids = {};
local change = {};

local guiService = game:GetService("GuiService");
local selectObject = function(object)
	if(connectedController) then
		guiService.SelectedObject = object;
	end
end

local on = function(pet)
	count += 1;
	library:setShadowedText(ui.Amount,"Pets: " .. count .."/"..localPlayer:GetAttribute("petLimit"));
	if(not petCache[pet.name]) then
		ids[pet.name] = pet.identifier;
		local gradient = template.Gradients[pet.tier].Color;
		local temp = template:Clone();
		local state = false;
		local equipButton = library.gui.Cover.Absolute.Equip;
		local setSelection = function()
			temp.Interact.NextSelectionRight = equipButton;
		end
		temp.Tier.Gradient.Color = gradient;
		temp.Tier.TextLabel.Text = pet.displayName;
		temp.Icon.Image = pet.image;
		change[pet.displayName] = function(new)
			state = new;
			states[pet.displayName] = new;
		end
		local absolute = function()
			local pos = temp.Absolute.AbsolutePosition;
			if(state) then
				library.gui.Cover.Absolute.Position = UDim2.fromOffset(pos.X,pos.Y);
				library.gui.Cover.Absolute.Visible = true;
			end
		end
		local onClick;
		onClick = function(realClick)
			states[pet.displayName] = state;
			absolute();
			local found = false;
			for key,v in pairs(states) do
				if(v) then
					found = true;
					break;
				end
			end
			if(not found) then
				library.gui.Cover.Absolute.Visible = false;
			end
			if(realClick) then
				for _,signal in pairs(signals) do
					signal:Disconnect();
				end
				for _,object in pairs(library.gui.Cover.Absolute:GetChildren()) do
					if(object:IsA("TextButton")) then
						table.insert(signals,object.MouseButton1Click:Connect(function()
							library:moveOut();
							for name,_ in pairs(states) do
								change[name](false);
							end
							absolute();
							clicked(pet,object.Name);
							onClick();
						end));
					end
				end
			end
		end
		temp.Parent = ui.Pages.Pets.Canvas.Scroller;
		library.whenFrameVisibilityChanges(ui.Pages.Pets.Canvas.Scroller,temp.Absolute,function(visible)
			if(not visible and (state and (states[pet.displayName]))) then
				state = false;
				for name,_ in pairs(states) do
					change[name](false);
				end
				onClick();
			end
		end)
		temp:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
			absolute();
		end)
		absolute();
		temp.Interact.MouseButton1Click:Connect(function()
			state = not state;
			states[pet.displayName] = state;
			setSelection();
			if(state) then
				onClick(true);
			else
				library.gui.Cover.Absolute.Visible = false;
			end
		end)
		setSelection();
		petCache[pet.name] = {
			template = temp,
			amount = 1
		};
	else
		duplicates[pet.name] = duplicates[pet.name] or {
			ids[pet.name]
		};
		table.insert(duplicates[pet.name],pet.identifier);
		petCache[pet.name].amount += 1;
		local more = petCache[pet.name].template.More;
		more.TextLabel.Text = petCache[pet.name].amount;
		more.Visible = true;
	end
end

shared.just_unlocked = function(petData)
	on(petData);
	table.insert(myPets,petData);
	add["Pets"]();
end

local refresh = function(myPets)
	count = 0;
	states = {};
	library.gui.Cover.Absolute.Visible = false;
	library:setShadowedText(ui.Amount,"Pets: " .. count .."/"..localPlayer:GetAttribute("petLimit"));
	for _,pet in pairs(myPets) do
		on(pet);
	end
end

refresh(myPets);
network:bindRemoteEvent("refreshPets",function()
	for _,pet in pairs(ui.Pages.Pets.Canvas.Scroller:GetChildren()) do
		if(pet:IsA("Frame")) then
			pet:Destroy();
		end
	end
	local success,result = network:invokeServer("petManager","getPets");
	local pets = (success and result.owned or {});
	myPets = pets;
	petCache = {};
	duplicates = {};
	refresh(myPets);
end)

-- stuff:

library.descendantOfClassLoaded(workspace,{"ScrollingFrame"},function(object)
	library:scrollingFrameBar(object,50,true);
end)

-- yea:

local callbacks = {
	["Music"] = function(state)
		localPlayer:SetAttribute("MusicEnabled",state);
	end,
	["Sfx"] = function(state)
		localPlayer:SetAttribute("Sfx",state);
	end,
	["OtherPets"] = function(state)
		shared.pet_state(state);
	end,
}

local gui = localPlayer.PlayerGui:WaitForChild("UI")
local colorPickerWidget = gui:WaitForChild("Widget")
local colorPickerModule = require(game:GetService("ReplicatedStorage"):WaitForChild("logic"):WaitForChild("colorPicker"))
local currentColor

local colorPickerApi = colorPickerModule:start(colorPickerWidget,function(newColor)
	currentColor = newColor
end)

local confirm = colorPickerWidget:WaitForChild("Buttons"):WaitForChild("Confirm")
local decline = confirm.Parent:WaitForChild("Decline")
local onClicked = function() end

confirm.MouseButton1Click:Connect(function()
	onClicked(true)
end)

decline.MouseButton1Click:Connect(function()
	onClicked(false)
end)

table.insert(library.out,function()
	colorPickerWidget:TweenPosition(UDim2.fromScale(-1.5,0.5),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,0.25,true)
end)

library.descendantOfClassLoaded(library.gui,{"Frame"},function(object)
	if(object:GetAttribute("ConfigName")) then
		local configName = object:GetAttribute("ConfigName");
		local class = object:GetAttribute("Class");
		if(class == "bool") then
			local state = true;
			if(uiData[configName] ~= nil) then
				state = uiData[configName];
			end

			local check = object:WaitForChild("Check");
			local checked = check:WaitForChild("Checked");
			local unchecked = check:WaitForChild("Unchecked");

			local handle = function()
				uiData[configName] = state;
				callbacks[configName](state);
				checked.Visible = state;
				unchecked.Visible = (not state);
			end

			unchecked.MouseButton1Click:Connect(function()
				state = not state;
				handle();
			end)

			checked.MouseButton1Click:Connect(function()
				state = not state;
				handle();
			end)

			handle();
		elseif(class == "code") then
			local claim = object:WaitForChild("Claim");
			local input = object:WaitForChild("Input"):WaitForChild("Box");
			claim.MouseButton1Click:Connect(function()
				local success,response = network:invokeServer("redeemCode",input.Text);
				library:notify(response);
			end)
		elseif(class == "Color3") then
			local color = network:invokeServer("getColor",configName)
			local box = object:WaitForChild("Check")
			local container = box.Parent.Parent.Parent
			if(color) then
				box.BackgroundColor3 = Color3.fromHex(color)
			end
			box.MouseButton1Click:Connect(function()
				if(not localPlayer:GetAttribute("Colors")) then
					marketplaceService:PromptGamePassPurchase(localPlayer,45343802)
					return
				end
				colorPickerApi:setColor(box.BackgroundColor3)
				library:moveOut()
				task.wait()
				colorPickerWidget:TweenPosition(UDim2.fromScale(0.5,0.5),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.25,true)
				onClicked = function(state)
					if(state) then
						box.BackgroundColor3 = currentColor
						task.spawn(function()
							network:invokeServer("changeChatColor",configName,currentColor)
						end)
					end
					library:moveOut()
				end
			end)
		end
	end
end)

-- admin util:
local icon = require(game:GetService("ReplicatedStorage"):WaitForChild("client"):WaitForChild("topbar"));
local ss = game:GetService("SocialService");
local success,can = pcall(function()
	return ss:CanSendGameInviteAsync(localPlayer);
end)
if(success and can) then
	local invite = icon.new():setLabel("Invite"):setImage(6035056477);
	invite.selected:Connect(function()
		invite:deselect();
		ss:PromptGameInvite(localPlayer);
	end)
end

if(localPlayer:GetRankInGroup(12248057) > 200) then
	local fps = icon.new():setLabel("0 FPS")

	fps.selected:Connect(function()
		fps:deselect();
	end)

	local ping = icon.new():setLabel("0 ping")

	ping.selected:Connect(function()
		ping:deselect();
	end)

	local i = 0;
	local s = tick();
	game:GetService("RunService").RenderStepped:Connect(function()
		i += 1;
		if(tick()-s>=1) then
			s = tick();
			fps:setLabel(i .. " FPS");
			i = 0;
		end
	end)

	coroutine.wrap(function()
		while wait(0.5) do
			local s = tick();
			network:invokeServer("ping");
			ping:setLabel(math.floor(((tick() - s) / 2) * 1000) .. " ping");
		end
	end)();
end

-- daily login:

local initKey = "beginTransmissions";
local dailyRewardEvent = "dailyRewardTransmitter";
local dailyRewardMenu = library.gui.DailyReward;
local canClaim = false;
local currentStreakRelative = 0;

local try = function()
	dailyRewardMenu.Claim.Visible = canClaim;
	dailyRewardMenu.Claimed.Visible = (not canClaim);
end

local getDayFromId = function(day)
	for _,child in pairs(dailyRewardMenu.Claims:GetChildren()) do
		if(child:IsA("Frame") and child.LayoutOrder == day) then
			return child;
		end
	end
end

local setProgressBar = function(streak)
	local original = streak;
	if(streak > 5) then
		repeat
			streak += -5;
		until(streak <= 5);
	end
	local difference = (original - streak);
	currentStreakRelative = streak;
	dailyRewardMenu.Progress.Bar:TweenSize(UDim2.fromScale(
		(streak / 5),1
		),Enum.EasingDirection.Out,Enum.EasingStyle.Bounce,0.85,true);
	for day = 1,5 do
		local object = getDayFromId(day);
		local claimStatus = streak >= day;
		library:dailyRewardObjectState(object,(not claimStatus));
		object.Title.Text = "Day " .. day + difference
	end
end

network:bindRemoteEvent(dailyRewardEvent,function(key,...)
	local args = {...};
	if(key == "lostStreak") then
		setProgressBar(0);
	elseif(key == "newStreak") then
		local currentStreak = args[1];
		setProgressBar(currentStreak);
		try();
	elseif(key == "countdown") then
		canClaim = false;
		local canClaimIn = library:formatTime(args[1]);
		local text = ("Next reward in %s"):format(canClaimIn);
		library:setShadowedText(dailyRewardMenu.Next,text);		
		try();
	elseif(key == "claimBy") then
		canClaim = true;
		local hasToClaimBy = library:formatTime(args[1]);
		local text = ("Claim in %s"):format(hasToClaimBy);
		library:setShadowedText(dailyRewardMenu.Next,text);		
		try();
	elseif(key == "canClaim") then
		local canClaimIn = library:formatTime(0);
		local text = ("Next reward in %s"):format(canClaimIn);
		canClaim = true;
		try();
	elseif(key == "playStreakSound") then
		library.sound.play(library.sound.library.daily,1);
	end
end)

local update = function()
	local rewards = network:invokeServer("nextRewards");
	for _,reward in pairs(rewards) do
		for _,day in pairs(dailyRewardMenu["Claims"]:GetChildren()) do
			if(day:IsA("Frame")) then
				if(day.LayoutOrder == reward.day) then
					day["Icon"]["Image"] = reward.icon;
					day["Reward"]["Text"] = reward.text;
				end
			end
		end
	end
end

table.insert(library.out,function()
	dailyRewardMenu:TweenPosition(UDim2.fromScale(0.5,-1.5),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.16,true);
end)

local ctrls = require(localPlayer.PlayerScripts:WaitForChild("PlayerModule")):GetControls();
local controls = {};

function controls:Enable()
	game:GetService("GuiService").TouchControlsEnabled = true;
end

function controls:Disable()
	game:GetService("GuiService").TouchControlsEnabled = false;
end

dailyRewardMenu:WaitForChild("Close").MouseButton1Click:Connect(function()
	game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All,true);
	shared.menuClosedLol = true;
	controls:Enable();
	dailyRewardMenu:TweenPosition(UDim2.fromScale(0.5,-1.5),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.16,true);
end)

dailyRewardMenu:TweenPosition(UDim2.fromScale(0.5,0.5),Enum.EasingDirection.In,Enum.EasingStyle.Quad,0.16,true);

network:fireServer(dailyRewardEvent,initKey);
dailyRewardMenu.Claim.MouseButton1Click:Connect(function()
	network:fireServer(dailyRewardEvent,"claimDaily");
	game:GetService("RunService").Heartbeat:Wait();
	update();
end)
update();

local leaderstats = localPlayer:WaitForChild("leaderstats");
local coins = leaderstats:WaitForChild("Coins"):WaitForChild("Real");
local toys = leaderstats:WaitForChild("Toys"):WaitForChild("Real");
local last = {
	coins = coins.Value,
	toys = toys.Value
};

local handleDifference = function(diff,class,actual)
	if(diff > 1) then
		local template = script.Parent:WaitForChild("templates"):WaitForChild(("Add%s"):format(class)):Clone();
		local viewportSize = workspace.CurrentCamera.ViewportSize;
		template.Position = UDim2.fromOffset(
			math.random(1,viewportSize.X),
			math.random(1,viewportSize.Y)
		)
		template.Parent = library.gui;
		template.TextLabel.Text = "+"..(library:format(diff));
		local a = library.gui.Container.Bottom.Menu[actual].AbsolutePosition;
		template:TweenPosition(UDim2.fromOffset(
			a.X,a.Y
			),Enum.EasingDirection.In,Enum.EasingStyle.Linear,0.75,true,function()
				template:Destroy();
			end)
	end
end

network:bindRemoteEvent("onStatChange",function(difference,class,actual)
	handleDifference(difference,class,actual);
end)

shared.controllers = {};

local connected = false;
controllerService.Connected:Connect(function(controller)
	connectedController = controller;
	connected = true;
	shared.controllers[controller.Enum] = controller;
	controller.PrimaryButtonPressed:Connect(function(button,gameProcessed)
		if(not gameProcessed) then
			if(button == Enum.KeyCode.ButtonB) then
				for _,callback in pairs(pageCloseCallbacks) do
					callback();
				end
			end
		end
	end)
end)

controllerService.Disconnected:Connect(function(enum)
	shared.controllers[enum] = nil;
	connected = false;
	connectedController = nil;
end)

game:GetService("RunService").Heartbeat:Wait();
controllerService:Start();
local selectableClasses,selectCallback = {"TextButton","ImageButton"},function(obj)
	obj.Selectable = true;
end
library.descendantOfClassLoaded(library.gui,selectableClasses,selectCallback);
library.descendantOfClassLoaded(library.gui,{"ScrollingFrame"},function(obj)
	obj.Selectable = false;
end)