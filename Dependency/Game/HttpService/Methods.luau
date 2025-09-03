return (function(Roblox, Network)
  local Serde = require("@lune/serde")
  
  local function randomHex(n)
    local Hex = ""
    for i = 1, n do
      Hex = Hex .. string.format("%x", math.random(0, 15))
    end
    return Hex
  end
  
  Roblox.implementMethod("HttpService", "GetSecret", function(_, ...)
    return ""
  end)
  
  Roblox.implementMethod("HttpService", "GenerateGUID", function(_, Braces)
    local Part1 = randomHex(8)
    local Part2 = randomHex(4)
    local Part3 = "4" .. randomHex(3)
    local Part4 = string.format("%x", math.random(8,11)) .. randomHex(3)
    local Part5 = randomHex(12)
    local GUID = string.format("%s-%s-%s-%s-%s", Part1, Part2, Part3, Part4, Part5)
    if Braces then
      GUID = "{" .. GUID .. "}"
    end
    return GUID
  end)
  
  Roblox.implementMethod("HttpService", "JSONEncode", function(_, Data)
    return Serde.encode("json", Data)
  end)
  
  Roblox.implementMethod("HttpService", "JSONDecode", function(_, Data)
    if type(Data) ~= "string" then
      error("HttpService:JSONDecode expects #1 argument to be a string", 2)
    end
    return Serde.decode("json", Data)
  end)
  
  Roblox.implementMethod("HttpService", "UrlEncode", function(_, String)
    if type(String) ~= "string" then
      error("HttpService:UrlEncode expects #1 argument to be a string", 2)
    end
    return (String:gsub("[^%w%-_%.~]", function(Data)
      return string.format("%%%02X", string.byte(Data))
    end))
  end)
  
  Roblox.implementMethod("HttpService", "UrlDecode", function(_, String)
    if type(String) ~= "string" then
      error("HttpService:UrlDecode expects #1 argument to be a string", 2)
    end
    return (String:gsub("%%(%x%x)", function(Hex)
      return string.char(tonumber(Hex, 16))
    end))
  end)
  
  Roblox.implementMethod("HttpService", "IsUrlWhitelisted", function(_, Url)
    if type(Url) ~= "string" then
      error("HttpService:IsUrlWhitelisted expects #1 argument to be a string", 2)
    end
    return true
  end)
  
  Roblox.implementMethod("HttpService", "RequestAsync", function(_, Arguments)
    assert(type(Arguments) == "table", "HttpService:RequestAsync expects #1 argument to be a table")
    assert(Arguments.Url, "HttpService:RequestAsync expects a Url field")
    local Success, Response = pcall(Network.Request, {
      Url = Arguments.Url,
      Method = Arguments.Method,
      Headers = Arguments.Headers,
      Body = Arguments.Body or nil
    })
    if not Success then
      error("HttpService:RequestAsync failed: " .. tostring(Response), 2)
    end
    return {
      StatusCode = Response.StatusCode or 0,
      StatusMessage = Response.StatusMessage or "",
      Headers = Response.Headers or {},
      Body = Response.Body or ""
    }
  end)
  
  Roblox.implementMethod("HttpService", "GetAsync", function(_, Url, NoCache)
    assert(type(Url) == "string", "HttpService:GetAsync expects #1 argument to be a string")
    local Response = Network.Request({
      Url = Url,
      Method = "GET"
    })
    return Response.Body
  end)
  
  Roblox.implementMethod("HttpService", "PostAsync", function(_, Url, Data, ContentType, Compress)
    assert(type(Url) == "string", "HttpService:PostAsync expects #1 argument to be a string")
    ContentType = ContentType or "application/x-www-form-urlencoded"
    local Response = Network.Request({
      Url = Url,
      Method = "POST",
      Body = Data,
      Headers = {["Content-Type"] = ContentType}
    })
    return Response.Body
  end)
end)