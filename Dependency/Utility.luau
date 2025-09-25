local Utility = {}

local next = next
local type = type
local select = select
local require = require

Utility.getModule = function(Module)
  return require("./" .. Module)
end

Utility.getLLibrary = function(Library)
  return require("@Src/LuauLibrary/" .. Library)
end

Utility.getELibrary = function(Library)
  return require("@Src/ExploitLibrary/" .. Library)
end

local function DeepMerge(Target, Source, maxIndex)
  local maxIndex = maxIndex or 0
  for Key, Value in next, Source do
    if type(Key) == "number" then
      maxIndex += 1
      Target[maxIndex] = Value
    elseif type(Value) == "table" then
      local TargetValue = Target[Key]
      if TargetValue ~= nil and type(TargetValue) == "table" then
        DeepMerge(TargetValue, Value)
      else
        Target[Key] = Value
      end
    else
      Target[Key] = Value
    end
  end
  return Target, maxIndex
end

local function DeepClone(Table)
  local Compiled = {}
  for Index, Value in next, Table do
    if type(Value) == "table" then
      Compiled[Index] = DeepClone(Value)
    else
      Compiled[Index] = Value
    end
  end
  return Compiled
end

function Utility:DeepClone(Table)
  return DeepClone(Table)
end

function Utility:DeepMerge(...)
  local Compiled = {}
  local Count = select("#", ...)
  local maxIndex = 0
  for Index = 1, Count do
    local Table = select(Index, ...)
    if type(Table) == "table" then
      Compiled, maxIndex = DeepMerge(Compiled, Table, maxIndex)
    end
  end
  return Compiled
end

return Utility