local task = require("@lune/task")
local Task = {
  cancel = task.cancel,
  defer = task.defer,
  delay = task.delay,
  spawn = task.spawn,
  wait = task.wait,
}
  
return Task
