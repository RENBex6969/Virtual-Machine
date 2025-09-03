
# VM
Runs roblox **scripts** on a executor environment with a partial **Roblox API**

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

### Services 
1. HttpService - Full
2. DebrisService - Full
3. RunService - Partial
4. PlayersService - Partial
5. RbxAnalyticsService - Partial
6. UserInputService - Partial
8. CorePackages - Partial
9. Lightning - Full
10. Game - Partial

### Suggestions
Sumbit a issue
