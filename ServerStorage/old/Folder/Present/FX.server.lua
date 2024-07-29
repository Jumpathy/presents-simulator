local network = require(game:GetService("ReplicatedStorage"):WaitForChild("shared"):WaitForChild("network"));
network:fireAllClients("giftAnimation",script.Parent,script.Parent.Values.Owner.Value);

local owner = script.Parent.Values.Owner.Value;

script.Parent.Health.Enabled = false;
game:GetService("Debris"):AddItem(script.Parent,5);