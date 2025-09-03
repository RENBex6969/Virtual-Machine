return (function(Roblox)
  local setProperty = function(PropertyName, Value)
    Roblox.implementProperty("Players", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end

  
end)
