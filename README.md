# ⚡ VM

![version](https://img.shields.io/badge/version-pre--alpha--0.1-red?style=flat-square)
![license](https://img.shields.io/badge/license-MIT-green?style=flat-square)
![status](https://img.shields.io/badge/status-in--development-yellow?style=flat-square)

Runs Roblox **scripts** inside an executor-like environment with a **partial Roblox API** implementation.

> ⚠️ **It is usable in a production environment, but proceed with caution.**  
> The sandbox is not fully secured against environment leakage.

### Installation
1. Install [Lune](https://lune-org.github.io/docs/getting-started/1-installation/)
2. Install [Lute](https://github.com/luau-lang/lute/releases/tag/0.1.0-nightly.20251115) version **2025.1115**
3. Fork this repository

### Syntax Issue
Try setting **HookOp** to false in ``config.json``

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

## s/UNC Scores

| Unified Naming Convention's | Score |
|-----------|-------|
| UNC       | **99%** |
| sUNC      | **92%** |

## Missing
Functions that are deemed useful and submitted for review will be added. Additionally, any functions defined in the **sUNC** [standard](https://docs.sunc.su/About/what-is-sunc/) will be implemented as part of future updates.

## Updates
I'm currently in the process of refactoring all modules to improve security and readability.

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
