return (function(Roblox, Game)
  --[[
  Roblox.implementMethod("", "", function(_, X, Y)
    
  end)
  ]]

  local Database = Roblox.getReflectionDatabase()
  local Class = Database:GetClass("Workspace")

  for Name, _ in Class.Properties do
    --[[
    local Default = Class.DefaultProperties[Name]
    Roblox.implementProperty("Workspace", Name, function()
      return Default
    end)
    ]]
  end
  
  print(Game.Workspace.Scale)

  Roblox.implementMethod("Workspace", "DescendantAdded", function(_, X, Y)
    
  end)

end)