
local string_format = string.format
local math_floor = math.floor
local select = select
return {
	tobit = function(x)
		x = x%(2^32)
		if x >= 2^31 then
			return x-2^32
		end
		return x
	end,
	tohex = function(x, n)
		if n == nil then
			n = 8
		elseif n < 0 then
			n = -n
			x = x%(2^(n*4))
			x = string_format("%0"..n.."X", x)
			return x
		end
		x = x%(2^(n*4))
		x = string_format("%0"..n.."x", x)
		return x
	end,
	bnot = function(x)
		x = x%(2^32)
		local output = 0
		for i=0, 31 do
			if x%2 == 0 then
				output = output+2^i
			end
			x = math_floor(x/2)
		end
		if output >= 2^31 then
			output = output-2^32
		end
		return output
	end,
	bor = function(...)
		local output = 0
		local bits = {}
		for i=1, select("#", ...) do
			local x = select(i, ...)
			x = x%(2^32)
			for i=1, 32 do
				if x%2 ~= 0 and bits[i] == nil then
					bits[i] = true
					output = output+2^(i-1)
				end
				x = math_floor(x/2)
			end
		end
		if output >= 2^31 then
			output = output-2^32
		end
		return output
	end,
	band = function(...)
		local output = 2^32-1
		local bits = {}
		for i=1, select("#", ...) do
			local x = select(i, ...)
			x = x%(2^32)
			for i=1, 32 do
				if x%2 == 0 and bits[i] == nil then
					bits[i] = true
					output = output-2^(i-1)
				end
				x = math_floor(x/2)
			end
		end
		if output >= 2^31 then
			output = output-2^32
		end
		return output
	end,
	bxor = function(...)
		local bits = {}
		for i=1, select("#", ...) do
			local x = select(i, ...)
			x = x%(2^32)
			for i=1, 32 do
				if x%2 ~= 0 then
					bits[i] = not bits[i]
				end
				x = math_floor(x/2)
			end
		end
		local output = 0
		for i=1, 32 do
			if bits[i] == true then
				output = output+2^(i-1)
			end
		end
		if output >= 2^31 then
			output = output-2^32
		end
		return output
	end,
	lshift = function(x, n)
		x = x%(2^32)
		n = n%32
		x = x*(2^n)
		x = x%(2^32)
		if x >= 2^31 then
			x = x-2^32
		end
		return x
	end,
	rshift = function(x, n)
		x = x%(2^32)
		n = n%32
		for i=1, n do
			x = math_floor(x/2)
		end
		if x >= 2^31 then
			x = x-2^32
		end
		return x
	end,
	arshift = function(x, n)
		x = x%(2^32)
		n = n%32
		local extension = 0
		if x >= 2^31 then
			extension = 2^31
		end
		for i=1, n do
			x = math_floor(x/2)+extension
		end
		if x >= 2^31 then
			x = x-2^32
		end
		return x
	end,
	rol = function(x, n)
		x = x%(2^32)
		n = n%32
		for i=1, n do
			x = x*2
			if x >= 2^32 then
				x = x%(2^32)+1
			end
		end
		if x >= 2^31 then
			x = x-2^32
		end
		return x
	end,
	ror = function(x, n)
		x = x%(2^32)
		n = n%32
		for i=1, n do
			local msb = 0
			if x%2 ~= 0 then
				msb = 2^31
			end
			x = math_floor(x/2)+msb
		end
		if x >= 2^31 then
			x = x-2^32
		end
		return x
	end,
	bswap = function(x)
		x = x%(2^32)
		local b1 = math_floor(x/0x1000000)
		local b2 = math_floor(x/0x10000)%0x100
		local b3 = math_floor(x/0x100)%0x100
		local b4 = x%0x100
		x = b4*0x1000000+b3*0x10000+b2*0x100+b1
		if x >= 2^31 then
			x = x-2^32
		end
		return x
	end,
}
