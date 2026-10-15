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
const RunService = game:GetService("RunService")
const isServer = RunService:IsServer()
const isClient = RunService:IsClient()
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
	if isServer then
		server.AddToEventList(self)
		server.OnServerInvoke(self, function()
			warn(`{NetworkEvent.Type} {eventName} does not have ServerInvoke callback. Please assign one.`)
		end)
	end
	if isClient then
		client.AddToEventList(self)
		client.OnClientInvoke(self, function()
			warn(`{NetworkEvent.Type} {eventName} does not have ClientInvoke callback. Please assign one.`)
		end)
	end
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
	if isClient then
		client.FireServer(self, ...)
	else
		warn("Cannot call FireServer(...) from server! Please use FireClient(player, ...) instead!")
	end
end
--FireClient
function NetworkEvent.FireClient(self, player, ...) --Server
	if isServer then
		server.FireClient(self, player, ...)
	else
		warn("Cannot call FireClient(player, ...) from client! Please use FireServer(...) instead!")
	end
end
--InvokeServer
function NetworkEvent.InvokeServer(self, ...) --Client
	if isClient then
		return client.InvokeServer(self, ...)
	else
		warn("Cannot call InvokeServer(...) from server! Please use InvokeClient(player, ...) instead!")
		return
	end
end
--InvokeClient
function NetworkEvent.InvokeClient(self, player, ...) --Server
	if isServer then
		return server.InvokeClient(self, player, ...)
	else
		warn("Cannot call InvokeClient(player, ...) from client! Please use InvokeServer(...) instead!")
		return
	end
end
--OnServerInvoke
function NetworkEvent.OnServerInvoke(self, callback) --Server
	if isServer then
		server.OnServerInvoke(self, callback)
	else
		warn("Cannot set OnServerInvoke from server! Please use OnClientInvoke instead!")
	end
end
--OnClientInvoke
function NetworkEvent.OnClientInvoke(self, callback) --Client
	if isClient then
		client.OnClientInvoke(self, callback)
	else
		warn("Cannot set OnClientInvoke from server! Please use OnServerInvoke instead!")
	end
end
--------------------------------------------------------------------------------
return networkEventConstructor
--------------------------------------------------------------------------------
