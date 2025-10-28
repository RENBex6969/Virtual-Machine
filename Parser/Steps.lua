local Constructor = require("Constructor")
local Pretty = require("pp").dump
local Gen = require("luagen")
local IsA = type

local Steps = {}
local Math = {
  ["ADD"] = true,
  ["SUB"] = true,
  ["MUL"] = true,
  ["DIV"] = true,
  ["IDIV"] = true,
  ["MOD"] = true,
  ["POW"] = true,
}
local Comparison = {
  ["EQ"] = true,
  ["NE"] = true,
  ["GT"] = true,
  ["LT"] = true,
  ["GE"] = true,
  ["LE"] = true,
  ["OR"] = true,
  ["AND"] = true,
  ["NOT"] = true
}

local ComputeMath = function(L, R, Operator)
  if Operator == "ADD" then
    return L + R
  end
  
  if Operator == "SUB" then
    return L - R
  end
  
  if Operator == "MUL" then
    return L * R
  end
  
  if Operator == "DIV" then
    return L / R
  end
  
  if Operator == "IDIV" then
    return math.floor(L / R)
  end
  
  if Operator == "MOD" then
    return L % R
  end
  
  if Operator == "POW" then
    return L ^ R
  end
  
end
local Compare = function(L, R, Operator)
  if Operator == "EQ" then
    return L == R
  end
  
  if Operator == "NE" then
    return L ~= R
  end
  
  if Operator == "GT" then
    return L > R
  end
  
  if Operator == "LT" then
    return L < R
  end
  
  if Operator == "GE" then
    return L >= R
  end
  
  if Operator == "LE" then
    return L <= R
  end
  
  if Operator == "AND" then
    return L and R
  end
  
  if Operator == "OR" then
    return L or R
  end
  
  if Operator == "NOT" then
    return not L
  end
  
end
local Red = function(String)
  return print("\27[31m" .. String .. "\27[0m")
end

function Steps:FoldOperation(AST)
  local Types = {
    ["String"] = true,
    ["Number"] = true,
    ["Boolean"] = true,
    ["Nil"] = true
  }
    
  local Traverse; Traverse = function(Node)
    if IsA(Node) ~= "table" then
      return Node
    end
    for i, Child in ipairs(Node) do
      Node[i] = Traverse(Child)
    end
    
    if Node.tag == "Op" then
      local Operator = string.upper(Node[1])
      local L, R = Node[2], Node[3]
      local LTag, RTag = L.tag, R and R.tag
      
      if Math[Operator] and LTag == "Number" and RTag == "Number" then
        local Value = ComputeMath(L[1], R[1], Operator)
        
        if Value ~= nil then
          return Constructor:Number(Value)
        end
      end
      
      if Operator == "UNM" and LTag == "Number" then
        return Constructor:Number(-L[1])
      end
      
      if Comparison[Operator] and Types[LTag] and Types[RTag] then
        local Value = Compare(L[1], R[1], Operator)
        
        if Value ~= nil then
          return Constructor:Boolean(Value)
        end
      end
      
      if Operator == "OR" and LTag ~= nil then
        return (L[1] and L) or R
      end
      
      if Operator == "AND" and LTag ~= nil then
        return (not L[1] and L) or R
      end
      
      if Operator == "NOT" and LTag == "Boolean" then
        return Constructor:Boolean(not L[1])
      end
      
      if Operator == "CONCAT" and (LTag == "String" or LTag == "Number") and (RTag == "String" or RTag == "Number") then
        return Constructor:String(L[1] .. R[1])
      end
      
      if Operator == "LEN" then
        if LTag == "String" then
          return Constructor:Number(#L[1])
        end
        
        if LTag == "Table" then
          local Count = 0
          for _, _ in ipairs(L) do
            Count = 1 + Count
          end
          return Constructor:Number(Count)
        end
      end
      
      return Node
    end
    
    if Node.tag == "Paren" and #Node == 1 then
      local Child = Node[1]
      if Types[Child.tag] then
        return Constructor[Child.tag](Constructor, Child[1])
      end
    end
    
    return Node
  end
  
  Traverse(AST)
  return AST
end
function Steps:IfPruning(AST)
  local Traverse; Traverse = function(Node)
    if IsA(Node) ~= "table" then
      return Node
    end
    
    if Node.tag == "If" then
      for i = 1, #Node, 2 do
        local Condition = Node[i]
        local Block = Node[i + 1]
        
        if not Condition or not Block then
          break
        end
        
        if Condition.tag == "Boolean" and Condition[1] == true then
          return Traverse(Block)
        end
      end
      
      if (#Node % 2 == 1) then
        local ElseBlock = Node[#Node]
        if ElseBlock and ElseBlock.tag == "Block" then
          return Traverse(ElseBlock)
        end
      end
    end
    
    for i, Child in ipairs(Node) do
      Node[i] = Traverse(Child)
    end
    
    return Node
  end
  
  Traverse(AST)
  return AST
end
function Steps:BatchVariables(AST)
  local function ExtractIdentifiers(Node, Out)
    if IsA(Node) ~= "table" then return end
    if Node.tag == "Id" then
      Out[Node[1]] = true
    end
    for _, v in ipairs(Node) do
      ExtractIdentifiers(v, Out)
    end
  end

  local function DependsOn(Node, Names)
    if not Node then return false end
    local ids = {}
    ExtractIdentifiers(Node, ids)
    for name in pairs(ids) do
      if Names[name] then
        return true
      end
    end
    return false
  end
  
  local function HasSideEffects(Node)
    if IsA(Node) ~= "table" then return false end
    local tag = Node.tag
    if tag == "Call" or tag == "Invoke" or tag == "Vararg" then
      return true
    end
    if tag == "Index" then
      return true
    end
    for _, child in ipairs(Node) do
      if HasSideEffects(child) then
        return true
      end
    end
    return false
  end

  local function CloneExpr(expr)
    if not expr then return nil end
    local t = {}
    for k, v in pairs(expr) do
      if type(v) == "table" then
        t[k] = CloneExpr(v)
      else
        t[k] = v
      end
    end
    return t
  end

  local Traverse; Traverse = function(Node)
    if IsA(Node) ~= "table" then
      return Node
    end
    
    if Node.tag == "Block" then
      local i = 1
      while i <= #Node do
        local Child = Node[i]
        if Child.tag == "Local" then
          local Replacement = {
            tag = "Local",
            pos = 0,
            [1] = { tag = "NameList", pos = 0 },
            [2] = { tag = "ExpList", pos = 0 }
          }
          
          local startIndex = i
          local SafeToBatch = true
          local DefinedNames = {}
          local Batched = {}
          
          while SafeToBatch and i <= #Node and Node[i].tag == "Local" do
            local LocalNode = Node[i]
            local AnySideEffect = false
            
            for j, NameNode in ipairs(LocalNode[1]) do
              local ExprNode = LocalNode[2][j]
              
              if ExprNode then
                if DependsOn(ExprNode, DefinedNames) or HasSideEffects(ExprNode) then
                  SafeToBatch = false
                  AnySideEffect = true
                  break
                end
              end
              
              table.insert(Batched, {
                name = NameNode[1],
                expr = ExprNode and CloneExpr(ExprNode) or nil
              })
            
              DefinedNames[NameNode[1]] = true
            end
            
            if SafeToBatch and not AnySideEffect then
              table.remove(Node, i)
            else
              break
            end
          end
          
          table.sort(Batched, function(a, b)
            if a.expr and not b.expr then
              return true
            elseif not a.expr and b.expr then
              return false
            else
              return false
            end
          end)
          
          for _, item in ipairs(Batched) do
            table.insert(Replacement[1], { tag = "Id", pos = 0, [1] = item.name })
            if item.expr then
              table.insert(Replacement[2], item.expr)
            else
              if #Replacement[2] > 0 then
                table.insert(Replacement[2], { tag = "Nil", pos = 0 })
              end
            end
          end
          
          if #Replacement[1] > 0 then
            table.insert(Node, startIndex, Replacement)
            i = startIndex + 1
          else
            i = i + 1
          end
        else
          i = i + 1
        end
      end
    end
    
    for i, Child in ipairs(Node) do
      Node[i] = Traverse(Child)
    end
    
    return Node
  end

  return Traverse(AST)
end
function Steps:DeadDeclaration(AST)
  local function CollectIdentifiers(Node, out)
    if type(Node) ~= "table" then return end
    if Node.tag == "Id" then
      out[Node[1]] = true
    end
    for _, v in ipairs(Node) do
      CollectIdentifiers(v, out)
    end
  end

  local Traverse; Traverse = function(Node)
    if type(Node) ~= "table" then
      return Node
    end
    
    if Node.tag == "Block" or Node.tag == "Do" then
      local i = 1
      while i <= #Node do
        local Child = Node[i]
        local NextChild = Node[i + 1]
        
        if Child and NextChild and Child.tag == "Local" and NextChild.tag == "Local" then
          local SameVar = (#Child[1] == 1 and #NextChild[1] == 1)
            and (Child[1][1][1] == NextChild[1][1][1])
          local SameExpr = Gen(Child) == Gen(NextChild)
          
          if SameVar and SameExpr then
            table.remove(Node, i + 1)
            goto continue
          end
        end
        
        if Child and Child.tag == "Local" then
          local NextIdx = i + 1
          while NextIdx <= #Node do
            local N = Node[NextIdx]
            if N.tag == "Local" then
              local redefined = {}
              for _, nameNode in ipairs(N[1]) do
                redefined[nameNode[1]] = true
              end
              
              for _, nameNode in ipairs(Child[1]) do
                local name = nameNode[1]
                if redefined[name] then
                  local used = false
                  for k = i + 1, NextIdx - 1 do
                    local checkNode = Node[k]
                    if checkNode then
                      local ids = {}
                      CollectIdentifiers(checkNode, ids)
                      if ids[name] then
                        used = true
                        break
                      end
                    end
                  end
                  if not used then
                    table.remove(Node, i)
                    i = i - 1
                    goto continue
                  end
                end
              end
            end
            NextIdx = NextIdx + 1
          end
        end
        
        ::continue::
        i = i + 1
      end
    end
    
    for _, Child in ipairs(Node) do
      Traverse(Child)
    end
    
    return Node
  end

  Traverse(AST)
  return AST
end
function Steps:Call(AST)
  local function Traverse(Node)
    if type(Node) ~= "table" then
      return Node
    end
    
    for i, Child in ipairs(Node) do
      Node[i] = Traverse(Child)
    end
    
    if Node.tag == "Call" then
      local first = Node[1]
      if type(first) == "table" and first.tag == "Id" and first[1] == "CALL" then
        return Node
      end

      local Replacement = {
        tag = "Call",
        pos = 0,
        [1] = {
          tag = "Id",
          pos = 0,
          [1] = "CALL"
        }
      }
      
      for _, Field in ipairs(Node) do
        table.insert(Replacement, Field)
      end
      
      return Replacement
    end
    
    return Node
  end

  return Traverse(AST)
end

return Steps