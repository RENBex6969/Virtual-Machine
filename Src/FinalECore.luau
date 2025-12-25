return (function(ECore, LCore, Game, Registry)
  ECore.gethui = function()
    return Game:GetService("CoreGui")
  end
  
  ECore.protect_gui = function(Instance)
    Instance.Parent = Game:GetService("CoreGui")
  end
  
  ECore.getinstances = function()
    return Game:GetDescendants()
  end
  
  ECore.getrenv = function()
    return LCore
  end
  
  local Functions = {}
  local Functionsids = {}
  local FuncHooks = {}
  local Org = {}
  
  ECore.CALL = function(Func, ...)
    return (FuncHooks[Func] or Func)(...)
  end
  
  ECore.NAMECALL = function(Table, Index, Table, ...)
    local Function = Table[Index]
    
    return (FuncHooks[Function] or Function)(Table, ...)
  end
  
  ECore.FUNC = function(fn, id)
    Functions[id] = { 
      hooks = {}
    }
    
    Functionsids[fn] = id
    
    return fn
  end

  ECore.UPVALUE = function(ref, funcid, upvalID)
  local Info = Functions[funcid]
  
  if Info then
    if Info.hooks[upvalID] then
      return Info.hooks[upvalID]
    end
  end
  
  return ref
end

  ECore.debug.setupvalue = function(fn, upvalID, value)
    local id = Functionsids[fn]
    if id then
      local info = Functions[id]
      if info then
        info.hooks[upvalID] = value
      end
    end
  end

  ECore.hookfunction = function(Old, New)
    FuncHooks[Old] = New
    Org[New] = Old
    
    return ECore.clonefunction(Old)
  end
  
  ECore.detourfunction = function(...)
    return ECore.hookfunction(...)
  end
  
  ECore.replaceclosure = function(...)
    return ECore.hookfunction(...)
  end
  
  ECore.restorefunction = function(New)
    local Old = Org[New]
    if Old then
      FuncHooks[New] = Old
    end
  end
  
  ECore.setsimulationradius = function(Simulation, MaxSimulation)
    Game:GetService("LocalPlayer").SimulationRadius = Number
    Game:GetService("LocalPlayer").MaxSimulationRadius = Number
  end
  
  ECore.getscripts = function()
    local Compiled = {}
    for _, Obj in next, Game:GetDescendants() do 
      if Obj.ClassName == 'ModuleScript' or Obj.ClassName == 'LocalScript' then 
        table.insert(Compiled, Obj) 
      end 
    end
    table.insert(Compiled, {
      Name = "ClassicCamera"
    })
    return Compiled
  end
  
  ECore.getrunningscripts = function()
    local Compiled = {}
    for _, Obj in next, Game:GetDescendants() do 
      if Obj.ClassName == 'LocalScript' or Obj.ClassName == 'ModuleScript' then 
        table.insert(Compiled, Obj)
      end
    end
    return Compiled
  end
  
  ECore.getcallingscript = function()
    local Source = debug.info(1, 's')
    for _, Obj in next, Game:GetDescendants() do 
      if Obj:GetFullName() == Source then 
        return Obj
      end 
    end
  end
  
  ECore.getloadedmodules = function()
    local Compiled = {}
    for _, Obj in next, Game:GetDescendants() do 
      if Obj.ClassName == 'ModuleScript' then 
        table.insert(Compiled, Obj) 
      end 
    end
    table.insert(Compiled, {
      Name = "Invisicam"
    })
    return Compiled
  end
end)