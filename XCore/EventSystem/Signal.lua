-- Signal.lua
-- A threaded Lua signal system using coroutines.
-- Designed after Roblox's RBXScriptSignal class with some extra bells and whistles.


-- Synchronous signals can return `true` in any connected function to cancel the event.
-- A signal object has a "Canceled" property that will be set to true if the last FireSynchronously call was canceled. It is only changed when FireSynchronously is called.

local EventConnection = require("code/XCore/EventSystem/EventConnection")

local Signal = {}
Signal.__index = Signal
Signal.__type = "Signal"

-- Creates a new event signal provider.
function Signal.new()
	return setmetatable({
		Connections = {},
		Canceled = false
	}, Signal)
end

-- Connects a function to this signal.
-- Returns an EventConnection, which offers information about the event. It offers a :Disconnect() method to dispose that event.
function Signal:Connect(func)
	local connection = EventConnection.new(self, func)
	connection.Index = table.insertRetIdx(self.Connections, connection) -- Insert it into the connection array and set its ID so its Disconnect method works.
	self.Connections[connection.Index] = connection
	return connection
end

-- Asynchronously fires this signal, which runs all connected functions in their own coroutine.
-- They are not guaranteed to run in any particular order.
function Signal:Fire(...)
	local allCons = self.Connections
	for index = 1, #allCons do
		if allCons[index].Delegate ~= nil then
			-- Signal may be disconnected!
			Spawn(allCons[index].Delegate, ...)
		end
	end
end

-- Fires all connections in order and in the main thread, which can delay event calls if any function yields or does expensive operations.
-- A callback can return true to cancel the event.
function Signal:FireSynchronously(...)
	local allCons = self.Connections
	for index = 1, #allCons do
		if allCons[index].Delegate ~= nil then
			-- Signal may be disconnected!
			if allCons[index].Delegate(...) then
				self.Canceled = true
				return
			end
		end
	end
	self.Canceled = false
end

-- Fires all connections in order and in the main thread, which can delay event calls if any function yields or does expensive operations.
-- This version cannot be canceled.
function Signal:FireSynchronouslyNoCancel(...)
	local allCons = self.Connections
	for index = 1, #allCons do
		if allCons[index].Delegate ~= nil then
			-- Signal may be disconnected!
			if allCons[index].Delegate(...) then error("Cannot cancel event. Do not return true in any callbacks to this event!") end
		end
	end
end

-- Disposes all connections made to this signal and disposes the signal provider.
function Signal:Dispose()
	local allCons = self.Connections
	for index = 1, #allCons do
		allCons[index]:Disconnect()
	end
	DisposeObject(self)
end

return Signal