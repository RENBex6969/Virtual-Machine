return (function(Roblox, LightingProperty)
  Roblox.implementMethod("Lighting", "GetMoonPhase", function()
    return 0.75
  end)
  Roblox.implementMethod("Lighting", "GetMoonDirection", function()
    return Roblox.Vector3.new(0, 0, 0)
  end)
  Roblox.implementMethod("Lighting", "GetSunDirection", function()
    return Roblox.Vector3.new(0, 0, 0)
  end)
  Roblox.implementMethod("Lighting", "GetMinutesAfterMidnight", function()
    local hours = math.floor(LightingProperty.ClockTime)
    local minutes = math.floor((LightingProperty.ClockTime % 1) * 60)
    return hours * 60 + minutes
  end)
  Roblox.implementMethod("Lighting", "SetMinutesAfterMidnight", function(minutes)
    minutes = math.clamp(minutes, 0, 1439)
    LightingProperty.ClockTime = minutes / 60
    LightingProperty.TimeOfDay = string.format("%02d:%02d:%02d",
      math.floor(Property.ClockTime),
      math.floor((Property.ClockTime % 1) * 60),
      math.floor((((Property.ClockTime % 1) * 60) % 1) * 60)
    )
    if Registry.LightingChanged then
      Registry.LightingChanged:Fire("ClockTime", Property.ClockTime)
    end
  end)
end)