--------------------------------------------------------------------------------
--Services
--------------------------------------------------------------------------------
local RunService = game:GetService("RunService")
--------------------------------------------------------------------------------
--Types
--------------------------------------------------------------------------------
local types = require("./types")
--
type NetworkEvent<S..., C...> = types.NetworkEvent<S..., C...>
--------------------------------------------------------------------------------
--Runtime
--------------------------------------------------------------------------------
const function checkRunContext(): boolean
	return RunService:IsClient()
end
--------------------------------------------------------------------------------
--Initialize
--------------------------------------------------------------------------------
local NetworkEventClient = {}
--
local eventList = {}
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
function NetworkEventClient.AddToEventList<S..., C...>(event: NetworkEvent<S..., C...>)
	eventList[event.Name] = event
end
--FireServer
function NetworkEventClient.FireServer<S..., C...>(event: NetworkEvent<S..., C...>, ...: any)
	if not checkRunContext() then
		warn("Cannot call FireServer(...) from server! Please use FireClient(player, ...) instead!")
		return
	end
	remoteEvent:FireServer(event.Name, ...)
end
--InvokeServer
function NetworkEventClient.InvokeServer<S..., C...>(_event: NetworkEvent<S..., C...>, ...: any)
	if not checkRunContext() then
		warn("Cannot call InvokeServer(...) from server! Please use InvokeClient(player, ...) instead!")
		return
	end
	return remoteFunction:InvokeServer(...)
end
--OnClientInvoke
function NetworkEventClient.OnClientInvoke<S..., C...>(event: NetworkEvent<S..., C...>, callback: (C...) -> S..., bypass: boolean?)
	if not checkRunContext() then
		if bypass then
			return
		end
		warn("Cannot set OnClientInvoke from server! Please use OnServerInvoke instead!")
		return
	end
	event._clientInvokeCallback = callback
	remoteFunction.OnClientInvoke = event._clientInvokeCallback
end
--OnClientEvent
const function onClientEvent(eventName: string, ...)
	local event = eventList[eventName] :: NetworkEvent<(any), (any)>
	if not event then
		return
	end
	event.OnClientEvent:Fire(...)
end
if checkRunContext() then
	remoteEvent.OnClientEvent:Connect(onClientEvent)
end
--------------------------------------------------------------------------------
return NetworkEventClient
--------------------------------------------------------------------------------
