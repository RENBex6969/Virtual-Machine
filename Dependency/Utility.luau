local Utility = {}

Utility.getModule = function(Module)
  return require("./" .. Module)
end

Utility.getLLibrary = function(Library)
  return require("@Src/LuauLibrary/" .. Library)
end

Utility.getELibrary = function(Library)
  return require("@Src/ExploitLibrary/" .. Library)
end

Utility.DeepMerge = function(...)
  local Compiled = {}
  local function deepMerge(Target, Source)
    table.foreach(Source, function(Key, Value)
      if type(Value) == "table" and type(Target[Key]) == "table" then
        deepMerge(Target[Key], Value)
      else
        Target[Key] = Value
      end
    end)
  end
  table.foreach({...}, function(_, Table)
    deepMerge(Compiled, Table)
  end)
  return Compiled
end

Utility.Copy = function(Table)
  local function deepCopy(Original)
    local copy = {}
    table.foreach(Original, function(Key, Value)
      if type(Value) == "table" then
        copy[Key] = deepCopy(Value)
      else
        copy[Key] = Value
      end
    end)
    return copy
  end
  return deepCopy(Table)
end

return Utility