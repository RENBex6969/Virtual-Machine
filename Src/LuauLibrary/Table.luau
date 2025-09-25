return (function(ECore)
  local Table = {
    clear = table.clear,
    clone = table.clone,
    concat = table.concat,
    create = table.create,
    find = table.find,
    foreach = table.foreach,
    foreachi = table.foreachi,
    freeze = function(Table)
      if type(Table) ~= "table" then 
        return Table
      end
      
      ECore.setreadonly(Table, true)
      
      if ECore.isreadonly(Table) == false then
        table.freeze(Table)
      end
      
      return tbl
    end,
    getn = table.getn,
    insert = table.insert,
    isfrozen = function(Table)
      if type(Table) ~= "table" then
        return false
      end
      
      local MT = ECore.getrawmetatable(Table)
      if MT and MT.__readonly then
        return true
      end
      
      if table.isfrozen(tbl) then
        return true
      end
      
      return false
    end,
    maxn = table.maxn,
    move = table.move,
    pack = table.pack,
    remove = table.remove,
    sort = table.sort,
    unpack = table.unpack,
  }
  
  return Table
end)