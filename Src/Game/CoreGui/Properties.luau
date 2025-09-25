return (function(Roblox, Game)
  local setProperty = function(PropertyName, Value)
    Roblox.implementProperty("CoreGui", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end

  Game:GetService("CoreGui").Version = 0
  setProperty("SelectionImageObject", function() end)
end)
