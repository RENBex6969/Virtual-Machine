local Debugger = {}

function Debugger:Recreate(func)
  local funcName = debug.info(func, "n") or "Unknown"
  local nparams, isVararg = debug.info(func, "a")
  local params = {}
  for i = 1, nparams do
    table.insert(params, "V"..i)
  end
  if isVararg then
    table.insert(params, "...")
  end
  local paramStr = table.concat(params, ", ")
  local source = string.format("local %s = function(%s)\n    -- body\nend", funcName, paramStr)
  return source
end

return Debugger
