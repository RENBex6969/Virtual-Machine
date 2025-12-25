local Random = {
  Charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  NumCharset = "1234456789",
  Hex = "0123456789abcdef"
}

function Random:string(Length : number): string
  local Output = ""
  
  for i = 1, Length do
    local Index = math.random(1, #self.Charset)
    Output ..= self.Charset:sub(Index, Index)
  end
  
  return Output
end

function Random:number(Length : number): number
  local Output = ""
  
  for i = 1, Length do
    local Index = math.random(1, #self.NumCharset)
    Output ..= self.NumCharset:sub(Index, Index)
  end
  
  return tonumber(Output)
end

function Random:hex(Length : number): string
	local Output = ""
	
	for i = 1, Length do
		local Index = math.random(1, #self.Hex)
		Output ..= self.Hex:sub(Index, Index)
	end
	
	return Output
end

function Random:tablevalue(Table : table): table
  local Out = {}
  for i, Value in pairs(Table) do
    if type(Value) == "string" then
      Out[i] = self:string(6)
    elseif type(Value) == "number" then
      Out[i] = self:number(2)
    elseif type(Value) == "boolean" then
      Out[i] = math.random(1, 2) == 1
    else
      Out[i] = Value
    end
  end
  return Out
end

function Random:pickword(... : any?): string
	local Options = {...}
	
	local Index = math.random(1, #Options)
	return Options[Index]
end

function Random:filename(Length : number, Type : string, Directory : string): string
  if Directory then
    return Directory .. self:string(Length) .. Type
  end
  
  return self:string(Length) .. Type
end

return Random