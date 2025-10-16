--// Because local lookups are faster than global lookups
local require = require

local Network = require("@Src/ExploitLibrary/Network")
local Registry = require("@Dep/Registry")
local Utility = require("@Dep/Utility")
local Roblox = require("@lune/roblox")
local FileSystem = require("@lune/fs")

local Game = Roblox.Instance.new("DataModel")
Game.PlaceId = 0
Registry.Roblox = Roblox
Registry.ConnectionsMap = {}

--local GameFile = FileSystem.readFile("file.rbxl")
--local Game = Roblox.deserializePlace(GameFile)

local GameMethods = require("./Game/Game/Methods")(Roblox)
local GameProperties = require("./Game/Game/Properties")(Roblox, Game)

local HttpMethods = require("./Game/HttpService/Methods")(Roblox, Network)
local HttpProperties = require("./Game/HttpService/Properties")(Roblox)

local RunMethods = require("./Game/RunService/Methods")(Roblox)
local RunProperties = require("./Game/RunService/Properties")(Roblox, Registry, Utility)

--local UserInputMethods = require("./Game/UserInputService/Methods")(Roblox)
local UserInputProperties = require("./Game/UserInputService/Properties")(Roblox, Game)

local LightningProperties = require("./Game/LightningService/Properties")(Roblox)
local LightningMethods = require("./Game/LightningService/Methods")(Roblox)

local CorePackagesProperties = require("./Game/CorePackages/Properties")(Roblox)
--local CorePackagesMethod = require("./Game/CorePackages/Methods")(Roblox)

--local RbxAnalyticsProperties = require("./Game/RbxAnalyticsService/Properties")(Roblox)
local RbxAnalyticsMethods = require("./Game/RbxAnalyticsService/Methods")(Roblox)

local PlayersProperties = require("./Game/PlayersService/Properties")(Roblox, Game)
local PlayersMethods = require("./Game/PlayersService/Methods")(Roblox, Game)

local LocalPlayer = require("./Game/PlayersService/LocalPlayer/LocalPlayer")(Roblox, Game)
local LocalPlayerMethods = require("./Game/PlayersService/LocalPlayer/Methods")(Roblox, Game)
--local LocalPlayerProperties = require("./Game/PlayersService/LocalPlayer/Properties")(Roblox)
--local LocalPlayerEvents

--local DebrisProperties = require("./Game/DebrisService/Properties")(Roblox)
local DebrisMethods = require("./Game/DebrisService/Methods")(Roblox)


--local TeleportProperties = require("./Game/TeleportService/Properties")(Roblox)
local TeleportMethods = require("./Game/TeleportService/Methods")(Roblox)


--local GroupProperties = require("./Game/GroupService/Properties")(Roblox)
local GroupMethod = require("./Game/GroupService/Methods")(Roblox)


local SoundProperties = require("./Game/SoundService/Properties")(Roblox)
local SoundMethods = require("./Game/SoundService/Methods")(Roblox)

--local TextProperties = require("./Game/TextService/Properties")(Roblox)
local TextMethods = require("./Game/TextService/Methods")(Roblox)

local CoreGuiProperties = require("./Game/CoreGui/Properties")(Roblox, Game)
local CoreGuiMethods = require("./Game/CoreGui/Methods")(Roblox, Game)

local WorkspaceProperties = require("./Game/Workspace/Properties")(Roblox, Game)
local WorkspaceMethods = require("./Game/Workspace/Methods")(Roblox)


local Instance = Roblox.Instance

for i = 1, 50 do
  local localScript = Instance.new("LocalScript")
  localScript.Name = "MyLocalScript"
  localScript.Parent = Game:GetService("StarterPlayer")
  
  local moduleScript = Instance.new("ModuleScript")
  moduleScript.Name = "MyModuleScript"
  moduleScript.Parent = Game:GetService("ReplicatedStorage")
end

local CoreGui = Game:GetService("CoreGui")
local RobloxGui = CoreGui:FindFirstChild("RobloxGui") or Instance.new("Folder")
RobloxGui.Name = "RobloxGui"
RobloxGui.Parent = CoreGui

local Modules = RobloxGui:FindFirstChild("Modules") or Instance.new("Folder")
Modules.Name = "Modules"
Modules.Parent = RobloxGui

local Common = Modules:FindFirstChild("Common") or Instance.new("Folder")
Common.Name = "Common"
Common.Parent = Modules

local Constants = Instance.new("ModuleScript")
Constants.Name = "Constants"
Constants.Parent = Common

Constants.Source = [[
  return {
    "Virtualization"
  }
]]

Registry.Game = Game

return Game
