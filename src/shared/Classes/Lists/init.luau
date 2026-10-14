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
export type List<T> = {
	-----------------
	Type: "List",
	-----------------
	--Private
	_size: number,
	-----------------
	--Public
	GetSize: (self: List<T>) -> number,
	IsEmpty: (self: List<T>) -> boolean,
	Get: (self: List<T>, index: number, range: number?) -> ...T?,
	Iterate: (self: List<T>, callback: (i: number, v: T) -> (), from: number?, to: number?) -> (),
	-----------------
	Indert: (self: List<T>, index: number, value: T) -> () & (self: List<T>, value: T) -> (),
	-----------------
	Remove: (self: List<T>, index: number) -> (),
	-----------------
	Clear: (self: List<T>) -> (),
	-----------------
}
--------------------------------------------------------------------------------
local Lists = {}
--------------------------------------------------------------------------------
function Lists.CheckIndex<T>(list: List<T>, index: number)
	if list._size == 0 then
		warn(`List is empty! Index {index} out of range.`)
		return false
	end
	if index < 1 or index > list._size then
		warn(`Index out of range! Expected number from 1-{list._size}, got {index}.`)
		return false
	end
	return true
end
--------------------------------------------------------------------------------
return Lists
--------------------------------------------------------------------------------
