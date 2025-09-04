return (function(Roblox)
  local CreateTemplate = function(ID)
    return {
      Name = "Virtual Group",
      Id = ID,
      Owner = {
        Name = "Renbex",
        Id = 0
      },
      EmblemUrl = "http://www.roblox.com/asset/?id=60428602",
      Description = "Virtualized Environment",
      Roles = {
        [1] = {
          Name = "Owner",
          Rank = 1
        }
      }
    }
  end

  Roblox.implementMethod("GroupService", "GetAlliesAsync", function(_, GroupId)
    return CreateTemplate(GroupId)
  end)

  Roblox.implementMethod("GroupService", "GetEnemiesAsync", function(_, GroupId)
    return CreateTemplate(GroupId)
  end)

  Roblox.implementMethod("GroupService", "GetGroupInfoAsync", function(_, GroupId)
    return CreateTemplate(GroupId)
  end)

  Roblox.implementMethod("GroupService", "GetGroupsAsync", function(_, UserId)
    return {
      CreateTemplate(1),
      CreateTemplate(2)
    }
  end)
end)