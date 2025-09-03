local Roblox = require("@lune/roblox")
local OldInstance = Roblox.Instance

local Instance = {
  new = function(ClassName, Parent)
    local Object = OldInstance.new(ClassName)
    local MT = {}
    
    MT.__index = function(_, Key)
      return Object[Key]
    end
    
    MT.__newindex = function(_, Key, Value)
      Object[Key] = Value
    end
    
    MT.__metatable = nil
    MT.__type = typeof(Object)
    MT.__tostring = function()
      return typeof(Object)
    end
    
    return setmetatable({}, MT)
  end
}

local A = Instance.new("Part")
A.Parent = nil
print(A, type(A), typeof(A))