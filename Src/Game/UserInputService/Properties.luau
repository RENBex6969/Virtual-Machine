return (function(Roblox, Game)
  local setProperty = function(PropertyName, Value)
    pcall(function()
      Game:GetService("UserInputService")[PropertyName]= Value
    end)
    Roblox.implementProperty("UserInputService", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the game")
    end)
  end

  setProperty("AccelerometerEnabled", false)
  setProperty("GamepadEnabled", false)
  setProperty("GyroscopeEnabled", false)
  setProperty("MouseBehaviour", false) -- Enum.MouseBehaviour
  setProperty("MouseDeltaSensitivity", 0)
  setProperty("MouseEnabled", true)
  setProperty("MouseIcon", 0)
  setProperty("MouseIconEnabled", false)
  setProperty("KeyboardEnabled", true)
  setProperty("OnScreenKeyboardPosition", Roblox.Vector2.new(0, 0))
  setProperty("OnScreenKeyboardSize", Roblox.Vector2.new(5, 5))
  setProperty("OnScreenKeyboardVisible", false)
  setProperty("PreferredInput", false) -- Enum.PrefferedInput.Gamepad
  setProperty("TouchEnabled", false)
  setProperty("VREnabled", true)
end)
