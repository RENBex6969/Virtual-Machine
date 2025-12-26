local Beautify = require("@Dep/Beautify")
local Parser = require("@std/syntax/parser")
local Process = require("@lute/process") 
local FileSystem = require("@lute/fs")

local Arguments = Process.env
local InputPath = Arguments.InputPath
local OutputPath = Arguments.OutputPath

local Unparser = {}
local maxNum, tab, visited = 2^64, "    ", {}
local FunctionDepth = 0

local Source = FileSystem.readfiletostring(InputPath)
local Statements = Parser.parseblock(Source).statements

local Lines = Source:split("\n")

local FuncScopes = {}

local Id = 1
local function PushFunctionScope()
  table.insert(FuncScopes, {
    ID = Id,
    UpvalueId = 1,
    ConstantId = 1
  })
  Id += 1
end

local function PeepFunctionScope()
  return FuncScopes[#FuncScopes]
end

local function PopFunctionScope()
  table.remove(FuncScopes)
end

function Unparser:construct( Stat : table ): table
  if Stat.istoken then
    return {
      class = "Constant"
    }
  end
  
  if Stat.kind == "stat" then
    return {
      class = "Statement",
      tag = Stat.tag
    }
  elseif Stat.kind == "expr" then
    return {
      class = "Expression",
      kind = Stat.tag
    }
  end
  
  return {
    class = "null"
  }
end

function Unparser:format( Text : string, ... :any? ): string
  return string.format(Text, ...)
end

function Unparser:readparameters( Stat : table ): string
  local Parameters = Stat.parameters
  local Out = "("

  for i, Parameter in Parameters do
    Out ..= (i > 1 and ", " or "") .. self:readexpr(Parameter, false)
  end

  if Stat.vararg then
    if #Parameters > 0 then
      Out ..= ", ..."
    else
      Out ..= "..."
    end
  end

  return Out .. ")", Stat.vararg
end

function Unparser:readstatement(Stat : table, shouldAddDo : boolean, ... : any?): string
  local Tag = Stat.tag
  
  if Tag == "local" then
    local Out = "local "
    for i, Variable in Stat.variables do
      local Name = Variable.node.name.text
      Out ..= (i > 1 and ", "or "") .. Name
    end
    
    if #Stat.values == 0 then
      return Out
    end
    Out ..= " = "
    
    for i, Value in Stat.values do
      local Expr = self:readexpr(Value.node)
      
      
      
      Out ..= (i > 1 and ", " or "") .. Expr
    end
    
    return Out
  end
  
  if Tag == "assign" then
    local Out = ""
    for i, Variable in Stat.variables do
      Out ..= (i > 1 and ", " or "") .. self:readexpr(Variable.node, false, true)
    end
    
    Out ..= " = "
    
    for i, Value in Stat.values do
      Out ..= (i > 1 and ", " or "") .. self:readexpr(Value.node --[[, false, true]])
    end
    
    return Out
  end
  
  if Tag == 'compoundassign' then
    return self:format("%s %s %s", self:readexpr(Stat.variable, nil, true), Stat.operand.text, self:readexpr(Stat.value))
  end
  
  if Tag == "expression" then
    return self:readexpr(Stat.expression)
  end
  
  if Tag == "function" then
    PushFunctionScope()
    
    local Parameters, Vararg = self:readparameters(Stat.body)
    local Out = "function " .. self:readexpr(Stat.name, nil, true, true) .. Parameters
    Out ..= self:readexpr(Stat.body.body, true, nil, Vararg) .. " end"
    
    PopFunctionScope()
    
    return Out
  end
  
  if Tag == "localfunction" then
    PushFunctionScope()
    
    local Info = PeepFunctionScope()
    
    local Parameters, Vararg = self:readparameters(Stat.body)
    local Name = self:readexpr(Stat.name)
    local Out = string.format("function%s", Parameters)
    
    Out ..= self:readexpr(Stat.body.body, true, nil, Vararg) .. " end"
    
    Out = string.format("local %s; %s = FUNC(%s, %s)", Name, Name, Out, Info.ID)
    
    PopFunctionScope()
    
    return Out
  end
  
  if Tag == "block" then
    local Location = Stat.location.begin
    local Content = Lines[Location.line + 1]
    
    local shouldAddDo = Content:sub(Location.column + 1, Location.column + 2) == "do"
    
    local Out = shouldAddDo and "do " or ""
    
    for _, Stat in Stat.statements do
      local Str = self:readexpr(Stat, typeof(dontAddDo) == "string" and dontAddDo or nil)
      
      Out ..= Str .. (Str ~= "..." and Str:sub(#Str) ~= ";" and ";" or "")
    end
    
    return Out .. (shouldAddDo and "end;" or "")
  end
  
  if Tag == "conditional" then
    local ElseBlock = ""
    if Stat.elseblock then
        ElseBlock = string.format(
            "else %s ",
            self:readstatement(Stat.elseblock)
        )
    end
   
    local ElseifBlocks = ""
   
    for _, Elif in ipairs(Stat.elseifs or {}) do
        ElseifBlocks ..= string.format(
            "elseif %s then %s ",
            self:readexpr(Elif.condition),
            self:readstatement(Elif.thenblock)
        )
    end
    
    local Out = string.format(
        "if %s then %s %s %s end",
        self:readexpr(Stat.condition),
        self:readstatement(Stat.thenblock),
        ElseifBlocks,
        ElseBlock
    )
    
    return Out
  end
  
  if Tag == "while" then
    local Out = "while " .. self:readexpr(Stat.condition) .. " do "
    Out ..= self:readstatement(Stat.body) .. " end"
    
    return Out
  end
  
  if Tag == "return" then
    local Out = "return "
    
    if #Stat.expressions == 0 then
      return Out
    end
    
    for i, Node in Stat.expressions do
      Out ..= (i > 1 and ", " or "") .. self:readexpr(Node.node)
    end
    
    return Out
  end
  
  if Tag == "for" then
    local Variable = Stat.variable.name.text
    local Start = self:readexpr(Stat.from)
    local End = self:readexpr(Stat.to)
    
    local Step = ""
    if Stat.step then
      Step = ", " .. self:readexpr(Stat.step)
    end
    
    local Out = "for " .. Variable .. " = " .. Start .. ", " .. End .. Step .. " do "
    Out ..= self:readstatement(Stat.body)
    return Out .. " end"
  end
  
  if Tag == "forin" then
    local Out = "for "
    for i, Node in Stat.variables do
      Out ..= (i > 1 and ", " or "") .. Node.node.name.text
    end
    
    local forin = ""
    for i, Value in Stat.values do
      forin ..= (i > 1 and ", " or "") .. self:readexpr(Value.node)
    end
    
    Out ..= self:format(" in %s do %s end", forin, self:readstatement(Stat.body, true))
    return Out
  end
  
  if Tag == "repeat" then
    return self:format("repeat %s until %s", self:readexpr(Stat.body, true), self:readexpr(Stat.condition))
  end
  
  if Tag == "typealias" then
    return self:format("export type %s = %s", Stat.name.text, self:readexpr(Stat.type, nil, nil, true))
  end
  
  error("Unsupported statement " .. Tag)
end

function Unparser:readexpr(Stat, isValue, ...)
  local Expr = self:construct(Stat)
  
  -- Statement
  if Expr.class == "Statement" then
    return self:readstatement(Stat, ...)
  end
  
  -- Constant
  if Stat.istoken and not Stat.tag then
    if Stat.value ~= nil then
      return Beautify(Stat.value, Stat.qoutestyle)
    end
    
    return Beautify(Stat.text, Stat.quotestyle)
  end
  
  --[[
  if Stat.istoken and not Stat.tag then
    local FuncScope = PeepFunctionScope()
    if FuncScope then
      local ValueStr = Stat.value ~= nil and Beautify(Stat.value, Stat.qoutestyle) or Beautify(Stat.text, Stat.quotestyle)
      local Out = string.format("GETCONSTANT(%s, %d, %d)", ValueStr, FuncScope.ID, FuncScope.ConstantId)
      
      return Out
    else
      if Stat.value ~= nil then
        return Beautify(Stat.value, Stat.qoutestyle)
      end
      
      return Beautify(Stat.text, Stat.quotestyle)
    end
  end
  ]]
  
  -- Constant
  
  local Node = Stat.node
  if Node then
    Stat = Node
  end
  
  local Tag = Stat.tag or Stat.kind
  
--  print(Tag)

  if Tag == "string" or Tag == "nil" or Tag == "number" or Tag == "boolean" then
    local FuncScope = PeepFunctionScope()
    
    local ValueStr
    if Tag == "string" then
      ValueStr = Beautify(Stat.text, Stat.quotestyle, Stat.blockdepth)
    elseif Tag == "nil" then
      ValueStr = "nil"
    elseif Tag == "number" then
      ValueStr = Stat.text or tostring(Stat.value)
    elseif Tag == "boolean" then
      ValueStr = tostring(Stat.value)
    end
    
    if FuncScope then
      local FuncID = FuncScope.ID
      local ConstID = FuncScope.ConstantId
      
      local Out = string.format("GETCONSTANT(%s, %d, %d)", ValueStr, FuncID, ConstID)
      FuncScope.ConstantId += 1
      
      return Out
    end
    
    return ValueStr
  end
  
  if Tag == "table" then
    local Out = "{"
    local Length = #Stat.entries
    
    for i, Entry in Stat.entries do
      if Entry.key then
        if Entry.value.tag == "reference" then
          Out ..= Entry.key.text .. ": " .. self:readexpr(Entry.value)
        else
          Out ..= "[" .. self:readexpr(Entry.key) .. "] = " .. self:readexpr(Entry.value)
        end
      else
        Out ..= self:readexpr(Entry.value)
      end
      
      if i ~= Length then
        Out ..= ", "
      end
    end
    
    return Out .. "}"
  end
  
  if Tag == "vararg" then
    return "..."
  elseif Tag == "break" then
    return "break"
  elseif Tag == "continue" then
    return "continue"
  end
  
  if Tag == "local" or Tag == "global" then
    local Info = PeepFunctionScope()
    local Name = (Stat.name or Stat.token).text
    
    if isValue and Info ~= nil and Stat.upvalue then
      local Out = string.format("UPVALUE(%s, %s, %s)", Name, Info.ID, Info.UpvalueId)
      Info.UpvalueId += 1
      return Out
    end
    
    return Name
  end

  if Tag == "function" then
    PushFunctionScope()
    
    local Info = PeepFunctionScope()
    
    local Parameters, Vararg = self:readparameters(Stat.body)
    local Body = self:readexpr(Stat.body.body, nil, nil, Vararg)
    
    PopFunctionScope()
    
    return string.format("FUNC(function%s%s end, %d)", Parameters, Body, Info.ID)
  end
  
  if Tag == "conditional" then
    
    local Out = self:format("if %s then %s ", self:readexpr(Stat.condition), self:readexpr(Stat.thenexpr))
    for _, Elif in Stat.elseifs do
      Out ..= self:format("elseif %s then %s ", self:readexpr(Elif.condition), self:readexpr(Elif.thenexpr))
    end
    
    Out ..= self:format("else %s", self:readexpr(Stat.elseexpr))
    return Out
  end
  
  if Tag == "call" then
    local Func = self:readexpr(Stat.func, true, Stat.self)
    local Out = ""
    
    if Stat.func.tag == "group" then
      Out = "CALL(" .. Func
      
      for i, Arg in Stat.arguments do
        Out ..= (i == 1 and ", " or ",") .. self:readexpr(Arg.node, true)
      end
      
      Out ..= ")"
    elseif Stat.self then
      local Obj = self:readexpr(Stat.func.expression)
      local Method = Stat.func.index.text
      
      Out = self:format("NAMECALL(%s, %q", Obj, Method)
      Out ..= "," .. Obj
      
      for i, Arg in Stat.arguments do
        Out ..= "," .. self:readexpr(Arg.node)
      end
      
      Out ..= ")"
    else
      Out = "CALL(" .. Func
      
      for i, Arg in Stat.arguments do
        Out ..= (i == 1 and ", " or ",") .. self:readexpr(Arg.node)
      end
      
      Out ..= ")"
    end
    
    return Out
  end

  if Tag == "binary" then
    return self:format('%s %s %s', self:readexpr(Stat.lhsoperand), Stat.operator.text, self:readexpr(Stat.rhsoperand))
  end
  
  if Tag == "unary" then
    return self:format('%s %s', Stat.operator.text, self:readexpr(Stat.operand))
  end
  
  if Tag == "group" then
    return self:format("(%s)", self:readexpr(Stat.expression))
  end
  
  if Tag == "indexname" then
    local Table = self:readexpr(Stat.expression)
    local Accessor = Stat.accessor.text
    local Index = Stat.index.text
    
    return Table .. Accessor .. Index
  end
  
  if Tag == "index" then
    local Table = self:readexpr(Stat.expression)
    local Index = self:readexpr(Stat.index)
    
    return Table .. "[" .. Index .. "]"
  end
  
  if Tag == "interpolatedstring" then
    local Out = "\""
    local List = {}

    for _, str in Stat.strings do
      table.insert(List, {
        kind = "string",
        at = str.position.column,
        expr = str.text
      })
    end

    for _, Expression in Stat.expressions do
      table.insert(List, {
        kind = "expr",
        at = (Expression.position or Expression.location.begin).column,
        Expression = Expression
      })
    end
    
    table.sort(List, function(a, b) return a.at < b.at end)
    
    for _, Value in List do
      if Value.kind == "expr" then
        Out ..= tostring(self:readexpr(Value.Expression))
      else
        Out ..= Value.Expression
      end
    end
    
    Out ..= "\""
    return Out
  end
  
  if Tag == "cast" then
    return ""
  end
  
  if Tag == "reference" then
    return Stat.name.text
  end
  
  error("Missing expression " .. Tag)
end

local s = os.clock()
local Out = table.create(128)
for i, Stat in Statements do
  Out[i] = Unparser:readexpr(Stat)
end

print(tostring(os.clock() - s) .. ", ".. tostring(#Out / 1024))
FileSystem.writestringtofile(OutputPath, table.concat(Out, "\n"))