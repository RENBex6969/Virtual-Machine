return (function(Roblox, CachedInstances, Registry, Game)
  local Task = require("@lune/task")
  local Signal = require("./ExploitLibrary/Signal")
  local Spy = require("../Spy")
  Registry.CallbackStorage = {}
  local CallbackStorage = Registry.CallbackStorage

  local General = {}

  function General.MouseButton1Click(...)
    local Connections = {}
    return {
      Connect = function(_, Func)
        table.insert(Connections, Func)
        Func()
        return {
          Disconnect = function()
            for Index, F in pairs(Connections) do
              if F == Func then
                table.remove(Connections, Index)
              end
            end
          end
        }
      end
    }
  end

  local RegistryParent = {}

  local function GetParent(Proxy)
    for Real, Wrapped in pairs(RegistryParent) do
      if Wrapped == Proxy then
        return Real
      end
    end
    return nil
  end

  local InstanceProxies = {}

  function InstanceProxies.ProximityPrompt(Obj)
    CallbackStorage[Obj] = {}

    local TriggeredSignal = Signal.new()
    CallbackStorage[Obj].Triggered = TriggeredSignal
    CallbackStorage[Obj].Connections = {}

    local oldConnect = TriggeredSignal.Connect
    TriggeredSignal.Connect = function(self, fn)
      local conn = oldConnect(self, fn)

      local connectionTable = {
        Enabled = true,
        Function = fn,
        Disconnect = function()
          conn:Disconnect()
          local list = CallbackStorage[Obj].Connections
          for i, v in ipairs(list) do
            if v.Function == fn then
              table.remove(list, i)
              break
            end
          end
        end,
        Fire = function(...) fn(...) end
      }

      table.insert(CallbackStorage[Obj].Connections, connectionTable)
      return connectionTable
    end

    function TriggeredSignal:Once(fn)
      local conn
      conn = self:Connect(function(...)
        fn(...)
        if conn then conn:Disconnect() end
      end)
      return conn
    end

    function TriggeredSignal:Fire(...)
      for _, conn in ipairs(CallbackStorage[Obj].Connections) do
        if conn.Enabled then conn.Function(...) end
      end
    end

    local Proxy = {}
    function Proxy:__index(Key)
      if Key == "Triggered" then return CallbackStorage[Obj].Triggered end
      local Value = Obj[Key]
      if type(Value) == "function" then
        return function(...)
          return Value(Obj, ...)
        end
      end
      return Obj[Key]
    end
    function Proxy:__newindex(Key, Value)
      if Key == "Triggered" then
        CallbackStorage[Obj].Triggered = Value
      else
        Obj[Key] = Value
      end
    end

    return setmetatable({}, Proxy)
  end

  function InstanceProxies.BindableFunction(Obj)
    CallbackStorage[Obj] = {}
    local Proxy = {}
    function Proxy:__index(Key)
      if Key == "OnInvoke" then
        return CallbackStorage[Obj].OnInvoke
      end
      return Obj[Key]
    end
    function Proxy:__newindex(Key, Value)
      if Key == "OnInvoke" then
        CallbackStorage[Obj].OnInvoke = Value
      else
        Obj[Key] = Value
      end
    end
    return setmetatable({}, Proxy)
  end

  function InstanceProxies.RemoteFunction(Obj)
    CallbackStorage[Obj] = {}
    local Proxy = {}
    function Proxy:__index(Key)
      if Key == "OnClientInvoke" then
        return CallbackStorage[Obj].OnClientInvoke
      elseif Key == "OnServerInvoke" then
        return CallbackStorage[Obj].OnServerInvoke
      end
      return Obj[Key]
    end
    function Proxy:__newindex(Key, Value)
      if Key == "OnClientInvoke" or Key == "OnServerInvoke" then
        CallbackStorage[Obj][Key] = Value
      else
        Obj[Key] = Value
      end
    end
    return setmetatable({}, Proxy)
  end

  function InstanceProxies.ClickDetector(Obj)
    CallbackStorage[Obj] = {}

    local Events = {
      MouseClick = Signal.new(),
      MouseHoverEnter = Signal.new(),
      MouseHoverLeave = Signal.new()
    }

    for name, evt in pairs(Events) do
      CallbackStorage[Obj][name] = evt
      CallbackStorage[Obj][name .. "Connections"] = {}

      local oldConnect = evt.Connect
      evt.Connect = function(self, fn)
        local conn = oldConnect(self, fn)

        local connectionTable = {
          Enabled = true,
          Function = fn,
          Disconnect = function()
            conn:Disconnect()
            local list = CallbackStorage[Obj][name .. "Connections"]
            for i, v in ipairs(list) do
              if v.Function == fn then table.remove(list, i) break end
            end
          end,
          Fire = function(...) fn(...) end
        }

        table.insert(CallbackStorage[Obj][name .. "Connections"], connectionTable)
        return connectionTable
      end

      function evt:Once(fn)
        local conn
        conn = evt:Connect(function(...)
          fn(...)
          if conn then conn:Disconnect() end
        end)
        return conn
      end

      function evt:Fire(...)
        for _, conn in ipairs(CallbackStorage[Obj][name .. "Connections"]) do
          if conn.Enabled then conn.Function(...) end
        end
      end
    end

    local Proxy = {}
    function Proxy:__index(Key)
      if Events[Key] then return Events[Key] end
      return Obj[Key]
    end
    function Proxy:__newindex(Key, Value)
      if Events[Key] then Events[Key] = Value else Obj[Key] = Value end
    end

    return setmetatable({}, Proxy)
  end

  function InstanceProxies.BindableEvent(Obj)
    local EventSignal = Signal.new()
    CallbackStorage[Obj] = {}
    CallbackStorage[Obj].Event = EventSignal
    CallbackStorage[Obj].Connections = {}

    local OldConnect = EventSignal.Connect
    EventSignal.Connect = function(self, fn)
      local conn = OldConnect(self, fn)

      local connectionTable = {
        Enabled = true,
        ForeignState = false,
        LuaConnection = true,
        Function = fn,
        Thread = coroutine.create(fn),
        Fire = function(...) fn(...) end,
        Defer = function(...) task.spawn(fn, ...) end,
        Disconnect = function()
          conn:Disconnect()
          local list = CallbackStorage[Obj].Connections
          for i, v in ipairs(list) do
            if v.Function == fn then
              table.remove(list, i)
              break
            end
          end
        end,
        Disable = function(self) self.Enabled = false end,
        Enable = function(self) self.Enabled = true end
      }

      table.insert(CallbackStorage[Obj].Connections, connectionTable)
      return connectionTable
    end

    function EventSignal:Once(fn)
      local conn
      conn = self:Connect(function(...)
        fn(...)
        if conn then conn:Disconnect() end
      end)
      return conn
    end

    function EventSignal:Fire(...)
      for _, conn in ipairs(CallbackStorage[Obj].Connections) do
        if conn.Enabled then conn.Function(...) end
      end
    end

    local Proxy = {}
    function Proxy:__index(Key)
      if Key == "Event" then return CallbackStorage[Obj].Event end
      return Obj[Key]
    end
    function Proxy:__newindex(Key, Value)
      if Key == "Event" then
        CallbackStorage[Obj].Event = Value
      else
        Obj[Key] = Value
      end
    end

    return setmetatable({}, Proxy)
  end

  function InstanceProxies.RemoteEvent(Obj)
    CallbackStorage[Obj] = {}
    local Proxy = {}
    function Proxy:__index(Key)
      if Key == "OnClientEvent" then
        return CallbackStorage[Obj].OnClientEvent
      elseif Key == "OnServerEvent" then
        return CallbackStorage[Obj].OnServerEvent
      end
      return Obj[Key]
    end
    function Proxy:__newindex(Key, Value)
      if Key == "OnClientEvent" or Key == "OnServerEvent" then
        CallbackStorage[Obj][Key] = Value
      else
        Obj[Key] = Value
      end
    end
    return setmetatable({}, Proxy)
  end

  local function NewInstance(ClassName, ...)
    local Obj = Roblox.Instance.new(ClassName, ...)
    CachedInstances[Obj] = "valid"
    if InstanceProxies[ClassName] then
      return InstanceProxies[ClassName](Obj)
    end

    Task.spawn(function()
      local LastParent = Obj.Parent
      if LastParent == nil then
        table.insert(Registry.NilInstances, Obj)
      end
      while Obj do
        if Obj.Parent == nil and LastParent ~= nil then
          if not table.find(Registry.NilInstances, Obj) then
            table.insert(Registry.NilInstances, Obj)
          end
        elseif Obj.Parent ~= nil and LastParent == nil then
          for i, V in ipairs(Registry.NilInstances) do
            if V == Obj then
              table.remove(Registry.NilInstances, i)
              break
            end
          end
        end
        LastParent = Obj.Parent
        Task.wait(0.1)
      end
    end)
    
    print("local " .. Spy:getVarName(Obj) .. " = Instance.new('" .. tostring(ClassName) .. "')")
    return Spy:Instance(Obj)
  end

  local Libraries = {}
  
  for Index, Value in pairs(Roblox) do
    if type(Value) == "table" then
      Libraries[Index] = Value
    end
  end
  
  Libraries.Instance = {}
  Libraries.Instance = {
    new = NewInstance
  }
  
  Libraries.Enum = Roblox.Enum
  
  Roblox.implementProperty("TextButton", "MouseButton1Click", General.MouseButton1Click, function() end)
  Roblox.implementProperty("ImageButton", "MouseButton1Click", General.MouseButton1Click, function() end)

  return Libraries
end)