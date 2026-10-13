--!strict

local shared = game:GetService("ReplicatedStorage").Shared

--SERVER
local NetworkEvent = require(shared.Classes.NetworkEvent)

local incrementUserCoins = NetworkEvent("IncrementUserCoins")

incrementUserCoins:OnServerInvoke(function(player: Player, coins: number)
	--Do some check if player has right amount of coins
	print(`Coins: {coins}`)
	print(`Added 1 to {player.DisplayName}'s coins.`)
	return coins + 1
end)
