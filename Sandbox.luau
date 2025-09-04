local Libraries = require("./Dependency/LuauLibrary/CompiledLibrary")
local Utility = require("./Dependency/Utility")
local Core = require("./Dependency/Core")
local Task = require("@lune/task")

local getModule = Utility.getModule

local Sandbox = {}
function Sandbox:Create()
  local MainDirectory = (debug.info(1, 's')):gsub("Sandbox", "")
  local Registry = getModule("Registry")
  local Game = getModule("Game")
  local LCore = getModule("LCore")
  local ECore = getModule("ECore")(MainDirectory)
  local FinalECore = getModule("FinalECore")(ECore, LCore, Game)
  local RobloxAPI = getModule("RobloxAPI")(Registry.Roblox, Registry.CachedInstances, Registry, Game)
  local GameShortcuts = getModule("GameShortcuts")(Game)
  RobloxAPI.game = Game
  
  ECore.checkcaller = function()
    local Source = debug.info(1, 's')
    if Source ~= MainDirectory .. "Sandbox" then
      return false
    end
    return true
  end
  
  local MT = {
    __index = function(_, Key)
      local val = rawget(LCore, Key)
      if val ~= nil then
        return val
      end
      
      val = rawget(Registry.GlobalVariables, Key)
      if val ~= nil then
        return val
      end
      
      val = rawget(GameShortcuts, string.lower(Key))
      if val ~= nil then
        return val
      end
      
      val = rawget(RobloxAPI, Key)
      if val ~= nil then
        return val
      end
      
      val = rawget(Libraries, Key)
      if val ~= nil then
        return val
      end
      
      if Key == "_G" then
        return ECore
      end
      
      print("Missing", Key)
      return nil
    end,
    __newindex = function(_, Key, Value)
      rawset(Registry.GlobalVariables, Key, Value)
    end
  }
  
  return ECore, MT
end

function Sandbox:Run(Code, ...)
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
        optimizationLevel = 2,
        coverageLevel = 0,
        debugLevel = 1
      })
    end)
    if not IsOk then
      return nil, tostring(Bytecode)
    end
    local IsOk2, callableFn = pcall(function()
      return Luau.load(Bytecode, {
        debugName = string.format("[string \"%s\"]", chunkName),
        environment = Compiled,
        injectGlobals = false,
        codegenEnabled = true
      })
    end)
    if not IsOk2 then
      return nil, tostring(callableFn)
    end
    return callableFn
  end)
  
  rawset(ECore, "loadfile", function(Path)
    local Bytecode = Luau.compile(ECore.readfile(Path), {
      optimizationLevel = 2,
      coverageLevel = 0,
      debugLevel = 1
    })
    local callableFn = Luau.load(Bytecode, {
      debugName = "[VM - LOADFILE]: " .. Count,
      environment = Compiled,
      injectGlobals = false,
      codegenEnabled = true
    })
    Count = Count + 1
    return callableFn
  end)
  
  local Bytecode = Luau.compile(Code, {
    optimizationLevel = 2,
    coverageLevel = 0,
    debugLevel = 1
  })
  local CompiledFN = Luau.load(Bytecode, {
    debugName = "",
    environment = Compiled,
    injectGlobals = false,
    codegenEnabled = true
  })

  return Task.spawn(function(...)
    local succ, er = pcall(CompiledFN, ...)
    if er and not succ then
      print(er)
    end
    return succ, er
  end)
end

return Sandbox


