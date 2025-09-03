return (function(Roblox, Registry)
  local Task = require("@lune/task")
  local function makeEvent()
    local connections = {}
    local waiting = {}
    return {
      Connect = function(self, fn)
        table.insert(connections, fn)
        return {
          Disconnect = function()
            for i, f in ipairs(connections) do
              if f == fn then
                table.remove(connections, i)
                break
              end
            end
          end,
        }
      end,
      Fire = function(self, ...)
        for _, thread in ipairs(waiting) do
          Task.spawn(thread, ...)
        end
        table.clear(waiting)
        for _, fn in ipairs(connections) do
          fn(...)
        end
      end,
      Wait = function(self)
        local thread = coroutine.running()
        table.insert(waiting, function(...)
          coroutine.resume(thread, ...)
        end)
        return coroutine.yield()
      end,
    }
  end
  local runServiceEvents = {
    RenderStepped   = makeEvent(),
    Heartbeat       = makeEvent(),
    Stepped         = makeEvent(),
    PreSimulation   = makeEvent(),
    PostSimulation  = makeEvent(),
    PreRender       = makeEvent(),
    Pause           = makeEvent(),
    Unpause         = makeEvent(),
  }
  for name, event in pairs(runServiceEvents) do
    Roblox.implementProperty("RunService", name, function()
      return event
    end)
  end
  Task.spawn(function()
    while true do
      local fpsCap = Registry.FpsCap
      if fpsCap <= 0 then
        fpsCap = 60
			end
			local dt = math.max(1 / fpsCap, 1/1000)
			lastFps = 1 / dt
			runServiceEvents.PreSimulation:Fire(dt)
			runServiceEvents.Stepped:Fire(dt, os.clock())
			runServiceEvents.PostSimulation:Fire(dt)
			runServiceEvents.Heartbeat:Fire(dt)
			runServiceEvents.PreRender:Fire(dt)
			runServiceEvents.RenderStepped:Fire(dt)
			Task.wait(dt)
		end
	end)
end)