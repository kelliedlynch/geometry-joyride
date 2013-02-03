Dispatch = {}
Dispatch.events = {}

function Dispatch.registerEvent(event, listener, persistent)
	if not persistent then persistent = false end
	if Dispatch.events[event] then
		if Dispatch.events[event][listener] then
			print("event listener already registered")
		else
			--print("registered listener", listener, "for event", event)
			Dispatch.events[event][listener] = persistent
		end
	else
		--print("registered listener", listener, "for event", event)
		Dispatch.events[event] = {}
		Dispatch.events[event][listener] = persistent
	end
end

function Dispatch.triggerEvent(event, ...)
	--print("triggering event", event)
	if Dispatch.events[event] then
		--print("event exists")
		for listener, persistent in pairs(Dispatch.events[event]) do
			--print("pinging listener", listener)
			listener["___"..event](listener, ...)
			if not persistent then
				Dispatch.events[event][listener] = nil
			end
		end
	end
end

function Dispatch.unregisterEvent(event)
	--print("unregistering event", event)
	Dispatch.events[event] = nil
end

function Dispatch.removeListener(listener)
	for event, listeners in pairs(Dispatch.events) do
		--print("removing listener", listener)
		listeners[listener] = nil
	end
end

function Dispatch.removeListenerForEvent(listener, event)
	Dispatch.events[event][listener] = nil
end