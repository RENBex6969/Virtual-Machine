
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
local Sandbox = require("./Sandbox") -- Adjust thr path to the path of Sandbox
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
1. Has an **89%** score on the UNC test
2. Has an **80%** score on the sUNC test (Public August 2024 Version)

### Not to Implement
1. **Debug Library - Non** :
Partially impossible since luau does not supply the full debug library like lua

2. **Hookfunction - Partial** : 
Impossinle since hookfunction is a low level function that isnt possible to recreate in luau

### Roblox 

1. HttpService - Full
2. DebrisService - Full
3. GroupService = Full
4. TextService = Full
5. PlayersService - Partial
6. RbxAnalyticsService - Partial
7. UserInputService - Partial
8. TeleportService - Partial
9. RunService - Partial
10. SoundService = Partial

1. CorePackages - Partial
2. Lightning - Full
3. Game - Partial

### Suggestions
Sumbit a issue