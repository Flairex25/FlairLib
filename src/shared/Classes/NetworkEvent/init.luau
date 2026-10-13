-- --!strict
--!nonstrict
-- --!nocheck
--------------------------------------------------------------------------------
--Directories
--------------------------------------------------------------------------------
--const shared = game:GetService("ReplicatedStorage").Shared
--------------------------------------------------------------------------------
--Classes
--------------------------------------------------------------------------------
--const class = require(shared.Classes.class)
const Signal = require("./Signal")
--------------------------------------------------------------------------------
--Services
--------------------------------------------------------------------------------
--const Service = require(shared.Services.Service)
--------------------------------------------------------------------------------
--Types
--------------------------------------------------------------------------------
local types = require("@self/types")
--
export type NetworkEvent<S... = (), C... = (), S2... = (), C2... = ()> = types.NetworkEvent<S..., C..., S2..., C2...>
--------------------------------------------------------------------------------
--Class
--------------------------------------------------------------------------------
local server = require("@self/server")
local client = require("@self/client")
--------------------------------------------------------------------------------
--Object
--------------------------------------------------------------------------------
local NetworkEvent = {} :: NetworkEvent<any>
NetworkEvent.Type = "NetworkEvent"
NetworkEvent.__index = NetworkEvent
NetworkEvent.__newindex = function(self, key)
	warn(`Attempt to index [{key}] of {self.Type}.`)
end
--------------------------------------------------------------------------------
--Constructor
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
const function networkEventConstructor<S..., C..., S2..., C2...>(eventName: string): NetworkEvent<S..., C..., S2..., C2...>
	local self = {} :: NetworkEvent<S..., C..., S2..., C2...>
	self.Name = eventName
	self._serverInvokeCallback = function() end
	self._clientInvokeCallback = function() end
	self.OnServerEvent = Signal()
	self.OnClientEvent = Signal()
	self = (setmetatable(self, NetworkEvent) :: any) :: NetworkEvent<S..., C..., S2..., C2...>
	server.AddToEventList(self)
	client.AddToEventList(self)
	server.OnServerInvoke(self, function()
		warn(`{NetworkEvent.Type} {eventName} does not have ServerInvoke callback. Please assign one.`)
	end, true)
	client.OnClientInvoke(self, function()
		warn(`{NetworkEvent.Type} {eventName} does not have ClientInvoke callback. Please assign one.`)
	end, true)
	return self :: NetworkEvent<S..., C..., S2..., C2...>
end
--------------------------------------------------------------------------------
--Private Functions
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--Methods
--------------------------------------------------------------------------------
--FireServer
function NetworkEvent.FireServer(self, ...) --Client
	client.FireServer(self, ...)
end
--FireClient
function NetworkEvent.FireClient(self, player, ...) --Server
	server.FireClient(self, player, ...)
end
--InvokeServer
function NetworkEvent.InvokeServer(self, ...) --Client
	return client.InvokeServer(self, ...)
end
--InvokeClient
function NetworkEvent.InvokeClient(self, player, ...) --Server
	return server.InvokeClient(self, player, ...)
end
--OnServerInvoke
function NetworkEvent.OnServerInvoke(self, callback) --Server
	server.OnServerInvoke(self, callback)
end
--OnClientInvoke
function NetworkEvent.OnClientInvoke(self, callback) --Client
	client.OnClientInvoke(self, callback)
end
--------------------------------------------------------------------------------
return networkEventConstructor
--------------------------------------------------------------------------------
