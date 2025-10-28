-- vm.lua
local VM = {}
VM.__index = VM

-- Create new VM instance
function VM.new(bytecode)
    return setmetatable({
        ip = 1,              -- instruction pointer
        stack = {},          -- data stack
        vars = {},           -- environment / locals
        code = bytecode or {},
        running = false
    }, VM)
end

------------------------------------------------------------
-- Stack helpers
------------------------------------------------------------
function VM:push(v)
    self.stack[#self.stack + 1] = v
end
function VM:pop()
    local v = self.stack[#self.stack]
    self.stack[#self.stack] = nil
    return v
end
function VM:peek()
    return self.stack[#self.stack]
end

VM.Ops = {
    ["PUSH"] = function(self, instr)
      self:push(instr.VAL)
    end,
}

function VM:step()
  local instr = self.code[self.ip]
  if not instr then return false end

  local op = instr.OP
  local handler = self.Ops[op]

  if not handler then
      error("Unknown opcode: " .. tostring(op))
  end

  handler(self, instr)
  self.ip = self.ip + 1
  return true
end
function VM:run()
  self.running = true
  while self.running and self:step() do end
end
function VM:stop()
  self.running = false
end
function VM:dump()
    print("== STACK ==")
    for i, v in ipairs(self.stack) do
        print(i, v)
    end
    print("== VARS ==")
    for k, v in pairs(self.vars) do
        print(k, v)
    end
    print("IP:", self.ip)
    print("==============")
end

return VM