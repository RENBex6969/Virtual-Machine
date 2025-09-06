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
  
  ECore.hookfunction = function(Old, New)
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
    
    
    
    local Copy = Old
    Old = New
    
    
    return Copy
  end
  
  
  ECore.detourfunction = function(...)
    return ECore.hookfunction(...)
  end
  
  ECore.replaceclosure = function(...)
    return ECore.hookfunction(...)
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
    return Compiled
  end
end)