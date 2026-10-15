----!strict

print("Comparing apples to oranges!")
local apples = 4
local oranges = 2
print(`I have a total of {apples + oranges} apples and oranges.`)
print("I found 2 more apples!")
apples += 2
print(`I have a total of {apples + oranges} apples and oranges.`)
-------------------------------------------------------------------------------------------------------------------------------
const shared = game:GetService("ReplicatedStorage").Shared
const server = script
const toServerDirectory = server.ToServerDirectory
const toServerPointer = toServerDirectory.ToServerPointer
-------------------------------------------------------------------------------------------------------------------------------
--Classes
--const Signal = require(shared.Classes.Signal)
-------------------------------------------------------------------------------------------------------------------------------
--Services
const ModuleService = require(shared.Services.ModuleService)
-------------------------------------------------------------------------------------------------------------------------------
const serverModuleBlacklist = {
	server.Packages,
	toServerDirectory,
} :: {Folder}
-------------------------------------------------------------------------------------------------------------------------------
local moduleList = {} :: { ModuleService.ServerModule }
local startList = {} :: { ModuleService.ServerModule }
local sharedModuleList = {} :: { ModuleService.SharedModule }
-------------------------------------------------------------------------------------------------------------------------------
local currentModuleID = 0
local serverPointerID = 0
-------------------------------------------------------------------------------------------------------------------------------
--Hide Server Modules
const function SharedModuleLoop(moduleScript: ModuleScript)
	-------------------------------------------------------
	local module: ModuleService.SharedModule
	--
	local success, errorMsg = pcall(function()
		module = require(moduleScript) :: ModuleService.SharedModule
	end)
	--
	if not success then
		warn(`Error loading shared Class or Service '{moduleScript.Name}': {errorMsg}`)
	end
	--
	if typeof(module) ~= typeof({}) then
		return
	end
	if module.Params then
		table.insert(sharedModuleList, module)
		--Move to Server
		if module.Params.ToServer then
			const parent = moduleScript.Parent
			const pointerName = `{serverPointerID}-{moduleScript.Name}`
			const moduleName = moduleScript.Name
			const newPointer = toServerPointer:Clone() :: ModuleScript
			newPointer.Name = moduleName
			newPointer:SetAttribute("PointerName",pointerName)
			newPointer:SetAttribute("ServerIgnore",true)
			newPointer.Parent = parent
			moduleScript.Name = pointerName
			moduleScript.Parent = toServerDirectory
			serverPointerID += 1
		end
	else
		return
	end
	-------------------------------------------------------
end
--
for _, module in ipairs(shared:GetDescendants()) do
	if module:IsA("ModuleScript") and not module:GetAttribute("ServerIgnore") then
		SharedModuleLoop(module)
	end
end
-------------------------------------------------------------------------------------------------------------------------------
--Process Return Codes
const function ProcessReturnCode(module: ModuleService.ServerModule, returnCode: number | nil, functionName: string)
	--
	if not module.params.debug and (returnCode ~= -2) then
		return
	end
	--
	if returnCode == nil or returnCode == 0 then
		--Standard Debug Message
		if not module.params.verboseDebug then
			print(
				module.params.uniqueID,
				" : Successfully completed",
				module.params.debugPrefix :: string .. "." .. functionName .. "() with exit code 0"
			)
		else
			--Verbose Debug Message
			print(
				module.params.uniqueID,
				": Successfully completed",
				module.params.debugPrefix :: string .. "." .. functionName .. "() with exit code 0",
				"(" .. module.params.directory :: string .. ") At:",
				os.time()
			)
		end
	elseif returnCode == -1 then
		return
	elseif returnCode == -2 then
		--Standard Debug Message
		if not module.params.verboseDebug then
			print(
				module.params.uniqueID,
				" : Successfully completed",
				module.params.debugPrefix :: string .. "." .. functionName .. "() with exit code -2"
			)
		else
			--Verbose Debug Message
			print(
				module.params.uniqueID,
				": Successfully completed",
				module.params.debugPrefix :: string .. "." .. functionName .. "() with exit code -2",
				"(" .. module.params.directory :: string .. ") At:",
				os.time()
			)
		end
	else
		--Standard Debug Message
		if not module.params.verboseDebug then
			warn(
				module.params.uniqueID,
				": Completed",
				module.params.debugPrefix :: string .. "." .. functionName .. "() with exit code",
				returnCode
			)
		else
			--Verbose Debug Message
			warn(
				module.params.uniqueID,
				": Completed",
				module.params.debugPrefix :: string .. "." .. functionName .. "() with exit code",
				returnCode,
				"(",
				module.params.directory,
				") At:",
				os.time()
			)
		end
	end
	--
end
-------------------------------------------------------------------------------------------------------------------------------
--Process Module Function PCall
const function ProcessModuleFunctionPCall(
	module: ModuleService.ServerModule,
	functionName: string,
	success: boolean,
	errorMsg: string,
	functionNameOverride: string?
)
	if not module.params.debug then
		return
	end
	if success then
		table.insert(moduleList, module)
		if not module.params.verboseDebug then
			--Standard Debug Message
			print((functionNameOverride and functionNameOverride or functionName), module.params.debugPrefix)
		else
			--Verbose Debug Message
			print(
				(functionNameOverride and functionNameOverride or functionName),
				module.params.debugPrefix,
				"(",
				module.params.directory,
				") | Unique ID",
				module.params.uniqueID,
				"| At:",
				os.time()
			)
		end
	else
		warn("Failed to", functionName, module.params.directory, "|", errorMsg)
		return
	end
end
-------------------------------------------------------------------------------------------------------------------------------
const function CheckServerBlacklist(moduleScript: ModuleScript)
	-----------------------------------------------------------
	local highestFolder
	-----------------------------------------------------------
	const function ancestorLoop(currentInstance: Instance)
		const folder = currentInstance:FindFirstAncestorOfClass("Folder")
		if folder then
			ancestorLoop(folder)
		else
			highestFolder = currentInstance
		end
	end
	-----------------------------------------------------------
	ancestorLoop(moduleScript)
	return (table.find(serverModuleBlacklist, highestFolder) ~= nil)
end
-------------------------------------------------------------------------------------------------------------------------------
const function AddModulesToList(moduleScript: ModuleScript)
	------------------------------------------------------
	local module = {} :: ModuleService.ServerModule
	--
	local success, errorMsg = pcall(function()
		--
		module = require(moduleScript)
		--
		if module.params == nil then
			module.params = {} :: ModuleService.ModuleParams
		end
		if module.params.enabled == nil then
			module.params.enabled = true
		end
		if module.params.debug == nil then
			module.params.debug = false
		end
		if module.params.verboseDebug == nil then
			module.params.verboseDebug = false
		end
		module.params.name = moduleScript.Name
		module.params.directory = moduleScript:GetFullName()
		module.params.uniqueID = currentModuleID
		currentModuleID += 1
		if module.params.debugPrefix == nil then
			module.params.debugPrefix = module.params.name
		end
		if module.params.isClass == nil then
			module.params.isClass = false
		end
		if not module.params.isClass then
			module.params.className = nil
		end
		if not module.params.waitForPlayerLoaded then
			module.params.waitForPlayerLoaded = false
		end
		if not module.params.waitForCharacterLoaded then
			module.params.waitForCharacterLoaded = false
		end
	end)
	--
	ProcessModuleFunctionPCall(module, "require", success, errorMsg, "Required")
	---------------------------------------------------
	if module.params.isClass or module.params.isSubmodule then
		return
	end
	---------------------------------------------------
	--Add methods
	if module.Init and module.params.enabled then
		local initSuccess, initErrorMsg = pcall(function()
			const returnCode = module.Init()
			ProcessReturnCode(module, returnCode, "Init")
		end)
		--
		ProcessModuleFunctionPCall(module, "initialize", initSuccess, initErrorMsg, "Initialized")
	end
	if module.Start then
		table.insert(startList, module)
	end
	---------------------------------------------------
end
-------------------------------------------------------------------------------------------------------------------------------
--Add Modules
for _, moduleScript in ipairs(server:GetDescendants()) do
	if moduleScript:IsA("ModuleScript") then
		if CheckServerBlacklist(moduleScript) then
			continue
		end
		coroutine.wrap(function()
			AddModulesToList(moduleScript)
		end)()
	end
end
-------------------------------------------------------------------------------------------------------------------------------
--Start
const function StartModule(module: ModuleService.ServerModule)
	--
	if not module.params.enabled then
		return
	end
	--
	local success, errorMsg = pcall(function()
		const returnCode = module.Start()
		ProcessReturnCode(module, returnCode, "Start")
	end)
	--
	ProcessModuleFunctionPCall(module, "start", success, errorMsg, "Started")
end
--
for _, module in ipairs(startList) do
	coroutine.wrap(function()
		StartModule(module)
	end)()
end
-------------------------------------------------------------------------------------------------------------------------------