return (function(Roblox)
  local Registry = require("@Dep/Registry")
  local GenerateID = function()
    local Template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
    local ID, _ = string.gsub(Template, "[xy]", function(C)
      local V = (C == "x") and math.random(0, 15) or math.random(8, 11)
      return string.format("%x", V)
    end)
    return ID
  end
  local ClientID = GenerateID()
  local PlaySessionID = GenerateID()

  Roblox.implementMethod("RbxAnalyticsService", "GetClientId", function(_, Url, ...)
    return Registry.HWID
  end)

  Roblox.implementMethod("RbxAnalyticsService", "GetPlaySessionId", function(_, Url, ...)
    return PlaySessionID
  end)
  
  Roblox.implementMethod("RbxAnalyticsService", "GetSessionId", function(_, Url, ...)
    return "Virtual Session"
  end)
end)
