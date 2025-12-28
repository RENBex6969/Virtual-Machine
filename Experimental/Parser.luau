local Parser = {}

function Parser:Number(Token: string): number?
  Token = Token:upper()
  
  if Token == "INF" then
    return math.huge
  elseif Token == "-INF" then
    return -math.huge
  end
  
  return tonumber(Token)
end

function Parser:Pair(String: string): (number?, number?)
  local Left, Right = string.match(String, "%s*([^,%s]+)%s*[, ]%s*([^,%s]+)")
  
  if not Left or not Right then
    return nil, nil
  end
  
  return self:Number(Left), self:Number(Right)
end

function Parser:Triple(String: string): (number?, number?, number?)
  local A, B, C = string.match(String, "%s*([^,%s]+)%s*,%s*([^,%s]+)%s*,%s*([^,%s]+)")
  
  if not A or not B or not C then
    return nil, nil, nil
  end
  
  return self:Number(A), self:Number(B), self:Number(C)
end

function Parser:Quadruple(String: string): (number?, number?, number?, number?)
  local A, B, C, D = string.match(String, "%s*([^,%s]+)%s*,%s*([^,%s]+)%s*,%s*([^,%s]+)%s*,%s*([^,%s]+)")
  
  if not A or not B or not C or not D then
    return nil, nil, nil, nil
  end
  
  return self:Number(A), self:Number(B), self:Number(C), self:Number(D)
end

function Parser:Quintuple(String: string): (number?, number?, number?, number?, number?)
  local A, B, C, D, E = string.match(
    String,
    "%s*([^,%s]+)%s*[, ]%s*([^,%s]+)%s*[, ]%s*([^,%s]+)%s*[, ]%s*([^,%s]+)%s*[, ]%s*([^,%s]+)"
  )
  
  if not A or not B or not C or not D or not E then
    return nil, nil, nil, nil, nil
  end
  
  return self:Number(A), self:Number(B), self:Number(C), self:Number(D), self:Number(E)
end

function Parser:Hexuple(String: string): (number?, number?, number?, number?, number?, number?)
  local A, B, C, D, E, F = string.match(
    String,
    "%s*([^,%s]+)%s+([^,%s]+)%s+([^,%s]+)%s+([^,%s]+)%s+([^,%s]+)%s+([^,%s]+)"
  )
  
  if not A or not B or not C or not D or not E or not F then
    return nil, nil, nil, nil, nil, nil
  end
  
  return self:Number(A), self:Number(B), self:Number(C), self:Number(D), self:Number(E), self:Number(F)
end

function Parser:Decuple(String: string): (number?, number?, number?, number?, number?, number?, number?, number?, number?, number?)
  local A, B, C, D, E, F, G, H, I, J = string.match(
    String,
    "%s*([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)[,%s]+([^,%s]+)"
  )
  
  if not A then
    return nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
  end
  
  return self:Number(A), self:Number(B), self:Number(C), self:Number(D), self:Number(E), self:Number(F), self:Number(G), self:Number(H), self:Number(I), self:Number(J)
end

function Parser:TwoPair(String: string): UDim2?
  local XPart, YPart = string.match(String, "%{([^}]+)%}%s*,%s*%{([^}]+)%}")
  
  if not XPart or not YPart then
    return nil
  end
  
  local ScaleX, OffsetX = self:Pair(XPart)
  local ScaleY, OffsetY = self:Pair(YPart)
  
  if not ScaleX or not OffsetX or not ScaleY or not OffsetY then
    return nil
  end
  
  return ScaleX, OffsetX, ScaleY, OffsetY
end

function Parser:PairOfTriples(String: string)
  local A1, A2, A3, B1, B2, B3 = string.match(
    String,
    "{%s*([^,%s]+)%s*,%s*([^,%s]+)%s*,%s*([^,%s]+)%s*}%s*,%s*{%s*([^,%s]+)%s*,%s*([^,%s]+)%s*,%s*([^,%s]+)%s*}"
  )
  
  if not A1 or not A2 or not A3 or not B1 or not B2 or not B3 then
    return nil, nil, nil, nil, nil, nil
  end
  
  return self:Number(A1), self:Number(A2), self:Number(A3), self:Number(B1), self:Number(B2), self:Number(B3)
end

return Parser