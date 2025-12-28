local Task = require("@lune/task")
local Library = {}

function Library.Connection(Function : any?, Connections : table ): userdata
  local Proxy = newproxy(true)
  local Properties = getmetatable(Proxy)
  
  local IsConnected = true
  Properties.__index = function(_, Key)
    if Key == "Connected" then
      return Connections[Function].Status
    end
    
    if Key == "Disconnect" then
      return function()
        Connections[Function].Status = false
      end
    end
    
    return nil
  end
  
  Properties.__tostring = function()
    return "RBXScriptConnection"
  end
  
  return Proxy
end

function Library.Signal(): userdata
  local Proxy = newproxy(true)
  local Properties = getmetatable(Proxy)
  local Master = {}
  local Connections = {}
  
  function Master.CallAll(... : any?)
    for Function, Metadata in pairs(Connections) do
      if Metadata.Status then
        if Metadata.Parallel then
          local Arguments = {...}
          Task.spawn(function()
            local Succ = pcall(Function, unpack(Arguments))
            if not Succ then
              warn("RBXScriptSignal D:")
            end
          end)
        else
          local Succ = pcall(Function, ...)
          if not Succ then
            warn("RBXScriptSignal D:")
          end
        end
      end
      if Metadata.Lifetime == "Once" then
        Metadata.Status = false
      end
    end
  end
  
  Properties.__index = function(_, Key)
    if Key == "Connect" then
      return function(_, Function : any?)
        Connections[Function] = { Lifetime = "Forever", Status = true }
        
        return Library.Connection(Function, Connections)
      end
    elseif Key == "ConnectParallel" then
      return function(_, Function : any?)
        Connections[Function] = { Lifetime = "Forever", Status = true, Parallel = true }
        
        return Library.Connection(Function, Connections)
      end
    elseif Key == "Once" then
      return function(_, Function : any?)
        Connections[Function] = { Lifetime = "Once", Status = true }
        
        return Library.Connection(Function, Connections)
      end
    elseif Key == "Wait" then
      return function()
        Task.wait()
      end
    end
    
    return nil
  end
  
  Properties.__tostring = function()
    return "RBXScriptSignal"
  end
  
  return Proxy, Master
end

return Library