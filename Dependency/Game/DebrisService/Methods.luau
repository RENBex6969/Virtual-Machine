return (function(Roblox, Network)
  local Task = require("@lune/task")
  local DebrisItems = {}
  local LegacyMaxEnabled = false
  local LegacyMaxCount = 1000
  
  Roblox.implementMethod("Debris", "AddItem", function(_, Instance, Lifetime)
    Lifetime = tonumber(Lifetime) or 10  
    table.insert(DebrisItems, Instance)
    Task.delay(Lifetime, function()
      for I, Obj in ipairs(DebrisItems) do
        if Obj == Instance then
          table.remove(DebrisItems, I)
          break
        end
      end
      if Instance and Instance.Destroy then
        Instance:Destroy()
      end
    end)
    if LegacyMaxEnabled and #DebrisItems > LegacyMaxCount then
      local Oldest = table.remove(DebrisItems, 1)
      if Oldest and Oldest.Destroy then
        Oldest:Destroy()
      end
    end
  end)
  
  Roblox.implementMethod("Debris", "GetUnreplicatedInstances", function()
    local Copy = {}
    for I, Obj in ipairs(DebrisItems) do
      Copy[I] = Obj
    end
    return Copy
  end)
  
  Roblox.implementMethod("Debris", "SetLegacyMaxItems", function(_, Enabled)
    LegacyMaxEnabled = Enabled and true or false
  end)
  
end)