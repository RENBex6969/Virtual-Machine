local tinsert, tconcat = table.insert, table.concat
local tostring = tostring
local gmatch = string.gmatch

local function split(str, delimiter)
  local returnTable = {}
  for v in gmatch(str, "([^" .. delimiter .. "]+)") do
    returnTable[#returnTable+1] = v
  end
  return returnTable
end

local function indent(x)
  local pack = split(x, "\n")
  for k,v in ipairs(pack) do
    pack[k] = "\t" .. v
  end
  pack = tconcat(pack, "\n")
  return pack
end

function map(node, delimiter)
  local pack = {}
  for _,v in ipairs(node) do
    tinsert(pack, gen(v))
  end
  pack = tconcat(pack, delimiter or "\n")
  return pack
end

local function CLAUSE(node, TYPE)
  local out = ""
  local cond
  if TYPE then
    local cond = gen(node.cond)
    out = out..TYPE.." "..cond.." then\n"
  else
    out = out.."else\n"
  end
  local body = gen(node.body)
  out = out..indent(body)
  out = out
  return out
end

local op_label = {
  -- Comparison
  eq = {operator = "==", Is_Unary = 0},
  ne = {operator = "~=", Is_Unary = 0},
  gt = {operator = ">", Is_Unary = 0},
  lt = {operator = "<", Is_Unary = 0},
  ge = {operator = ">=", Is_Unary = 0},
  le = {operator = "<=", Is_Unary = 0},

  -- Logical
  ["and"] = {operator = "and", Is_Unary = 0},
  ["or"] = {operator = "or", Is_Unary = 0},
  ["not"] = {operator = "not", Is_Unary = 1},

  -- Math
  add = {operator = "+", Is_Unary = 0},
  sub = {operator = "-", Is_Unary = 0},
  mul = {operator = "*", Is_Unary = 0},
  div = {operator = "/", Is_Unary = 0},
  idiv = {operator = "//", Is_Unary = 0}, -- integer division
  mod = {operator = "%", Is_Unary = 0},
  pow = {operator = "^", Is_Unary = 0},
  unm = {operator = "-", Is_Unary = 1}, -- unary minus
  len = {operator = "#", Is_Unary = 1}, -- length operator

  -- Concatenation
  concat = {operator = "..", Is_Unary = 0},

  -- Bitwise (Lua 5.3+ or LuaJIT)
  band = {operator = "&", Is_Unary = 0},
  bor = {operator = "|", Is_Unary = 0},
  bxor = {operator = "~", Is_Unary = 0},
  shl = {operator = "<<", Is_Unary = 0},
  shr = {operator = ">>", Is_Unary = 0},
  bnot = {operator = "~", Is_Unary = 1},
}

local nodeHandlers = {
  Block = function(node)
    return map(node)
  end,
  Call = function(node)
    local pack = {}
    -- generate arguments
    for i = 2, #node do
      tinsert(pack, gen(node[i]))
    end
    pack = tconcat(pack, ", ")
    return gen(node[1]).."("..pack..")"
  end,
  Id = function(node)
    local out = ""
    out = out .. node[1]
    return out
  end,
  String = function(node)
    local out = ""
    out = out .. '"'..node[1]..'"'
    return out
  end,
  Number = function(node)
    return tostring(node[1])
  end,
  Nil = function(node)
    return "nil"
  end,
  SemiColon = function()
    return ";"
  end,
  Do = function(node)
    local out = ""
    out = out .. "do\n"
    local pack = map(node)
    out = out .. indent(pack);
    out = out .. "\nend"
    return out
  end,
  Fornum = function(node)
    local out = ""
    local Loop_variable = gen(node[1])
    local Start = gen(node[2])
    local End = gen(node[3])
    local Skip = #node == 5 and gen(node[4])
    local Body = gen(#node == 5 and node[5] or node[4])
    out = out.."for "..Loop_variable.." = "..Start..", "..End
    if Skip then
      out = out..", "..Skip
    end
    out = out.." do\n"
    out = out..indent(Body)
    out = out.."\nend"
    return out
  end,
  While = function(node)
    local out = ""
    out = out.."while "..gen(node[1]).." do\n"
    out = out..indent(gen(node[2]))
    out = out.."\nend"
    return out
  end,
  Boolean = function(node)
    return tostring(node[1])
  end,
  Repeat = function(node)
    local out = ""
    out = out.."repeat\n"
    out = out..indent(gen(node[1]))
    out = out.."\nuntil "..gen(node[2])
    return out
  end,
  Set = function(node)
    local out = ""
    local variables = map(node[1], ", ")
    local init = map(node[2], ", ")
    out = out..variables.." = "..init
    return out
  end,
  Local = function(node)
  local out = ""
  local variables = map(node[1], ", ")
  local init = node[2] and map(node[2], ", ") or ""
  out = out.."local "..variables
  if init ~= "" then
    out = out.." = "..init
  end
  return out
end,
  Function = function(node)
    local out = ""
    local params = map(node[1], ", ")
    local body = map(node[2])
    out = out.."function"
    out = out.."("..params..")"
    if #body ~= 0 then
      out = out.."\n"..indent(body).."\n"
    end
    out = out.."end"
    return out 
  end,
  Dots = function(node)
    return "..."
  end,
  Localrec = function(node)
    -- Does this type, have any use outside of a local function?
    -- This below same code as the local type
    local out = ""
    local variables = map(node[1], ", ")
    local init = map(node[2], ", ")
    out = out.."local "
    out = out..variables.." = "..init
    return out
  end,
  Table = function(node)
    local out = ""
    if #node == 0 then
      out = "{}"
    else
      local vals = indent(map(node, ", \n"))
      out = out.."{\n"..vals.."\n}"
    end
    return out
  end,
  Pair = function(node)
    local key = gen(node[1])
    local val = gen(node[2])
    return "["..key.."]".." = "..val
  end,
  Forin = function(node)
    local out = ""
    local variables = map(node[1], ", ")
    local ExpList = gen(node[2])
    local body = gen(node[3])
    out = out.."for "..variables.." in "..ExpList
    out = out.." do\n"
    out = out..indent(body)
    out = out.."\nend"
    return out
  end,
  ExpList = function(node)
    local List = map(node, ", ")
    return List
  end,
  Return = function(node)
    local List = map(node, ", ")
    return "return "..List
  end,
  Label = function(node)
    return "::"..node[1].."::"
  end,
  Goto = function(node)
    return "goto "..node[1]
  end,
  Paren = function(node)
    return "("..gen(node[1])..")"
  end,
  Index = function(node)
    local Left = gen(node[1])
    local Right = gen(node[2])
    return Left.."["..Right.."]"
  end,
  Invoke = function(node)
    local out = ""
    out = out..gen(node[1])
    out = out..":"..node[2][1]
    local pack = {}
    -- generate arguments
    for i = 3, #node do
      tinsert(pack, gen(node[i]))
    end
    pack = tconcat(pack, ", ")
    out = out.."("..pack..")"
    return out
  end,
  If = function(node)
    local Node = {}
    -- The first clause is always a if clause
    tinsert(Node, {
      type = "if",
      cond = node[1],
      body = node[2]
    })
    -- Setting the rest as a ELSEIF clause
    for i = 3, #node, 2 do
      tinsert(Node, {
        type = "elseif",
        cond = node[i],
        body = node[i + 1]
      })
    end
    -- This detects if the final clause is ELSE
    -- Returns nil if a ELSE clause, otherwise returns a table for a ELSEIF clause
    local IsFinalClause_ELSE = Node[#node / 2]
    if IsFinalClause_ELSE == nil then
      local FinalClause = Node[#Node]
      -- Change ElseifClause to nil
      FinalClause.type = nil
      FinalClause.body = FinalClause.cond
      FinalClause.cond = nil
    end
    -- Now we have a table that tells us each clause
    -- Time to generate code fromn the clause
    local pack = {}
    for k,v in ipairs(Node) do
      tinsert(pack, CLAUSE(v, v.type))
    end
    pack = tconcat(pack, "\n")
    -- There is only END, after the final clause
    pack = pack.."\nend"
    return pack
  end,
  NameList = function(node)
  return map(node, ", ")
end,
  Op = function(node)
    local out = ""
    local label = op_label[node[1]]
    if label.Is_Unary == 0 then
      out = out..gen(node[2])
      out = out.." "..label.operator.." "
      out = out..gen(node[3])
    else
      out = out..label.operator
      out = out.." "..gen(node[2])
    end
    return out
  end,
  True = function(node)
  return "true"
end,

False = function(node)
  return "false"
end,

Boolean = function(node)
  return tostring(node[1])
end,
Else = function(node)
  local body = gen(node[1])
  return "else\n" .. indent(body)
end,
VarList = function(node)
  return map(node, ", ")
end,
}

nodeHandlers["IfClause"] = function(node)
  return CLAUSE({
    cond = node[1],
    body = node[2]
  }, "if")
end

nodeHandlers["ElseClause"] = function(node)
  return CLAUSE({
    body = node[1]
  }, nil)
end


function gen(node)
  local formatter = nodeHandlers[node.tag];
  -- For unsupported types
  if not formatter then
    error("Unhandled: " .. node.tag)
  end
  local text = formatter(node)
  return text
end

return gen
