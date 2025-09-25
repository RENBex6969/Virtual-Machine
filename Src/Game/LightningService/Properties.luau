return (function(Roblox, Registry)
  local Registry = require("@Dep/Registry")
  
  local Task = require("@lune/task")
  local Lighting = {}
  local function makeEvent()
    local connections = {}
    local waiting = {}
    return {
      Connect = function(_, fn)
        table.insert(connections, fn)
        return {
          Disconnect = function()
            for i, f in ipairs(connections) do
              if f == fn then
                table.remove(connections, i)
                break
              end
            end
          end
        }
      end,
      Fire = function(_, ...)
        for i, thread in ipairs(waiting) do
          coroutine.resume(thread, ...)
        end
        table.clear(waiting)
        for _, fn in ipairs(connections) do
          fn(...)
        end
      end,
      Wait = function(_)
        local thread = coroutine.running()
        table.insert(waiting, thread)
        return coroutine.yield()
      end
    }
  end

  local Property = {
    Brightness = 2,
    Ambient = Roblox.Color3.fromRGB(255,255,255),
    OutdoorAmbient = Roblox.Color3.fromRGB(255,255,255),
    ClockTime = 12,
    TimeOfDay = "12:00:00",
    FogEnd = 1000,
    FogStart = 0,
    GlobalShadows = true,
    GeographicLatitude = 41.73,
    EnvironmentDiffuseScale = 1,
    EnvironmentSpecularScale = 1,
    ExposureCompensation = 0,
    ShadowSoftness = 0,
    ColorShift_Bottom = Roblox.Color3.fromRGB(0,0,0),
    ColorShift_Top = Roblox.Color3.fromRGB(0,0,0),
    PrioritizeLightingQuality = true,
    FogColor = Roblox.Color3.fromRGB(255,255,255),
    ExtendLightRangeTo120 = nil, -- Enum.RolloutState
    Technology = nil, -- Enum.Technology
    LightingStyle = nil, -- Enum.LightingStyle
  }

  local LightingChanged = makeEvent()

  for name, value in pairs(Property) do
    Roblox.implementProperty("Lighting", name,
      function()
        return Property[name]
      end,
      function(_, newValue)
        Property[name] = newValue
        LightingChanged:Fire(name, newValue)
      end
    )
  end

  Roblox.implementProperty("Lighting", "LightingChanged", function()
    return LightingChanged
  end)
  
  Registry.LightingProperty = Property
  Registry.LightingChanged = LightingChanged

  Task.spawn(function()
    local dt = 1 / Registry.FpsCap
    local increment = 0.01
    while true do
      Property.ClockTime = Property.ClockTime + increment
      if Property.ClockTime >= 24 then
        Property.ClockTime = Property.ClockTime - 24
      end
      Property.TimeOfDay = string.format("%02d:%02d:%02d",
        math.floor(Property.ClockTime),
        math.floor((Property.ClockTime % 1) * 60),
        math.floor((((Property.ClockTime % 1) * 60) % 1) * 60)
      )
      LightingChanged:Fire("ClockTime", Property.ClockTime)
      Task.wait(dt)
    end
  end)
end)