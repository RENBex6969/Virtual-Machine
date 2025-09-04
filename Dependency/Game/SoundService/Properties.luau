return (function(Roblox)
  local setProperty = function(PropertyName, Value)
    Roblox.implementProperty("SoundService", PropertyName, function()
      return Value
    end, function() 
      error("Cannot modify the SoundService")
    end)
  end
  
  setProperty("AmbientReverb", nil) -- Enum.ReverbType
  setProperty("CharacterSoundsUseNewApi", nil) -- Enum.RolloutState
  setProperty("DistanceFactor", 1)
  setProperty("DopplerScale", 1)
  setProperty("RespectFilteringEnabled", true)
  setProperty("RolloffScale", 1)
  setProperty("VolumetricAudio", nil) -- Enum.VolumetricAudio
end)