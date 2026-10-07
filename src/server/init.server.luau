--!strict

local shared = game:GetService("ReplicatedStorage").Shared
local Signal = require(shared.Classes.Signal)

local event = Signal()

coroutine.wrap(function()
	while true do
		print("Hi")
		event:Wait()
	end
end)()

event:Connect(function(msg: string)
	print(msg)
end)

task.wait(3)

event:Fire("Hello")
