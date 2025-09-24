local SetCClosure = require("./Core").SetCClosure
local Utility = require("./Utility")
local getLibrary = Utility.getLLibrary
local Registry = Utility.getModule("Registry")
local Task = require("@lune/task")
local Luau = require("@lune/luau")
local ModuleCache = {}

local MAX_DEPTH = 50
local _indexDepth = setmetatable({}, {__mode = "k"}) -- weak table per table

local function isClone(obj)
	for _, clones in pairs(Registry.clonerefs) do
		if table.find(clones, obj) then
			return true
		end
	end
	return false
end

local LCore = {
  print = function(...)
    return print("[PRINT]:", ...)
  end,
  warn = function(...)
    return print("[WARN]:", ...)
  end,
  error = function(Message, Stack)
    return error(Message, (Stack or 0)+ 2)
  end,
  pcall = function(Func, ...)
    local Arguments = {...}
    local Results = {pcall(Func, ...)}
    local Error = Results[2]
    if not Results[1] and type(Error) == "string" and string.find(Error, "attempt to perform arithmetic") then
      local Line = Error:sub(1, Error:find(":(%d*):")) .. "1:"
      local Metatable; Metatable = setmetatable({
        gsub = function()
          return Metatable
        end
      },{
        __eq = function()
          return true
        end, 
        __tostring = function()
          return Line .. " attempt to perform arithmetic (pow) on string and number"
        end
      })
      print("[VM - System ]: Bypassing (Prometheus / Forks) line check")
      return false, Metatable
    end
    if Results[1] == false then
      pcall(function()
        Results[2] = Results[2]:gsub(":%d+:",":1:")
      end)
    end
    local Succ, Err = table.unpack(Results)
    if type(err) == "userdata" then
      Err = tostring(Err)
    end
    return table.unpack(Results)
  end,
  xpcall = function(...)
    return xpcall(...)
  end,
  tonumber = function(...)
    return tonumber(...)
  end,
  tostring = function(...)
    return tostring(...)
  end,
  assert = function(Condition, Message, ...)
    if not Condition then
      error(Message or "assertion failed!", 2)
    end
    return Condition, Message
  end,
  pairs = function(...)
    return pairs(...)
  end,
  ipairs = function(...)
    return ipairs(...)
  end,
  select = function(...)
    return select(...)
  end,
  newproxy = function(HasMT)
    local Userdata = newproxy(HasMT)
    if HasMT then
      Registry.RawMetatables[Userdata] = getmetatable(Userdata)
    end
    return Userdata
  end,
  unpack = function(...)
    return table.unpack(...)
  end,
  next = function(...)
    return next(...)
  end,
  type = function(...)
    return type(...)
  end,
  typeof = function(Object)
    if isClone(Object) then
      return "Instance"
    end
    return typeof(Object)
  end,
  rawset = function(...)
    return rawset(...)
  end,
  rawget = function(...)
    return rawget(...)
  end,
  rawequal = function(...)
    return rawequal(...)
  end,
  setmetatable = function(Table, MT)
    local Table = Table or {}
    local MT = MT or {}
    Registry.RawMetatables[Table] = MT
    return setmetatable(Table, Registry.RawMetatables[Table])
  end,
  getmetatable = function(Table)
    return getmetatable(Table)
  end,
  wait = function(...)
    return Task.wait(...)
  end,
  tick = function(...)
    return os.time() + (os.clock() % 1)
  end,
  delay = function(Seconds, Func)
    return Task.delay(Seconds, Func)
  end,
  require = function(Module)
    assert(Module, "No module provided")
    if ModuleCache[Module] then
      return ModuleCache[Module]
    end
    local Result
    local t = typeof(Module)
    if t == "Instance" then
      assert(Module:IsA("ModuleScript"), "Instance must be a ModuleScript")
      local success, ret = pcall(function()
        local bytecode = Luau.compile(Module.Source)
        local callableFn = Luau.load(bytecode, {
          environment = getfenv(),
          injectGlobals = true,
          codegenEnabled = true
        })
        return callableFn()
      end)
      if not success then
        error("ModuleScript failed: " .. tostring(ret))
      end
      Result = ret
    elseif type(Module) == "function" then
      Result = Module()
    elseif type(Module) == "table" then
      Result = Module
    else
      error("Unsupported module type: " .. t)
    end
    ModuleCache[Module] = Result
    return Result
  end
}

Registry.LCore = LCore
return LCore