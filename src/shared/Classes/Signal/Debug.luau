-- --!strict
-- --!nonstrict
--!nocheck
--!optimize 2
--------------------------------------------------------------------------------
--Directories
--------------------------------------------------------------------------------
--const shared = game:GetService("ReplicatedStorage").Shared
--------------------------------------------------------------------------------
--Classes
--------------------------------------------------------------------------------
--const class = require(shared.Classes.class)
const LinkedList = require("./Lists/LinkedList")
--------------------------------------------------------------------------------
--Services
--------------------------------------------------------------------------------
--const Service = require(shared.Services.Service)
const TaskService = require("../Services/TaskService")
--------------------------------------------------------------------------------
--Types
--------------------------------------------------------------------------------
export type Signal<T...> = {
	-----------------
	Type: "Signal",
	-----------------
	--Private
	_list: LinkedList.LinkedList<Connection<T...>>,
	-----------------
	--Public
	Fire: (self:Signal<T...>,T...)->(),
	-----------------
	Connect: (self:Signal<T...>, fn: (T...)->(), ...any?)->Connection<T...>,
	Once: (self:Signal<T...>, fn: (T...)->(), ...any?)->Connection<T...>,
	Wait: (self:Signal<T...>)->(T...),
	-----------------
	DisconnectAll: (self:Signal<T...>)->(),
	-----------------
}
--
export type Connection<T...> = {
	-----------------
	Type: "Connection",
	-----------------
	--Private
	_signal: Signal<T...>,
	_args: {any},
	_function: (T...)->(),
	_thread: thread?,
	_once: boolean,
	_listNode: LinkedList.LinkedListNode<Connection<T...>>?,
	-----------------
	--Public
	Disconnect: (self: Connection<T...>)->(),
	Reconnect: (self: Connection<T...>)->(),
	GetPriority: (self: Connection<T...>)->number?,
	SetPriority: (self: Connection<T...>, priority: number)->(),
	Reassign: (self: Connection<T...>, fn: (T...)->(), ...any?)->(),
	Remove: (self: Connection<T...>)->(),
	-----------------
}
--------------------------------------------------------------------------------
--Class
--------------------------------------------------------------------------------
local Signal = {} :: Signal<any>
Signal.Type = "Signal"
Signal.__index = Signal
--
local Connection = {} :: Connection<any>
Connection.Type = "Connection"
Connection.__index = Connection
--------------------------------------------------------------------------------
--Constructor
--------------------------------------------------------------------------------
const function signalConstructor<T...>(): Signal<T...>
	local self = (setmetatable({}, Signal) :: any) :: Signal<T...>
	self._list = LinkedList()
	return self
end
--
const function connectionConstructor<T...>(signal: Signal<T...>, fn: (T...)->(), ...:any?): Connection<T...>
	local self = (setmetatable({}, Connection) :: any) :: Connection<T...>
	self._args = {...}
	self._signal = signal
	self._function = fn
	self._once = false
	self._listNode = signal._list:InsertBack(self)
	return self
end
--------------------------------------------------------------------------------
--Private Functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--Signal Methods
--------------------------------------------------------------------------------
--Fire
function Signal.Fire<T...>(self: Signal<T...>, ...:T...)
	const args = ...
	self._list:Iterate(function(_i:number, connection: Connection<T...>)
		connection._thread = TaskService.Defer(connection._function, args, table.unpack(connection._args))
		if connection._once then
			connection:Disconnect()
		end
	end)
end
--Connect
function Signal.Connect<T...>(self: Signal<T...>, fn: (T...)->(), ...:any?): Connection<T...>
	return connectionConstructor(self, fn, ...)
end
--Once
function Signal.Once<T...>(self: Signal<T...>, fn: (T...)->(), ...:any?): Connection<T...>
	local connection = connectionConstructor(self, fn, ...)
	connection._once = true
	return connection
end
--Wait
function Signal.Wait<T...>(self: Signal<T...>): T...
	const waitingCoroutine = coroutine.running()
	local connection
	connection = connectionConstructor(self, function(...:T...)
		connection:Disconnect()
		coroutine.resume(waitingCoroutine, ...)
	end)
	return coroutine.yield()
end
--------------------------------------------------------------------------------
--Connection Methods
--------------------------------------------------------------------------------
--Disconnect
function Connection.Disconnect<T...>(self: Connection<T...>)
	if self._listNode then
		self._listNode:Remove()
		self._listNode = nil
	else
		warn("Cannot Disconnect! Connection is already disconnected.")
	end
end
--Reconnect
function Connection.Reconnect<T...>(self: Connection<T...>)
	if not self._listNode then
		self._listNode = self._listNode:GetList():InsertBack(self)
	else
		warn("Cannot Reconnect! Connection is already connected.")
	end
end
--Get Priority
function Connection.GetPriority<T...>(self: Connection<T...>): number?
	return self._listNode:GetIndex()
end
--Set Priority
function Connection.SetPriority<T...>(self: Connection<T...>, priority: number)
	if self._listNode then
		priority = math.clamp(priority, 1, self._signal._list:GetSize())
		self._listNode:Remove()
		self._listNode:GetList():Insert(priority, self)
		self._listNode = self._signal._list:Get(priority)
	else
		warn("Cannot set priority of disconnected Connection!")
	end
end
--Reassign
function Connection.Reassign<T...>(self: Connection<T...>, fn: (T...)->(), ...:any?)
	self._function = fn
	local args = {...}
	if #args > 0 then
		self._args = args
	end
end
--Remove
function Connection.Remove<T...>(self: Connection<T...>)
	if self._listNode then
		self._listNode:Remove()
		self._listNode._list = nil
		self._listNode._value = nil
		self._listNode = nil
	end
	self = nil
end
--------------------------------------------------------------------------------
return signalConstructor
--------------------------------------------------------------------------------
