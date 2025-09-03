return (function(Roblox, Network)
  
  Roblox.implementMethod("DataModel", "HttpGet", function(_, Url, ...)
    return Network.HttpGet(Url)
  end)
  
  Roblox.implementMethod("DataModel", "HttpGetAsync", function(_, Url, ...)
    return Network.HttpGet(Url)
  end)
  
  Roblox.implementMethod("DataModel", "HttpPost", function(_, Url, Body, ...)
    return Network.HttpPost(Url, Body)
  end)
  
  Roblox.implementMethod("DataModel", "HttpPostAsync", function(_, Url, Body, ...)
    return Network.HttpPost(Url, Body)
  end)
  
  Roblox.implementMethod("DataModel", "IsLoaded", function(_, ...)
    return true
  end)
  
  Roblox.implementMethod("DataModel", "BindToClose", function(_, ...)
    return 
  end)
  
  Roblox.implementMethod("DataModel", "GetJobsInfo", function(_, ...)
    return {}
  end)
  
  Roblox.implementMethod("DataModel", "GetObjects", function(_, Url)
    return nil
  end)
  
  Roblox.implementMethod("DataModel", "SetPlaceId", function(_, ID)
    Registry.Game.PlaceId =  ID
  end)
  
  Roblox.implementMethod("DataModel", "SetUniverseId", function(_, ID)
    Registry.Game.UniverseId =  ID
  end)
  
end)