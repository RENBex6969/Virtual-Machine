return (function(Roblox)
  local setProperty = function(PropertyName, Value)
    Roblox.implementProperty("HttpService", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end

  setProperty("HttpEnabled", false)
  setProperty("HttpProxyEnabled", false)
end)
