-- --!strict
--!nonstrict
-- --!nocheck
--------------------------------------------------------------------------------
--Directories
--const shared = game:GetService("ReplicatedStorage").Shared
--------------------------------------------------------------------------------
--Classes
--const class = require(shared.Classes.class)
--------------------------------------------------------------------------------
--Services
--const Service = require(shared.Services.Service)
--------------------------------------------------------------------------------
--Types
export type TaskService = {
	-----------------------
	Type: "TaskService",
	-----------------------
	Spawn: (fn: (...any) -> (), ...any) -> thread,
	Defer: (fn: (...any) -> (), ...any) -> thread,
	Delay: (duration: number, fn: (...any) -> (), ...any) -> thread,
	-----------------------
}
--------------------------------------------------------------------------------
local TaskService = {} :: TaskService
TaskService.Type = "TaskService"
--------------------------------------------------------------------------------
local Call, Thread
local threads = {} :: { thread }
--------------------------------------------------------------------------------
function TaskService.Spawn(fn: (...any) -> (), ...: any)
	return task.spawn(table.remove(threads) or task.spawn(Thread), fn, ...)
end
--
function TaskService.Defer(fn: (...any) -> (), ...: any)
	return task.spawn(table.remove(threads) or task.spawn(Thread), fn, ...)
end
--
function TaskService.Delay(duration: number, fn: (...any) -> (), ...: any)
	return task.delay(duration, table.remove(threads) or task.spawn(Thread), fn, ...)
end
--------------------------------------------------------------------------------
function Call(fn: (...any) -> (), ...)
	fn(...)
	table.insert(threads, coroutine.running())
end
--
function Thread()
	while true do
		Call(coroutine.yield())
	end
end
--------------------------------------------------------------------------------
return TaskService
--------------------------------------------------------------------------------
