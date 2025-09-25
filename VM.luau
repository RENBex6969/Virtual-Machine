local VM = require("./Sandbox")

VM:Run([=[
task.wait(69)
print("yo")
]=])
	