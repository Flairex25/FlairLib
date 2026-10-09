-- --!strict
-- --!nonstrict
--!nocheck
--------------------------------------------------------------------------------
--Directories
--------------------------------------------------------------------------------
--const shared = game:GetService("ReplicatedStorage").Shared
--------------------------------------------------------------------------------
--Classes
--------------------------------------------------------------------------------
--const class = require(shared.Classes.class)
const Lists = require("../Lists")
--------------------------------------------------------------------------------
--Services
--------------------------------------------------------------------------------
--const Service = require(shared.Services.Service)
--------------------------------------------------------------------------------
--Types
--------------------------------------------------------------------------------
export type LinkedList<T> = {
	-----------------
	Type: "LinkedList",
	-----------------
	--Private
	_size: number,
	_head: LinkedListNode<T>?,
	_tail: LinkedListNode<T>?,
	-----------------
	--Public
	-----------------
	GetSize: (self: LinkedList<T>) -> number,
	IsEmpty: (self: LinkedList<T>) -> boolean,
	Get: (self: LinkedList<T>, index: number) -> T?,
	GetFront: (self: LinkedList<T>) -> T?,
	GetBack: (self: LinkedList<T>) -> T?,
	Iterate: (self: LinkedList<T>, callback: (i: number, v: T) -> (), from: number?, to: number?) -> (),
	GetNode: (self: LinkedList<T>, index: number) -> LinkedListNode<T>?,
	GetHead: (self: LinkedList<T>) -> LinkedListNode<T>?,
	GetTail: (self: LinkedList<T>) -> LinkedListNode<T>?,
	IterateNodes: (
		self: LinkedList<T>,
		callback: (i: number, v: LinkedListNode<T>) -> (),
		from: number?,
		to: number?
	) -> (),
	-----------------
	Insert: (self: LinkedList<T>, value: T) -> () & (self: LinkedList<T>, index: number, value: T) -> (),
	InsertFront: (self: LinkedList<T>, value: T) -> LinkedListNode<T>,
	InsertBack: (self: LinkedList<T>, value: T) -> LinkedListNode<T>,
	-----------------
	Remove: (self: LinkedList<T>, index: number) -> T?,
	-----------------
	Clear: (self: LinkedList<T>) -> (),
	-----------------
}
--
export type LinkedListNode<T> = {
	-----------------
	Type: "LinkedNode",
	-----------------
	--Private
	_value: T,
	_list: LinkedList<T>,
	_prev: LinkedListNode<T>?,
	_next: LinkedListNode<T>?,
	-----------------
	--Public
	GetList: (self: LinkedListNode<T>) -> LinkedList<T>,
	GetPrevious: (self: LinkedListNode<T>) -> LinkedListNode<T>?,
	GetNext: (self: LinkedListNode<T>) -> LinkedListNode<T>?,
	GetIndex: (self: LinkedListNode<T>) -> number?,
	-----------------
	InsertPrevious: (self: LinkedListNode<T>, value: T) -> LinkedListNode<T>,
	InsertNext: (self: LinkedListNode<T>, value: T) -> LinkedListNode<T>,
	-----------------
	Remove: (self: LinkedListNode<T>) -> (),
	-----------------
}
--------------------------------------------------------------------------------
--Object
--------------------------------------------------------------------------------
local LinkedList = {} :: LinkedList<any>
LinkedList.Type = "LinkedList"
LinkedList.__index = LinkedList
--
local Node = {} :: LinkedListNode<any>
Node.Type = "LinkedListNode"
Node.__index = Node
--------------------------------------------------------------------------------
--Constructors
--------------------------------------------------------------------------------
const function linkedListConstructor<T>(): LinkedList<T>
	local self = (setmetatable({}, LinkedList) :: any) :: LinkedList<T>
	self._size = 0
	return self
end
--
const function nodeConstructor<T>(list: LinkedList<T>, value: T): LinkedListNode<T>
	local self = (setmetatable({}, Node) :: any) :: LinkedListNode<T>
	self._list = list
	self._value = value
	return self
end
--------------------------------------------------------------------------------
--Private Functions
--------------------------------------------------------------------------------
--Iterate
const function iterateNodes<T>(list: LinkedList<T>, callback: (i: number, v: LinkedListNode<T>) -> (), to: number)
	const function iter(currentIndex: number, currentNode: LinkedListNode<T>?)
		if currentNode then
			callback(currentIndex, currentNode)
			if currentIndex < to then
				iter(currentIndex + 1, currentNode._next)
			end
		end
	end
	iter(1, list._head)
end
const function iterateNodesBack<T>(list: LinkedList<T>, callback: (i: number, v: LinkedListNode<T>) -> (), to: number)
	const function iter(currentIndex: number, currentNode: LinkedListNode<T>?)
		if currentNode then
			callback(currentIndex, currentNode)
			if currentIndex > to then
				iter(currentIndex - 1, currentNode._prev)
			end
		end
	end
	iter(list._size, list._tail)
end
--------------------------------------------------------------------------------
--LinkedList Methods
--------------------------------------------------------------------------------
--Get Size
function LinkedList.GetSize<T>(self: LinkedList<T>): number
	return self._size
end
--IsEmpty
function LinkedList.IsEmpty<T>(self: LinkedList<T>): boolean
	return (self._size == 0)
end
--Get
function LinkedList.Get<T>(self: LinkedList<T>, index: number): T?
	if not Lists.CheckIndex((self :: any) :: Lists.List<T>, index) then
		return
	end
	local value
	iterateNodes(self, function(i: number, v: LinkedListNode<T>)
		if i == index then
			value = v._value
		end
	end, index)
	return value
end
--Get Front
function LinkedList.GetFront<T>(self: LinkedList<T>): T?
	if self._head then
		return self._head._value
	end
	return nil
end
--Get Back
function LinkedList.GetBack<T>(self: LinkedList<T>): T?
	if self._tail then
		return self._tail._value
	end
	return nil
end
--Iterate
function LinkedList.Iterate<T>(self: LinkedList<T>, callback: (i: number, v: T) -> (), from: number?, to: number?)
	from = from or 1
	to = to or self._size
	if
		not Lists.CheckIndex((self :: any) :: Lists.List<T>, from :: number)
		or not Lists.CheckIndex((self :: any) :: Lists.List<T>, to :: number)
	then
		return
	end
	if to :: number - from :: number >= 0 then
		iterateNodes(self, function(i: number, v: LinkedListNode<T>)
			if i >= from then
				callback(i, v._value)
			end
		end, to :: number)
	else
		iterateNodesBack(self, function(i: number, v: LinkedListNode<T>)
			if i <= from then
				callback(i, v._value)
			end
		end, to :: number)
	end
end
--Get Node
function LinkedList.GetNode<T>(self: LinkedList<T>, index: number): LinkedListNode<T>?
	if not Lists.CheckIndex((self :: any) :: Lists.List<T>, index) then
		return
	end
	local node
	iterateNodes(self, function(i: number, v: LinkedListNode<T>)
		if i == index then
			node = v
		end
	end, index)
	return node
end
--Get Head
function LinkedList.GetHead<T>(self: LinkedList<T>): LinkedListNode<T>?
	return self._head
end
--Get Tail
function LinkedList.GetTail<T>(self: LinkedList<T>): LinkedListNode<T>?
	return self._tail
end
--IterateNodes
function LinkedList.IterateNodes<T>(
	self: LinkedList<T>,
	callback: (i: number, v: LinkedListNode<T>) -> (),
	from: number?,
	to: number?
)
	from = from or 1
	to = to or self._size
	if
		not Lists.CheckIndex((self :: any) :: Lists.List<T>, from :: number)
		or not Lists.CheckIndex((self :: any) :: Lists.List<T>, to :: number)
	then
		return
	end
	if to :: number - from :: number >= 0 then
		iterateNodes(self, function(i: number, v: LinkedListNode<T>)
			if i >= from then
				callback(i, v)
			end
		end, to :: number)
	else
		iterateNodesBack(self, function(i: number, v: LinkedListNode<T>)
			if i <= from then
				callback(i, v)
			end
		end, to :: number)
	end
end
--Insert
function LinkedList.Insert<T>(self: LinkedList<T>, index: number | T, value: T?): LinkedListNode<T>?
	if not value or self._size == 0 then
		return self:InsertBack(index :: T)
	else
		if not Lists.CheckIndex((self :: any) :: Lists.List<T>, index :: number) then
			return
		end
		local node = self:GetNode(index :: number) :: LinkedListNode<T>
		node:InsertPrevious(value)
		return node
	end
end
--Insert Front
function LinkedList.InsertFront<T>(self: LinkedList<T>, value: T): LinkedListNode<T>
	if self._head then
		return self._head:InsertPrevious(value)
	else
		local newNode = nodeConstructor(self, value)
		self._head = newNode
		self._tail = newNode
		self._size += 1
		return newNode
	end
end
--Insert Back
function LinkedList.InsertBack<T>(self: LinkedList<T>, value: T): LinkedListNode<T>
	if self._tail then
		return self._tail:InsertNext(value)
	else
		local newNode = nodeConstructor(self, value)
		self._head = newNode
		self._tail = newNode
		self._size += 1
		return newNode
	end
end
--Remove
function LinkedList.Remove<T>(self: LinkedList<T>, index: number): T?
	if not Lists.CheckIndex((self :: any) :: Lists.List<T>, index) then
		return
	end
	local node = self:GetNode(index) :: LinkedListNode<T>
	local value = node._value
	node:Remove()
	return value
end
--Clear
function LinkedList.Clear<T>(self: LinkedList<T>)
	iterateNodes(self, function(_index: number, node: LinkedListNode<T>)
		node:Remove()
	end, self._size)
	self._size = 0
end
--------------------------------------------------------------------------------
--Node Methods
--------------------------------------------------------------------------------
--Get List
function Node.GetList<T>(self: LinkedListNode<T>): LinkedList<T>
	return self._list
end
--Get Previous
function Node.GetPrevious<T>(self: LinkedListNode<T>): LinkedListNode<T>?
	return self._prev
end
--Get Next
function Node.GetNext<T>(self: LinkedListNode<T>): LinkedListNode<T>?
	return self._next
end
--Get Index
function Node.GetIndex<T>(self: LinkedListNode<T>): number?
	local result
	self:GetList():IterateNodes(function(i: number, v: LinkedListNode<T>)
		if v == self then
			result = i
		end
	end)
	return result
end
--Insert Previous
function Node.InsertPrevious<T>(self: LinkedListNode<T>, value: T): LinkedListNode<T>
	local newNode = nodeConstructor(self._list, value)
	newNode._next = self
	if self._prev then
		self._prev._next = newNode
		newNode._prev = self._prev
		self._prev = newNode
	else
		self._prev = newNode
		self._list._head = newNode
	end
	self._list._size += 1
	return newNode
end
--Insert Next
function Node.InsertNext<T>(self: LinkedListNode<T>, value: T): LinkedListNode<T>
	local newNode = nodeConstructor(self._list, value)
	newNode._prev = self
	if self._next then
		self._next._prev = newNode
		newNode._next = self._next
		self._next = newNode
	else
		self._next = newNode
		self._list._tail = newNode
	end
	self._list._size += 1
	return newNode
end
--Remove
function Node.Remove<T>(self: LinkedListNode<T>)
	if self._prev then
		self._prev._next = self._next
	else
		self._list._head = self._next
	end
	if self._next then
		self._next._prev = self._prev
	else
		self._list._tail = self._prev
	end
	self._list._size -= 1
	self._next = nil
	self._prev = nil
end
--------------------------------------------------------------------------------
return linkedListConstructor
--------------------------------------------------------------------------------
