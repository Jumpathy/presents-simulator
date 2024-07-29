local Ripple = script.Parent.Texture
local RipplePosUMax = Ripple.StudsPerTileU-1
local RipplePosVMax = Ripple.StudsPerTileV-1
local Water = script.Parent:FindFirstAncestorOfClass("Model")
local RippleDelay = Water:GetAttribute("Delay")

while true do
	
	Ripple.OffsetStudsU = math.random(0,RipplePosUMax)
	Ripple.OffsetStudsV = math.random(0,RipplePosVMax)
	task.wait(RippleDelay)
	
end
