return (function(Roblox, Registry)
  local setProperty = function(PropertyName, Value)
    Roblox.implementProperty("CorePackages", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end
  

  setProperty("Name", "CorePackages")
end)