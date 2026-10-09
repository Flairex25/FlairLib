--!strict

local shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(shared.Classes.Signal)

local event = Signal()

local newThread = coroutine.create(function()
	print("Yielding...")
	local timeBeforeYield = os.time()
	local msg = event:Wait()
	print(`Message "{msg}" received after {os.time() - timeBeforeYield}s!`)
end)

coroutine.resume(newThread)

task.wait(5)

event:Fire("Hello from the Antontio and Rrrrrashaun squad!")
