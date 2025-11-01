return (function(Roblox)
  Roblox.implementMethod("MarketplaceService", "GetDeveloperProductsAsync", function(_, ...)
    return Roblox.Instance.new("Pages")
  end)
  
  Roblox.implementMethod("MarketplaceService", "GetProductInfo", function(_, Id, InfoType)
    local isPlace = (InfoType == Enum.InfoType.Place or type(Id) == "number" and Id > 1000000)
    
    if isPlace then
      return {
        ["Name"] = "VM",
        ["Description"] = "A virtualized environment",
        ["UniverseId"] = Id,
        ["Creator"] = {
          ["Id"] = 0,
          ["Name"] = "Roblox",
          ["CreatorType"] = "User",
          ["HasVerifiedBadge"] = true
        },
        ["PriceInRobux"] = 0,
        ["Created"] = "2025-01-01T00:00:00Z",
        ["Updated"] = "2025-01-01T00:00:00Z",
        ["IsForSale"] = true,
        ["IsNew"] = true,
        ["IsPublicDomain"] = true,
        ["IconImageAssetId"] = 987654321,
        ["Visits"] = 1,
        ["Playing"] = 1,
        ["MaxPlayers"] = 1,
        ["Genre"] = "Adventure",
        ["AllowedGearGenres"] = {"All"},
        ["DeveloperProductIds"] = {}
      }
    else
      return {
        ["Name"] = "VM",
        ["Description"] = "",
        ["PriceInRobux"] = 0,
        ["ProductId"] = Id,
        ["ProductType"] = "Asset",
        ["Updated"] = "2025-01-01T00:00:00Z",
        ["ContentRatingTypeId"] = 0,
        ["IsPublicDomain"] = true,
        ["TargetId"] = Id,
        ["Creator"] = {
          ["Id"] = 0,
          ["Name"] = "Roblox",
          ["CreatorType"] = "User",
          ["HasVerifiedBadge"] = false
        },
        ["AssetTypeId"] = 0,
        ["Created"] = "2025-01-01T00:00:00Z",
        ["Remaining"] = math.huge,
        ["Sales"] = 0,
        ["IsLimited"] = true,
        ["IsLimitedUnique"] = false
      }
    end
  end)
  
  Roblox.implementMethod("MarketplaceService", "GetSubscriptionProductInfoAsync", function(_, Id)
    return {
      ["Name"] = "VM Premium",
      ["Description"] = "Totally real!",
      ["PriceInRobux"] = 100,
      ["ProductId"] = Id,
      ["ProductType"] = "GamePass",
      ["Updated"] = "2025-01-01T00:00:00Z",
      ["ContentRatingTypeId"] = 0,
      ["IsPublicDomain"] = true,
      ["SubscriptionDuration"] = 30,
      ["SubscriptionId"] = ProductId,
      ["ProductCategory"] = "Subscription"
    }
  end)
  
  
  Roblox.implementMethod("MarketplaceService", "GetUserSubscriptionDetailsAsync", function(_, userId, SubscriptionId)
    return {
      ["SubscriptionId"] = SubscriptionId,
      ["UserId"] = UserId,
      ["ProductId"] = 123456789,
      ["ProductType"] = "GamePass",
      ["StartDate"] = "2025-01-01T00:00:00Z",
      ["EndDate"] = "2025-12-31T23:59:59Z",
      ["IsActive"] = true,
      ["IsExpired"] = false,
      ["IsCancelled"] = false,
      ["HasPaymentMethod"] = true,
      ["BillingFrequency"] = "Monthly",
      ["Currency"] = "Robux",
      ["PriceInRobux"] = 100,
      ["RemainingTime"] = 2592000,
      ["NextPaymentDate"] = "2025-02-01T00:00:00Z",
      ["IsTrial"] = false,
      ["TrialEndDate"] = nil,
      ["PaymentMethod"] = "RobuxBalance", 
      ["CanRenew"] = true
    }
  end)


  Roblox.implementMethod("MarketplaceService", "GetUserSubscriptionPaymentHistoryAsync", function(_, UserId, ProductId)
    return {
      {
        ["UserId"] = UserId,
        ["ProductId"] = ProductId,
        ["SubscriptionId"] = ProductId,
        ["PaymentDate"] = "2025-01-01T12:00:00Z",
        ["PriceInRobux"] = 500,
        ["Currency"] = "Robux",
        ["TransactionId"] = "TX123456789"
      },
      {
        ["UserId"] = UserId,
        ["ProductId"] = ProductId,
        ["SubscriptionId"] = ProductId,
        ["PaymentDate"] = "2025-02-01T12:00:00Z",
        ["PriceInRobux"] = 1000,
        ["Currency"] = "Robux",
        ["TransactionId"] = "TX987654321"
      }
    }
  end)

  
  Roblox.implementMethod("MarketplaceService", "GetUserSubscriptionStatusAsync", function(_, UserId, ProductId)
    return {
      ["IsActive"] = false,
      ["HasSubscription"] = false,
      ["StartDate"] = "2025-01-01T00:00:00Z",
      ["EndDate"] = "2025-02-01T00:00:00Z",
      ["ProductId"] = ProductId,
      ["UserId"] = UserId,
      ["SubscriptionId"] = ProductId
    }
  end)

  Roblox.implementMethod("MarketplaceService", "GetUsersPriceLevelsAsync", function(_, UserIds, AssetId)
    local Compiled = {}
    for _, UserId in ipairs(UserIds) do
      Compiled[UserId] = {
        ["MembershipType"] = Roblox.Enum.MembershipType.None,
        ["PriceLevel"] = math.random(10, 40)
      }
    end
    return Compiled
  end)
  
  Roblox.implementMethod("MarketplaceService", "PlayerOwnsAsset", function(_, ...)
    return false
  end)
  
  Roblox.implementMethod("MarketplaceService", "PlayerOwnsBundle", function(_, ...)
    return false
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptBulkPurchase", function(_, ...)
    print("[VM]: PromptBulkPurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptBundlePurchase", function(_, ...)
    print("[VM]: PromptBundlePurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptGamePassPurchase", function(_, ...)
    print("[VM]: PromptGamePassPurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptPremiumPurchase", function(_, ...)
    print("[VM]: PromptPremiumPurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptProductPurchase", function(_, ...)
    print("[VM]: PromptProductPurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptPurchase", function(_, ...)
    print("[VM]: PromptPurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "PromptSubscriptionPurchase", function(_, ...)
    print("[VM]: PromptSubscriptionPurchase")
  end)
  
  Roblox.implementMethod("MarketplaceService", "UserOwnsGamePassAsync", function(_, ...)
    return false
  end)
end)