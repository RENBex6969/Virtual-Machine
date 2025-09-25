return (function(Roblox)
  local setProperty = function(PropertyName, Value)
    Roblox.implementProperty("CoreGui", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end

  setProperty("Version", 0)
  setProperty("SelectionImageObject", false)
end)
