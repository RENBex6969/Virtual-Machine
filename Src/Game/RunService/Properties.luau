return (function(Roblox, Registry, Utility)
	local Task = require("@lune/task")
	local Signal = Utility.getELibrary("Signal") -- <- import the yield-safe Signal module

	local runServiceEvents = {
		RenderStepped   = Signal.new(),
		Heartbeat       = Signal.new(),
		Stepped         = Signal.new(),
		PreSimulation   = Signal.new(),
		PostSimulation  = Signal.new(),
		PreRender       = Signal.new(),
		Pause           = Signal.new(),
		Unpause         = Signal.new(),
	}

	-- Hook them up as properties on RunService
	for name, event in pairs(runServiceEvents) do
		Roblox.implementProperty("RunService", name, function()
			return event
		end, function() end)
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