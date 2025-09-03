return (function(Roblox, Registry)
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

  setGameProperty("Archivable", true)
  setGameProperty("ClassName", "DataModel")
  setGameProperty("Name", "Virtual Machine")
  setGameProperty("CreatorId", 0)
  setGameProperty("CreatorType", nil)
  setGameProperty("Genre", nil) -- Enum.Genre
  setGameProperty("MatchmakingType", nil) -- Enum.MatchmakingType
  setGameProperty("GameId", 0)
  setGameProperty("PlaceId", Registry.Game.PlaceId)
  setGameProperty("UniverseId", Registry.Game.UniverseId)
  setGameProperty("PlaceVersion", 1)
  setGameProperty("PrivateServerId", "VIRTUAL")
  setGameProperty("PrivateServerOwnerId", 0)
  setGameProperty("JobId", "00000000-0000-0000-0000-000000000000")
  setGameProperty("CurrentCamera", nil)
  setGameProperty("ReplicationFocus", nil)
end)