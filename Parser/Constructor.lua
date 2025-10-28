local Constructor = {}

function Constructor:OneIf(Block)
  return {
    ["tag"] = "If",
    ["pos"] = 0,
    [1] = {
      ["tag"] = "Boolean",
      ["pos"] = 0,
      [1] = true
    },
    [2] = Block
  }
end

function Constructor:Local(Name, Value, Type)
  return {
    ["tag"] = "Local",
    ["pos"] = 0,
    [1] = {
      ["tag"] = "NameList",
      ["pos"] = 0,
      [1] = {
        ["tag"] = "Id",
        ["pos"] = 0,
        [1] = Name
      }
    },
    [2] = {
      ["tag"] = "ExpList",
      ["pos"] = 0,
      [1] = {
        ["tag"] = Type,
        ["pos"] = 0,
        [1] = Value
      }
    }
  }
end

function Constructor:Call(Name, ...)
  local Arguments = {...}
  local Template = {
    ["tag"] = "Call",
    ["pos"] = 0,
    [1] = {
      ["tag"] = "Id",
      ["pos"] = 0,
      [1] = Name
    }
  }
  
  
  
  for _, Value in ipairs(Arguments) do
    local IsA = type(Value)
    table.insert(Template, {
      ["tag"] = IsA:gsub("^%l", string.upper),
      ["pos"] = 0,
      [1] = Value
    })
  end
  
  return Template
end

function Constructor:Paren(Node)
  return {
    ["tag"] = "Paren",
    ["pos"] = 0,
    [1] = Node
  }
end

function Constructor:Number(Number)
  return {
    ["tag"] = "Number",
    ["pos"] = 0,
    [1] = Number
  }
end

function Constructor:String(String)
  return {
    ["tag"] = "String",
    ["pos"] = 0,
    [1] = String
  }
end

function Constructor:Boolean(Boolean)
  return {
    ["tag"] = "Boolean",
    ["pos"] = 0,
    [1] = Boolean
  }
end

return Constructor