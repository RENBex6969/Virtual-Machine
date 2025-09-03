  GNU nano 8.4                     README.md
# VM
Runs roblox **scripts** on a executor environment with a partial *Roblox A>

### Installation
1. Install Lune from rokit
2. Fork this current repository
3. Follow instruction **1 & 2**

### Usage
The VM has bulit in API system you can use it on your scripts!

**Requiring the VM** :
```luau
local Sandbox = require("./Sandbox") -- Adjust thr path to the path of San>
```

**Example Script** :
```luau
local Sandbox = require("./Sandbox")
Sandbox:Run([[
  print("hello world")
  getrenv().print("hii")
  hookfunction(print, warn)
  print("Woa")
]])
```

### UNC / Unified Naming Convention
1. Has an **84%** score on the UNC test
2. Has an **75%** score on the sUNC test (Public August 2024 Version)

### Suggestions
Sumbit a issue
