return (function(Roblox, Game)
  Roblox.implementMethod("Players", "BanAsync", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "Chat", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "CreateHumanoidModelFromDescription", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "CreateHumanoidModelFromUserId", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "GetBanHistoryAsync", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "GetCharacterAppearanceInfoAsync", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "GetFriendsAsync", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "GetHumanoidDescriptionFromOutfitId", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "GetHumanoidDescriptionFromUserId", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "GetNameFromUserIdAsync", function(_, ...)
    for _, Player in Game.Players:GetChildren()  do
      if Player.UserId == UserId then
        return Player.Name
      end
    end 
    return nil
  end)

  Roblox.implementMethod("Players", "GetPlayerByUserId", function(_, UserId)
    for _, Player in Game.Players:GetChildren()  do
      if Player.UserId == UserId then
        return Player
      end
    end
    return nil
  end)

  Roblox.implementMethod("Players", "GetPlayerFromCharacter", function(_, Character)
    for _, Player in pairs(Players:GetPlayers()) do
      if Player.Character == Character then
        return Player
      end
    end
    return nil
  end)

  Roblox.implementMethod("Players", "GetPlayers", function(_, ...)
    return {
      Game.Players.LocalPlayer
    }
  end)

  Roblox.implementMethod("Players", "GetUserIdFromNameAsync", function(_, Name)
    for _, Player in pairs(Players:GetPlayers()) do
      if Player.Name == Name then
        return Player.UserId
      end
    end 
  end)

  Roblox.implementMethod("Players", "GetUserThumbnailAsync", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "SetChatStyle", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "TeamChat", function(_, ...)
    return 
  end)

  Roblox.implementMethod("Players", "UnbanAsync", function(_, ...)
    return 
  end)
end)