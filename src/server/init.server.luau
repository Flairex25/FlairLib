--!strict

local shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(shared.Classes.Signal)

local event = Signal()

event:Fire("Hi")
