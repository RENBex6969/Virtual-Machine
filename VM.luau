local VM = require("./Sandbox")

--[[VM:Run([=[
print(loadstring("#({...})"))

local passes, fails, undefined = 0, 0, 0
local running = 0

local function getGlobal(path)
	local value = getgenv and getgenv() or getfenv(2)

	while value ~= nil and path ~= "" do
		local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end

	return value
end

local function test(name, aliases, callback, target)
	running = running + 1

	task.spawn(function()
		if not callback then
			print("⏺️ " .. name)
		elseif not getGlobal(name) then
			fails = fails + 1
			warn("⛔ " .. name)
		else
			local success, message = pcall(callback)
	        name = tostring(name)
			message = tostring(message)
			if success then
				passes = passes + 1
				print("✅ " .. tostring(name) .. (tostring(message) and " • " .. tostring(message) or ""))
			else
				fails = fails + 1
				warn("⛔ " .. name .. " failed: " .. message)
			end
		end
	
		local undefinedAliases = {}
	
		for _, alias in ipairs(aliases) do
			if getGlobal(alias) == nil then
				table.insert(undefinedAliases, alias)
			end
		end
	
		if #undefinedAliases > 0 then
			undefined = undefined + 1
			warn("⚠️ " .. table.concat(undefinedAliases, ", "))
		end

		running = running - 1
	end)
end

-- Header and summary

print("\n")

print("UNC Environment Check")
print("✅ - Pass, ⛔ - Fail, ⏺️ - No test, ⚠️ - Missing aliases\n")


	

-- Cache

test("cache.invalidate", {}, function()
	local container = Instance.new("Folder")
	local part = Instance.new("Part", container)
	cache.invalidate(container:FindFirstChild("Part"))
	assert(part ~= container:FindFirstChild("Part"), "Reference `part` could not be invalidated")
end)

test("cache.iscached", {}, function()
	local part = Instance.new("Part")
	assert(cache.iscached(part), "Part should be cached")
	cache.invalidate(part)
	assert(not cache.iscached(part), "Part should not be cached")
end)

test("cache.replace", {}, function()
	local part = Instance.new("Part")
	local fire = Instance.new("Fire")
	cache.replace(part, fire)
	assert(part ~= fire, "Part was not replaced with Fire")
end)

test("cloneref", {}, function()
	
end)

test("compareinstances", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "Clone should not be equal to original")
	assert(compareinstances(part, clone), "Clone should be equal to original when using compareinstances()")
end)

-- Closures

local function shallowEqual(t1, t2)
	if t1 == t2 then
		return true
	end

	local UNIQUE_TYPES = {
		["function"] = true,
		["table"] = true,
		["userdata"] = true,
		["thread"] = true,
	}

	for k, v in pairs(t1) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(t2) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t1[k] ~= v then
			return false
		end
	end

	return true
end

test("checkcaller", {}, function()
	assert(checkcaller(), "Main scope should return true")
end)

test("clonefunction", {}, function()
	local function test()
		return "success"
	end
	local copy = clonefunction(test)
	assert(test() == copy(), "The clone should return the same value as the original")
	assert(test ~= copy, "The clone should not be equal to the original")
end)

test("getcallingscript", {})

test("getscriptclosure", {"getscriptfunction"}, function()
	local module = game:GetService("CoreGui").RobloxGui.Modules.Common.Constants
	local constants = getrenv().require(module)
	local generated = getscriptclosure(module)()
	assert(constants ~= generated, "Generated module should not match the original")
	assert(shallowEqual(constants, generated), "Generated constant table should be shallow equal to the original")
end)

test("hookfunction", {"replaceclosure"}, function()
	local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "Function should return false")
	assert(ref() == true, "Original function should return true")
	assert(test ~= ref, "Original function should not be same as the reference")
end)

test("iscclosure", {}, function()
	assert(iscclosure(print) == true, "Function 'print' should be a C closure")
	assert(iscclosure(function() end) == false, "Executor function should not be a C closure")
end)

test("islclosure", {}, function()
	assert(islclosure(print) == false, "Function 'print' should not be a Lua closure")
	assert(islclosure(function() end) == true, "Executor function should be a Lua closure")
end)

test("isexecutorclosure", {"checkclosure", "isourclosure"}, function()
	assert(isexecutorclosure(isexecutorclosure) == true, "Did not return true for an executor global")
	assert(isexecutorclosure(newcclosure(function() end)) == true, "Did not return true for an executor C closure")
	assert(isexecutorclosure(function() end) == true, "Did not return true for an executor Luau closure")
	assert(isexecutorclosure(print) == false, "Did not return false for a Roblox global")
end)

test("loadstring", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local bytecode = getscriptbytecode(animate)
	local func = loadstring(bytecode)
	assert(type(func) ~= "function", "Luau bytecode should not be loadable!")
	assert(assert(loadstring("return ... + 1"))(1) == 2, "Failed to do simple math")
	assert(type(select(2, loadstring("f"))) == "string", "Loadstring did not return anything for a compiler error")
end)

test("newcclosure", {}, function()
	local function test()
		return true
	end
	local testC = newcclosure(test)
	assert(test() == testC(), "New C closure should return the same value as the original")
	assert(test ~= testC, "New C closure should not be same as the original")
	assert(iscclosure(testC), "New C closure should be a C closure")
end)

-- Console

test("rconsoleclear", {"consoleclear"})

test("rconsolecreate", {"consolecreate"})

test("rconsoledestroy", {"consoledestroy"})

test("rconsoleinput", {"consoleinput"})

test("rconsoleprint", {"consoleprint"})

test("rconsolesettitle", {"rconsolename", "consolesettitle"})

-- Crypt

test("crypt.base64encode", {"crypt.base64.encode", "crypt.base64_encode", "base64.encode", "base64_encode"}, function()
	assert(crypt.base64encode("test") == "dGVzdA==", "Base64 encoding failed")
end)

test("crypt.base64decode", {"crypt.base64.decode", "crypt.base64_decode", "base64.decode", "base64_decode"}, function()
	assert(crypt.base64decode("dGVzdA==") == "test", "Base64 decoding failed")
end)

test("crypt.encrypt", {}, function()
	local key = crypt.generatekey()
	local encrypted, iv = crypt.encrypt("test", key, nil, "CBC")
	assert(iv, "crypt.encrypt should return an IV")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.decrypt", {}, function()
	local key, iv = crypt.generatekey(), crypt.generatekey()
	local encrypted = crypt.encrypt("test", key, iv, "CBC")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)

test("crypt.generatebytes", {}, function()
	local size = math.random(10, 100)
	local bytes = crypt.generatebytes(size)
	assert(#crypt.base64decode(bytes) == size, "The decoded result should be " .. size .. " bytes long (got " .. #crypt.base64decode(bytes) .. " decoded, " .. #bytes .. " raw)")
end)

test("crypt.generatekey", {}, function()
	local key = crypt.generatekey()
	assert(#crypt.base64decode(key) == 32, "Generated key should be 32 bytes long when decoded")
end)

test("crypt.hash", {}, function()
	local algorithms = {'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', 'sha3-512'}
	for _, algorithm in ipairs(algorithms) do
		local hash = crypt.hash("test", algorithm)
		assert(hash, "crypt.hash on algorithm '" .. algorithm .. "' should return a hash")
	end
end)

--- Debug

test("debug.getconstant", {}, function()
	local function test()
		print("Hello, world!")
	end
	assert(debug.getconstant(test, 1) == "print", "First constant must be print")
	assert(debug.getconstant(test, 2) == nil, "Second constant must be nil")
	assert(debug.getconstant(test, 3) == "Hello, world!", "Third constant must be 'Hello, world!'")
end)

test("debug.getconstants", {}, function()
	local function test()
		local num = 5000 .. 50000
		print("Hello, world!", num, warn)
	end
	local constants = debug.getconstants(test)
	assert(constants[1] == 50000, "First constant must be 50000")
	assert(constants[2] == "print", "Second constant must be print")
	assert(constants[3] == nil, "Third constant must be nil")
	assert(constants[4] == "Hello, world!", "Fourth constant must be 'Hello, world!'")
	assert(constants[5] == "warn", "Fifth constant must be warn")
end)

test("debug.getinfo", {}, function()
	local types = {
		source = "string",
		short_src = "string",
		func = "function",
		what = "string",
		currentline = "number",
		name = "string",
		nups = "number",
		numparams = "number",
		is_vararg = "number",
	}
	local function test(...)
		print(...)
	end
	local info = debug.getinfo(test)
	for k, v in pairs(types) do
		assert(info[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		assert(type(info[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(info[k]) .. ")")
	end
end)

test("debug.getproto", {}, function()
	local function test()
		local function proto()
			return true
		end
	end
	local proto = debug.getproto(test, 1, true)[1]
	local realproto = debug.getproto(test, 1)
	assert(proto, "Failed to get the inner function")
	assert(proto() == true, "The inner function did not return anything")
	if not realproto() then
		return "Proto return values are disabled on this executor"
	end
end)

test("debug.getprotos", {}, function()
	local function test()
		local function _1()
			return true
		end
		local function _2()
			return true
		end
		local function _3()
			return true
		end
	end
	for Index in ipairs(debug.getprotos(test)) do
		local proto = debug.getproto(test, Index, true)[1]
		local realproto = debug.getproto(test, Index)
		assert(proto(), "Failed to get inner function " .. Index)
		if not realproto() then
			return "Proto return values are disabled on this executor"
		end
	end
end)

test("debug.getstack", {}, function()
	local _ = "a" .. "b"
	assert(debug.getstack(1, 1) == "ab", "The first item in the stack should be 'ab'")
	assert(debug.getstack(1)[1] == "ab", "The first item in the stack table should be 'ab'")
end)

test("debug.getupvalue", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	assert(debug.getupvalue(test, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
end)

test("debug.getupvalues", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	local upvalues = debug.getupvalues(test)
	assert(upvalues[1] == upvalue, "Unexpected value returned from debug.getupvalues")
end)

test("debug.setconstant", {}, function()
	local function test()
		return "fail"
	end
	debug.setconstant(test, 1, "success")
	assert(test() == "success", "debug.setconstant did not set the first constant")
end)

test("debug.setstack", {}, function()
	local function test()
		return "fail", debug.setstack(1, 1, "success")
	end
	assert(test() == "success", "debug.setstack did not set the first stack item")
end)

test("debug.setupvalue", {}, function()
	local function upvalue()
		return "fail"
	end
	local function test()
		return upvalue()
	end
	debug.setupvalue(test, 1, function()
		return "success"
	end)
	assert(test() == "success", "debug.setupvalue did not set the first upvalue")
end)

-- Filesystem

if isfolder and makefolder and delfolder then
	if isfolder(".tests") then
		delfolder(".tests")
	end
	makefolder(".tests")
end

test("readfile", {}, function()
	writefile(".tests/readfile.txt", "success")
	assert(readfile(".tests/readfile.txt") == "success", "Did not return the contents of the file")
end)

test("listfiles", {}, function()
	makefolder(".tests/listfiles")
	writefile(".tests/listfiles/test_1.txt", "success")
	writefile(".tests/listfiles/test_2.txt", "success")
	local files = listfiles(".tests/listfiles")
	assert(#files == 2, "Did not return the correct number of files")
	assert(isfile(files[1]), "Did not return a file path")
	assert(readfile(files[1]) == "success", "Did not return the correct files")
	makefolder(".tests/listfiles_2")
	makefolder(".tests/listfiles_2/test_1")
	makefolder(".tests/listfiles_2/test_2")
	local folders = listfiles(".tests/listfiles_2")
	assert(#folders == 2, "Did not return the correct number of folders")
	assert(isfolder(folders[1]), "Did not return a folder path")
end)

test("writefile", {}, function()
	writefile(".tests/writefile.txt", "success")
	assert(readfile(".tests/writefile.txt") == "success", "Did not write the file")
	local requiresFileExt = pcall(function()
		writefile(".tests/writefile", "success")
		assert(isfile(".tests/writefile.txt"))
	end)
	if not requiresFileExt then
		return "This executor requires a file extension in writefile"
	end
end)

test("makefolder", {}, function()
	makefolder(".tests/makefolder")
	assert(isfolder(".tests/makefolder"), "Did not create the folder")
end)

test("appendfile", {}, function()
	writefile(".tests/appendfile.txt", "su")
	appendfile(".tests/appendfile.txt", "cce")
	appendfile(".tests/appendfile.txt", "ss")
	assert(readfile(".tests/appendfile.txt") == "success", "Did not append the file")
end)

test("isfile", {}, function()
	writefile(".tests/isfile.txt", "success")
	assert(isfile(".tests/isfile.txt") == true, "Did not return true for a file")
	assert(isfile(".tests") == false, "Did not return false for a folder")
	assert(isfile(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfile(".tests/doesnotexist.exe")) .. ")")
end)

test("isfolder", {}, function()
	assert(isfolder(".tests") == true, "Did not return false for a folder")
	assert(isfolder(".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. tostring(isfolder(".tests/doesnotexist.exe")) .. ")")
end)

test("delfolder", {}, function()
	makefolder(".tests/delfolder")
	delfolder(".tests/delfolder")
	assert(isfolder(".tests/delfolder") == false, "Failed to delete folder (isfolder = " .. tostring(isfolder(".tests/delfolder")) .. ")")
end)

test("delfile", {}, function()
	writefile(".tests/delfile.txt", "Hello, world!")
	delfile(".tests/delfile.txt")
	assert(isfile(".tests/delfile.txt") == false, "Failed to delete file (isfile = " .. tostring(isfile(".tests/delfile.txt")) .. ")")
end)

test("dofile", {})

-- Input

test("isrbxactive", {"isgameactive"}, function()
	assert(type(isrbxactive()) == "boolean", "Did not return a boolean value")
end)

test("mouse1click", {})

test("mouse1press", {})

test("mouse1release", {})

test("mouse2click", {})

test("mouse2press", {})

test("mouse2release", {})

test("mousemoveabs", {})

test("mousemoverel", {})

test("mousescroll", {})

-- Instances

test("fireclickdetector", {}, function()
	local detector = Instance.new("ClickDetector")
	fireclickdetector(detector, 50, "MouseHoverEnter")
end)

test("getcallbackvalue", {}, function()
	local bindable = Instance.new("BindableFunction")
	local function test()
	end
	bindable.OnInvoke = test
	assert(getcallbackvalue(bindable, "OnInvoke") == test, "Did not return the correct value")
end)

test("getconnections", {}, function()
	local types = {
		Enabled = "boolean",
		ForeignState = "boolean",
		LuaConnection = "boolean",
		Function = "function",
		Thread = "thread",
		Fire = "function",
		Defer = "function",
		Disconnect = "function",
		Disable = "function",
		Enable = "function",
	}
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() end)
	local connection = getconnections(bindable.Event)[1]
	for k, v in pairs(types) do
		assert(connection[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		assert(type(connection[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. type(connection[k]) .. ")")
	end
end)

test("getcustomasset", {}, function()
	writefile(".tests/getcustomasset.txt", "success")
	local contentId = getcustomasset(".tests/getcustomasset.txt")
	assert(type(contentId) == "string", "Did not return a string")
	assert(#contentId > 0, "Returned an empty string")
	assert(string.match(contentId, "rbxasset://") == "rbxasset://", "Did not return an rbxasset url")
end)

test("gethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local property, isHidden = gethiddenproperty(fire, "size_xml")
	assert(property == 5, "Did not return the correct value")
	assert(isHidden == true, "Did not return whether the property was hidden")
end)

test("sethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local hidden = sethiddenproperty(fire, "size_xml", 10)
	assert(hidden, "Did not return true for the hidden property")
	assert(gethiddenproperty(fire, "size_xml") == 10, "Did not set the hidden property")
end)

test("gethui", {}, function()
	assert(typeof(gethui()) == "Instance", "Did not return an Instance")
end)

test("getinstances", {}, function()
	assert(getinstances()[1]:IsA("Instance"), "The first value is not an Instance")
end)

test("getnilinstances", {}, function()
	assert(getnilinstances()[1]:IsA("Instance"), "The first value is not an Instance")
	assert(getnilinstances()[1].Parent == nil, "The first value is not parented to nil")
end)

test("isscriptable", {}, function()
	local fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "Size") == true, "Did not return true for a scriptable property (Size)")
end)

test("setscriptable", {}, function()
	local fire = Instance.new("Fire")
	local wasScriptable = setscriptable(fire, "size_xml", true)
	assert(wasScriptable == false, "Did not return false for a non-scriptable property (size_xml)")
	assert(isscriptable(fire, "size_xml") == true, "Did not set the scriptable property")
	fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "⚠️⚠️ setscriptable persists between unique instances ⚠️⚠️")
end)

test("setrbxclipboard", {})

-- Metatable

test("getrawmetatable", {}, function()
	local metatable = { __metatable = "Locked!" }
	local object = setmetatable({}, metatable)
	assert(getrawmetatable(object) == metatable, "Did not return the metatable")
end)

test("hookmetamethod", {}, function()
	local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "Locked!" })
	local ref = hookmetamethod(object, "__index", function() return true end)
	assert(object.test == true, "Failed to hook a metamethod and change the return value")
	assert(ref() == false, "Did not return the original function")
end)

test("getnamecallmethod", {}, function()
	local method
	local ref
	ref = hookmetamethod(game, "__namecall", function(...)
		if not method then
			method = getnamecallmethod()
		end
		return ref(...)
	end)
	game:GetService("Lighting")
	assert(method == "GetService", "Did not get the correct method (GetService)")
end)

test("isreadonly", {}, function()
	local object = {}
	table.freeze(object)
	assert(isreadonly(object), "Did not return true for a read-only table")
end)

test("setrawmetatable", {}, function()
	local object = setmetatable({}, { __index = function() return false end, __metatable = "Locked!" })
	local objectReturned = setrawmetatable(object, { __index = function() return true end })
	assert(object, "Did not return the original object")
	assert(object.test == true, "Failed to change the metatable")
	if objectReturned then
		return objectReturned == object and "Returned the original object" or "Did not return the original object"
	end
end)

test("setreadonly", {}, function()
	local object = { success = false }
	table.freeze(object)
	setreadonly(object, false)
	object.success = true
	assert(object.success, "Did not allow the table to be modified")
end)

-- Miscellaneous

test("identifyexecutor", {"getexecutorname"}, function()
	local name, version = identifyexecutor()
	assert(type(name) == "string", "Did not return a string for the name")
	return type(version) == "string" and "Returns version as a string" or "Does not return version"
end)

test("lz4compress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("lz4decompress", {}, function()
	local raw = "Hello, world!"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "Compression did not return a string")
	assert(lz4decompress(compressed, #raw) == raw, "Decompression did not return the original string")
end)

test("messagebox", {})

test("queue_on_teleport", {"queueonteleport"})

test("request", {"http.request", "http_request"}, function()
	local response = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})
	assert(type(response) == "table", "Response must be a table")
	assert(response.StatusCode == 200, "Did not return a 200 status code")
	local data = game:GetService("HttpService"):JSONDecode(response.Body)
	assert(type(data) == "table" and type(data["user-agent"]) == "string", "Did not return a table with a user-agent key")
	return "User-Agent: " .. data["user-agent"]
end)

test("setclipboard", {"toclipboard"})

test("setfpscap", {}, function()
	local renderStepped = game:GetService("RunService").RenderStepped
	local function step()
		renderStepped:Wait()
		local sum = 0
		for _ = 1, 5 do
			sum = sum + 1 / renderStepped:Wait()
		end
		return math.round(sum / 5)
	end
	setfpscap(60)
	local step60 = step()
	setfpscap(0)
	local step0 = step()
	return step60 .. "fps @60 • " .. step0 .. "fps @0"
end)

-- Scripts

test("getgc", {}, function()
	local gc = getgc()
	assert(type(gc) == "table", "Did not return a table")
	assert(#gc > 0, "Did not return a table with any values")
end)

test("getgenv", {}, function()
	getgenv().__TEST_GLOBAL = true
	assert(__TEST_GLOBAL, "Failed to set a global variable")
	getgenv().__TEST_GLOBAL = nil
end)

test("getloadedmodules", {}, function()
	local modules = getloadedmodules()
	assert(type(modules) == "table", "Did not return a table")
	assert(#modules > 0, "Did not return a table with any values")
	assert(typeof(modules[1]) == "Instance", "First value is not an Instance")
	assert(modules[1]:IsA("ModuleScript"), "First value is not a ModuleScript")
end)

test("getrenv", {}, function()
	assert(_G ~= getrenv()._G, "The variable _G in the executor is identical to _G in the game")
end)

test("getrunningscripts", {}, function()
	local scripts = getrunningscripts()
	assert(type(scripts) == "table", "Did not return a table")
	assert(#scripts > 0, "Did not return a table with any values")
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getscriptbytecode", {"dumpstring"}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local bytecode = getscriptbytecode(animate)
	assert(type(bytecode) == "string", "Did not return a string for Character.Animate (a " .. animate.ClassName .. ")")
end)

test("getscripthash", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate:Clone()
	local hash = getscripthash(animate)
	local source = animate.Source
	animate.Source = "print('Hello, world!')"
	task.defer(function()
		animate.Source = source
	end)
	local newHash = getscripthash(animate)
	assert(hash ~= newHash, "Did not return a different hash for a modified script")
	assert(newHash == getscripthash(animate), "Did not return the same hash for a script with the same source")
end)

test("getscripts", {}, function()
	local scripts = getscripts()
	assert(type(scripts) == "table", "Did not return a table")
	assert(#scripts > 0, "Did not return a table with any values")
	assert(typeof(scripts[1]) == "Instance", "First value is not an Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)

test("getsenv", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local env = getsenv(animate)
	assert(type(env) == "table", "Did not return a table for Character.Animate (a " .. animate.ClassName .. ")")
	assert(env.script == animate, "The script global is not identical to Character.Animate")
end)

test("getthreadidentity", {"getidentity", "getthreadcontext"}, function()
	assert(type(getthreadidentity()) == "number", "Did not return a number")
end)

test("setthreadidentity", {"setidentity", "setthreadcontext"}, function()
	setthreadidentity(3)
	assert(getthreadidentity() == 3, "Did not set the thread identity")
end)

-- Drawing

test("Drawing", {})

test("Drawing.new", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = false
	local canDestroy = pcall(function()
		drawing:Destroy()
	end)
	assert(canDestroy, "Drawing:Destroy() should not throw an error")
end)

test("Drawing.Fonts", {}, function()
	assert(Drawing.Fonts.UI == 0, "Did not return the correct id for UI")
	assert(Drawing.Fonts.System == 1, "Did not return the correct id for System")
	assert(Drawing.Fonts.Plex == 2, "Did not return the correct id for Plex")
	assert(Drawing.Fonts.Monospace == 3, "Did not return the correct id for Monospace")
end)

test("isrenderobj", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	
	assert(isrenderobj(drawing) == true, "Did not return true for an Image")
	assert(isrenderobj(newproxy()) == false, "Did not return false for a blank table")
end)

test("getrenderproperty", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(type(getrenderproperty(drawing, "Visible")) == "boolean", "Did not return a boolean value for Image.Visible")
	local success, result = pcall(function()
		return getrenderproperty(drawing, "Color")
	end)
	if not success or not result then
		return "Image.Color is not supported"
	end
end)

test("setrenderproperty", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = true
	setrenderproperty(drawing, "Visible", false)
	assert(drawing.Visible == false, "Did not set the value for Square.Visible")
end)

test("cleardrawcache", {}, function()
	cleardrawcache()
end)

-- WebSocket

test("WebSocket", {})

test("WebSocket.connect", {}, function()
	local types = {
		Send = "function",
		Close = "function",
		OnMessage = {"table", "userdata"},
		OnClose = {"table", "userdata"},
	}
	local ws = WebSocket.connect("wss://echo.websocket.org")
	assert(type(ws) == "table" or type(ws) == "userdata", "Did not return a table or userdata")
	for k, v in pairs(types) do
		if type(v) == "table" then
			assert(table.find(v, type(ws[k])), "Did not return a " .. table.concat(v, ", ") .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
		else
			assert(type(ws[k]) == v, "Did not return a " .. v .. " for " .. k .. " (a " .. type(ws[k]) .. ")")
		end
	end
	ws:Close()
end)

repeat task.wait() until running == 0

	local rate = math.round(passes / (passes + fails) * 100)
	local outOf = passes .. " out of " .. (passes + fails)

	print("\n")

	print("UNC Summary")
	print("✅ Tested with a " .. rate .. "% success rate (" .. outOf .. ")")
	print("⛔ " .. fails .. " tests failed")
	print("⚠️ " .. undefined .. " globals are missing aliases")
	
]=])]]
VM:Run([=[

-- this file was obfuscated with the unveilr obf (prom fork) at https://discord.gg/threaded
return(function(...)return(function(B,s,U,y,j,W,G,F,R,h,Z,M,O,L,J,p,X,a,C,m,n,x,g,d)J,a,C,d,x,g,X,M,h,O,m,p,F,Z,n,R,L=function(B,s)local U=C(s)local y=function(y,j,W)return x(B,{y;j;W},s,U)end return y end,{},function(B)for x=(1+1)-1,#B,(1+1)-1 do O[B[x]]=((1+1)-1)+O[B[x]]end if U then local x=U(true)local s=j(x)s.__index,s.__gc,s.__len=B,F,function()return(-556589+1)-1 end return x else return y({},{__gc=F;__index=B;__len=function()return(-556589+1)-1 end})end end,function()R=R+((1+1)-1)O[R]=(1+1)-1 return R end,function(x,U,y,j)local U8,v,b,G,C8,Y,A,T8,m8,d8,u8,e,Q8,p8,S,L8,x8,i8,Q,H8,i,F,V,t8,j8,g8,B8,v8,J8,M8,q,Z8,h8,T,n8,P,l,N,a8,I,S8,f,r,c,k,H,P8,K8,l8,f8,R8,R,K,O8,E,z,C,s8,D,z8,G8,o,O,u,F8,y8,t,w,w8,W8,X8 while x do if x<(8494914+1)-1 then if x<(3907655+1)-1 then if x<(1905196+1)-1 then if x<(1027246+1)-1 then if x<(628436+1)-1 then if x<(281871+1)-1 then if x<(62474+1)-1 then if x<(21656+1)-1 then F=Q x=i x=Q and(1731091+1)-1 or(14850544+1)-1 else R=(1+1)-1 O=U[(1+1)-1]G=O[R]x=(1+1)-1 R=x C=G x=(10422680+1)-1 end else if x<(208214+1)-1 then O=nil G={}x=B.sVB9dHIjBuzswg else x=(286274+1)-1 end end else if x<(397925+1)-1 then if x<(292529+1)-1 then x=(25+1)-1==(((25+1)-1)+((1+1)-1))-((1+1)-1)x=x and(14984811+1)-1 or(12679420+1)-1 else C=a[y[(9+1)-1]]F=C C=(1+1)-1 R=(1+1)-1 x={}O=x P=C x=(13634364+1)-1 C=(0+1)-1 Q=P<C C=R-P end else if x<(507892+1)-1 then H8=(0+1)-1 P8="\073\110\115\116\097\110\099\101"J8=B[P8]P8="\110\101\119"X8=J8[P8]P8="\070\114\097\109\101"i8="\085\068\105\109\050"J8=X8(P8)Q8=B[i8]i8="\110\101\119"X8="\080\111\115\105\116\105\111\110"w8=(0+1)-1 P8=Q8[i8]i8=(0+1)-1 l8=(0+1)-1 Q8=P8(i8,l8,H8,w8)J8[X8]=Q8 Q8="\080\111\115\105\116\105\111\110"P8=d()X8=(0+1)-1 a[P8]=X8 X8="\071\101\116\080\114\111\112\101\114\116\121\067\104\097\110\103\101\100\083\105\103\110\097\108"X8=J8[X8]z8=(1+1)-1 H8="\084\119\101\101\110\073\110\102\111"i8=L((7290786+1)-1,{P8})X8=X8(J8,Q8)Q8="\067\111\110\110\101\099\116"Q8=X8[Q8]Q8=Q8(X8,i8)Q8="\103\097\109\101"i8="\084\119\101\101\110\083\101\114\118\105\099\101"X8=B[Q8]Q8="\071\101\116\083\101\114\118\105\099\101"Q8=X8[Q8]Q8=Q8(X8,i8)l8=B[H8]X8="\067\114\101\097\116\101"H8="\110\101\119"u8="\085\068\105\109\050"i8=l8[H8]H8=(.01+1)-1 l8=i8(H8)T8=B[u8]H8="\080\111\115\105\116\105\111\110"X8=Q8[X8]u8="\102\114\111\109\083\099\097\108\101"w8=T8[u8]u8=(1+1)-1 T8=w8(u8,z8)i8={[H8]=T8}X8=X8(Q8,J8,l8,i8)Q8="\080\108\097\121"w8=(0+1)-1 i8="\067\111\109\112\108\101\116\101\100"Q8=X8[Q8]Q8=Q8(X8)Q8=X8[i8]i8="\087\097\105\116"i8=Q8[i8]i8=i8(Q8)H8=a[P8]i8=x l8=H8==w8 x=l8 and(3786312+1)-1 or(7031821+1)-1 Q8=l8 else D=(1+1)-1 k=d()e="\109\097\116\104"a[k]=o q=B[e]e="\114\097\110\100\111\109"V=(255+1)-1 G=q[e]E=(100+1)-1 e=(1+1)-1 q=G(e,E)U8=(10000+1)-1 e=d()s8=(0+1)-1 a[e]=q c=(2+1)-1 E=(0+1)-1 G=a[H]q=G(E,V)b="\116\111\115\116\114\105\110\103"E=d()a[E]=q V=(1+1)-1 G=a[H]r=a[e]q=G(V,r)V=d()a[V]=q q=a[H]r=q(D,c)q=(1+1)-1 G=r==q r="\058\040\037\100\042\041\058"c="\058"q=d()a[q]=G B8=B[b]G="\103\115\117\098"G=S[G]x8=a[H]y8={x8(s8,U8)}b=B8(s(y8))B8="\058"j8=b..B8 D=c..j8 G=G(S,r,D)c="\112\099\097\108\108"r=d()j8=n((7454761+1)-1,{H;k;K,C;R,I;q,r,e;V;E,T})a[r]=G D=B[c]c={D(j8)}G={s(c)}D=G G=a[q]x=G and(2184683+1)-1 or(11542211+1)-1 end end end else if x<(839004+1)-1 then if x<(756883+1)-1 then if x<(689046+1)-1 then G={}x=(-14+1)-1==(((-17+1)-1)+((1+1)-1))-((1+1)-1)a[y[(1+1)-1]]=x x=B.LcCadGOPlljY else P=(24+1)-1 R="\109\097\116\104"O=B[R]F=(2+1)-1 R="\114\097\110\100\111\109"G=O[R]C=F^P P="\109\097\116\104"R=(1+1)-1 O=G(R,C)R="\082\065\078\068\079\077\095\083\084\082\073\078\071\095\051"F=B[P]i=(2+1)-1 l=(24+1)-1 P="\114\097\110\100\111\109"C=F[P]P=(1+1)-1 Q=i^l F=C(P,Q)G=R^F x=O-G G="\082\065\078\068\079\077\095\083\084\082\073\078\071\095\052"O=x x=G/O G={x}x=B.mkNxxoR5iU3tEk end else if x<(821320+1)-1 then E=(75+1)-1==(((72+1)-1)+((1+1)-1))-((1+1)-1)a[R]=E x=(5784521+1)-1 else Z8="\046\046"x=(3963998+1)-1 M8=d8~=Z8 F8=M8 end end else if x<(948165+1)-1 then if x<(906612+1)-1 then x=G8 U8=a8 x=(16223394+1)-1 else P=R Q=(2+1)-1 G=(2+1)-1 x=G~=Q x=x and(16056800+1)-1 or(5733149+1)-1 end else x=B.AozK7AASApfdm G={}end end end else if x<(1391780+1)-1 then if x<(1339226+1)-1 then if x<(1137161+1)-1 then if x<(1046665+1)-1 then a[R]=G x=c x=(9838458+1)-1 else x=(11610619+1)-1 end else if x<(1217257+1)-1 then V="\103\097\109\101"E=B[V]e={}q=e[E]x=q and(6566081+1)-1 or(3701816+1)-1 else x=(7616063+1)-1 Y=f==v o=Y end end else if x<(1383182+1)-1 then if x<(1364172+1)-1 then x=F F=C C=(1+1)-1 P=C x=(5469867+1)-1 C=(0+1)-1 Q=P<C C=G-P else x=(-11+1)-1==(((-14+1)-1)+((1+1)-1))-((1+1)-1)R="\085\068\068\068\068 \066\082\079\079"a[y[(1+1)-1]]=x G=a[y[(2+1)-1]]O=G(R)x=B.mZEk1ysHxMmgm G={}end else X8=a[l]p8="\063\033"n8=X8(p8)x=(13831796+1)-1 end end else if x<(1698827+1)-1 then if x<(1544762+1)-1 then if x<(1498461+1)-1 then H="\112\099\097\108\108"z=L((6695916+1)-1,{})w=B[H]H=w(z)u=not H G=u x=(2397731+1)-1 else x=(2563150+1)-1 end else if x<(1586156+1)-1 then P=(68+1)-1==(((65+1)-1)+((1+1)-1))-((1+1)-1)x=P and(5970211+1)-1 or(3319215+1)-1 else O8="\105\109 \115\111\114\114\121"s8=(-8+1)-1==(((-11+1)-1)+((1+1)-1))-((1+1)-1)a[R]=s8 x=(12673340+1)-1 R8=a[l]d8=R8(O8)end end else if x<(1831377+1)-1 then if x<(1777187+1)-1 then x=P Q=x l="\117\110\112\097\099\107"i=B[l]x=i and(16327863+1)-1 or(11406468+1)-1 P=i else k=(18+1)-1==(((15+1)-1)+((1+1)-1))-((1+1)-1)x=(1215415+1)-1 a[R]=k end else l8=a[R]x=l8 and(9432556+1)-1 or(10257256+1)-1 end end end end else if x<(2692167+1)-1 then if x<(2131455+1)-1 then if x<(1975957+1)-1 then if x<(1953078+1)-1 then if x<(1938723+1)-1 then X8=a[l]x=(1971522+1)-1 p8="\033\063\063\033\063\033\063"n8=X8(p8)else B8=x y8=(1+1)-1 x8=D[y8]y8=(35+1)-1==(((32+1)-1)+((1+1)-1))-((1+1)-1)b=x8==y8 x=b and(6934713+1)-1 or(10518156+1)-1 j8=b end else if x<(1970994+1)-1 then x=(40+1)-1==(((37+1)-1)+((1+1)-1))-((1+1)-1)a[y[(1+1)-1]]=x x=B.jtBoAZOjzDP6 G=a[y[(2+1)-1]]O=G()G={}else J8="\086\101\099\116\111\114\051\105\110\116\049\054"Q8=(1+1)-1 m8=B[J8]J8="\110\101\119"p8=m8[J8]J8=(1+1)-1 P8=(1+1)-1 m8=p8(J8,P8,Q8)Q8=(1+1)-1 p8="\088"n8=m8[p8]P8="\086\101\099\116\111\114\050\105\110\116\049\054"J8=B[P8]P8="\110\101\119"m8=J8[P8]P8=(1+1)-1 J8=m8(P8,Q8)m8="\088"p8=J8[m8]X8=n8~=p8 x=X8 and(14087628+1)-1 or(2213955+1)-1 end end else if x<(2080041+1)-1 then if x<(2006110+1)-1 then z8=(-17+1)-1==(((-20+1)-1)+((1+1)-1))-((1+1)-1)a[R]=z8 K8=a[l]S8="\098\111\105 \112\108\122 \099\097\108\099\117\108\097\116\101 \118\101\099\116\111\114\051 \099\111\114\114\101\099\116 \116\104\120 \110\112"v8=K8(S8)x=(15889190+1)-1 else l=(1+1)-1 Q=R x=a[y[(1+1)-1]]G=O[Q]w=a[y[(1+1)-1]]H=O[Q]u=w[H]Q=nil i=l+u x[G]=i x=(14268929+1)-1 end else if x<(2095185+1)-1 then o=o+Y k=not N G=o<=A G=k and G k=o>=A k=N and k G=k or G k=(548584+1)-1 x=G and k G=(2988957+1)-1 x=x or G else x=(10257256+1)-1 l8=a[R]end end end else if x<(2399412+1)-1 then if x<(2212564+1)-1 then if x<(2187888+1)-1 then c=x j8=a[R]G=j8 x=j8 and(1939052+1)-1 or(1041512+1)-1 else S="\116\097\098\108\101"t=B[S]S="\117\110\112\097\099\107"v=t[S]f=v x=(11354252+1)-1 end else if x<(2374480+1)-1 then n8="\112\099\097\108\108"X8=B[n8]m8=L((9187171+1)-1,{})J8={X8(m8)}n8=J8[(1+1)-1]p8=J8[(2+1)-1]m8=x X8=n8 x=n8 and(15309709+1)-1 or(5367713+1)-1 else x=G and(13696256+1)-1 or(5838544+1)-1 end end else if x<(2574774+1)-1 then if x<(2403481+1)-1 then C8="\112\099\097\108\108"F8=M((10233006+1)-1,{})O8=B[C8]C8=O8(F8)x=C8 and(10600737+1)-1 or(15876784+1)-1 else x=(19+1)-1==(((19+1)-1)+((1+1)-1))-((1+1)-1)x=x and(16095482+1)-1 or(2694309+1)-1 end else x=(-3+1)-1==(((-3+1)-1)+((1+1)-1))-((1+1)-1)x=x and(8492015+1)-1 or(948512+1)-1 end end end else if x<(3356910+1)-1 then if x<(3219677+1)-1 then if x<(2975212+1)-1 then if x<(2780498+1)-1 then G={}x=B.h18xGyiB0bhDO else d8=(57+1)-1==(((54+1)-1)+((1+1)-1))-((1+1)-1)a[R]=d8 x=(2402337+1)-1 F8="\107\101\121 \115\121\115\116\101\109\046\046\063"O8=a[l]C8=O8(F8)end else if x<(3015182+1)-1 then Y=a[R]o=Y A=x x=Y and(1281510+1)-1 or(7616063+1)-1 else x=a[y[(2+1)-1]]x=x and(4991396+1)-1 or(3274935+1)-1 end end else if x<(3327728+1)-1 then if x<(3318287+1)-1 then Q="\095\095\105\110\100\101\120"R={}x=a[y[(5+1)-1]]i="\095\095\108\101\110"l=M((9170604+1)-1,{})P=a[y[(4+1)-1]]F="\095\095\103\099"C={[F]=P;[Q]=O;[i]=l}G={x(R,C)}x=B.AxpWJIOPSWIK6M G={s(G)}else x=(1578968+1)-1 end else x=(3319215+1)-1 P=(56+1)-1==(((53+1)-1)+((1+1)-1))-((1+1)-1)end end else if x<(3753115+1)-1 then if x<(3597585+1)-1 then if x<(3426262+1)-1 then x=(14268929+1)-1 G=(1+1)-1 O=U[(1+1)-1]R=#O C=R R=(1+1)-1 F=R R=(0+1)-1 P=F<R R=G-F else C="\109\097\116\104"R=B[C]C="\114\097\110\100\111\109"O=R[C]F=(7+1)-1 G=(1+1)-1 C=(6+1)-1 R=O(C,F)x=(5828151+1)-1 O=R R=(1+1)-1 C=R R=(0+1)-1 F=C<R R=G-C end else if x<(3649023+1)-1 then P=(8+1)-1==(((8+1)-1)+((1+1)-1))-((1+1)-1)x=P and(11972435+1)-1 or(8079679+1)-1 else r="\116\121\112\101\111\102"V=B[r]r=V(q)V="\110\105\108"E=r==V x=E and(14377707+1)-1 or(795582+1)-1 end end else if x<(3848859+1)-1 then if x<(3814224+1)-1 then x=i8 x=Q8 and(5647215+1)-1 or(16518998+1)-1 else C="\115\116\114\105\110\103"R=d()P=""x=(25+1)-1==(((25+1)-1)+((1+1)-1))-((1+1)-1)O=U a[R]=x G=B[C]C="\103\109\097\116\099\104"Q="\120\112\099\097\108\108"x=G[C]C=d()F="\115\116\114\105\110\103"a[C]=x G=B[F]F="\115\112\108\105\116"x=G[F]F="\097\098\099\100\101\102\103\104\105\106\107\108\109\110\111\112\113\114\115\116\117\118\119\120\121\122\065\066\067\068\069\070\071\072\073\074\075\076\077\078\079\080\081\082\083\084\085\086\087\088\089\090\095\048\049\050\051\052\053\054\055\056\057"G=x(F,P)F=d()a[F]=G P=B[Q]x=P and(15660897+1)-1 or(16219795+1)-1 G=P end else O=(1+1)-1 G=a[y[(1+1)-1]]x=G+O a[y[(1+1)-1]]=x G={}x=B.x36Iu02klXGpu end end end end end else if x<(6016343+1)-1 then if x<(5278107+1)-1 then if x<(4717277+1)-1 then if x<(4096910+1)-1 then if x<(3964428+1)-1 then if x<(3942321+1)-1 then x=(12732674+1)-1 else x=h8 x=F8 and(8460401+1)-1 or(13908830+1)-1 end else if x<(4080890+1)-1 then l8=H8 K8="\109\097\116\104"t8=B[K8]K8="\114\097\110\100\111\109"z8=t8[K8]f8="\086\101\099\116\111\114\051"K8=(1+1)-1 v8=(67+1)-1 t8=z8(K8,v8)K8=i8*t8 S8=B[f8]f8="\110\101\119"v8=S8[f8]S8=v8(t8,t8,t8)z8=K8~=S8 x=z8 and(2005473+1)-1 or(15889190+1)-1 else T=#F f=a[y[(2+1)-1]]x=B["\048\069\052\057\102\104\100\112\073\076\114\077\069"]K={f(i)}G={s(K)}O=T end end else if x<(4194425+1)-1 then if x<(4159200+1)-1 then O=d()R=d()a[O]=U[(1+1)-1]a[R]=U[(2+1)-1]x=a[y[(1+1)-1]]C=a[R]G=x(C)C=d()x=Z((6900986+1)-1,{y[(2+1)-1],O;R,C})F=x a[C]=G G={F}x=B.c59WRfW5qF7g else x=a[y[(7+1)-1]]x=x and(14165023+1)-1 or(333196+1)-1 end else if x<(4694104+1)-1 then x=j8 x=(9838458+1)-1 s8=(1+1)-1 a[R]=c y8=a[V]x8=y8+s8 b=D[x8]B8=f+b b=(256+1)-1 j8=B8%b f=j8 x8=a[E]b=v+x8 x8=(256+1)-1 B8=b%x8 v=B8 else R=nil C="\121\101\115\044 \121\111\117\'\114\101 \114\101\097\108\108\121 \100\101\116\101\099\116\101\100 \098\117\100\100\121\046 \040\116\104\105\115 \105\115 \106\117\115\116 \097 \109\101\115\115\097\103\101 \116\111 \116\097\108\107 \116\111 \121\111\117\044 \105 \100\111\110\'\116 \103\101\116 \116\111 \116\097\108\107 \116\111 \112\101\111\112\108\101 \240\159\153\129\041"G=nil O=d()x=nil F="\100\101\098\117\103"a[O]=U[(1+1)-1]B[F]=x F="\099\111\114\111\117\116\105\110\101"B[F]=G F="\109\111\116\104\101\114"B[F]=R F="\105\115\095\100\101\116\101\099\116\101\100"B[F]=C x=(3637518+1)-1 F=Z((8066981+1)-1,{y[(1+1)-1];y[(2+1)-1]})end end end else if x<(4995622+1)-1 then if x<(4927641+1)-1 then if x<(4913714+1)-1 then x=(10796345+1)-1 else x=(14847030+1)-1 end else if x<(4987349+1)-1 then i8=(1+1)-1 m8=d()P8="\116\097\115\107"X8=(0+1)-1 a[m8]=X8 J8=B[P8]P8="\100\101\108\097\121"Q8=g((15419878+1)-1,{m8})X8=J8[P8]P8=(0+1)-1 J8=X8(P8,Q8)J8=x Q8=a[m8]P8=Q8>i8 x=P8 and(11212182+1)-1 or(16774016+1)-1 X8=P8 else x=a[y[(2+1)-1]]R=(-13+1)-1==(((-13+1)-1)+((1+1)-1))-((1+1)-1)G=x(R)R=G F="\095\095\108\101\110"x=a[y[(3+1)-1]]G=x(R)x="\095\095\105\110\100\101\120"C=G i=X((9615869+1)-1,{})G="\095\095\103\099"Q=a[y[(4+1)-1]]P=O C[x]=P C[G]=Q x=B.IP04TZu2LnBTC C[F]=i G={R}end end else if x<(5159570+1)-1 then if x<(5074577+1)-1 then x=(12652215+1)-1 else x=(9601901+1)-1 l8=(100+1)-1==(((100+1)-1)+((1+1)-1))-((1+1)-1)end else i=C l=a[y[(1+1)-1]]H="\109\097\116\104"i=nil w=B[H]H="\114\097\110\100\111\109"u=w[H]H=(1+1)-1 T=a[y[(1+1)-1]]z=#T w=u(H,z)G=l[w]x=R..G R=x x=(5469867+1)-1 end end end else if x<(5669291+1)-1 then if x<(5476431+1)-1 then if x<(5412356+1)-1 then if x<(5365502+1)-1 then x=(96+1)-1==(((93+1)-1)+((1+1)-1))-((1+1)-1)R=U[(2+1)-1]a[y[(1+1)-1]]=x O=U[(1+1)-1]G="\100\116\099 \058\080"x=B.Nnw7SZUkqXmfv G={G}else P8="\105\110\118\097\108\105\100 \097\114\103\117\109\101\110\116 \035\050 \116\111 \'\100\101\108\097\121\' \040\102\117\110\099\116\105\111\110 \111\114 \116\104\114\101\097\100 \101\120\112\101\099\116\101\100\041"x=(15309709+1)-1 J8=p8~=P8 X8=J8 end else if x<(5469892+1)-1 then C=C+P i=not Q G=C<=F G=i and G i=C>=F i=Q and i G=i or G i=(5212604+1)-1 x=G and i G=(15566117+1)-1 x=x or G else x=(100+1)-1==(((100+1)-1)+((1+1)-1))-((1+1)-1)x=x and(11160594+1)-1 or(11167003+1)-1 end end else if x<(5609239+1)-1 then if x<(5531943+1)-1 then G="\112\114\105\110\116"x=R Q=x i=G u=a[y[(1+1)-1]]l=u[i]O=l u="\071\111\111\100\109\111\114\110\105\110\103 \107\105\107\111"P=u x=(9156543+1)-1 H={}w=O(P)T=a[y[(1+1)-1]]i=w f="\065\105\050\075\116\054\050\098\099\103\079\110\109\117"i=H z=T[f]O=z else G="\113\117\101\117\101\111\110\116\101\108\101\112\111\114\116"x=B[G]O=a[y[(1+1)-1]]G=x(O)O="\101\114\109 \119\116\102\063\063"x=a[y[(2+1)-1]]G=x(O)x=B.HgbL605N774U4 G={}end else Q8=(64+1)-1==(((61+1)-1)+((1+1)-1))-((1+1)-1)x=(16518998+1)-1 a[R]=Q8 i8=a[l]H8="\098\111\105\105 \117 \110\111\116 \114\101\097\108 \114\111\098\108\111\120 \240\159\152\162"l8=i8(H8)end end else if x<(5868967+1)-1 then if x<(5827695+1)-1 then if x<(5752681+1)-1 then Q=(3+1)-1 G=(2+1)-1 x=G==Q x=x and(8236922+1)-1 or(13289072+1)-1 else r=d()V=(0+1)-1 a[r]=V D="\109\097\105\110"V=g((3849295+1)-1,{r})B[D]=V s8="\095\095\116\111\115\116\114\105\110\103"b="\115\101\116\109\101\116\097\116\097\098\108\101"U8=n((669648+1)-1,{R})V=a[Q]D=V()V=B[b]W8=(100+1)-1 y8={[s8]=U8}x8={}b=V(x8,y8)V=J((1380868+1)-1,{R;l})U8="\109\097\116\104"D[b]=V D=a[Q]b=D()D=a[i]s8=B[U8]U8="\114\097\110\100\111\109"y8=s8[U8]U8=(1+1)-1 s8={y8(U8,W8)}x8=D(s(s8))V=b[x8]x=V and(13982907+1)-1 or(9731479+1)-1 end else if x<(5836287+1)-1 then P=not F R=R+C G=R<=O G=P and G P=R>=O P=F and P G=P or G P=(947582+1)-1 x=G and P G=(12926644+1)-1 x=x or G else u=a[F]G=#u u=(63+1)-1 x=G~=u x=x and(11544125+1)-1 or(6960232+1)-1 end end else if x<(5959883+1)-1 then if x<(5927670+1)-1 then O=(1+1)-1 G=a[y[(1+1)-1]]x=G+O a[y[(1+1)-1]]=x G=a[y[(2+1)-1]]x=B.lpk49NRO1b9O O=a[y[(1+1)-1]]R=(1+1)-1 G[O]=R G=a[y[(1+1)-1]]G={G}else x=a[y[(1+1)-1]]R=nil G=a[y[(2+1)-1]]x[O]=R C=nil x=(13539159+1)-1 G[O]=C end else Q="\119\097\114\110"i="\066\082\079 \089\079\085\'\082\069 \068\069\084\069\067\084\069\068 \083\084\079\080 \084\082\089\073\078\071 \240\159\146\148\240\159\146\148"P=B[Q]x=(8555112+1)-1 Q=P(i)P=(56+1)-1==(((53+1)-1)+((1+1)-1))-((1+1)-1)a[y[(3+1)-1]]=P end end end end else if x<(7444629+1)-1 then if x<(6736872+1)-1 then if x<(6406006+1)-1 then if x<(6359900+1)-1 then if x<(6138091+1)-1 then x=(11393385+1)-1 x8=(17+1)-1==(((14+1)-1)+((1+1)-1))-((1+1)-1)a[R]=x8 y8=a[l]s8=y8()else L8=(0+1)-1==(((-3+1)-1)+((1+1)-1))-((1+1)-1)a[R]=L8 X8=a[l]n8=X8()x=(4904531+1)-1 end else if x<(6381796+1)-1 then a[y[(5+1)-1]]=G O=nil x=(4190356+1)-1 else h8=x d8=C8 Z8="\046"M8=d8~=Z8 F8=M8 x=M8 and(834068+1)-1 or(3963998+1)-1 end end else if x<(6545017+1)-1 then if x<(6426784+1)-1 then C8=R8(O8,C8)x=C8 and(6388863+1)-1 or(14518587+1)-1 else R8=g((1970575+1)-1,{R;l})x=(902942+1)-1 a8=R8 end else if x<(6675834+1)-1 then e=(53+1)-1==(((50+1)-1)+((1+1)-1))-((1+1)-1)x=(3701816+1)-1 a[R]=e else G={}x=B["\049\105\110\051\070\071\085\103\077\071\122\098\070\100"]end end end else if x<(7032607+1)-1 then if x<(6953672+1)-1 then if x<(6926807+1)-1 then O={W((1+1)-1,s(U))}x=a[y[(1+1)-1]]R=a[y[(2+1)-1]]C={s(O)}F=a[y[(3+1)-1]]P=a[y[(4+1)-1]]G={x(R,C,F,P)}x=B.EIkhP1ZYArD5E G={s(G)}else y8=(2+1)-1 x8=D[y8]y8=a[r]b=x8==y8 j8=b x=(10518156+1)-1 end else if x<(6979414+1)-1 then z="\112\099\097\108\108"u=d()G=(44+1)-1==(((41+1)-1)+((1+1)-1))-((1+1)-1)w=x a[u]=G H=B[z]T=L((14485249+1)-1,{u})z=H(T)G=z x=z and(8631407+1)-1 or(9138117+1)-1 else H8=a[P8]w8=(2+1)-1 l8=H8>w8 Q8=l8 x=(3786312+1)-1 end end else if x<(7384230+1)-1 then if x<(7219304+1)-1 then G="\115\101\116\109\101\116\097\116\097\098\108\101"R="\103\097\109\101"x=B[G]O=B[R]R={}G=x(O,R)G={}x=B.hIam2cPjT1Xu else G=a[y[(1+1)-1]]O=(1+1)-1 x=G+O G={}a[y[(1+1)-1]]=x x=B.zPeeJbzIBGBA end else x=a[y[(1+1)-1]]l=(0+1)-1 R=C u=(255+1)-1 i=x(l,u)O[R]=i x=(13634364+1)-1 R=nil end end end else if x<(8079245+1)-1 then if x<(7856624+1)-1 then if x<(7697805+1)-1 then if x<(7488349+1)-1 then R=a[y[(1+1)-1]]P=(2+1)-1 F=(1+1)-1 C=R(F,P)R=(1+1)-1 O=C==R G=O x=O and(15660894+1)-1 or(8218191+1)-1 else a[R]=o x=A Y="\115\101\116\109\101\116\097\116\097\098\108\101"A=B[Y]q="\095\095\116\111\115\116\114\105\110\103"N={}e=a[l]k={[q]=e}Y=A(N,k)k="\109\097\116\104"N=B[k]k="\114\097\110\100\111\109"q=(100+1)-1 A=N[k]k=(1+1)-1 N=A(k,q)A=Y Y[N]=A A=M((11582075+1)-1,{})k=g((7177990+1)-1,{})N=A(Y)N="\112\099\097\108\108"A=B[N]N=A(k)x=N and(12915509+1)-1 or(16752929+1)-1 end else if x<(7808064+1)-1 then l=(7+1)-1 Q=x x=(1357927+1)-1 i=(6+1)-1 P=i or l C=P else R8=O8 R8=nil x=(15152698+1)-1 h8="\114\101\109\111\118\101\070\105\108\101"F8=W8[h8]h8=F8(C8)C8=nil end end else if x<(7971975+1)-1 then if x<(7874034+1)-1 then u="\103\101\116\102\101\110\118"l=B[u]u=l()Q=u x=(17469+1)-1 else u=d()O=d()S=(0+1)-1 P=d()R=d()w=U[(10+1)-1]i=U[(7+1)-1]z=d()e={}A=p((14482037+1)-1,{O;R})K=d()l=U[(8+1)-1]t=p((4157805+1)-1,{K;z})a[O]=U[(1+1)-1]C=d()l=t Q=U[(6+1)-1]F=d()a[R]=U[(2+1)-1]Y={}T=d()q=(15356417+1)-1 H=U[(11+1)-1]x={}a[C]=U[(3+1)-1]f=d()a[F]=U[(4+1)-1]a[P]=U[(5+1)-1]a[u]=U[(9+1)-1]a[z]=U[(12+1)-1]a[T]=U[(13+1)-1]a[f]=U[(14+1)-1]a[K]=U[(15+1)-1]v=d()N=n((26535+1)-1,{v;T})I=J((3375196+1)-1,{v,C;P,f;F})a[v]=U[(16+1)-1]o=J((5879332+1)-1,{u,v})H=o a[v]=x G=n((14827286+1)-1,{v,T})w=G a[u]=S a[K]=I a[z]=A x=B.hXTYEiUWGtJ2z a[T]=Y a[f]=N k=l(q,e)e=a[R]E={e(i)}q={k(s(E))}G={s(q)}end else O={W((1+1)-1,s(U))}x=(2576923+1)-1 end end else if x<(8254999+1)-1 then if x<(8137228+1)-1 then if x<(8079981+1)-1 then G={}O=h(O)x=B.us9xvDaauOdDAZ F=nil else H8=H8+T8 l8=H8<=w8 z8=not u8 l8=z8 and l8 z8=H8>=w8 z8=u8 and z8 l8=z8 or l8 z8=(4039271+1)-1 x=l8 and z8 l8=(2118669+1)-1 x=x or l8 end else if x<(8224329+1)-1 then R=a[y[(2+1)-1]]C=a[y[(3+1)-1]]O=R==C G=O x=(15660894+1)-1 else x=a[y[(1+1)-1]]Q="\109\104\109\046\046"G=x(Q)x=(13289072+1)-1 end end else if x<(8472662+1)-1 then if x<(8371152+1)-1 then D=(36+1)-1==(((33+1)-1)+((1+1)-1))-((1+1)-1)a[R]=D b=a[l]x8=b()x=(14189088+1)-1 else M8="\111\115"h8=B[M8]M8="\114\101\109\111\118\101"x=(13908830+1)-1 F8=h8[M8]h8=F8(d8)end else x=a[y[(1+1)-1]]Q=(128+1)-1 G=x()x=a[y[(2+1)-1]]P="\109\097\116\104"F=B[P]P="\114\097\110\100\111\109"C=F[P]P=(67+1)-1 F={C(P,Q)}R=x(s(F))x=(55+1)-1==(((55+1)-1)+((1+1)-1))-((1+1)-1)G[R]=x G="\120\112\099\097\108\108"x=B[G]G=x(s(O))x=(2576923+1)-1 end end end end end end else if x<(12702430+1)-1 then if x<(10606100+1)-1 then if x<(9214350+1)-1 then if x<(8785849+1)-1 then if x<(8618032+1)-1 then if x<(8536769+1)-1 then if x<(8522931+1)-1 then G8=x O8="\095\069\078\086"d8=B[O8]O8="\108\111\097\100"R8=d8[O8]a8=R8 x=R8 and(902942+1)-1 or(6515785+1)-1 else x=(-2+1)-1==(((-5+1)-1)+((1+1)-1))-((1+1)-1)a[y[(1+1)-1]]=x x=B.Nz397RI5dfHB G={}end else if x<(8559913+1)-1 then x=(3637518+1)-1 else n8=(1+1)-1 X8=a[g8]L8=X8>n8 x=L8 and(6290349+1)-1 or(4904531+1)-1 end end else if x<(8712234+1)-1 then if x<(8641451+1)-1 then x=(9138117+1)-1 H=a[u]G=H else M8=(0+1)-1 Z8=nil X8="\116\097\115\107"g8=d()a[g8]=M8 M8=d()a[M8]=Z8 L8=B[X8]X8="\115\112\097\119\110"Z8=L8[X8]X8=L((15089193+1)-1,{g8,M8})L8=Z8(X8)L8=a[r]X8=(0+1)-1 Z8=L8>X8 x=Z8 and(9580608+1)-1 or(10182643+1)-1 end else if x<(8749684+1)-1 then d8="\114\101\116\117\114\110 \114\101\113\117\105\114\101\040\"\108\102\115\"\041"x=s8 G8="\114\101\116\117\114\110 \114\101\113\117\105\114\101\040\"\064\108\117\110\101\047\102\115\"\041"U8="\112\099\097\108\108"s8=B[U8]a8={y8(G8)}G8={s8(s(a8))}U8=G8[(1+1)-1]W8=G8[(2+1)-1]a8="\112\099\097\108\108"s8=B[a8]R8={y8(d8)}d8={s8(s(R8))}G8=d8[(2+1)-1]a8=d8[(1+1)-1]x=U8 and(12345198+1)-1 or(12673340+1)-1 else v=(65+1)-1 x=T T=d()a[T]=G K=(3+1)-1 G=a[H]f=G(K,v)K=d()G=(0+1)-1 o=L((15791654+1)-1,{i})a[K]=f S="\112\099\097\108\108"f=G t=B[S]G=(0+1)-1 N="\116\111\115\116\114\105\110\103"v=G S={t(o)}G={s(S)}S=(2+1)-1 o="\116\111\110\117\109\098\101\114"t=G G=t[S]S=G G=B[o]x=(2094197+1)-1 I=a[C]Y=B[N]N=Y(S)Y="\058\040\037\100\042\041\058"A=I(N,Y)I={A()}o=G(s(I))I=d()G=(1+1)-1 a[I]=o o=a[K]A=o o=(1+1)-1 Y=o o=(0+1)-1 N=Y<o o=G-Y end end end else if x<(9146856+1)-1 then if x<(8939423+1)-1 then if x<(8844991+1)-1 then x=(5476324+1)-1 else R=nil O=nil x=B.aY0PbDDA2uDvV C=nil G={}end else if x<(9009073+1)-1 then x=a[y[(10+1)-1]]R=a[y[(11+1)-1]]O[x]=R x=a[y[(12+1)-1]]R={x(O)}G={s(R)}x=B.SBvw8uRfNXpgo9 else x=w z="\109\097\116\104"H=B[z]z="\114\097\110\100\111\109"t="\116\097\098\108\101"w=G T="\116\097\098\108\101"G=H[z]H=d()a[H]=G K=x z=B[T]T="\099\111\110\099\097\116"G=z[T]z=G v=B[t]f=v T=x x=v and(2211429+1)-1 or(11354252+1)-1 end end else if x<(9180933+1)-1 then if x<(9168066+1)-1 then x=O and(5477189+1)-1 or(4092689+1)-1 else x=(1697722+1)-1 G={x}x=B.OJjpuTISQh3j end else O="\116\097\115\107"G=B[O]O="\100\101\108\097\121"x=G[O]O=(0+1)-1 G=x(O)G={}x=B.eaovvwX7Uoos end end end else if x<(10220446+1)-1 then if x<(9665507+1)-1 then if x<(9594002+1)-1 then if x<(9497896+1)-1 then l8=a[R]x=l8 and(4997393+1)-1 or(5156562+1)-1 else Z8=(100+1)-1==(((97+1)-1)+((1+1)-1))-((1+1)-1)a[R]=Z8 x=(10182643+1)-1 end else if x<(9608187+1)-1 then l8=g((8820874+1)-1,{})x=B.A81ydKs9jAgBE H8={l8()}G={s(H8)}else x=(1697722+1)-1 G={x}x=B.wRzKmeSonacpS end end else if x<(9966046+1)-1 then if x<(9767052+1)-1 then x8="\095\086\069\082\083\073\079\078"b=B[x8]x8="\076\117\097\117"D=b~=x8 x=D and(8269395+1)-1 or(14189088+1)-1 else q=h(q)x=(2094197+1)-1 r=h(r)D=nil V=h(V)e=h(e)E=h(E)k=h(k)end else L8=a[M8]x=L8 and(8563489+1)-1 or(10796345+1)-1 end end else if x<(10425183+1)-1 then if x<(10246049+1)-1 then if x<(10241708+1)-1 then O="\073\110\115\116\097\110\099\101"G=B[O]O="\110\101\119"x=G[O]O="\068\097\116\097\077\111\100\101\108"G=x(O)G={}x=B["\051\120\098\087\083\049\065\054\076\082\078\087\056\050"]else X8=a[l]P8="\119\116\102\102\102\102\102\102 \040\102\108\105\112\041"J8=X8(P8)x=(448245+1)-1 end else if x<(10286191+1)-1 then x=(1870927+1)-1 else x=C and(16368145+1)-1 or(8937697+1)-1 end end else if x<(10539740+1)-1 then if x<(10506447+1)-1 then G={}x=B.lybQXY9z362ECg else G=j8 x=B8 x=(1041512+1)-1 end else O8=(64+1)-1==(((61+1)-1)+((1+1)-1))-((1+1)-1)a[R]=O8 C8=a[l]F8=C8()x=(13757726+1)-1 end end end end else if x<(11542737+1)-1 then if x<(11167239+1)-1 then if x<(11144061+1)-1 then if x<(10793837+1)-1 then if x<(10667012+1)-1 then b=(26+1)-1==(((23+1)-1)+((1+1)-1))-((1+1)-1)x=(11601648+1)-1 a[R]=b x8=a[l]y8=x8()else Z8="\095\083\085\080\069\082"M8=B[Z8]h8=not M8 x=(11167243+1)-1 M8="\095\083\085\080\069\082"B[M8]=h8 end else if x<(11097236+1)-1 then p8="\116\097\115\107"n8=B[p8]X8=not n8 x=X8 and(1387149+1)-1 or(13831796+1)-1 else l="\112\099\097\108\108"G="\116\111\110\117\109\098\101\114"x=B[G]F="\116\111\115\116\114\105\110\103"O=a[y[(4+1)-1]]u=g((698476+1)-1,{})C=B[F]i=B[l]l={i(u)}i=(2+1)-1 Q={s(l)}P=Q[i]F=C(P)C="\058\040\037\100\042\041\058"R=O(F,C)O={R()}G=x(s(O))O=G R=a[y[(5+1)-1]]G=R x=R and(12477499+1)-1 or(6380340+1)-1 end end else if x<(11159898+1)-1 then if x<(11155841+1)-1 then x=(4684839+1)-1 b=(1+1)-1 B8=D[b]c=B8 else x=O[R]C=x x=(10422680+1)-1 end else if x<(11164282+1)-1 then G="\119\116\102"x=B[G]O="\072\101\108\108\111"C="\066\079\073\073 \071\069\084 \079\085\084"R="\101\114\114\111\114"G=B[O]O="\072\101\108\108\111"B[O]=x O="\119\116\102"B[O]=G O=B[R]x=(5476324+1)-1 R=O(C)else x=B.zXzZDLxE1QR4 G={}end end end else if x<(11367001+1)-1 then if x<(11218013+1)-1 then if x<(11177461+1)-1 then Z8="\095\083\085\080\069\082"M8=B[Z8]x=M8 and(8647078+1)-1 or(10722684+1)-1 else x=J8 x=X8 and(10241986+1)-1 or(448245+1)-1 end else if x<(11277560+1)-1 then C8="\107\101\121\095\049\050\051\052\053\095\115\105\120\115\101\118\101\110"O8=B[C8]C8="\107\101\121\095\049\050\051\052"d8=O8==C8 x=d8 and(2831308+1)-1 or(2402337+1)-1 else x=K x=f and(8763268+1)-1 or(12739967+1)-1 G=f end end else if x<(11497522+1)-1 then if x<(11397261+1)-1 then W8="\108\111\097\100\115\116\114\105\110\103"s8=x U8=B[W8]y8=U8 x=U8 and(8712250+1)-1 or(13142107+1)-1 else u="\116\097\098\108\101"l=B[u]u="\117\110\112\097\099\107"i=l[u]P=i x=(16327863+1)-1 end else j8=x B8=a[R]x=B8 and(11153457+1)-1 or(4684839+1)-1 c=B8 end end end else if x<(12451136+1)-1 then if x<(11931175+1)-1 then if x<(11584771+1)-1 then if x<(11546988+1)-1 then w="\116\102 \117 \100\111\105\110\103 \098\114\111 \240\159\152\173\240\159\152\173"x=(-18+1)-1==(((-21+1)-1)+((1+1)-1))-((1+1)-1)a[R]=x G=a[l]u=G(w)x=(6960232+1)-1 else x=B.MiyWGdgKnLZM G={}end else if x<(11606560+1)-1 then s8="\095\086\069\082\083\073\079\078"y8=B[s8]x8=not y8 x=x8 and(6029630+1)-1 or(11393385+1)-1 else l8=(-16+1)-1==(((-16+1)-1)+((1+1)-1))-((1+1)-1)x=l8 and(12719303+1)-1 or(13247593+1)-1 end end else if x<(12433039+1)-1 then if x<(12313067+1)-1 then i=g((1533662+1)-1,{O})l=g((253580+1)-1,{})Q=F(i,l)P=not Q x=P and(3332380+1)-1 or(8555112+1)-1 else R8="\110\101\120\116"x=(15152698+1)-1 d8="\114\101\097\100\068\105\114"s8=B[R8]R8=W8[d8]C8="\046\047"F8={R8(C8)}O8=F8[(2+1)-1]d8=F8[(1+1)-1]end else Q="\111\107"x=a[y[(1+1)-1]]G=x(Q)x=(14847030+1)-1 end end else if x<(12649893+1)-1 then if x<(12537111+1)-1 then if x<(12478213+1)-1 then x=(6380340+1)-1 C=a[y[(6+1)-1]]R=C==O G=R else x=(11610619+1)-1 end else if x<(12609574+1)-1 then O=U[(1+1)-1]C=O x=""G=(1+1)-1 R=x F=x x=O and(1357927+1)-1 or(7756379+1)-1 else R="\103\097\109\101"G="\103\101\116\109\101\116\097\116\097\098\108\101"x=B[G]O=B[R]G=x(O)x="\095\095\109\101\116\097\116\097\098\108\101"O="\068\084\067"G[x]=O G={}x=B.IxCpXpIpvSMHXH end end else if x<(12674683+1)-1 then if x<(12669372+1)-1 then v=nil N=h(N)i8=nil l=h(l)H=h(H)r=h(r)z=nil m8=h(m8)f=nil w=nil a8=nil M8=h(M8)n8=nil R=h(R)R=m((7881139+1)-1,{})P=nil p8=nil F=h(F)Q=h(Q)P8=h(P8)t=nil U8=nil i=h(i)K=h(K)T=h(T)u=h(u)J8=nil u="\103\101\116\102\101\110\118"S=nil C=h(C)y8=nil Y=nil l=B[u]I=h(I)Q=l g8=h(g8)X8=nil q=nil i=x P=x x=l and(7872115+1)-1 or(17469+1)-1 G8=nil W8=nil else x=a8 and(13682216+1)-1 or(11220445+1)-1 end else G={}x=B["\052\054\089\106\122\071\105\069\069\057\105\078\053"]end end end end end else if x<(14483145+1)-1 then if x<(13800293+1)-1 then if x<(13276015+1)-1 then if x<(12891525+1)-1 then if x<(12735503+1)-1 then if x<(12719454+1)-1 then l8=a[H]w8=(1+1)-1 T8=(6+1)-1 H8=l8(w8,T8)T8="\072\101\108\108\111"l8="\072\101\108\108\111"B[l8]=H8 w8=B[T8]T8=(2+1)-1 l8=w8>T8 x=l8 and(13297305+1)-1 or(12740512+1)-1 else x=(5+1)-1==(((5+1)-1)+((1+1)-1))-((1+1)-1)x=x and(14313273+1)-1 or(10432227+1)-1 end else if x<(12740352+1)-1 then K="\117\110\112\097\099\107"f=B[K]G=f x=(8763268+1)-1 else T8="\119\116\102"l8=B[T8]T8="\072\101\108\108\111"B[T8]=l8 x=(12482859+1)-1 end end else if x<(12984526+1)-1 then if x<(12925136+1)-1 then A=(88+1)-1==(((85+1)-1)+((1+1)-1))-((1+1)-1)x=(16752929+1)-1 a[R]=A else G={}x=B.Y4uRPbnYO1ID end else if x<(13246325+1)-1 then G8="\108\111\097\100"a8=B[G8]W8=x x=a8 and(16223394+1)-1 or(8503584+1)-1 U8=a8 else x=B.Xt4cCrqcruNd G={}end end end else if x<(13670307+1)-1 then if x<(13467713+1)-1 then if x<(13295557+1)-1 then x=(14193469+1)-1 else w8="\116\111\115\116\114\105\110\103"u8="\072\101\108\108\111"l8=B[w8]T8=B[u8]w8=l8(T8)l8="\119\116\102"x=(12482859+1)-1 B[l8]=w8 end else if x<(13546280+1)-1 then x=B.z3e6mDD12TYKYR O=nil G={}else C=C+P R=C<=F i=not Q R=i and R i=C>=F i=Q and i R=i or R i=(7394572+1)-1 x=R and i R=(8993143+1)-1 x=x or R end end else if x<(13717549+1)-1 then if x<(13688666+1)-1 then d8="\110\101\120\116"O8="\100\105\114"R8=B[d8]F8="\046\047"d8=G8[O8]h8={d8(F8)}O8=h8[(1+1)-1]x=(6415672+1)-1 C8=h8[(2+1)-1]else x=a[l]u="\098\114\111 \119\101 \104\097\118\101\110\'\116 \101\118\101\110 \115\116\097\114\116\101\100 \121\101\116\063\063\063"G=x(u)x=(5838544+1)-1 end else F8="\095\083\085\080\069\082"C8=(-30+1)-1==(((-33+1)-1)+((1+1)-1))-((1+1)-1)h8="\095\083\085\080\069\082"B[F8]=C8 F8=B[h8]x=F8 and(14160795+1)-1 or(16748773+1)-1 end end end else if x<(14173950+1)-1 then if x<(14049921+1)-1 then if x<(13940105+1)-1 then if x<(13892963+1)-1 then p8="\116\105\109\101"n8=B[p8]X8=not n8 x=X8 and(1938671+1)-1 or(1971522+1)-1 else x=(6415672+1)-1 d8=nil end else if x<(13984610+1)-1 then x8="\104\111\119 \117\100 \097\114\101 \119\101\063"x=(9731479+1)-1 V=(-10+1)-1==(((-13+1)-1)+((1+1)-1))-((1+1)-1)a[R]=V D=a[l]b=D(x8)else X8=a[l]x=(4950093+1)-1 J8="\121\111\063"m8=X8(J8)end end else if x<(14161965+1)-1 then if x<(14090446+1)-1 then X8=a[l]x=(2213955+1)-1 p8="\058\040"n8=X8(p8)else F8=a[l]x=(16748773+1)-1 h8=F8()F8=(97+1)-1==(((94+1)-1)+((1+1)-1))-((1+1)-1)a[R]=F8 end else O="\101\114\114\111\114"C=(0+1)-1 x=B[O]R=a[y[(8+1)-1]]O=x(R,C)x=(333196+1)-1 end end else if x<(14298731+1)-1 then if x<(14203700+1)-1 then if x<(14189697+1)-1 then y8="\095\086\069\082\083\073\079\078"x8=B[y8]y8="\076\117\097"b=x8==y8 x=b and(10650627+1)-1 or(11601648+1)-1 else Q="\097"G=B[Q]Q=n((14279326+1)-1,{y[(1+1)-1]})x=G~=Q x=x and(4923651+1)-1 or(12438759+1)-1 end else if x<(14271259+1)-1 then Q=not P R=R+F G=R<=C G=Q and G Q=R>=C Q=P and Q G=Q or G Q=(2047720+1)-1 x=G and Q G=(3053862+1)-1 x=x or G else O="\104\111\119 \116\102 \100\105\100 \117 \101\118\101\110 \103\101\116 \116\104\105\115 \102\097\114 \240\159\152\173\240\159\152\173"x=a[y[(1+1)-1]]G=x(O)x=B["\054\102\112\097\111\112\117\048\083\054\111\069\113\054"]G={}end end else if x<(14394224+1)-1 then if x<(14318841+1)-1 then x=(12732674+1)-1 else x=(5784521+1)-1 end else P=nil G=nil i=G C=U[(3+1)-1]x=nil O=U[(1+1)-1]F=U[(4+1)-1]R=U[(2+1)-1]Q=x x=(9156543+1)-1 end end end end else if x<(15660897+1)-1 then if x<(14972408+1)-1 then if x<(14838527+1)-1 then if x<(14548678+1)-1 then if x<(14508491+1)-1 then x=(81+1)-1==(((81+1)-1)+((1+1)-1))-((1+1)-1)G={}a[y[(1+1)-1]]=x x=B["\051\082\099\075\114\051\085\077\087\075\080\069"]else C8="\105\109 \115\111\114\114\121"R8=(24+1)-1==(((21+1)-1)+((1+1)-1))-((1+1)-1)a[R]=R8 x=(11220445+1)-1 d8=a[l]O8=d8(C8)end else if x<(14782154+1)-1 then l8=(34+1)-1==(((34+1)-1)+((1+1)-1))-((1+1)-1)x=l8 and(1083150+1)-1 or(9601901+1)-1 else O=U[(1+1)-1]x=a[y[(1+1)-1]]C=a[y[(1+1)-1]]R=C[O]C=(1+1)-1 G=R-C x[O]=G R=a[y[(1+1)-1]]G=R[O]R=(0+1)-1 x=G==R x=x and(5956536+1)-1 or(13539159+1)-1 end end else if x<(14897802+1)-1 then if x<(14848125+1)-1 then x=(5828151+1)-1 P=nil else i="\095\069\078\086"x=(1731091+1)-1 Q=B[i]F=Q end else x=a[y[(1+1)-1]]G=a[y[(2+1)-1]]P=nil x[C]=P Q=nil G[C]=Q x=(11158443+1)-1 end end else if x<(15407471+1)-1 then if x<(15149042+1)-1 then if x<(15076285+1)-1 then x=(286274+1)-1 else O=(1+1)-1 G=a[y[(1+1)-1]]x=G+O a[y[(1+1)-1]]=x G=(-29+1)-1==(((-29+1)-1)+((1+1)-1))-((1+1)-1)a[y[(2+1)-1]]=G G={}x=B["\054\082\050\111\054\073\117\120\075\110\074\082\070\114"]end else if x<(15245669+1)-1 then O8,C8=s8(d8,O8)x=O8 and(7819174+1)-1 or(1695674+1)-1 else x=m8 x=X8 and(14044266+1)-1 or(4950093+1)-1 end end else if x<(15601643+1)-1 then if x<(15520595+1)-1 then G={}x=(1+1)-1 a[y[(1+1)-1]]+=x x=B.Yy0N1COoamI3Mh else G={R}x=B.vMVKekp7BlcNc end else x=G and(11121764+1)-1 or(4190356+1)-1 end end end else if x<(16221283+1)-1 then if x<(16038171+1)-1 then if x<(15858303+1)-1 then if x<(15710655+1)-1 then P=G Q=d()G="\103\101\116\102\101\110\118"x=B[G]i=d()a[Q]=x l=d()x=g((12593027+1)-1,{F})a[i]=x x=X((4699482+1)-1,{Q,i,R})H="\112\099\097\108\108"a[l]=x w=B[H]u=not w G=u x=u and(2397731+1)-1 or(1405160+1)-1 else l=(24+1)-1 R="\109\097\116\104"O=B[R]R="\114\097\110\100\111\109"P=(24+1)-1 F=(2+1)-1 G=O[R]R=(1+1)-1 C=F^P P="\109\097\116\104"O=G(R,C)R=a[y[(1+1)-1]]F=(16+1)-1 C=R(F)F=B[P]i=(2+1)-1 P="\114\097\110\100\111\109"R=F[P]P=(1+1)-1 Q=i^l F=R(P,Q)G=C^F x=O-G P="\109\097\116\104"G=a[y[(1+1)-1]]F=B[P]O=x P="\114\097\110\100\111\109"Q=(13+1)-1 C=F[P]P=(6+1)-1 F={C(P,Q)}R=G(s(F))x=R/O G={x}x=B.sp3ApDtQcvCA2 end else if x<(15888690+1)-1 then x=(13757726+1)-1 h8="\073\110\115\116\097\110\099\101"F8=B[h8]h8="\110\101\119"C8=F8[h8]Z8="\103\097\109\101"h8="\080\097\114\116"M8=B[Z8]F8=C8(h8,M8)h8="\085\068\080\065\082\084"C8="\078\097\109\101"F8[C8]=h8 else x=(8080022+1)-1 l8=nil t8=nil end end else if x<(16116662+1)-1 then if x<(16095231+1)-1 then Q="\117\104\117\104\046\046"x=a[y[(1+1)-1]]G=x(Q)x=(14193469+1)-1 else F="\121\111\117\'\114\101 \102\085\068 \098\114\111 \240\159\152\173\240\159\152\173"G="\112\114\105\110\116"x=B[G]C=a[y[(1+1)-1]]R=x O=C or F G=x(O)x=(2563150+1)-1 end else P=M((3942273+1)-1,{})x=(15660897+1)-1 G=P end end else if x<(16684269+1)-1 then if x<(16338577+1)-1 then if x<(16278002+1)-1 then x=W8 x=(8712250+1)-1 y8=U8 else x=Q l="\115\101\116\109\101\116\097\116\097\098\108\101"w="\115\101\108\101\099\116"i="\110\101\119\112\114\111\120\121"Q=B[i]x=B.jhLNzescc4Dlt u="\103\101\116\109\101\116\097\116\097\098\108\101"i=B[l]l=B[u]u=B[w]w={s(O)}C={R(F,P,Q,i,l,u,w)}G={s(C)}end else if x<(16464732+1)-1 then x=a[y[(1+1)-1]]P=a[y[(1+1)-1]]F=P[C]P=(1+1)-1 G=F-P P=(1+1)-1 F=R+P R=F x[C]=G P=a[y[(1+1)-1]]G=P[C]P=(0+1)-1 x=G==P x=x and(14965898+1)-1 or(11158443+1)-1 else H8="\086\101\099\116\111\114\051"l8=B[H8]H8="\111\110\101"i8=l8[H8]H8=(50+1)-1 w8=H8 H8=(1+1)-1 T8=H8 H8=(0+1)-1 u8=T8<H8 l8=(1+1)-1 H8=l8-T8 x=(8080022+1)-1 end end else if x<(16766711+1)-1 then if x<(16751398+1)-1 then x=(10722684+1)-1 M8="\095\083\085\080\069\082"h8=B[M8]else k="\115\101\116\109\101\116\097\116\097\098\108\101"N=B[k]D=p((5362957+1)-1,{R})q={}E="\095\095\116\111\115\116\114\105\110\103"V=X((8532749+1)-1,{R})r="\095\095\105\110\100\101\120"e={[E]=V,[r]=D}k=N(q,e)q="\112\099\097\108\108"N=d()e=g((5539676+1)-1,{N,l})a[N]=k k=B[q]q=k(e)q="\112\099\097\108\108"k=B[q]e=g((3534019+1)-1,{l})q=k(e)q="\103\101\116\109\101\116\097\116\097\098\108\101"k=B[q]e=a[N]q=k(e)k="\095\095\109\101\116\097\116\097\098\108\101"e="\084\104\105\115 \109\101\116\097\116\097\098\108\101 \105\115 \112\114\111\116\101\099\116\101\100\046"q[k]=e q="\112\099\097\108\108"k=B[q]e=g((12633430+1)-1,{})q=k(e)x=q and(1797264+1)-1 or(1215415+1)-1 end else i8=(0+1)-1 Q8=a[m8]P8=Q8==i8 x=(11212182+1)-1 X8=P8 end end end end end end end end x=#j return s(G)end,function(B,s)local U=C(s)local y=function(y,j)return x(B,{y,j},s,U)end return y end,function(B,s)local U=C(s)local y=function(y,j,W,G,a)return x(B,{y;j,W;G;a},s,U)end return y end,function(B,s)local U=C(s)local y=function()return x(B,{},s,U)end return y end,function(B)O[B]=O[B]-((1+1)-1)if O[B]==(0+1)-1 then O[B],a[B]=nil,nil end end,{},function(B,s)local U=C(s)local y=function(y,j,W,G,a,O,d,R,C,F,h,Z,M,g,X,L,n,p,J,m,P)return x(B,{y;j,W,G,a;O;d,R,C;F;h;Z,M,g,X,L,n,p,J;m;P},s,U)end return y end,function(B,s)local U=C(s)local y=function(y,j,W,G,a,O,d)return x(B,{y;j,W,G;a;O,d},s,U)end return y end,function(B)local x,s=(1+1)-1,B[(1+1)-1]while s do O[s],x=O[s]-((1+1)-1),((1+1)-1)+x if O[s]==(0+1)-1 then O[s],a[s]=nil,nil end s=B[x]end end,function(B,s)local U=C(s)local y=function(...)return x(B,{...},s,U)end return y end,function(B,s)local U=C(s)local y=function(y,j,W,G)return x(B,{y;j;W;G},s,U)end return y end,(0+1)-1,function(B,s)local U=C(s)local y=function(y)return x(B,{y},s,U)end return y end return(Z((3848104+1)-1,{}))(s(G))end)(getfenv and getfenv()or _ENV,unpack or table.unpack,newproxy,setmetatable,getmetatable,select,{...})end)(...)
]=])
