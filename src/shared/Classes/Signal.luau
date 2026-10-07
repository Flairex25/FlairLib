-- --!strict
-- --!nonstrict
--!nocheck
--------------------------------------------------------------------------------
--Directories
const shared = game:GetService("ReplicatedStorage").Shared
--------------------------------------------------------------------------------
--Classes
--const class = require(shared.Classes.class)
--------------------------------------------------------------------------------
--Services
--const Service = require(shared.Services.Service)
const TaskService = require(shared.Services.TaskService)
--------------------------------------------------------------------------------
--Types
export type Signal<T...> = {
	-----------------
	Type: "Signal",
	-----------------
	--Private
	_firstConnection: Connection<T...>?,
	_lastConnection: Connection<T...>?,
	-----------------
	--Public
	GetConnections: (self: Signal<T...>) -> { Connection<T...> },
	GetFirstConnection: (self: Signal<T...>) -> Connection<T...>?,
	GetLastConnection: (self: Signal<T...>) -> Connection<T...>?,
	--
	Fire: (self: Signal<T...>, T...) -> (),
	--
	Connect: (self: Signal<T...>, fn: (T...) -> (), ...any) -> Connection<T...>,
	Once: (self: Signal<T...>, fn: (T...) -> (), ...any) -> Connection<T...>,
	Wait: (self: Signal<T...>) -> T...,
	-----------------
}
--
export type Connection<T...> = {
	-----------------
	Type: "Connection",
	-----------------
	--Private
	_signal: Signal<T...>,
	_prev: Connection<T...>?,
	_next: Connection<T...>?,
	_fn: (T...) -> (),
	_once: boolean,
	_thread: thread?,
	_args: { any },
	-----------------
	--Public
	GetSignal: (self: Connection<T...>) -> Signal<T...>,
	GetNext: (self: Connection<T...>) -> Connection<T...>?,
	GetPrevious: (self: Connection<T...>) -> Connection<T...>?,
	GetFunction: (self: Connection<T...>) -> (T...) -> (),
	GetThread: (self: Connection<T...>) -> thread,
	GetArgs: (self: Connection<T...>) -> ...any?,
	--
	Disconnect: (self: Connection<T...>) -> (),
	Reconnect: (self: Connection<T...>) -> (),
	-----------------
}
--------------------------------------------------------------------------------
--Class
--------------------------------------------------------------------------------
--Objects
local Signal = {} :: Signal<any>
Signal.Type = "Signal"
Signal.__index = Signal
--
local Connection = {} :: Connection<any>
Connection.Type = "Connection"
Connection.__index = Connection
--------------------------------------------------------------------------------
--Make Objects Strict
setmetatable(Signal, {
	------------------
	__index = function(_:Signal<any>, key)
		warn(string.format("Attempt to get invalid member %s of Signal!",key))
	end,
	__newindex = function(_:Signal<any>, key)
		warn(string.format("Attempt to set invalid member %s of Signal!",key))
	end,
})
--
setmetatable(Connection, {
	------------------
	__index = function(_:Connection<any>, key)
		warn(string.format("Attempt to get invalid member %s of Connection!",key))
	end,
	__newindex = function(_:Connection<any>, key)
		warn(string.format("Attempt to set invalid member %s of Connection!",key))
	end,
})
--------------------------------------------------------------------------------
--Constructors
const function signalConstructor<T...>(): Signal<T...>
	return (setmetatable({}, Signal) :: any) :: Signal<T...>
end
--
const function connectionConstructor<T...>(signal: Signal<T...>, fn: (T...) -> (), ...: any): Connection<T...>
	local self = (setmetatable({}, Connection) :: any) :: Connection<T...>
	self._signal = signal
	self._fn = fn
	self._once = false
	self._args = { ... }
	return self
end
--------------------------------------------------------------------------------
--Private Functions

const function connectToSignal<T...>(signal: Signal<T...>, connection: Connection<T...>)
	if signal._lastConnection then
		signal._lastConnection._next = connection
		connection._prev = signal._lastConnection
		signal._lastConnection = connection
	else
		signal._firstConnection = connection
		signal._lastConnection = connection
	end
end

--------------------------------------------------------------------------------
--Signal Methods

--Get Connections
function Signal.GetConnections<T...>(self: Signal<T...>): { Connection<T...> }
	local result = {}
	const function iterateConnections(currentConnection: Connection<T...>?)
		if currentConnection then
			table.insert(result, currentConnection)
			iterateConnections(currentConnection._next)
		end
	end
	iterateConnections(self._firstConnection)
	return result
end

--Get First Connection
function Signal.GetFirstConnection<T...>(self: Signal<T...>): Connection<T...>?
	return self._firstConnection
end

--Get Last Connection
function Signal.GetLastConnection<T...>(self: Signal<T...>): Connection<T...>?
	return self._lastConnection
end

--Fire
function Signal.Fire<T...>(self: Signal<T...>, ...: T...)
	const args = { ... }
	const function iterateConnections(currentConnection: Connection<T...>?)
		if currentConnection then
			local next = currentConnection._next
			TaskService.Defer(currentConnection._fn, table.unpack(args), table.unpack(currentConnection._args))
			if currentConnection._once then
				currentConnection:Disconnect()
			end
			iterateConnections(next)
		else
			TaskService.Defer(function() end)
		end
	end
	iterateConnections(self._firstConnection)
	return
end

--Connect
function Signal.Connect<T...>(self: Signal<T...>, fn: (T...) -> (), ...: any): Connection<T...>
	local newConnection = connectionConstructor(self, fn, ...)
	connectToSignal(self, newConnection)
	return newConnection
end

--Once
function Signal.Once<T...>(self: Signal<T...>, fn: (T...) -> (), ...: any): Connection<T...>
	local newConnection = connectionConstructor(self, fn, ...)
	connectToSignal(self, newConnection)
	newConnection._once = true
	return newConnection
end

--Wait
function Signal.Wait<T...>(self: Signal<T...>): T...
	const waitingCoroutine = coroutine.running()
	local newConnnection
	local returnArgs
	newConnnection = self:Connect(function(...:any)
		returnArgs = ...
		newConnnection:Disconnect()
		coroutine.resume(waitingCoroutine)
	end)
	return coroutine.yield(returnArgs)
end
--------------------------------------------------------------------------------
--Connection Methods

--Get Signal
function Connection.GetSignal<T...>(self: Connection<T...>): Signal<T...>
	return self._signal
end

--Get Next
function Connection.GetNext<T...>(self: Connection<T...>): Connection<T...>?
	return self._next
end

--Get Previous
function Connection.GetPrevious<T...>(self: Connection<T...>): Connection<T...>?
	return self._prev
end

--Get Function
function Connection.GetFunction<T...>(self: Connection<T...>): (T...) -> ()
	return self._fn
end

--Get Thread
function Connection.GetThread<T...>(self: Connection<T...>): thread?
	return self._thread
end

--Get Args
function Connection.GetArgs<T...>(self: Connection<T...>): ...any?
	return table.unpack(self._args)
end

--Disconnect
function Connection.Disconnect<T...>(self: Connection<T...>)
	if self._prev then
		self._prev._next = self._next
	else
		self._signal._firstConnection = self._next
	end
	if self._next then
		self._next._prev = self._prev
	else
		self._signal._lastConnection = self._prev
	end
	return
end

--Reconnect
function Connection.Reconnect<T...>(self: Connection<T...>)
	connectToSignal(self._signal, self)
	return
end
--------------------------------------------------------------------------------
return signalConstructor
--------------------------------------------------------------------------------
