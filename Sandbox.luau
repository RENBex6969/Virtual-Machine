local Utility = require("@Dep/Utility")
local Core = require("@Src/Core")
local Task = require("@lune/task")
local FileSystem = require("@lune/fs")
local Process = require("@lune/process")

local isMade = false
local CacheRobloxAPI = {}

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
  
  if isMade == false then
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
  
  local MT = {
    __index = function(_, Key)
      local Source = debug.info(coroutine.running(), 2, "s")
      if Source == MainDirectory .. "Sandbox" then
        error("[SECRUITY]: Attempt to escape envrionmemt!", 3)
      end
      
      local Value = rawget(LCore, Key)
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
      
      --print("Missing", Key)
      return nil
    end,
    __newindex = function(_, Key, Value)
      local Source = debug.info(coroutine.running(), 2, "s")
      if Source == MainDirectory .. "Sandbox" then
        error("[SECRUITY]: Attempt to escape envrionmemt!", 3)
      end
      
      rawset(Registry.GlobalVariables, Key, Value)
    end,
  }
  
  return ECore, MT
end

--[[
function Sandbox:Process(Code)
  local tempIn = "temp_input.luau"
  local tempOut = "temp_output.luau"

  FileSystem.writeFile(tempIn, Code)

  local step1 = Process.exec("darklua", {
    "process",
    tempIn,
    tempOut,
    "-c",
    "config.json",
  })

  if not step1.ok then
    error("darklua failed:\n" .. step1.stderr)
  end

  local processed = FileSystem.readFile(tempOut)
  FileSystem.removeFile(tempIn)
  FileSystem.removeFile(tempOut)

  return processed
end
]]

function Sandbox:Run(Code, ...)
  local Code = Sandbox.Process and Sandbox:Process(Code) or Code
  local Luau = require("@lune/luau")
  
  print(">--------------------------------------------------------------------")
  local Time = os.clock()
  local ECore, MT = Sandbox:Create()
  local Compiled = setmetatable(ECore, MT)
  
  print("[VM]: Compilation of Environment took " .. (os.clock() - Time) .. " seconds")
  print(">--------------------------------------------------------------------")
  
  local Count = 0
  rawset(ECore, "loadstring", function(code, chunkName)
    
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
    
    local IsOk2, callableFn = pcall(function()
      return Luau.load(Bytecode, {
        debugName = string.format(chunkName),
        environment = setmetatable(table.unpack({require("./Sandbox"):Create()})),
        injectGlobals = false,
      })
    end)
    
    if not IsOk2 then
      return nil, tostring(callableFn)
    end
    return callableFn
  end)
  
  rawset(ECore, "loadfile", function(Path)
    local Bytecode = Luau.compile(ECore.readfile(Path), {
      optimizationLevel = 0,
      coverageLevel = 0,
      debugLevel = 0
    })
    local callableFn = Luau.load(Bytecode, {
      debugName = "[VM - LOADFILE]: " .. Count,
      environment = setmetatable(table.unpack({require("./Sandbox"):Create()})),
      injectGlobals = false,
    })
    Count = Count + 1
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

  return Task.spawn(function(...)
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
end

return Sandbox