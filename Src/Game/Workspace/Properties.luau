return (function(Roblox, Game)
  local setProperty = function(PropertyName, Value)
    pcall(function()
      Game:GetService("Workspace")[PropertyName] = Value
    end)
    Roblox.implementProperty("Workspace", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end

  local Camera = Roblox.Instance.new("Camera")
  Camera.ViewportSize = Roblox.Vector2.new(1920, 1080)
  
  setProperty("CurrentCamera", Camera)
end)
