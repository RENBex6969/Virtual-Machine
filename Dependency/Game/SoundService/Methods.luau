return (function(Roblox, Network)
  Roblox.implementMethod("SoundService", "GetListener", function(_, ...)
    return nil
  end)
  
  Roblox.implementMethod("SoundService", "OpenAttenuationCurveEditor", function(_, ...)
    return nil
  end)
  
  Roblox.implementMethod("SoundService", "PlayLocalSound", function(_, Sound)
    if Sound and typeof(Sound) == "Instance" and Sound:IsA("Sound") then
      Sound.Playing = true
      print("[VM - Sound] Playing ", Sound.Name, Sound.SoundId)
      return function()
        Sound.Playing = true
        print("[VM - Sound] Stopped ", Sound.Name, Sound.SoundId)
      end
    end
    return nil
  end)
  
  Roblox.implementMethod("SoundService", "SetListener", function(_, ...)
    return nil
  end)

  
end)