return (function(Roblox, Game)
  local Instance = Roblox.Instance
  local Players = Game:GetService("Players")

  local LocalPlayer = Instance.new("Player")
  LocalPlayer.Name = "VM"
  LocalPlayer.Parent = Players
  
  LocalPlayer.DisplayName = "Virtual Machine"
  LocalPlayer.FollowUserId = 0
  LocalPlayer.UserId = 0
  LocalPlayer.AccountAge = 0
  
  require("./Character")(Roblox, LocalPlayer)
  
  LocalPlayer.MembershipType = Roblox.Enum.MembershipType.None
  LocalPlayer.PartyId = "Virtual Machine"
  
  --LocalPlayer.Team
  LocalPlayer.Neutral = true
  LocalPlayer.TeamColor = Roblox.BrickColor.new("White")
  
  -- Appearance-related
  LocalPlayer.CharacterAppearanceId = 0
  LocalPlayer.CanLoadCharacterAppearance = false
  LocalPlayer.HealthDisplayDistance = 0
  LocalPlayer.NameDisplayDistance = 0
  
  -- Network/connection
  --LocalPlayer.ReplicatedFirst = nil
  
  local PlayerGui = Instance.new("Folder")
  PlayerGui.Parent = LocalPlayer
  PlayerGui.Name = "PlayerGui"
  
  Roblox.implementMethod("Player", "WaitForChild", function(_, ClassName)
    return ClassName
  end)
  
  Roblox.implementMethod("Player", "FindFirstChild", function(self, Name, Recursive)
    if type(self.Children) == "table" then
      for _, child in ipairs(self.Children) do
        if child.Name == Name then
          return child
        end
        if Recursive and child.FindFirstChild then
          local found = child:FindFirstChild(Name, true)
          if found then 
            return found 
          end
        end
      end
    end
    return nil
  end)
  
  local PlayerScripts = Instance.new("Folder")
  PlayerScripts.Parent = LocalPlayer
  PlayerScripts.Name = "PlayerScripts"
  
  local Backpack = Instance.new("Folder")
  Backpack.Parent = LocalPlayer
  Backpack.Name = "Backpack"
  
  local StarterGear = Instance.new("Folder")
  StarterGear.Parent = LocalPlayer
  StarterGear.Name = "StarterGear"

  LocalPlayer.CameraMaxZoomDistance = 128
  LocalPlayer.CameraMinZoomDistance = 0.5
  LocalPlayer.CameraMode = Roblox.Enum.CameraMode.Classic
  LocalPlayer.DevEnableMouseLock = true
  
  --LocalPlayer.DevCameraOcclusionMode = Roblox.Enum.DevCameraOcclusionMode
  --LocalPlayer.DevComputerMovementMode = Roblox.Enum.DevComputerMovementMode.Default
  --LocalPlayer.DevTouchMovementMode = Roblox.Enum.DevTouchMovementMode.Default
  --LocalPlayer.DevComputerCameraMode = Roblox.Enum.ComputerCameraMovementMode.Default
  --LocalPlayer.DevTouchCameraMode = Roblox.Enum.TouchCameraMovementMode.Default
  --LocalPlayer.DevEnableCameraMode = true
  
  --LocalPlayer.ChatMode = Roblox.Enum.ChatMode.TextAndVoice
  --LocalPlayer.ThirdPartyTextChatRestrictionStatus = Roblox.Enum.ChatRestrictionStatus
  LocalPlayer.HasVerifiedBadge = true
  LocalPlayer.GameplayPaused = false
  
  LocalPlayer.AutoJumpEnabled = false
  LocalPlayer.MaxSimulationRadius = 1000
  LocalPlayer.SimulationRadius = 1000
  LocalPlayer.LocaleId = "en-us"
  
  Players["LocalPlayer"] = LocalPlayer
  
  Roblox.implementProperty("Players", "LocalPlayer", function()
    return LocalPlayer
  end, function()
    error("Cannot modify LocalPlayer")
  end)
end)