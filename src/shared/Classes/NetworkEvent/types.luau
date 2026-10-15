--------------------------------------------------------------------------------
--Classes
--------------------------------------------------------------------------------
const Signal = require("../Signal")
--------------------------------------------------------------------------------
--Types
--------------------------------------------------------------------------------
export type NetworkEvent<S... = (), C... = (), S2... = (), C2... = ()> = {
	-----------------
	Type: "NetworkEvent",
	-----------------
	--Public
	Name: string,
	-----------------
	--Private
	_serverInvokeCallback: (player: Player, S2...) -> C2...,
	_clientInvokeCallback: (C2...) -> S2...,
	-----------------
	--Calls
	FireServer: (self: NetworkEvent<S..., C..., S2..., C2...>, S...) -> (),
	FireClient: (self: NetworkEvent<S..., C..., S2..., C2...>, player: Player, C...) -> (),
	InvokeServer: (self: NetworkEvent<S..., C..., S2..., C2...>, S2...) -> C2...,
	InvokeClient: (self: NetworkEvent<S..., C..., S2..., C2...>, player: Player, C2...) -> S2...,
	-----------------
	--Events & Callbacks
	OnServerEvent: Signal.Signal<(Player, S...)>,
	OnClientEvent: Signal.Signal<(C...)>,
	OnServerInvoke: (self: NetworkEvent<S..., C..., S2..., C2...>, callback: (player: Player, S2...) -> C2...) -> (),
	OnClientInvoke: (self: NetworkEvent<S..., C..., S2..., C2...>, callback: (C2...) -> S2...) -> (),
	-----------------
}
--------------------------------------------------------------------------------
return {}
--------------------------------------------------------------------------------
