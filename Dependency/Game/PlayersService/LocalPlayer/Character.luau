return (function(Roblox, LocalPlayer)
  local Instance = Roblox.Instance
  local Vector3 = Roblox.Vector3
  local Enum = Roblox.Enum

  local Character = Instance.new("Model")
  Character.Name = "Character"
  Character.Parent = LocalPlayer

  local HumanoidRootPart = Instance.new("Part")
  HumanoidRootPart.Name = "HumanoidRootPart"
  HumanoidRootPart.Size = Vector3.new(2, 2, 1)
  HumanoidRootPart.Position = Vector3.new(0, 5, 0)
  HumanoidRootPart.Anchored = false
  HumanoidRootPart.Parent = Character
  Character.PrimaryPart = HumanoidRootPart

  local Head = Instance.new("Part")
  Head.Name = "Head"
  Head.Size = Vector3.new(2, 1, 1)
  Head.Position = Vector3.new(0, 6.5, 0)
  Head.Parent = Character

  local Torso = Instance.new("Part")
  Torso.Name = "Torso"
  Torso.Size = Vector3.new(2, 2, 1)
  Torso.Position = Vector3.new(0, 4, 0)
  Torso.Parent = Character

  local LeftArm = Instance.new("Part")
  LeftArm.Name = "LeftArm"
  LeftArm.Size = Vector3.new(1, 2, 1)
  LeftArm.Position = Vector3.new(-1.5, 4, 0)
  LeftArm.Parent = Character

  local RightArm = Instance.new("Part")
  RightArm.Name = "RightArm"
  RightArm.Size = Vector3.new(1, 2, 1)
  RightArm.Position = Vector3.new(1.5, 4, 0)
  RightArm.Parent = Character

  local LeftLeg = Instance.new("Part")
  LeftLeg.Name = "LeftLeg"
  LeftLeg.Size = Vector3.new(1, 2, 1)
  LeftLeg.Position = Vector3.new(-0.5, 2, 0)
  LeftLeg.Parent = Character

  local RightLeg = Instance.new("Part")
  RightLeg.Name = "RightLeg"
  RightLeg.Size = Vector3.new(1, 2, 1)
  RightLeg.Position = Vector3.new(0.5, 2, 0)
  RightLeg.Parent = Character

  local Humanoid = Instance.new("Humanoid")
  Humanoid.Parent = Character
  
  -- Movement
  Humanoid.WalkSpeed = 16
  Humanoid.JumpPower = 50           
  Humanoid.JumpHeight = 7.2
  Humanoid.UseJumpPower = true
  Humanoid.AutoRotate = true
  
  Humanoid.Health = 100
  Humanoid.MaxHealth = 100
  --Humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.Always
  --Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
  Humanoid.NameDisplayDistance = 100
  Humanoid.HealthDisplayDistance = 100
  
  
  Humanoid.HipHeight = 2  
  
  Humanoid.PlatformStand = false
  Humanoid.Sit = false
  Humanoid.BreakJointsOnDeath = true
  Humanoid.DisplayName = LocalPlayer.Name
  Humanoid.RigType = Enum.HumanoidRigType.R6
  
  local Animate = Instance.new("LocalScript")
  Animate.Name = "Animate"
  Animate.Parent = Character
  Animate.Source = "gsgsg"

  -- Assign the character to the LocalPlayer
  LocalPlayer.Character = Character
  
  Roblox.implementMethod("Model", "WaitForChild", function(Self, Class)
    return Character[Class]
  end)
  
  Roblox.implementMethod("Model", "BreakJoints", function(Self)
    for _, child in ipairs(Self:GetChildren()) do
      if child:IsA("BasePart") then
        child.Anchored = false
      end
    end
  end)
end)