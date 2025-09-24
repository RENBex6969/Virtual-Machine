local Spy = {}
local Proxies = {}
local Roblox = require("@lune/roblox")
local Registry = require("./Dependency/Registry")
local Game = Roblox.Instance.new("DataModel")

local nextId = 0
local objectNames = setmetatable({}, { __mode = "k" })

function Spy:getVarName(instance)
  if not objectNames[instance] then
    nextId += 1
    objectNames[instance] = "Obj" .. nextId
  end
  return objectNames[instance]
end

function Spy:FixArgs(Args)
  for i, Value in ipairs(Args) do
    if type(Value) == "function" then
      Args[i] = "function() --[[ FUNCTION EXPLORER ]] end"
    else
      Args[i] = tostring(Value)
    end
  end
  return Args
end

function Spy:Table(Table, PassedKey, VarName)
  local VarName = VarName or "_"
  
  return setmetatable({}, {
    __index = function(_, Key)
      local Value = Table[Key]
      if type(Value) == "function" then
        return function(_, ...)
          local Args = {...}
          Args = Spy:FixArgs(Args)
          
          if PassedKey == "MouseButton1Click" then
            print(VarName .. "." .. PassedKey .. ":" .. Key .. "(" .. table.concat(Args, ", ") .. ")")
            return Value(Table, ...)
          end
          
          print("local _ = " .. PassedKey .. ":" .. Key .. "(" .. table.concat(Args, ", ") .. ")")
          return Value(Table, ...)
        end
      end
      
      if type(Value) == "table" then
        return Spy:Table(Value, Key)
      end
      
      return Value
    end
  })
end

function Spy:Instance(Instance)
  local VarName = Spy:getVarName(Instance)

  local Proxy = setmetatable({}, {
    __index = function(_, Key)
      local Value = Instance[Key]
      if type(Value) == "function" then
        return function(_, ...)
          local Args = {...}
          Args = Spy:FixArgs(Args)
          
          print(VarName .. ":" .. Key .. "(" .. table.concat(Args, ", ") .. ")")
          return Value(Instance, ...)
        end
      end
      
      if type(Value) == "table" then
        return Spy:Table(Value, Key, VarName)
      end

      return Value
    end,

    __newindex = function(_, Index, Value)
      local OrginalInstance = Proxies[Value]
      local ValueName = "_"
      local IsA = typeof(Value)
      local OrgInstance = getmetatable(Value)

      if OrginalInstance then
        print(VarName .. "." .. Index .. " = " .. Spy:getVarName(OrginalInstance))
        Instance[Index] = OrginalInstance
      else
        if Roblox[IsA] and IsA ~= "Instance" then
          print(VarName .. "." .. Index .. " = " .. IsA .. ".new(" .. tostring(Value) .. ")")
        elseif IsA == "Instance" then
          local What
          pcall(function()
            What = Game:GetService(tostring(Value))
          end)
          if What then
            print(VarName .. "." .. Index .. " = " .. tostring(What))
          else
            print(VarName .. "." .. Index .. " = Unknown")
          end
          Instance[Index] = Value
        else
          if IsA == "string" then
            print(VarName .. "." .. Index .. " = '" .. tostring(Value) .. "'")
          elseif IsA == "number" then
            print(VarName .. "." .. Index .. " = " .. tostring(Value))
          elseif IsA == "table" then
            print(VarName .. "." .. Index .. " = {} -- Maybe CoreGui broken due to cloneref")
          elseif IsA == "boolean" then
            print(VarName .. "." .. Index .. " = " .. tostring(Value))
          elseif IsA == "EnumItem" then
            print(VarName .. "." .. Index .. " = " .. tostring(Value))
          else
            print("Unexpected", IsA)
          end
          if Index == "Parent" then
            Instance[Index] = Game:FindService("CoreGui")
            return 
          end
          Instance[Index] = Value
        end
      end
    end,
    Instance = Instance
  })

  Proxies[Proxy] = Instance
  return Proxy
end

return Spy