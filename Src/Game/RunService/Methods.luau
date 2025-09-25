return (function(Roblox)
  Roblox.implementMethod("RunService", "IsStudio", function(_, Data)
    return false
  end)
  Roblox.implementMethod("RunService", "IsClient", function(_, Data)
    return true
  end)
  Roblox.implementMethod("RunService", "IsServer", function(_, Data)
    return false
  end)
  Roblox.implementMethod("RunService", "IsEdit", function()
    return false
  end)
  Roblox.implementMethod("RunService", "IsRunMode", function()
    return false
  end)
end)