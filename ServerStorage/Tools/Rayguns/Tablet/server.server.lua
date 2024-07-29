require(game:GetService("ServerScriptService"):WaitForChild("game"):WaitForChild("logic"):WaitForChild("raygun"))(
	script.Parent,
	script:WaitForChild("function"),
	{
		damage = function()
			return script.Parent:GetAttribute("Damage")
		end,
		["delay"] = script.Parent:GetAttribute("Delay")
	}
)