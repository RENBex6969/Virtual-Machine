return (function(MainDirectory)
  local WrapDirectory = function(Path)
    return MainDirectory .. Path
  end
  
  local Registry = require("@Dep/Registry")
  local Debugger = require("@Dep/Debugger")
  local Utility = require("@Dep/Utility")
  local Serde = require("@lune/serde")
  
  local getLibrary = Utility.getELibrary
  local Compression = getLibrary("Compression")
  local Base64 = getLibrary("Base64")
  local Network = getLibrary("Network")
  local Crypt = getLibrary("Crypt")
  local FileSystem = getLibrary("FileSystem")
  local WebSocket = getLibrary("WebSocket")
  local RConsole = getLibrary("Rconsole")
  local Console = getLibrary("Console")
  local Drawing = getLibrary("Drawing")
  local Mouse = getLibrary("Mouse")
  local Getrawmetatable = getLibrary("Getrawmetatables")
  
  local HiddenProperty = {}
  local scriptableOverrides = {}
  
  Registry.clonerefs = {}
  Registry.CachedInstances = {}
  
  local LCore = Registry.LCore
  local Game = Registry.Game
  
  local CurrentThreadIdentity = {}
  local SecureFolders = {}
  local LockedMT = {}
  
  --[[
    1. Some functions are impossible to implement so lite version are implemented
  ]] 
  
  local ENV; ENV = {
    lz4compress = Compression.LZ4.compress,
    lz4decompress = Compression.LZ4.decompress,
    lz4 = LZ4,
    request = Network.Request,
    http = {
      request = Network.Request
    },
    http_request = Network.Request,
    HttpGet = Network.HttpGet,
    crypt = Crypt,
    syn = {
      request = Network.Request,
      is_beta = function()
        return true
      end,
      protect_gui = function(Instance)
        ENV.protect_gui(Instance)
      end,
      unprotect_gui = function(Instance)
        Instance.Parent = nil
      end,
      cache_invalidate = function(...)
        return ENV.cache.invalidate(...)
      end,
      cache_replace = function(...)
        return ENV.cache.replace(...)
      end,
      is_cached = function(...)
        return ENV.cache.iscached(...)
      end,
      crypt = Crypt,
    },
    WebSocket = {
      connect = WebSocket.connect
    },
    base64 = Crypt.base64,
    base64_encode = Crypt.base64.encode,
    base64_decode = Crypt.base64.decode,
    gettenv = function(Thread)
      assert(Thread, 'Invalid argument #1 to "gettenv", thread expected, but got ' .. type(Thread))
      
      -- A full working gettenv is possible but i dont have time to implement it yet
      local Environment = {}
      for Index, ENV in pairs(Registry.ThreadEnvironments) do
        if Index == Thread then
          Environment = ENV
        end
      end
      
      return setmetatable(Environment, {})
    end,
    getallthreads = function()
      local Threads = {}
      
      for Thread, _ in pairs(Registry.ThreadEnvironments) do
        table.insert(Threads, Thread)
      end
      
      return Threads
    end,
    isdbgpresent = function()
      return true
    end,
    sethiddenproperty = function(Instance, Property, Value)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "sethiddenproperty", instance expected, but got ' .. typeof(Instance))
      assert(type(Property) == "string", 'Invalid argument #2 to "sethiddenproperty", string expected, but got ' .. type(Property))
      assert(Value, 'Invalid argument #3 to "sethiddenproperty", value expected, but got ' .. type(Value))
      
      local InstanceProperty = HiddenProperty[Instance]
      if not InstanceProperty then
        InstanceProperty = {}
        HiddenProperty[Instance] = InstanceProperty
      end
      InstanceProperty[Property] = Value
      return true
    end,
    gethiddenproperty = function(Instance, Property) 
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "gethiddenproperty", instance expected, but got ' .. typeof(Instance))
      assert(type(Property) == "string", 'Invalid argument #2 to "gethiddenproperty", string expected, but got ' .. type(Property))
      
      local InstanceProperty = HiddenProperty[Instance]
      if InstanceProperty and InstanceProperty[Property] then
        return InstanceProperty[Property], true
      end
      
      if Property == "size_xml" and Instance:IsA("Fire") then
        return HiddenProperty[Instance] and HiddenProperty[Instance][Property] or 5, true
      end
      
      return nil, false
    end,
    setproximitypromptduration = function(Prompt, Duration)
      Prompt.HoldDuration = Duration
    end,
    getproximitypromptduration = function(Prompt)
      return Prompt.HoldDuration
    end,
    isexecutorclosure = function(Func)
      assert(type(Func) == "function", 'Invalid argument #1 to "isexecutorclosure", function expected, but got ' .. type(Func))
      
      local src = debug.info(Func, "s") or ""
      src = src:gsub("%s+$", "")
      if src:sub(1, #WrapDirectory("Dependency/Game/")) == WrapDirectory("/Dependency/Game/") then
        return false
      end
      
      if debug.info(Func, "s") == WrapDirectory("Src/ECore") then
        return true
      end
      if debug.info(Func, "s") == WrapDirectory("Src/LCore") then
        return false
      end
      return true
    end,
    checkclosure = function(Func)
      assert(type(Func) == "function", 'Invalid argument #1 to "checkclosure", function expected, but got ' .. type(Func))
      return ENV.isexecutorclosure(Func)
    end,
    isourclosure = function(Func)
      assert(type(Func) == "function", 'Invalid argument #1 to "isourclosure", function expected, but got ' .. type(Func))
      return ENV.isexecutorclosure(Func)
    end,
    cache = {
      iscached = function(Obj)
        assert(typeof(Obj) == "Instance", 'Invalid argument #1 to "cache.iscached", instance expected, but got ' .. typeof(Obj))
        return Registry.CachedInstances[Obj] ~= 'invalid'
      end,
      invalidate = function(Obj)
        assert(typeof(Obj) == "Instance", 'Invalid argument #1 to "cache.invalidate", instance expected, but got ' .. typeof(Obj))
        pcall(function() 
          Registry.CachedInstances[Obj] = 'invalid' 
          Obj.Parent = nil
        end)
      end,
      replace = function(Old, New)
        assert(typeof(Old) == "Instance", 'Invalid argument #1 to "cache.replace", instance expected, but got ' .. typeof(Old))
        assert(typeof(New) == "Instance", 'Invalid argument #2 to "cache.replace", instance expected, but got ' .. typeof(New))
        Registry.CachedInstances[Old] = New
        New.Name = Old.Name
        New.Parent = Old.Parent
        Old.Parent = nil
      end
    },
    isscriptable = function(Instance, Property)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "isscriptable", instance expected, but got ' .. typeof(Instance))
      assert(Property, 'Invalid argument #2 to "isscriptable", value expected, but got ' .. type(Property))
      
      assert(typeof(Instance) == "Instance", "Argument #1 to 'isscriptable' must be an Instance, got " .. typeof(Instance))
      if scriptableOverrides[Instance] and scriptableOverrides[Instance][Property] ~= nil then
        return scriptableOverrides[Instance][Property]
      end
      return select(1, pcall(function()
        return Instance[Property]
      end))
    end,
    setscriptable = function(Instance, Property, Value)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "setscriptable", instance expected, but got ' .. typeof(Instance))
      assert(type(Property) == "string", 'Invalid argument #2 to "setscriptable", string expected, but got ' .. type(Property))
      assert(type(Value) == "boolean", 'Invalid argument #3 to "setscriptable", boolean expected, but got ' .. type(Value))
      
      scriptableOverrides[Instance] = scriptableOverrides[Instance] or {}
      local wasScriptable = ENV.isscriptable(Instance, Property)
      scriptableOverrides[Instance][Property] = Value
      return wasScriptable
    end,
    clonefunction = function(Function)
      assert(type(Function) == "function", 'Invalid argument #1 to "clonefunction", function expected, but got ' .. type(Function))
      
      local Compiled = function(...)
        return Function(...)
      end
      
      if ENV.iscclosure(Compiled) then
        Compiled = ENV.newcclosure(Compiled)
      end
      
      return Compiled
    end,
    newcclosure = function(Func)
      assert(type(Func) == "function", 'Invalid argument #1 to "newcclosure", function expected, but got ' .. type(Func))
      
      -- Yes i made newcclosures using "coroutine" possible to not do it with coroutines but oh well
      local Compiled = coroutine.wrap(function(...)
        local Unpacked = {coroutine.yield()}
        while true do
          Unpacked = {coroutine.yield(Func(table.unpack(Unpacked)))}
        end
      end)
      Compiled()
      
      Registry.CClosures[Func] = true
      return Compiled
    end,
    newlclosure = function(Function)
      assert(type(Function) == "function", 'Invalid argument #1 to "newlclosure", function expected, but got ' .. type(Function))
      
      return function(...)
        return Function(...)
      end
    end,
    iscclosure = function(Function)
      assert(type(Function) == "function", 'Invalid argument #1 to "iscclosure", function expected, but got ' .. type(Function))
      
      if type(Function) ~= "function" or Function == nil then
        return false
      end
      if debug.info(Function, "s") == WrapDirectory("Sandbox") then
        return true
      end
      if debug.info(Function, "s") == "__scheduler_wrap" then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Src/LCore") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Src/ECore") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Src/ExploitLibrary/FileSystem") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Src/ExploitLibrary/Debug") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Src/ExploitLibrary/WebSocket") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Src/ExploitLibrary/Drawing") then
        return true
      end
      if debug.info(Function, "s") == "Missing source" then
        return true
      end
      if debug.info(Function, "s") == "[C]" then
        return true
      end
      table.foreach(Registry.CClosures, function(Func, _)
        if Func == Function then
          return true
        end
      end)
      return false
    end,
    islclosure = function(Function)
      assert(type(Function) == "function", 'Invalid argument #1 to "islclosure", function expected, but got ' .. type(Table))
      
      return ENV.iscclosure(Function) == false
    end,
    setfflags = function(Flag, Value)
      assert(type(Flag) == "string", 'Invalid argument #1 to "setfflags", string expected, but got ' .. type(Flag))
      assert(type(Value) == "string" or type(Value) == "number", 'Invalid argument #2 to "setfflags", string or number expected, but got ' .. type(Table))
      
      local Succ, _ = pcall(function()
        Registry.FFlags[Flag] = Value
      end)
      return Succ
    end,
    cloneref = function(Object)
      assert(typeof(Object) == "Instance", 'Invalid argument #1 to "cloneref", instance expected, but got ' .. type(Table))
      
      if not Registry.clonerefs[Object] then 
        Registry.clonerefs[Object] = {} 
      end
      
      local MT = {
        __tostring = function()
          return Object.Name
        end,
        __index = function(_, Key)
          local Value = getmetatable(Object)[key]
          if type(Value) == 'function' then
            return function(_, ...)
              local Args = (...) or nil
              return Value(Object, Args)
            end
          end
          return Value
        end,
        __newindex = function(_, Key, Value)
          Object[Key] = Value
        end,
        __metatable = getmetatable(Object),
        __len = function(_)
          return #Object
        end
      }
      local Clone = setmetatable({}, MT)
      table.insert(Registry.clonerefs[Object], Clone)
      return Clone
    end,
    getrawmetatable = function(Table)
      assert(type(Table) == "table", 'Invalid argument #1 to "getrawmetatable", table expected, but got ' .. type(Table))
      
      if Registry.RawMetatables[Table] then
        return Registry.RawMetatables[Table]
      end
      return Getrawmetatable(Table)
    end,
    setrawmetatable = function(Table, Metatable)
      assert(type(Table) == "table", 'Invalid argument #1 to "setrawmetatable", table expected, but got ' .. type(Table))
      assert(type(Metatable) == "table", 'Invalid argument #2 to "setrawmetatable", table expected, but got ' .. type(Table))
      
      local MT = Registry.RawMetatables[Table]
      if not MT then
        Registry.RawMetatables[Table] = Metatable
        return setmetatable(Table, Registry.RawMetatables[Table])
      end
      local OldMetatable
      if MT.__metatable then
        OldMetatable = MT.__metatable
        MT.__metatable = nil
      end
      
      Registry.RawMetatables[Table] = Metatable
      local Compiled = setmetatable(Table, Registry.RawMetatables[Table])
      
      if OldMetatable then
        MT.__metatable = OldMetatable
      end
      
      return Compiled
    end,
    setreadonly = function(Table, Status)
      assert(type(Table) == "table", 'Invalid argument #1 to "setreadonly", table expected, but got ' .. type(Table))
      assert(type(Status) == "boolean", 'Invalid argument #2 to "setreadonly", boolean expected, but got ' .. type(Table))
      
      if Table == Game then
        local MT = ENV.getrawmetatable(Game)
        if Status == false then
          MT.__newindex = nil
          ECore.setrawmetatable(Game, MT)
          return
        else
          MT.__newindex = function() end
          ENV.setrawmetatable(Game, MT)
          return
        end
      end
      local MT = ENV.getrawmetatable(Table) or {}
      
      MT.__readonly = Status
      
      local oldNewIndex = MT.__newindex
      MT.__newindex = function(t, k, v)
        if MT.__readonly then
          
        elseif oldNewIndex then
          return oldNewIndex(t, k, v)
        else
          return rawset(t, k, v)
        end
      end
      
      MT.__PAIRS__ = function(t)
        return pairs(t)
      end
      
      MT.__IPAIRS__ = function(t)
        return ipairs(t)
      end
      
      MT.__NEXT__ = function(t, k)
        return next(t, k)
      end
      
      MT.__iter = function(t)
        return next, t, nil
      end
      
      MT.__metatable = MT.__metatable or {}
      
      ENV.setrawmetatable(Table, MT)
      return Table
    end,
    isreadonly = function(Table)
      assert(type(Table) == "table", 'Invalid argument #1 to "isreadonly", table expected, but got ' .. type(Table))
      if type(Table) == "table" then
        local mt = ENV.getrawmetatable(Table)
        if mt and mt.__readonly then
          return true
        end
      end
      return false
    end,
    hookmetamethod = function(Table, Index, New)
      assert(type(Table) == "table", 'Invalid argument #1 to "hookmetamethod", table expected, but got ' .. type(Table))
      assert(type(Index) == "string", 'Invalid argument #2 to "hookmetamethod", string expected, but got ' .. type(Index))
      assert(New, 'Invalid argument #3 to "hookmetamethod", value expected, but got ' .. type(New))
      
      local MT = Registry.RawMetatables[Table]
      if MT then
        local OldMetatable
        if MT.__metatable then
          OldMetatable = MT.__metatable
          MT.__metatable = nil
        end
        local OldFunc = MT[Index]
        MT[Index] = New
        if MT.__metatable then
          MT.__metatable = OldMetatable
        end
        return OldFunc
      end
      return nil
    end,
    getnilinstances = function()
      return Registry.NilInstances
    end,
    compareinstances = function(Target, Check)
      assert(typeof(Target) == "Instance", 'Invalid argument #1 to "compareinstances", instance expected, but got ' .. typeof(Target))
      assert(typeof(Target) == "Instance", 'Invalid argument #2 to "compareinstances", instance expected, but got ' .. typeof(Target))
      if not Registry.clonerefs[Target] then
        return Target == Check
      else
        if table.find(Registry.clonerefs[Target], Check) then 
          return true 
        end
      end
      return false
    end,
    getgc = function()
      local Compiled = {}
      for _, Value in pairs(LCore) do
        table.insert(Compiled, ENV.clonefunction(Value))
      end
      return Compiled
    end,
    filtergc = function(...)
      
    end,
    getsenv = function(Path)
      local Index = function(_, ...)
        return setmetatable({}, {
          __call = function(...)
            return (...)
          end
        })
      end
      
      return setmetatable({
        script = Path
      }, {
        __index = Index
      })
    end,
    getscriptcontext = function(...)
      return {}
    end,
    getscripthash = function(script)
      if not script:IsA("LocalScript") and not script:IsA("ModuleScript") and not script:IsA("Script") then
        return nil
      end
      local source = script.Source or script:GetAttribute("Source")
      if source then
        local hash = Serde.hash("sha384", source)
        return (function(hash)
          return (hash:gsub(".", function(c)
            return string.format("%02x", string.byte(c))
          end))
        end)(hash)
      else
        return nil
      end
    end,
    getscriptbytecode = function(...)
      return "Invalid"
    end,
    dumpstring = function(...)
      return "Invalid"
    end,
    getscriptclosure = function(module)
      return function()
        local original = ENV.getrenv().require(module)
        local function cloneTable(orig)
          local copy = {}
          for k, v in pairs(orig) do
            copy[k] = v
          end
          return copy
        end
        return cloneTable(original)
      end
    end,
    getnamecallmethod = function()
      local funcs = {}
      local Traceback = debug.traceback("")
      for line in Traceback:gmatch("[^\n]+") do
        local name = line:match("function%s+([%w_]+)")
        if name then
          table.insert(funcs, name)
        end
      end
      return Registry.currentNamecall or funcs[1]
    end,
    setnamecallmethod = function(Method)
      assert(type(Method) == "string", 'Invalid argument #1 to "setnamecallmethod", string expected, but got ' .. type(Method))
      Registry.currentNamecall = tostring(Method)
    end,
    getscriptfunction = function(module)
      return ENV.getscriptclosure(module)
    end,
    getfunctionhash = function(Func)
      assert(type(Func) == "function", 'Invalid argument #1 to "getfunctionhash", function expected, but got ' .. type(Func))
      return Serde.hash("sha-512", tostring(Func))
    end,
    getcallbackvalue = function(Object, Property)
      local Value = nil
      pcall(function() 
        Value = Object[Property]
      end)
      return Value
    end,
    fireclickdetector = function(ClickDetector, distance, EventType)
      assert(ClickDetector and ClickDetector.MouseClick, 'Invalid argument #1 to "fireclickdetector", clickdetector expected, but got ' .. typeof(ClickDetector))
      local eventToFire
      if EventType and typeof(EventType) == "string" and ClickDetector[EventType] then
        eventToFire = ClickDetector[EventType]
      else
        eventToFire = ClickDetector.MouseClick
      end
      
      assert(eventToFire, 'Invalid argument #1 to "fireclickdetector", event on clickdetector expected, but got nil')
      
      if type(eventToFire.Fire) == "function" then
        eventToFire:Fire(Game.Players.LocalPlayer)
      else
        ENV.firesignal(eventToFire)
      end
    end,
    fireproximityprompt = function(ProxPrompt)
      ProxPrompt.Triggered:Fire(Game.Players.LocalPlayer)
    end,
    getconnections = function(signal)
      for obj, data in pairs(Registry.CallbackStorage) do
        if data.Event == signal then
          return data.Connections or {}
        end
      end
      return {}
    end,
    firesignal = function(Signal, ...)
      for obj, data in pairs(Registry.CallbackStorage) do
        if data.Event == Signal and data.Connections then
          for _, conn in ipairs(data.Connections) do
            if conn.Enabled then
              conn.Function(...)
            end
          end
        end
      end
    end,
    firetouchinterest = function(Interest, With, Status)
      error("Firetouchinterest not implememted", 2)
    end,
    secure_call = function(Function, Environment, ...)
      assert(type(Function) == "function", 'Invalid argument #1 to "secure_call", function expected, but got ' .. typeof(Function))
      assert(type(Environment) == "table", 'Invalid argument #2 to "secure_call", table expected, but got ' .. typeof(Environment))
      local Arguments = {...}
      
      return Function(...)
    end,
    identifyexecutor = function()
      return "Virtual Machine", "@/1.0"
    end,
    getexecutorname = function()
      return "Virtual Machine", "@/1.0"
    end,
    printidentity = function()
      return print("[VM]: Current identity is " .. Registry.CurrentThreadIdentity)
    end,
    isrbxactive = function()
      return true
    end,
    isgameactive = function()
      return true
    end,
    isrenderobj = function(Obj)
      assert(type(Obj) == "userdata", 'Invalid argument #1 to "isrenderobj", userdata expected, but got ' .. typeof(Obj))
      
      for _, Object in pairs(Registry.DrawingCache) do
        if Object == Obj then
          return true
        end
      end
      
      return false
    end,
    cleardrawcache = function()
      
      DrawingCache = {}
    end,
    getrenderproperty = function(Object, Value)
      assert(ENV.isrenderobj(Object), 'Invalid argument #1 to "getrenderproperty", render object expected, but got ' .. typeof(Object))
      
      return Object[Value]
    end,
    setrenderproperty = function(Object, Index, Data)
      assert(ENV.isrenderobj(Object), 'Invalid argument #1 to "setrenderproperty", render object expected, but got ' .. typeof(Object))
      Object[Index] = Data
    end,
    is_secured_instance = function(Instance)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "is_secured_instance", instance expected, but got ' .. typeof(Object))
      return Registry.SecuredInstances[Instance]
    end,
    set_normal_instance = function(Instance)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "set_normal_instance", instance expected, but got ' .. typeof(Object))
      local Succ, _ = pcall(function()
        Registry.SecuredInstances[Instance] = false
      end)
      if Succ then
        return false
      else
        return true
      end
    end,
    set_secure_instance = function(Instance)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "set_secure_instance", instance expected, but got ' .. typeof(Object))
      local Succ, _ = pcall(function()
        Registry.SecuredInstances[Instance] = false
      end)
      if Succ then
        return false
      else
        return true
      end
    end,
    create_secure_folder = function(Path)
      assert(type(Path) == "string", 'Invalid argument #1 to "create_secure_folder", string expected, but got ' .. typeof(Object))
      local Parts = string.split(Path, "/")
      local Current = SecureFolders
      for _, Name in ipairs(Parts) do
        if not Current[Name] then
          Current[Name] = {
            Folder = Instance.new("Folder")
          }
          Current[Name].Folder.Name = Name
          Current[Name].Folder.Parent = ENV.gethui()
        end
        Current = Current[Name]
      end
      return Current.Folder
    end,
    isnetworkowner = function(Instance)
      assert(typeof(Instance) == "Instance", 'Invalid argument #1 to "isnetworkowner", instance expected, but got ' .. typeof(Object))
      return true
    end,
    setfpscap = function(Cap)
      assert(type(Cap) == "number", 'Invalid argument #1 to "setfpscap", number expected, but got ' .. type(Cap))
      Registry.FpsCap = Cap
    end,
    getfpscap = function()
      return Registry.FpsCap
    end,
    setclipboard = function(Text)
      Registry.Clipboard = tostring(Text)
    end,
    toclipboard = function(Text)
      Registry.Clipboard = tostring(Text)
    end,
    setrbxclipboard = function(Text)
      Registry.Clipboard = tostring(Text)
    end,
    getclipboard = function()
      return Registry.Clipboard
    end,
    queueonteleport = function(Script)
      assert(type(Script) == "string", 'Invalid argument #1 to "queueonteleport", string expected, but got ' .. typeof(Script))
      return
    end,
    queue_on_teleport = function(Script)
      assert(type(Script) == "string", 'Invalid argument #1 to "queue_on_teleport", string expected, but got ' .. typeof(Script))
      return
    end,
    getgenv = function()
      return setmetatable(ENV, {
        __newindex = function(_, Key, Value)
          rawset(Registry.GlobalVariables, Key, Value)
          rawset(ENV, Key, Value)
        end
      })
    end,
    setfenv = function(Arg, Environment)
      if type(Arg) == "number" then
        setfenv(2 + tonumber(Arg or 0), Environment)
      elseif type(Arg) == "function" then
        if ENV.iscclosure(Arg) == true then
          error("cannot inspect c")
        end
        setfenv(Arg, Environment)
      end
    end,
    getcustomasset = function(File)
      assert(type(File) == "string", 'Invalid argument #1 to "getcustomasset", string expected, but got ' .. type(File))
      return "rbxasset://textures/tempfile"
    end,
    gethwid = function()
      return Registry.HWID
    end,
    getdevice = function()
      return "Linux"
    end,
    getos = function()
      return "Linux"
    end,
    isluau = function()
      return true
    end,
    islua = function()
      return false
    end,
    printreg = function()
      print(Registry.GlobalVariables)
    end,
    Drawing = Drawing,
    _VERSION = "Luau"
  }
  
  local Debug = getLibrary("Debug")(ENV)
  ENV.debug = Debug
  table.foreach(FileSystem, function(Index, Value)
    ENV[Index] = Value
  end)
  
  table.foreach(RConsole, function(Index, Value)
    ENV[Index] = Value
  end)
  
  table.foreach(Console, function(Index, Value)
    ENV[Index] = Value
  end)
  
  table.foreach(Mouse, function(Index, Value)
    ENV[Index] = Value
  end)
  
  local CurrentThreadIdentity = {}
  
  local function setIdentity(Lvl)
    CurrentThreadIdentity[coroutine.running()] = Lvl
  end
  
  local function getIdentity()
    return CurrentThreadIdentity[coroutine.running()] or 9
  end
  
  local ThreadManagement = {
    "setthreadidentity", 
    "getthreadidentity",
    "setthreadcontext", 
    "getthreadcontext",
    "set_thread_context", 
    "get_thread_context",
    "set_thread_identity",
    "get_thread_identity",
    "setidentity", 
    "getidentity",
  }
  
  for _, name in ipairs(ThreadManagement) do
    if name:sub(1, 3) == "set" then
      ENV[name] = function(Lvl)
        assert(type(Lvl) == "number", 'Invalid argument #1 to ' .. name .. ', number expected, but got ' .. type(Lvl))
        return setIdentity(Lvl)
      end
    else
      ENV[name] = getIdentity
    end
  end
  
  return ENV
end)