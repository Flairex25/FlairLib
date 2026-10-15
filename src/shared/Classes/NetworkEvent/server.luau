--!nocheck
--------------------------------------------------------------------------------
--Services
--------------------------------------------------------------------------------
local RunService = game:GetService("RunService")
--------------------------------------------------------------------------------
--Types
--------------------------------------------------------------------------------
local types = require("./types")
--
type NetworkEvent<S... = (), C... = ()> = types.NetworkEvent<S..., C...>
--------------------------------------------------------------------------------
--Runtime
--------------------------------------------------------------------------------
const function checkRunContext(): boolean
	return RunService:IsServer()
end
--------------------------------------------------------------------------------
--Initialize
--------------------------------------------------------------------------------
local NetworkEventServer = {}
NetworkEventServer.Params = {
	['ToServer'] = true,
}
--
local eventList = {} :: { NetworkEvent }
--
local remoteEvent = script.Parent:FindFirstChild("RemoteEvent") :: RemoteEvent
local remoteFunction = script.Parent:FindFirstChild("RemoteFunction") :: RemoteFunction
--
if not remoteEvent then
	remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = "RemoteEvent"
	remoteEvent.Parent = script.Parent
end
if not remoteFunction then
	remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = "RemoteFunction"
	remoteFunction.Parent = script.Parent
end
--------------------------------------------------------------------------------
--Functions
--------------------------------------------------------------------------------
--AddToEventList
function NetworkEventServer.AddToEventList<S..., C...>(event: NetworkEvent<S..., C...>)
	eventList[event.Name] = event
end
--FireClient
function NetworkEventServer.FireClient<S..., C...>(event: NetworkEvent<S..., C...>, player: Player, ...: any)
	remoteEvent:FireClient(player, event.Name, ...)
end
--InvokeClient
function NetworkEventServer.InvokeClient<S..., C...>(_event: NetworkEvent<S..., C...>, player: Player, ...: any)
	return remoteFunction:InvokeClient(player, ...)
end
--OnServerInvoke
function NetworkEventServer.OnServerInvoke<S..., C...>(event: NetworkEvent<S..., C...>, callback: (player: Player, S...) -> C...)
	event._serverInvokeCallback = callback
	remoteFunction.OnServerInvoke = event._serverInvokeCallback
end
--OnServerEvent
const function onServerEvent(player: Player, eventName: string, ...)
	local event = eventList[eventName] :: NetworkEvent<(any), (any)>
	if not event then
		return
	end
	event.OnServerEvent:Fire(player, ...)
end
--
if checkRunContext() then
	remoteEvent.OnServerEvent:Connect(onServerEvent)
end
--------------------------------------------------------------------------------
return NetworkEventServer
--------------------------------------------------------------------------------
