local RbxScriptSignal = require("@Dep/RbxScriptSignal")
local Parser = require("./Parser")
local Roblox = require("@lune/roblox")
local Regex = require("@lune/regex")
local Network = require("@lune/net")
local Serde = require("@lune/serde")

local Database = Roblox.getReflectionDatabase()
local DataModel = Roblox.Instance.new("DataModel")
local Enum = Roblox.Enum

local Content = Network.request({
  url = "https://github.com/MaximumADHD/Roblox-Client-Tracker/raw/refs/heads/roblox/Full-API-Dump.json",
  method = "GET"
}).body

local APIDump = Serde.decode("json", Content)
local RegexService = Regex.new("Service")

local EnableDebug = false
local function Warn(Message : any?): nil
  if EnableDebug then
    warn(Message)
  end
end

local function HasNoDefault(Default : string): boolean
  local No = {
    ["__api_dump_no_string_value__"] = true,
    ["__api_dump_skipped_class__"] = true,
    ["__api_dump_class_not_creatable__"] = true,
    ["__api_dump_failed_to_create_class__"] = true,
    ["__api_dump_write_only_property__"] = true
  }
  
  return No[Default] == true
end

local function DefaultValue(Member : table): any?
  local Default = Member.Default
  local ValueType = Member.ValueType
  local Category = ValueType.Category
  local TypeName = ValueType.Name
  
  if HasNoDefault(Default) then
    if Category == "Primitive" then
      if TypeName == "bool" then
        return math.random(1, 2) == 1
      end
      
      if TypeName == "string" then
        return ""
      end
      
      if TypeName == "int" then
        return math.random(1, 2)
      end
      
      if TypeName == "int64" then
        return math.random(1, 2)
      end
      
      if TypeName == "float" then
        return math.random()
      end
      
      if TypeName == "double" then
        return math.random()
      end
      
      Warn("Missing handler for No-Default Primitive for " .. TypeName)
    end
    
    if Category == "DataType" then
      local DataType = Roblox[TypeName]
      if not DataType then
        return nil
      end
      
      if TypeName == "Axes" then
        return DataType.new()
      end
      
      if TypeName == "BrickColor" then
        return DataType.new("White")
      end
      
      if TypeName == "CFrame" then
        return DataType.new(Roblox.Vector3.new(0, 0, 0))
      end
      
      if TypeName == "Color3" then
          return DataType.new(0, 0, 0)
      end
      
      if TypeName == "ColorSequence" then
        return DataType.new({
          DataType.ColorSequenceKeypoint.new(0, Color3.new(0,0,0))
        })
      end
      
      if TypeName == "ColorSequenceKeypoint" then
        return DataType.new(0, Color3.new(0,0,0))
      end
      
      if TypeName == "Faces" then
        return DataType.new()
      end
      
      if TypeName == "Font" then
        return Enum.Font.SourceSans
      end
      
      if TypeName == "NumberRange" then
        return DataType.new(0, 0)
      end
      
      if TypeName == "NumberSequence" then
        return DataType.new({DataType.NumberSequenceKeypoint.new(0, 0)})
      end
      
      if TypeName == "NumberSequenceKeypoint" then
        return DataType.new(0, 0)
      end
      
      if TypeName == "PhysicalProperties" then
        return DataType.new(0, 0, 0, 0, 0)
      end
      
      if TypeName == "Ray" then
        return DataType.new(Roblox.Vector3.new(0,0,0), Roblox.Vector3.new(0,0,1))
      end
      
      if TypeName == "Rect" then
        return DataType.new(Roblox.Vector2.new(0, 0), Roblox.Vector2.new(0, 0))
      end
      
      if TypeName == "Region3" then
        return DataType.new(Roblox.Vector3.new(0,0,0), Roblox.Vector3.new(0,0,0))
      end
      
      if TypeName == "Region3int16" then
        return DataType.new(Roblox.Vector3int16.new(0,0,0), Roblox.Vector3int16.new(0,0,0))
      end
      
      if TypeName == "UDim" then
        return DataType.new(0, 0)
      end
      
      if TypeName == "UDim2" then
        return DataType.new(0, 0, 0, 0)
      end
      
      if TypeName == "Vector2" then
        return DataType.new(0, 0)
      end
      
      if TypeName == "Vector2int16" then
        return DataType.new(0, 0)
      end
      
      if TypeName == "Vector3" then
        return DataType.new(0, 0, 0)
      end
      
      if TypeName == "Vector3int16" then
        return DataType.new(0, 0, 0)
      end
      
      if TypeName == "PhysicalProperties" then
        return DataType.new(0, 0, 0, 0, 0)
      end
      
      if TypeName == "UniqueId" then
        return DataType.null
      end
      
      if TypeName == "Content" then
        return DataType.none
      end
      
      Warn("Missing handler for No-Default DataType for " .. TypeName)
    end
    
    if Category == "Enum" then
      local Succ, Enum = pcall(function()
        local Items = Enum[TypeName]:GetEnumItems()
        
        return Items[math.random(1, #Items)]
      end)
      
      if Succ then
        return Enum
      else
        Warn(string.format("Missing No-Default Enum.%s", TypeName))
        return nil
      end
    end
    
    return nil
  end
  
  if Category == "Primitive" then
    if TypeName == "bool" then
      if Default == "true" then
        return true
      else
        return false
      end
    end
    
    if TypeName == "string" then
      return Default
    end
    
    if TypeName == "int" then
      return tonumber(Default)
    end
    
    if TypeName == "int64" then
      return tonumber(Default)
    end
    
    if TypeName == "float" then
      return tonumber(Default)
    end
    
    if TypeName == "double" then
      return tonumber(Default)
    end
    
    Warn("Missing handler for Primitive for " .. TypeName)
  end
  
  if Category == "DataType" then
    local DataType = Roblox[TypeName]
    if not DataType then
      return nil
    end
    
    if TypeName == "Axes" then
      local AxesList = {}
      if Default:find("X") then 
        table.insert(AxesList, Enum.Axis.X) 
      end
      
      if Default:find("Y") then 
        table.insert(AxesList, Enum.Axis.Y) 
      end
      if Default:find("Z") then 
        table.insert(AxesList, Enum.Axis.Z) 
      end
      
      return DataType.new(unpack(AxesList))
    end
    
    if TypeName == "Color3" then
      local R, G, B = Parser:Triple(Default)
      return DataType.new(R, G, B)
    end
    
    if TypeName == "ColorSequence" then
      local T1, R1, G1, B1, A1, T2, R2, G2, B2, A2 = Parser:Decuple(Default)
      local Keypoints = {
        Roblox.ColorSequenceKeypoint.new(T1, Roblox.Color3.new(R1, G1, B1), A1),
        Roblox.ColorSequenceKeypoint.new(T2, Roblox.Color3.new(R2, G2, B2), A2)
      }
      
      return DataType.new(Keypoints)
    end
    
    if TypeName == "ColorSequenceKeypoint" then
      local T, R, G, B = Parser:Quadruple(Default)
      return DataType.new(T, Roblox.Color3.new(R, G, B))
    end
    
    if TypeName == "Faces" then
      local FacesList = {}
      if Default:find("Right") then 
        table.insert(FacesList, Enum.NormalId.Right) 
      end
      
      if Default:find("Top") then 
        table.insert(FacesList, Enum.NormalId.Top)
      end
      
      if Default:find("Back") then 
        table.insert(FacesList, Enum.NormalId.Back) 
      end
      
      if Default:find("Left") then 
        table.insert(FacesList, Enum.NormalId.Left) 
      end
      
      if Default:find("Bottom") then 
        table.insert(FacesList, Enum.NormalId.Bottom) 
      end
      
      if Default:find("Front") then 
        table.insert(FacesList, Enum.NormalId.Front) 
      end
      
      return DataType.new(unpack(FacesList))
    end
    
    if TypeName == "NumberRange" then
      local Min, Max = Parser:Pair(Default)
      return DataType.new(Min, Max)
    end
    
    if TypeName == "NumberSequence" then
      local T1, V1, E1, T2, V2, E2 = Parser:Hexuple(Default)
      local Keypoints = {
        Roblox.NumberSequenceKeypoint.new(T1, V1, E1),
        Roblox.NumberSequenceKeypoint.new(T2, V2, E2)
      }
      
      return DataType.new(Keypoints)
    end
    
    if TypeName == "NumberSequenceKeypoint" then
      local Time, Value, Envelope = Parser:Triple(Default)
      return DataType.new(Time, Value, Envelope)
    end
    
    if TypeName == "PhysicalProperties" then
      if Default == "default" then
        return DataType.new(0, 0, 0, 0, 0)
      end
      
      local Density, Friction, Elasticity, FrictionWeight, ElasticityWeight = Parser:Quintuple(Default)
      return DataType.new(Density, Friction, Elasticity, FrictionWeight, ElasticityWeight)
    end
    
    if TypeName == "Ray" then
      local OriginX, OriginY, OriginZ, DirX, DirY, DirZ = Parser:PairOfTriples(Default)
      local Origin = Roblox.Vector3.new(OriginX, OriginY, OriginZ)
      local Direction = Roblox.Vector3.new(DirX, DirY, DirZ)
      
      return DataType.new(Origin, Direction)
    end
    
    if TypeName == "Rect" then
      local X1, Y1, X2, Y2 = Parser:Quadruple(Default)
      return DataType.new(Roblox.Vector2.new(X1, Y1), Roblox.Vector2.new(X2, Y2))
    end
    
    if TypeName == "UDim" then
      local Scale, Offset = Parser:Pair(Default)
      return DataType.new(Scale, Offset)
    end
    
    if TypeName == "UDim2" then
      local ScaleX, OffsetX, ScaleY, OffsetY = Parser:TwoPair(Default)
      return DataType.new(ScaleX, OffsetX, ScaleY, OffsetY)
    end
    
    if TypeName == "Vector2" then
      local X, Y = Parser:Pair(Default)
      return DataType.new(X, Y)
    end
    
    if TypeName == "Vector2int16" then
      local X, Y = Parser:Pair(Default)
      return DataType.new(X, Y)
    end
    
    if TypeName == "Vector3" then
      local X, Y, Z = Parser:Triple(Default)
      return DataType.new(X, Y, Z)
    end
    
    if TypeName == "Vector3int16" then
      local X, Y, Z = Parser:Triple(Default)
      return DataType.new(X, Y, Z)
    end

    if TypeName == "UniqueId" then
      return DataType.null
    end
    
    if TypeName == "Content" then
      return DataType.none
    end
    
    Warn("Missing handler for No-Default DataType for " .. TypeName)
  end
  
  if Category == "Enum" then
    local Succ, Result = pcall(function()
      return Enum[TypeName][Default]
    end)
    
    if not Succ then
      Warn(string.format("Missing Enum.%s.%s", TypeName, Default))
      return nil
    end
    
    return Result
  end
  
  return nil
end

local IdentityMap = { 
  [1] = {"LocalGui", {
    "PluginSecurity", 
    "None", 
    "LocalUserSecurity"
  }},
  [2] = {"GameScript", {
    "None"
  }},
  [3] = {"CoreScript", {
    "PluginSecurity", 
    "None", 
    "LocalUserSecurity", 
    "RobloxScriptSecurity"
  }},
  [4] = {"CommandBar", {
    "PluginSecurity", 
    "None", 
    "LocalUserSecurity"
  }},
  [5] = {"StudioPlugin", {
    "PluginSecurity", 
    "None"
  }},
  [6] = {"ElevatedStudioPlugin", {
    "PluginSecurity", 
    "None", 
    "LocalUserSecurity", 
    "RobloxScriptSecurity"
  }},
  [7] = {"COM", {
    "PluginSecurity", 
    "None", 
    "LocalUserSecurity", 
    "WritePlayerSecurity", 
    "RobloxScriptSecurity", 
    "RobloxSecurity", 
    "NotAccessable"
  }},
  [8] = {"WebService", {
    "PluginSecurity", 
    "None", 
    "LocalUserSecurity", 
    "WritePlayerSecurity", 
    "RobloxScriptSecurity", 
    "RobloxSecurity", 
    "NotAccessable"
  }},
  [9] = {"Replicator", {
    "WritePlayerSecurity", 
    "None", 
    "RobloxScriptSecurity"
  }},
  [0] = {"Anonymous", {}},
  [-1] = {"InvalidIdentity", {}}
}

local function GetMinimumIdentity(Security)
  local function Search(Name)
    local MinimumIdentity = nil
    for Identity, Data in pairs(IdentityMap) do
      local SecurityList = Data[2]
      for _, Security in ipairs(SecurityList) do
        if Security == Name then
          if not MinimumIdentity or Identity < MinimumIdentity then
            MinimumIdentity = Identity
          end
          break
        end
      end
    end
    return MinimumIdentity
  end

  if type(Security) == "string" then
    return Search(Security)
  elseif type(Security) == "table" then
    local minRead = Security.Read and Search(Security.Read) or nil
    local minWrite = Security.Write and Search(Security.Write) or nil
    
    return minRead, minWrite
  end
  
  return nil
end

local CurrentIdentity = 0
local IgnoredClasses = {}

local function MakeSignal(ClassName : string?, Member : table, MinimumIdentity : number): nil
  local Signal, Master = RbxScriptSignal.Signal()
  
  Roblox.implementProperty(ClassName, Member.Name, function()
    if MinimumIdentity > CurrentIdentity then
      error(string.format("Caller identity insufficient, got %s expected %s", Identity, MinimumIdentity))
      return nil
    end
    
    return Signal
  end)
end

local function MakeFunction(ClassName : string?, Member : table, MinimumIdentity : number): nil
  local Handler = false or function(...)
    -- Stub
  end
  
  Roblox.implementMethod(ClassName, Member.Name, function(...)
    if MinimumIdentity > CurrentIdentity then
      error(string.format("Caller identity insufficient, got %s expected %s", Identity, MinimumIdentity))
      return nil
    end
    
    return Handler(...)
  end)
end

local function MakeProperty(ClassName : string?, Member : table, Default, ReadIdentity : number, WriteIdentity : number): nil
  Roblox.implementProperty(ClassName, Member.Name, function()
    if MinimumIdentity > CurrentIdentity then
      error(string.format("Caller identity insufficient, got %s expected %s", Identity, MinimumIdentity))
      return nil
    end
    
    return Default
  end, function()
    if MinimumIdentity > CurrentIdentity then
      error(string.format("Caller identity insufficient, got %s expected %s", Identity, MinimumIdentity))
      return nil
    end
    
    Warn("no op set")
  end)
end

local TotalServices = 0
local TotalOthers = 0
for i, Class in APIDump.Classes do
  local ClassName = Class.Name
  
  if IgnoredClasses[ClassName] then
    Warn(string.format("Ignoring class %q", ClassName))
  else
    if RegexService:isMatch(ClassName) then
      for _, Member in Class.Members do
        local TypeName = Member.MemberType
        
        if TypeName == "Function" then
          local Identity = GetMinimumIdentity(Member.Security)
          
          MakeFunction(ClassName, Member, Identity)
        elseif TypeName == "Event" then
          local Identity = GetMinimumIdentity(Member.Security)
          
          MakeSignal(ClassName, Member, Identity)
        elseif TypeName == "Property" then
          local Default = DefaultValue(Member)
          
          if Default then
            local ReadIdentity, WriteIdentity = GetMinimumIdentity(Member.Security)
            local Succ, _ = pcall(function()
              DataModel:GetService(ClassName)[Member.Name] = Default
            end)
            
            MakeProperty(ClassName, Member, Default, ReadIdentity, WriteIdentity)
          else
            Warn("no default")
          end
        end
      end
      TotalServices += 1
    else
      for _, Member in Class.Members do
        local TypeName = Member.MemberType
        if TypeName == "Function" then
          local Identity = GetMinimumIdentity(Member.Security)
          
          MakeFunction(ClassName, Member, Identity)
        elseif TypeName == "Event" then
          local Identity = GetMinimumIdentity(Member.Security)
          
          MakeSignal(ClassName, Member, Identity)
        elseif TypeName == "Property" then
          local Default = DefaultValue(Member)
          
          if Default then
            local ReadIdentity, WriteIdentity = GetMinimumIdentity(Member.Security)
            local Succ, _ = pcall(function()
              DataModel:GetService(ClassName)[Member.Name] = Default
            end)
            
            MakeProperty(ClassName, Member, Default, ReadIdentity, WriteIdentity)
          else
            Warn("no default")
          end
        end
      end
      TotalOthers += 1
    end
  end
end

print(string.format("Total Services, Others : %d, %d | Total : %d", TotalServices, TotalOthers, TotalServices + TotalOthers))