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
  
  local FuncHooks = {}
  local Org = {}
  
  ECore.CALL = function(Func, ...)
    print(Func)
    return (FuncHooks[Func] or Func)(...)
  end

  ECore.hookfunction = function(Old, New)
    --[[
    local Copy = function(...)
      return Old(...)
    end
    for Key, Value in pairs(ECore) do
      if Value == Old then
        ECore[Key] = New
        return Old
      end
    end
    
    for Key, Value in pairs(LCore) do
      if Value == Old then
        LCore[Key] = New
        return Old
      end
    end
    
    for Key, Value in pairs(Registry.GlobalVariables) do
      if Value == Old then
        Registry.GlobalVariables[Key] = New
        return Old
      end
    end
    ]]
    
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