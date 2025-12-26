local Utility = require("@Dep/Utility")
local Core = require("@Src/Core")
local Task = require("@lune/task")
local FileSystem = require("@lune/fs")
local Process = require("@lune/process")
local Serde = require("@lune/serde")
local Random = require("@Dep/Random")

local isMade = false
local CacheRobloxAPI = {}

local Result = Process.exec("lute", { "--version" })
assert(Result.ok, "Error occured whilst checking Lute. Did you install lute? (== 2025.1115)")
  
local Version = Result.stdout:gsub("%s+$", ""):sub(-4)
assert(Version == "1115", "Version mismatched expected Lute version 2025.1115 but got 2025." .. Version)

assert(FileSystem.isFile("config.json"), "Default config.json is missing from the root directory!")
local ConfigJSON = FileSystem.readFile("config.json")

local Config = Serde.decode("json", ConfigJSON)

local HookOp = function( Source : string ): string
  if not Config.Script.HookOp then
    return Source
  end
  
  local InputPath = Random:filename(16, ".luau", "./Src/Temp")
  local OutputPath = Random:filename(16, ".luau", "./Src/Temp")
  
  FileSystem.writeFile(InputPath, Source)
  
  local Result = Process.exec("lute", { "run", "./Dependency/Hookop", "--with-luaurc" }, { 
    env = { InputPath = InputPath, OutputPath = OutputPath },
    cwd = "./"
  })

  FileSystem.removeFile(InputPath)
  
  local Out; if Result.ok then
    assert(FileSystem.isFile(OutputPath), "[HOOKOP]: Designated output path is not found!")
    
    Out = FileSystem.readFile(OutputPath)
    FileSystem.removeFile(OutputPath)
  end
  

  --print(Result.stdout, Result.stderr)
  --[[
  assert(Result.ok, "[HOOKOP]: Error occured whilst patching script!")
  
  local CPUTime, SizeKB = Result.stdout:match("([%d%.]+), %s*([%d%.]+)")
  assert(CPUTime or SizeKB, "[HOOKOP]: Did not return any info! possible error.")
  
  CPUTime, SizeKB = tonumber(CPUTime), tonumber(SizeKB)
  
  if CPUTime < 1 then
    print(string.format("[HOOKOP]: %.2f ms ", CPUTime * 1000))
  else
    print(string.format("[HOOKOP]: %.2f s ", CPUTime))
  end
  
  print(string.format("[HOOKOP]: Old %.2f KB / New %.2f KB", #Source / 1024, SizeKB))
  ]]

  return Out
end

local Sandbox = {}
function Sandbox:Create()
  local MainDirectory = (debug.info(1, 's')):gsub("Sandbox", "")
  local Registry = require("@Dep/Registry")
  local Game = require("@Src/Game")
  local LCore = require("@Src/LCore")
  local ECore = require("@Src/ECore")(MainDirectory)
  local Libraries = require("@Src/LuauLibrary/CompiledLibrary")(ECore)
  local FinalECore = require("@Src/FinalECore")(ECore, LCore, Game, Registry)
  local GameShortcuts = require("@Src/GameShortcuts")(Game)
  local RobloxAPI = {}
  
  if not isMade then
    RobloxAPI = require("@Src/RobloxAPI")(Registry.Roblox, Registry.CachedInstances, Registry, Game)
    CacheRobloxAPI = RobloxAPI
  else
    RobloxAPI = CacheRobloxAPI
  end
  isMade = true
  
  RobloxAPI.game = ECore.setrawmetatable({}, {
    __index = function(_, Key)
      local Value = Game[Key]
      if type(Value) == "function" then
        return function(Self, ...)
          Registry.currentNamecall = Key
          local mt = getmetatable(Self)
          if mt and mt.__namecall then
            mt.__namecall(Self, ...)
          end
          return Value(Game, ...)
        end
      end
      return Value
    end,
    __newindex = function(_, Key, Value)
      
    end,
    __namecall = function(Self, ...)
      if Registry.currentNamecall then
        local Method = Registry.currentNamecall
        Registry.currentNamecall = nil
        return Game[Method](Game, ...)
      end
    end,
    __metatable = "Locked"
  })
  
  ECore.checkcaller = function()
    local Source = debug.info(1, 's')
    if Source ~= MainDirectory .. "Sandbox" then
      return false
    end 
    return true
  end
  
  Registry.ECore = ECore
  
  local Cache = {}
  
  local MT = {
    __index = function(_, Key)
      local Value
      
      Value = rawget(LCore, Key)
      if Value ~= nil then
        return Value
      end
      
      Value = rawget(Registry.GlobalVariables, Key)
      if Value ~= nil then
        return Value
      end
      
      Value = rawget(GameShortcuts, string.lower(Key))
      if Value ~= nil then
        return Value
      end
      
      Value = rawget(RobloxAPI, Key)
      if Value ~= nil then
        return Value
      end
      
      Value = rawget(Libraries, Key)
      if Value ~= nil then
        return Value
      end
      
      if Key == "_G" then
        return ECore
      end
      
      if Cache[Key] ~= true then
        print("[VM]: Missing", Key)
      end
      
      Cache[Key] = true
      
      return nil
    end,
    __newindex = function(_, Key, Value)
      rawset(Registry.GlobalVariables, Key, Value)
    end,
  }
  
  LCore.getfenv = function()
    local ENV = setmetatable(ECore, MT)
    return setmetatable({
      script = "Script"
    }, {
      __index = function(_, Key)
        return ENV[Key]
      end
    })
  end
  
  return ECore, MT, Registry
end

function Sandbox:Run(Code, ...)
  local Code = Sandbox.Process and Sandbox:Process(Code) or Code
  Code = HookOp(Code)
  print(Code)
  local Luau = require("@lune/luau")
  
  print(">--------------------------------------------------------------------")
  local Time = os.clock()
  local ECore, MT, Registry = Sandbox:Create()
  local Compiled = setmetatable(ECore, MT)
  
  print("[VM]: Compilation of Environment took " .. (os.clock() - Time) .. " seconds")
  print(">--------------------------------------------------------------------")
  
  local Count = 0
  rawset(ECore, "loadstring", function(code, chunkName)
    assert(type(code) == "string", 'Invalid argument #1 to "loadstring", string expected, but got ' .. type(code))
    code = HookOp(code)
    
    chunkName = chunkName or "[VM - Loadstring]: " .. Count
    Count = Count + 1
    local IsOk, Bytecode = pcall(function()
      return Luau.compile(code, {
        optimizationLevel = 0,
        coverageLevel = 0,
        debugLevel = 2
      })
    end)
    if not IsOk then
      return nil, tostring(Bytecode)
    end
    
    local ECore, MT, Registry = Sandbox:Create()
    local Compiled = setmetatable(ECore, MT)
    
    local IsOk2, callableFn = pcall(function()
      return Luau.load(Bytecode, {
        debugName = string.format(chunkName),
        environment = setmetatable(Compiled, MT),
        injectGlobals = false,
      })
    end)
    
    if not IsOk2 then
      return nil, tostring(callableFn)
    end
    return callableFn
  end)
  
  local Count2 = 0
  rawset(ECore, "loadfile", function(Path)
    assert(type(Path) == "string", 'Invalid argument #1 to "loadfile", string expected, but got ' .. type(Path))
    
    chunkName = chunkName or "[VM - Loadfile]: " .. Count
    Count2 = Count2 + 1
    local IsOk, Bytecode = pcall(function()
      local Code = HookOp(ECore.readfile(Path))
      
      return Luau.compile(Code, {
        optimizationLevel = 0,
        coverageLevel = 0,
        debugLevel = 2
      })
    end)
    if not IsOk or IsOk == nil then
      return nil, tostring(Bytecode)
    end
    
    local ECore, MT = require("./Sandbox"):Create()
    
    local IsOk2, callableFn = pcall(function()
      return Luau.load(Bytecode, {
        debugName = string.format(chunkName),
        environment = setmetatable(ECore, MT),
        injectGlobals = false,
      })
    end)
    
    if not IsOk2 or IsOk2 == nil then
      return nil, tostring(callableFn)
    end
    
    return callableFn
  end)
  
  local Count3 = 0
  rawset(ECore, "load", function(code, chunkName)
    assert(type(code) == "string", 'Invalid argument #1 to "load", string expected, but got ' .. type(code))
    code = HookOp(code)
    
    chunkName = chunkName or "[VM - LOAD]: " .. Count
    Count3 = Count3 + 1
    local IsOk, Bytecode = pcall(function()
      return Luau.compile(code, {
        optimizationLevel = 0,
        coverageLevel = 0,
        debugLevel = 2
      })
    end)
    if not IsOk then
      return nil, tostring(Bytecode)
    end
    
    local ECore, MT = require("./Sandbox"):Create()
    
    local IsOk2, callableFn = pcall(function()
      return Luau.load(Bytecode, {
        debugName = string.format(chunkName),
        environment = setmetatable(ECore, MT),
        injectGlobals = false,
      })
    end)
    
    if not IsOk2 then
      return nil, tostring(callableFn)
    end
    return callableFn
  end)
  
  
  local Bytecode = Luau.compile(Code, {
    optimizationLevel = 2,
    coverageLevel = 0,
    debugLevel = 0,
  })

  local CompiledFN = Luau.load(Bytecode, {
    debugName = "",
    environment = Compiled,
    injectGlobals = false,
    codegenEnabled = false
  })

  local Thread = Task.spawn(function(...)
    local succ, er = xpcall(function(...) 
      return CompiledFN(...) 
    end, function(err) 
      return debug.traceback(tostring(err), 2) 
    end, ...)
    
    if not succ then
      print("[RUNTIME - ERROR]:", er)
    end
  
    return succ, er
  end)
  
  Registry.ThreadEnvironments[Thread] = Registry.GlobalVariables
  return Thread
end

return Sandbox