package.path = package.path .. ";./Parser/?.lua"
local Parser = require("parser")
local Pretty = require("pp").dump
local Gen = require("luagen")
local Steps = require("Steps")
local Bytecoder = require("Bytecode")
local VM = require("Vm")
local Parse = function(Code)
  local AST = Parser.parse(Code)
  assert(AST, "Failed to parse")
  
  return setmetatable(AST, {
    __tostring = function()
      return Gen(AST)
    end
  })
end

local FixMath = function(Code)
  local Operations = {
    Addition = {'(%w+)(%s*)%+=(%s*)(%w+)', '%1%2=%3%1%2+%3%4'},
    Subtraction = {'(%w+)(%s*)%-=(%s*)(%w+)', '%1%2=%3%1%2-%3%4'},
    Multiplication = {'(%w+)(%s*)%*=(%s*)(%w+)', '%1%2=%3%1%2*%3%4'},
    Division = {'(%w+)(%s*)/=(%s*)(%w+)', '%1%2=%3%1%2/%3%4'},
    Modulus = {'(%w+)(%s*)%%=(%s*)(%w+)','%1%2=%3%1%2%%%3%4'},
    Concatenation = {'(%w+)(%s*)%.%.=(%s*)(%w+)', '%1%2=%3%1%2..%3%4'}
  }
  for _, Op in next, Operations do
    Code = string.gsub(Code, Op[1], Op[2])
  end
  return Code
end
local Measure = function(Func, Name, ...)
  local Time = os.clock()
  local Succ, Err = pcall(Func, ...)
  assert(Succ, Err)
  
  local Elapsed = (os.clock() - Time) * 1000
  
  print("Finished \27[35m" .. Name .. "\27[0m in " .. Elapsed .. "ms")
  return Err
end

local Main = function(Code)
  local Copy = Gen(Parse(Code))
  Code = Measure(FixMath, "FixMath", Copy)
  local AST = Measure(Parse, "Parse", Copy)
  
  --AST = Measure(Steps.FoldOperation, "FoldOperation", Steps, AST)
  --AST = Measure(Steps.IfPruning, "IfPruning", Steps, AST)
  --AST = Measure(Steps.DeadDeclaration, "DeadDeclaration", Steps, AST)
  --AST = Measure(Steps.BatchVariables, "BatchVariables", Steps, AST)
  AST = Measure(Steps.Call, "CallFix", Steps, AST)
  
  local Compiled = tostring(AST)
  local Diff = #Compiled - #Copy
  local Percent = (math.abs(Diff) / #Copy) * 100
  local Color, Symbol, Status
  
  if Diff < 0 then
    Color, Symbol, Status = "\27[32m", "↓", "Reduced"
  elseif Diff > 0 then
    Color, Symbol, Status = "\27[31m", "↑", "Increased"
  else
    Color, Symbol, Status = "\27[33m", "→", "Unchanged"
  end
  
  print(string.format(
    "[%s%s%s] %s %d chars %s (%.2f%% difference)",
    Color, Status, "\27[0m", Symbol, math.abs(Diff), Symbol, Percent
  ))

  return Compiled
end

if arg and arg[0] and arg[1] then
  local FileName = arg[1]
  local F = io.open(FileName, "r")
  local Code = F:read("*a")
  F:close()
  
  local Patched = Main(Code)
  local Out = io.open(FileName, "w")
  Out:write(Patched)
  Out:close()
  
end