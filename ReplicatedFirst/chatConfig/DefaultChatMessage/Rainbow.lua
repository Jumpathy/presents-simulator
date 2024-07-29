local cached = {};
-- rainbow credit: https://devforum.roblox.com/t/4-uigradient-animations-including-rainbow/557922

return function(gradient)
	coroutine.wrap(function()
		if(not cached[gradient]) then
			cached[gradient] = true;
			local ts = game:GetService("TweenService")
			local ti = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local offset = {Offset = Vector2.new(1, 0)}
			local create = ts:Create(gradient, ti, offset)
			local startingPos = Vector2.new(-1, 0)
			local list = {} --list of random colors (we'll be generating them shortly after)
			local s, kpt = ColorSequence.new, ColorSequenceKeypoint.new
			local counter = 0
			local status = "down"

			gradient.Offset = startingPos --reset the offset of the gradient

			local function rainbowColors()
				local sat, val = 255, 255 

				for i = 1, 15 do

					local hue = i * 17 --255/15 = 17
					table.insert(list, Color3.fromHSV(hue / 255, sat / 255, val / 255)) --divide by 255 to be in range of 0-1

				end

			end

			rainbowColors() --add to the list table

			--set up the first gradient 
			gradient.Color = s({

				kpt(0, list[#list]),
				kpt(0.5, list[#list - 1]),
				kpt(1, list[#list - 2])

			})

			counter = #list --max indexed is #list, which is 10 in this instance

			local function animate()

				create:Play()
				create.Completed:Wait() --wait for tween completion
				gradient.Offset = startingPos 
				gradient.Rotation = 180 --flip time!

				if counter == #list - 1 and status == "down" then

					gradient.Color = s({

						kpt(0, gradient.Color.Keypoints[1].Value), --preserve previous color, which we'll be able to see
						kpt(0.5, list[#list]), --change this color behind the scenes!
						kpt(1, list[1]) --change this color behind the scenes!

					})

					counter = 1 --last index is 1 i.e. list[1]
					status = "up" --the upper section already ran, time for the lower!

				elseif counter == #list and status == "down" then --if the current counter is exactly 10 (in this instance), then it will go back to 1 and 2

					gradient.Color = s({

						kpt(0, gradient.Color.Keypoints[1].Value),
						kpt(0.5, list[1]),
						kpt(1, list[2])

					})

					counter = 2
					status = "up"

				elseif counter <= #list - 2 and status == "down" then  --in all other cases, when couter is 1-8

					gradient.Color = s({

						kpt(0, gradient.Color.Keypoints[1].Value),
						kpt(0.5, list[counter + 1]), --one color over
						kpt(1, list[counter + 2]) --two colors over

					})

					counter = counter + 2
					status = "up"

				end

				create:Play()
				create.Completed:Wait()
				gradient.Offset = startingPos
				gradient.Rotation = 0 --flip time again!

				if counter == #list - 1 and status == "up" then --same as before, really, but instead of "down", it's "up", since the upper section already ran

					gradient.Color = s({

						--descending order because now it's rotation 0
						kpt(0, list[1]), --1
						kpt(0.5, list[#list]), --10
						kpt(1, gradient.Color.Keypoints[3].Value) --put this at #3 because we just flipped rotation, so this color will be at the opposite side

					})

					counter = 1
					status = "down" --below section already ran, back to the top!

				elseif counter == #list and status == "up" then

					gradient.Color = s({

						kpt(0, list[2]), --2
						kpt(0.5, list[1]), --1
						kpt(1, gradient.Color.Keypoints[3].Value) --10

					})

					counter = 2
					status = "down"

				elseif counter <= #list - 2 and status == "up" then --in all other cases like before

					gradient.Color = s({

						kpt(0, list[counter + 2]), 
						kpt(0.5, list[counter + 1]), 
						kpt(1, gradient.Color.Keypoints[3].Value) 

					})

					counter = counter + 2
					status = "down"

				end

				if(gradient:GetFullName() ~= gradient.Name) then
					animate() --call the function inside of itself, so that it runs indefinitely
				end
			end

			animate() --call the function initially 
		end
	end)();
end