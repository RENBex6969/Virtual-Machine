local SetCClosure = require("@Src/Core").SetCClosure
local Utility = require("@Dep/Utility")
local Registry = require("@Dep/Registry")
local Task = require("@lune/task")
local Luau = require("@lune/luau")
local getLibrary = Utility.getLLibrary
local ModuleCache = {}

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
    assert(Message , 'Invalid argument #1 to "error", argument expected, but got nil')
    
    if not type(Stack) == nil then
      assert(type(Level) == "number", 'Invalid argument #2 to "error", number expected, but got ' .. type(Level))
    end
    
    return error(Message, (Stack or 0)+ 2)
  end,
  pcall = function(Function, ...)
    assert(type(Function) == "function", 'Invalid argument #1 to "pcall", function expected, but got ' .. type(Function))
    
    local Arguments = {...}
    local Results = {pcall(Function, ...)}
    
    local Error = Results[2]
    if not Results[1] and type(Error) == "string" and string.find(Error, "attempt to perform arithmetic") then
      local Line = Error:sub(1, Error:find(":(%d*):")) .. "1:"
      local Metatable; Metatable = setmetatable({
        gsub = function()
          return Metatable
        end
      },{
        __eq = function(L, R)
          return true
        end, 
        __tostring = function()
          return Line .. " attempt to perform arithmetic (pow) on string and number"
        end
      })
      print("[VM - System ]: Bypassing (Prometheus / Forks) line check")
      return false, Metatable
    end
    
    return table.unpack(Results)
  end,
  xpcall = function(Function, Debug, ...)
    assert(type(Function) == "function", 'Invalid argument #1 to "xpcall", function expected, but got ' .. type(Function))
    assert(type(Debug) == "function", 'Invalid argument #2 to "xpcall", function expected, but got ' .. type(Debug))
    
    return xpcall(Function, Debug, ...)
  end,
  tonumber = function(...)
    
    return tonumber(...)
  end,
  tostring = function(...)
    return tostring(...)
  end,
  assert = function(Condition, Message)
    --assert(type(Message) == "string", 'Invalid argument #1 to "assert", string expected, but got ' .. type(Message))
    
    if not Condition then
      error(Message or "assertion failed!", 2)
    end
    return Condition, Message
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
  next = function(t, k)
    local getrawmetatable = Registry.ECore.getrawmetatable
    local MT = getrawmetatable(t)
    if MT and MT.__NEXT__ then
      return MT.__NEXT__(t, k)
    end
    return next(t, k)
  end,
  pairs = function(Table)
    assert(type(Table) == "table", 'Invalid argument #1 to "pairs", table expected, but got ' .. type(Table))
    
    local getrawmetatable = Registry.ECore.getrawmetatable
    local MT = getrawmetatable(Table)
    if MT and MT.__PAIRS__ then
      return MT.__PAIRS__(Table)
    end
    return pairs(Table)
  end,
  ipairs = function(Table)
    assert(type(Table) == "table", 'Invalid argument #1 to "ipairs", table expected, but got ' .. type(Table))
    
    local getrawmetatable = Registry.ECore.getrawmetatable
    local MT = getrawmetatable(Table)
    if MT and MT.__IPAIRS__ then
      return MT.__IPAIRS__(Table)
    end
    return ipairs(Table)
  end,
  type = function(Object)
    
    return type(Object)
  end,
  typeof = function(Object)
    
    if isClone(Object) then
      return "Instance"
    end
    return typeof(Object)
  end,
  rawset = function(Table, Index, Object)
    assert(type(Table) == "table", 'Invalid argument #1 to "rawset", table expected, but got ' .. type(Table))
    assert(type(Index) == "string", 'Invalid argument #2 to "rawset", string expected, but got ' .. type(Index))
    assert(Object, 'Missing #3 argument to "rawset"')
    
    return rawset(Table, Index, Object)
  end,
  rawget = function(Table, Index)
    assert(type(Table) == "table", 'Invalid argument #1 to "rawget", table expected, but got ' .. type(Table))
    assert(type(Index) == "string", 'Invalid argument #2 to "rawget", string expected, but got ' .. type(Index))
    
    return rawget(Table, Index)
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
  delay = function(Seconds, Function)
    return Task.delay(Seconds, Function)
  end,
  spawn = function(...)
    return Task.spawn(...)
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
        local Bytecode = Luau.compile(Module.Source)
        local ECore, MT = require("../Sandbox"):Create()
        
        local callableFn = Luau.load(Bytecode, {
          environment = setmetatable(ECore, MT),
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