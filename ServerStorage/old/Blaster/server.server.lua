require(game:GetService("ServerScriptService"):WaitForChild("logic"):WaitForChild("raygun"))(
	script.Parent,
	script:WaitForChild("function"),
	{
		damage = script.Parent:GetAttribute("Damage"),
		["delay"] = script.Parent:GetAttribute("Delay")
	}
)