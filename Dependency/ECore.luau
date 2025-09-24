return (function(MainDirectory)
  local WrapDirectory = function(Path)
    return MainDirectory .. Path
  end
  local Utility = require("./Utility")
  local Serde = require("@lune/serde")
  
  local getLibrary = Utility.getELibrary
  local Registry = Utility.getModule("Registry")
  local Debugger = Utility.getModule("Debugger")
  local Compression = getLibrary("Compression")
  local Base64 = getLibrary("Base64")
  local Network = getLibrary("Network")
  local Crypt = getLibrary("Crypt")
  local FileSystem = getLibrary("FileSystem")
  local WebSocket = getLibrary("WebSocket")
  local RConsole = getLibrary("Rconsole")
  local Console = getLibrary("Console")
  local Drawing = getLibrary("Drawing")(Utility)
  local Mouse = getLibrary("Mouse")
  local Getrawmetatable = getLibrary("Getrawmetatables")
  
  local HiddenProperty = {}
  local scriptableOverrides = setmetatable({}, { __mode = "k" })
  
  Registry.clonerefs = {}
  Registry.CachedInstances = {}
  local LCore = Registry.LCore
  local Game = Registry.Game
  
  local CurrentThreadIdentity = {}
  local SecureFolders = {}
  local LockedMT = {}
  
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
    setthreadidentity = function(Lvl)
      CurrentThreadIdentity[coroutine.running()] = Lvl
    end,
    getthreadidentity = function()
      return CurrentThreadIdentity[coroutine.running()] or 9
    end,
    setidentity = function(Lvl)
      CurrentThreadIdentity[coroutine.running()] = Lvl
    end,
    getidentity = function()
      return CurrentThreadIdentity[coroutine.running()] or 9
    end,
    setthreadcontext = function(Lvl)
      CurrentThreadIdentity[coroutine.running()] = Lvl
    end,
    getthreadcontext = function()
      return CurrentThreadIdentity[coroutine.running()] or 9
    end,
    set_thread_context = function(Lvl)
      CurrentThreadIdentity[coroutine.running()] = Lvl
    end,
    get_thread_context = function()
      return CurrentThreadIdentity[coroutine.running()] or 9
    end,
    gettenv = function(Thread)
      
    end,
    isdbgpresent = function()
      return true
    end,
    sethiddenproperty = function(Instance, Property, Value)
      local InstanceProperty = HiddenProperty[Instance]
      if not InstanceProperty then
        InstanceProperty = {}
        HiddenProperty[Instance] = InstanceProperty
      end
      InstanceProperty[Property] = Value
      return true
    end,
    gethiddenproperty = function(Instance, Property) 
      local InstanceProperty = HiddenProperty[Instance]
      if InstanceProperty and InstanceProperty[Property] then
        return InstanceProperty[Property], true
      end
      if Property == "size_xml" and Instance:IsA("Fire") then
        return HiddenProperty[Instance] and HiddenProperty[Instance][Property] or 5, true
      end
      return nil, false
    end,
    isexecutorclosure = function(fn)
      local src = debug.info(fn, "s") or ""
      src = src:gsub("%s+$", "")
      if src:sub(1, #"/host-env/Dependency/Game/") == "/host-env/Dependency/Game/" then
        return false
      end
      if debug.info(fn, "s") == "/host-env/Dependency/ECore" then
        return true
      end
      if debug.info(fn, "s") == "/host-env/Dependency/LCore" then
        return false
      end
      return true
    end,
    checkclosure = function(fn)
      return ENV.isexecutorclosure(fn)
    end,
    isourclosure = function(fn)
      return ENV.isexecutorclosure(fn)
    end,
    cache = {
      iscached = function(Obj)
        return Registry.CachedInstances[Obj] ~= 'invalid'
      end,
      invalidate = function(Obj)
        pcall(function() 
          Registry.CachedInstances[Obj] = 'invalid' 
          Obj.Parent = nil
        end)
      end,
      replace = function(Old, New)
        Registry.CachedInstances[Old] = New
        New.Name = Old.Name
        New.Parent = Old.Parent
        Old.Parent = nil
      end
    },
    isscriptable = function(Instance, Property)
      assert(typeof(Instance) == "Instance", "Argument #1 to 'isscriptable' must be an Instance, got " .. typeof(Instance))
      if scriptableOverrides[Instance] and scriptableOverrides[Instance][Property] ~= nil then
        return scriptableOverrides[Instance][Property]
      end
      return select(1, pcall(function()
        return Instance[Property]
      end))
    end,
    setscriptable = function(Instance, Property, Value)
      assert(typeof(Instance) == "Instance", "Argument #1 must be an Instance")
      assert(type(Property) == "string", "Argument #2 must be a string")
      assert(type(Value) == "boolean", "Argument #3 must be a boolean")
      scriptableOverrides[Instance] = scriptableOverrides[Instance] or {}
      local wasScriptable = ENV.isscriptable(Instance, Property)
      scriptableOverrides[Instance][Property] = Value
      return wasScriptable
    end,
    clonefunction = function(Function)
      local Compiled = function(...)
        return Function(...)
      end
      return Compiled
    end,
    newcclosure = function(Func)
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
      local Compiled = function(...)
        return Function(...)
      end
      return Compiled
    end,
    iscclosure = function(Function)
      if type(Function) ~= "function" or Function == nil then
        return false
      end
      if debug.info(Function, "s") == WrapDirectory("Sandbox") then
        return true
      end
      if debug.info(Function, "s") == "__scheduler_wrap" then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Dependency/LCore") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Dependency/ECore") then
        return true
      end
      if debug.info(Function, "s") == WrapDirectory("Dependency/ExploitLibrary/FileSystem") then
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
      if type(Function) ~= "function" or Function == nil then
        return false
      end
      if debug.info(Function, "s") == WrapDirectory("Sandbox") then
        return false
      end
      if debug.info(Function, "s") == "__scheduler_wrap" then
        return false
      end
      if debug.info(Function, "s") == WrapDirectory("Dependency/LCore") then
        return false
      end
      if debug.info(Function, "s") == WrapDirectory("Dependency/ECore") then
        return false
      end
      if debug.info(Function, "s") == WrapDirectory("Dependency/ExploitLibrary/FileSystem") then
        return false
      end
      if debug.info(Function, "s") == "Missing source" then
        return false
      end
      if debug.info(Function, "s") == "[C]" then
        return false
      end
      table.foreach(Registry.CClosures, function(Func, _)
        if Func == Function then
          return false
        end
      end)
      return true
    end,
    setfflags = function(Flag, Status)
      local Succ, _ = pcall(function()
        Registry.FFlags[Flag] = Status
      end)
      return Succ
    end,
    cloneref = function(Object)
      if typeof(Object) ~= "Instance" or Object == nil then
        return false
      end
      if not Registry.clonerefs[Object] then 
        Registry.clonerefs[Object] = {} 
      end
      local Clone = {}
      local MT = {
        __type = "Instance",
        __tostring = function()
          return Object.Name
        end,
        __index = function(_, Key)
          local MT = getmetatable(Object)[Key]
          if type(Obj) == 'function' then
            return function(...)
              return Obj(Object, ...)
            end
          else
            return MT
          end
        end,
        __newindex = function(_, key, value)
          Object[key] = value
        end,
        __metatable = getmetatable(Object),
        __len = function(_)
          return error('attempt to get length of Object userdata value')
        end
      }
      setmetatable(Clone, MT)
      table.insert(Registry.clonerefs[Object], Clone)
      return Clone
    end,
    setreadonly = function(Table, Status)
      
    end,
    isreadonly = function(Table)
      if type(Table) == "table" then
        return table.isfrozen(Table)
      end
      return false
    end,
    getrawmetatable = function(Table)
      if Registry.RawMetatables[Table] then
        return Registry.RawMetatables[Table]
      end
      local Copied = Getrawmetatable(Table)
      return Copied
    end,
    setrawmetatable = function(Table, Metatable)
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
    hookmetamethod = function(Table, Index, New)
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
    getsenv = function(Path)
      return setmetatable({
        script = Path
      }, {__index = {
        OnRunning = function() end
      }})
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
    getscriptbytecode = function()
      return "Invalid"
    end,
    dumpstring = function()
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
      local Traceback = debug.traceback("", i)
      for line in Traceback:gmatch("[^\n]+") do
        local name = line:match("function%s+([%w_]+)")
        if name then
          table.insert(funcs, name)
        end
      end
      return Registry.currentNamecall or funcs[1]
    end,
    setnamecallmethod = function(Method)
      Registry.currentNamecall = tostring(Method)
    end,
    getscriptfunction = function(module)
      return ENV.getscriptclosure(module)
    end,
    getcallbackvalue = function(Object, Property)
      local Value = nil
      pcall(function() 
        Value = Object[Property]
      end)
      return Value
    end,
    fireclickdetector = function(ClickDetector, distance, EventType)
      assert(ClickDetector and ClickDetector.MouseClick, "First argument is not ClickDetector")
      local eventToFire
      if EventType and typeof(EventType) == "string" and ClickDetector[EventType] then
        eventToFire = ClickDetector[EventType]
      else
        eventToFire = ClickDetector.MouseClick
      end
      assert(eventToFire, "Event not found on ClickDetector")
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
    firetouchinterest = function(...)
      error("Firetouchinterest not implememted", 2)
    end,
    secure_call = function(Function, _, ...)
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
      for _, Object in pairs(Registry.DrawingCache) do
        if Object.proxy == Obj then
          return true
        end
      end
      return false
    end,
    cleardrawcache = function()
      for _, Object in next, Registry.DrawingCache do
        Object.instance:Destroy()
      end
      DrawingCache = {}
    end,
    getrenderproperty = function(Object, Value)
      assert(ENV.isrenderobj(Object), "Invalid argument #1 to 'getrenderproperty', render object expected, got " .. typeof(Object))
      return Object[Value]
    end,
    setrenderproperty = function(Object, Index, Data)
      assert(ENV.isrenderobj(Object), "Invalid argument #1 to 'setrenderproperty', render object expected, got " .. typeof(Object))
      Object[Index] = Data
    end,
    is_secured_instance = function(Instance)
      return Registry.SecuredInstances[Instance]
    end,
    set_normal_instance = function(Instance)
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
      return true
    end,
    setfpscap = function(Cap)
      Registry.FpsCap = Cap
    end,
    getfpscap = function(Cap)
      return Registry.FpsCap
    end,
    setclipboard = function(Text)
      Registry.Clipboard = Text
    end,
    toclipboard = function(Text)
      Registry.Clipboard = Text
    end,
    setrbxclipboard = function(Text)
      Registry.Clipboard = Text
    end,
    getclipboard = function(Text)
      return Registry.Clipboard
    end,
    queueonteleport = function(...)
      return
    end,
    queue_on_teleport = function(...)
      return
    end,
    getgenv = function()
      return setmetatable(ENV, {
        __newindex = function(_, Key, Value)
          Registry.GlobalVariables[Key] = Value
          rawset(ENV, Key, Value)
        end
      })
    end,
    getfenv = function(Args)
      if type(Args) == "number" then
        return getfenv(2 + (Args or 0))
      end
      local ECore, MT = require("../Sandbox"):Create()
      return setmetatable({
        script = "Script"
      }, {
        __index = setmetatable(ECore, MT)
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
      return "rbxasset://textures/tempfile"
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
    Drawing = Drawing,
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
      ENV[name] = setIdentity
    else
      ENV[name] = getIdentity
    end
  end
  
  return ENV
end)