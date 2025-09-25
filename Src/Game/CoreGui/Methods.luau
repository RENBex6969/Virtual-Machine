return (function(Roblox, Game)
  local Instance = Roblox.Instance
  local CoreGui = Game:GetService("CoreGui")
  
  Roblox.implementMethod("CoreGui", "GetGuiObjectsAtPosition", function(_, X, Y)
    local Results = {}
    if X < 200 and y < 200 then
      local button = Instance.new("TextButton")
      button.Name = "TopLeftButton"
      button.Parent = CoreGui
      table.insert(Results, button)
    elseif X > 400 and y > 400 then
      local frame = Instance.new("Frame")
      frame.Name = "BottomRightFrame"
      frame.Parent = CoreGui
      table.insert(Results, frame)
    else
      local label = Instance.new("TextLabel")
      label.Name = "GenericLabel"
      label.Parent = CoreGui
      table.insert(Results, label)
    end
  
    return Results
  end)
  
end)