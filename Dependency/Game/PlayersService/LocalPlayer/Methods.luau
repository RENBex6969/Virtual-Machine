return (function(Roblox, Game)
  local LocalPlayer = Game:GetService("Players").LocalPlayer
  Roblox.implementMethod("Player", "AddReplicationFocus", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "ClearCharacterAppearance", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "DistanceFromCharacter", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "GetFriendsOnline", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "GetJoinData", function(_, ...)
    return {
      ["SourceGameId"] = 0,
      ["SourcePlaceId"] = 0,
      ["RefferedByPlayerId"] = 0,
      ["Members"] = nil,
      ["TeleportData"] = {},
      ["LaunchData"] = "",
      ["GameJoinContext"] = {}
    }
  end)
  
  Roblox.implementMethod("Player", "GetMouse", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "GetNetworkPing", function(_, ...)
    return 1
  end)
  
  Roblox.implementMethod("Player", "GetRankInGroup", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "GetRoleInGroup", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "HasAppearanceLoaded", function(_, ...)
    return true
  end)
  
  Roblox.implementMethod("Player", "IsFriendsWith", function(_, ...)
    return false
  end)
  
  Roblox.implementMethod("Player", "IsInGroup", function(_, ...)
    return false
  end)
  
  Roblox.implementMethod("Player", "IsVerified", function(_, ...)
    return false
  end)
  
  Roblox.implementMethod("Player", "Kick", function(_, ...)
    return print("[VM - KICKED] Reason : ", ...)
  end)
  
  Roblox.implementMethod("Player", "LoadCharacter", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "LoadCharacterWithHumanoidDescription", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "Move", function(_, Vector3, ...)
    local Position = Vector3
    return 
  end)
  
  Roblox.implementMethod("Player", "RemoveReplicationFocus", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "RequestStreamAroundAsync", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("Player", "SetAccountAge", function(_, Number)
    LocalPlayer.AccountAge = Number
  end)
  
  Roblox.implementMethod("Player", "SetSuperSafeChat", function(_, ...)
    return
  end)
end)
