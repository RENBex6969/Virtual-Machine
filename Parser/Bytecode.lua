local Instruction = {}
local Pretty = require("pp").dump
local Gen

local Add = function(Value)
  table.insert(Instruction, Value)
  return #Instruction
end


local NodeHandler = {
  ["Local"] = function(Node, Add)
    for i, NameNode in ipairs(Node[1]) do
      local ExprNode = Node[2][i]
      if ExprNode then
        Gen({ExprNode}, Add)
      else
        Add({ OP="PUSH", VAL = nil })
      end
      
      Add({ OP="STORE", NAME=NameNode[1] })
    end
  end,

  ["Op"] = function(Node, Add)
    if Node[2] then
      Gen({Node[2]}, Add)
    end
    if Node[3] then
      Gen({Node[3]}, Add)
    end
    
    Add({ OP = string.upper(Node[1]) })
  end,
  ["Paren"] = function(Node, Add)
    if type(Node[1]) == "table" then
      Gen({ Node[1] }, Add)
    else
      Add({ OP = "PUSH", VAL = Node[1] })
    end
  end,
  ["String"] = function(Node, Add)
    Add({ OP = "PUSH", VAL = Node[1] })
  end,
  ["Number"] = function(Node, Add)
    Add({ OP = "PUSH", VAL = Node[1] })
  end,
  ["Nil"] = function(Node, Add)
    Add({ OP = "PUSH", VAL = Node[1] })
  end,
  ["Id"] = function(Node, Add)
    Add({ OP = "LOAD", NAME = Node[1] })
  end
}

Gen = function(AST, AddFn)
  AddFn = AddFn or Add
  for _, Child in ipairs(AST) do
    if type(Child) ~= "table" then
        error("AST node is not a table")
    end
    
    local Handler = NodeHandler[Child.tag] or function(Node)
      error("Unhandled node type: " .. (Node.tag or "Unknown"))
    end
    Handler(Child, AddFn)
  end
  return Instruction
end
return Gen