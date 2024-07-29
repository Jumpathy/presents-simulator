local wrapper = {};
local service = game:GetService("MessagingService");

function wrapper.onEvent(topic)
	local bindable = Instance.new("BindableEvent");
	local success,response = pcall(function()
		service:SubscribeAsync(topic,function(response)
			bindable:Fire(response.Data);
		end)
	end)
	if(not success) then
		warn("[Messaging service error]:",response);
	end
	return bindable.Event;
end

function wrapper:post(topic,data)
	local success,response = pcall(function()
		service:PublishAsync(topic,data);
	end)
	if(not success) then
		warn(response);
	end
	return(success);
end

return wrapper;