return (function(Roblox, Game)
  local Registry = require("@Dep/Registry")
  local Instance = Roblox.Instance
  
  local setGameProperty = function(PropertyName, Value)
    Roblox.implementProperty("DataModel", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end
  
  Roblox.implementProperty("DataModel", "Loaded", table.unpack({
    function()
      return {
        Wait = function()
          return
        end,
        Connect = function(_, Callback)
          Callback()
          return { Disconnect = function() end }
        end
      }
    end, 
    function() end
  }))

  local Vector3 = Roblox.Vector3
  local CFrame = Roblox.CFrame
  local Enum = Roblox.Enum

  local Camera = Instance.new("Camera")
  Camera.Name = "VirtualCamera"
  Camera.CameraType = Enum.CameraType.Scriptable
  Camera.CFrame = CFrame.new(0, 10, 0)
  Camera.Parent = Game.Workspace
  
  local ReplicationFocus = Instance.new("Part")
  ReplicationFocus.Name = "ReplicationFocus"
  ReplicationFocus.Anchored = true
  ReplicationFocus.CanCollide = false
  ReplicationFocus.Transparency = 1
  ReplicationFocus.Size = Vector3.new(1,1,1)
  ReplicationFocus.Position = Vector3.new(0, 5, 0)
  ReplicationFocus.Parent = Game.Workspace

  setGameProperty("Archivable", true)
  setGameProperty("ClassName", "DataModel")
  setGameProperty("Name", Registry.Game.Name)
  setGameProperty("CreatorId", Registry.Game.CreatorId)
  setGameProperty("CreatorType", nil)
  setGameProperty("Genre", Enum.Genre.All)
  setGameProperty("MatchmakingType", nil) -- Enum.MatchmakingType
  setGameProperty("GameId", Registry.Game.GameId)
  setGameProperty("PlaceId", Registry.Game.PlaceId)
  setGameProperty("UniverseId", Registry.Game.UniverseId)
  setGameProperty("PlaceVersion", Registry.Game.PlaceVersion)
  setGameProperty("PrivateServerId", Registry.Game.PrivateServerId)
  setGameProperty("PrivateServerOwnerId", Registry.Game.PrivateServerOwnerId)
  setGameProperty("JobId", Registry.Game.JobId)
  setGameProperty("CurrentCamera", Camera)
  setGameProperty("ReplicationFocus", ReplicationFocus)
end)