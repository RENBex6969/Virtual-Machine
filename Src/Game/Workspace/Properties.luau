return (function(Roblox, Game)
  local setProperty = function(PropertyName, Value)
    pcall(function()
      Game.Workspace[PropertyName] = Value
    end)
    
    Roblox.implementProperty("Workspace", PropertyName, function()
      return Value
    end)
    
  end

  
end)
