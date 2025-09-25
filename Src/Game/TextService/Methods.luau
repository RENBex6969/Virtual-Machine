return (function(Roblox)
  Roblox.implementMethod("TextService", "FilterAndTranslateStringAsync", function(_, Text, Player, LanguageCode)
    return {
      GetNonChatStringForBroadcastAsync = function(Player)
        return Text
      end, 
      GetNonChatStringForPlayerAsync = function(...) 
        return Text
      end,
    }
  end)
  
  Roblox.implementMethod("TextService", "FilterStringAsync", function(_, Text, Player)
    return {
      GetNonChatStringForBroadcastAsync = function(Player)
        return Text
      end, 
      GetNonChatStringForPlayerAsync = function(...) 
        return Text
      end,
    }
  end)
  
  Roblox.implementMethod("TextService", "GetFamilyInfoAsync", function(_, ...)
    return
  end)
  
  Roblox.implementMethod("TextService", "GetTextBoundsAsync", function(_, Args)
    local text = Args.Text or ""
    local fontSize = Args.Size or 16
    local font = Args.Font or Enum.Font.SourceSans
    local frameSize = Args.Width and Vector2.new(Args.Width, math.huge) or nil
  
    local charWidth = fontSize * 0.6
    local lineHeight = fontSize * 1.2
    
    local width = 0
    local height = lineHeight
    local maxWidth = frameSize and frameSize.X or math.huge
    
    for char in text:gmatch(".") do
      width = width + charWidth
      if width > maxWidth then
        height = height + lineHeight
        width = charWidth
      end
    end
    
    return Roblox.Vector2.new(width, height)
  end)
  
  Roblox.implementMethod("TextService", "GetTextSize", function(_, Text, FontSize, Font, FrameSize)
    local charWidth = FontSize * 0.6
    local lineHeight = FontSize * 1.2
    
    local width = 0
    local height = lineHeight
    local maxWidth = FrameSize and FrameSize.X or math.huge
    
    for char in Text:gmatch(".") do
      width = width + charWidth
      if width > maxWidth then
        height = height + lineHeight
        width = charWidth
      end
    end
    
    return Roblox.Vector2.new(width, height)
  end)
  
  Roblox.implementMethod("TextService", "GetTextSizeOffsetAsync", function(_, FontSize, Font)
    return Roblox.Vector2.new(FontSize * 0.1, FontSize * 0.2)
  end)
  
end)