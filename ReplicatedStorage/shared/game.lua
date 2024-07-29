local psuedo = {
	GetService = function(self,service)
		print(service)
		if(service == "RunService") then
			local mt = {};
			function mt:IsStudio()
				return false;
			end
			function mt:IsClient()
				return game:GetService("RunService"):IsClient();
			end
			function mt:IsServer()
				return game:GetService("RunService"):IsServer();
			end
			setmetatable(mt,{
				__index = function(k,v)
					print(k,v);
				end,
			})
			return mt;
		end
	end
};

setmetatable(psuedo,{
	__index = function(k,v)
		print(k,v);
	end,
})

return psuedo;