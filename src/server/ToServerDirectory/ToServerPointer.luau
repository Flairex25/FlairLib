--This module has been marked as server only, thus moved to 'ServerScriptService/ToServerDirectory'
local RunService = game:GetService("RunService")

if not RunService:IsServer() then
    return {}
end

const directory = game:GetService("ServerScriptService").Server.ToServerDirectory

return directory:FindFirstChild(script:GetAttribute("PointerName"))