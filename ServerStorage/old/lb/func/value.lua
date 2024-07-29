local value = {
	values = {}
};

function value.new(base,start)
	local isObject = false;
	if(typeof(base) == "Instance") then
		isObject = (base:IsA("NumberValue") or base:IsA("IntValue"));
	end
	local psuedoObject = {};
	if(isObject) then
		local internal = {val = base.Value or 0,callbacks = {}};
		local update = function()
			local value = base.Value;
			internal.Value = value;
			for _,callback in pairs(internal.callbacks) do
				coroutine.wrap(callback)(value);
			end
		end
		base:GetPropertyChangedSignal("Value"):Connect(update);
		update();
		
		psuedoObject.Changed = {};
		function psuedoObject.Changed:Connect(callback)
			coroutine.wrap(callback)(internal.val);
			table.insert(internal.callbacks,callback);
		end
		
		function psuedoObject:Change(value)
			assert(typeof(value)=="number","Invalid type, looking for 'number'");
			base.Value = value;
		end
	else
		local internal = {val = start or 0,callbacks = {}};
		function psuedoObject:Change(value)
			assert(typeof(value)=="number","Invalid type, looking for 'number'");
			internal.val = value;
			for _,callback in pairs(internal.callbacks) do
				coroutine.wrap(callback)(value);
			end
		end
		
		psuedoObject.Changed = {};
		function psuedoObject.Changed:Connect(callback)
			coroutine.wrap(callback)(internal.val);
			table.insert(internal.callbacks,callback);
		end
	end
	table.insert(value.values,psuedoObject);
	return psuedoObject;
end

return value;