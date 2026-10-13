--!strict

local shared = game:GetService("ReplicatedStorage").Shared

--CLIENT
local NetworkEvent = require(shared.Classes.NetworkEvent)

local incrementUserCoins = NetworkEvent("IncrementUserCoins")

local currentCoins = 10
local newCoins = incrementUserCoins:InvokeServer(currentCoins)

print(`Coins: {newCoins}`)
