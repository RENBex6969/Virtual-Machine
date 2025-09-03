local Utility = require("./Utility")
local getModule = Utility.getModule
local Core = {}

local Registry = getModule("Registry")

local newcclosure = function(Function)
    local Compiled = coroutine.wrap(function(...)
      local b = {coroutine.yield()}
      while true do
        b = {coroutine.yield(Function(table.unpack(b)))}
      end
    end)
    Compiled()
    return Compiled
end

Core.SetCClosure = function(Funcs)
  local function Register(Value)
    if type(Value) == "function" then
      local Final = newcclosure(Value)
      Registry.CClosures[Final] = true
      Value = Final
    elseif type(Value) == "table" then
      table.foreach(Value, function(_, V)
        Register(V)
      end)
    end
  end
  Register(Funcs)
  return Funcs
end

Core.SetLClosure = function(Funcs)
  local function Register(Value)
    if type(Value) == "function" then
      Registry.CClosures[Value] = true
    elseif type(Value) == "table" then
      table.foreach(Value, function(_, V)
        Register(V)
      end)
    end
  end
  Register(Funcs)
  return Funcs
end

return Core