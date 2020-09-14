-- EventConnection.lua
-- Represents a connection to a Signal (see Signal.lua)

local Connection = {}
Connection.__index = Connection
Connection.__type = "Connection"

-- Constructs a new connection object.
function Connection.new(signal, func)
	-- Note to self or anyone else who knows Lua: See Globals.lua -- I've modified setmetatable to return the input table.
	return setmetatable({
		Signal = signal,
		Delegate = func,
		Index = -1 -- Calculated in the signal.
	}, Connection)
end

-- Disconnects this connection from its parent signal.
function Connection:Disconnect()
	assert(getmetatable(self) == Connection, ERR_STATIC_CALL:format("Disconnect", "Connection.new()"))
	table.remove(self.Signal.Connections, self.Index)
	self:Dispose()
end

-- Intended to be called INTERNALLY. This disposes of the connection but does NOT remove it from its parent Signal's connection list.
-- If it is not removed from the connection list, the parent signal will throw an error when it is fired due to attempting to fire a disposed object.
function Connection:Dispose()
	self.Signal = nil -- Get rid of this because it'll cause a stack overflow in the automatic disconnection that DisposeObject does.
	DisposeObject(self)
end

return Connection