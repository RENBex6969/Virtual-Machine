
# VM
Runs roblox **scripts** on a executor environment with a partial **Roblox API**

### Installation
1. Install Lune from rokit
2. Fork this current repository
3. Follow instruction **1 & 2**
4. Install lute version 2025.1115

### Notes
I dont recommend at all using this in a production envrionment as it is not secured enough to prevent environment leaking

### Usage
The VM has bulit in API system you can use it on your scripts!

**Requiring the VM** :
```luau
local Sandbox = require("./Sandbox") -- Adjust the path to the path of Sandbox
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
Running the latest sUNC test is impossible due to software incompatibility and as the script communicates with the testing place

1. Has an **98%** score on the UNC test
2. Has an **91%** score on the sUNC test (Public August 2024 Version)

### Not to Implement

1. **Fully working debug Library** :
Full debug library is impossible since luau does not supply the full debug library like lua instead it is faked to trick some scripts using the UNC (deprecated) to ensure a function is working

### TODO :

1. **Optimizing**
Optimizing because the compilation of the Game environment differs for most people (lune)

2. **Modular**
Making the sandbox more modular for better implementation of features

### Roblox 

1. HttpService - Full
2. DebrisService - Full
3. GroupService - Full
4. TextService - Full

5. PlayersService - Partial
6. RbxAnalyticsService - Partial
7. UserInputService - Partial
8. TeleportService - Partial
9. RunService - Partial
10. SoundService - Partial
11. MarketplaceService - Partial

1. CorePackages - Partial
2. Lightning - Full
3. Game - Partial
4. CoreGui - Full

### Suggestions
Sumbit a issue