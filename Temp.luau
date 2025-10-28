local passes, fails, undefined = 0, 0, 0
local running = 0
local getGlobal
;
getGlobal = function(path)
	local value = getgenv and CALL(getgenv) or CALL(getfenv, 2)
	while value ~= nil and path ~= "" do
		local name, nextValue = CALL(string["match"], path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end
	return value
end
local test
;
test = function(name, aliases, callback, target)
	running = running + 1
	CALL(task["spawn"], function()
		if not callback then
			CALL(print, "⏺️ " .. name)
		elseif not CALL(getGlobal, name) then
			fails = fails + 1
			CALL(warn, "⛔ " .. name)
		else
			local success, message = CALL(pcall, callback)
			name = CALL(tostring, name)
			message = CALL(tostring, message)
			if success then
				passes = passes + 1
				CALL(print, "✅ " .. CALL(tostring, name) .. (CALL(tostring, message) and " • " .. CALL(tostring, message) or ""))
			else
				fails = fails + 1
				CALL(warn, "⛔ " .. name .. " failed: " .. message)
			end
		end
		local undefinedAliases = {}
		for _, alias in CALL(ipairs, aliases) do
			if CALL(getGlobal, alias) == nil then
				CALL(table["insert"], undefinedAliases, alias)
			end
		end
		if # undefinedAliases > 0 then
			undefined = undefined + 1
			CALL(warn, "⚠️ " .. CALL(table["concat"], undefinedAliases, ", "))
		end
		running = running - 1
	end)
end
CALL(print, "\n")
CALL(print, "UNC Environment Check")
CALL(print, "✅ - Pass, ⛔ - Fail, ⏺️ - No test, ⚠️ - Missing aliases\n")
CALL(test, "cache.invalidate", {}, function()
	local container = CALL(Instance["new"], "Folder")
	local part = CALL(Instance["new"], "Part", container)
	CALL(cache["invalidate"], container:FindFirstChild("Part"))
	CALL(assert, part ~= container:FindFirstChild("Part"), "Reference `part` could not be invalidated")
end)
CALL(test, "cache.iscached", {}, function()
	local part = CALL(Instance["new"], "Part")
	CALL(assert, CALL(cache["iscached"], part), "Part should be cached")
	CALL(cache["invalidate"], part)
	CALL(assert, not CALL(cache["iscached"], part), "Part should not be cached")
end)
CALL(test, "cache.replace", {}, function()
	local part = CALL(Instance["new"], "Part")
	local fire = CALL(Instance["new"], "Fire")
	CALL(cache["replace"], part, fire)
	CALL(assert, part ~= fire, "Part was not replaced with Fire")
end)
CALL(test, "cloneref", {}, function()
	local part = CALL(Instance["new"], "Part")
	local clone = CALL(cloneref, part)
	CALL(assert, part ~= clone, "Clone should not be equal to original")
	clone["Name"] = "Test"
	CALL(assert, part["Name"] == "Test", "Clone should have updated the original")
end)
CALL(test, "compareinstances", {}, function()
	local part = CALL(Instance["new"], "Part")
	local clone = CALL(cloneref, part)
	CALL(assert, part ~= clone, "Clone should not be equal to original")
	CALL(assert, CALL(compareinstances, part, clone), "Clone should be equal to original when using compareinstances()")
end)
local shallowEqual
;
shallowEqual = function(t1, t2)
	if t1 == t2 then
		return true
	end
	local UNIQUE_TYPES = {
		["function"] = true, 
		["table"] = true, 
		["userdata"] = true, 
		["thread"] = true
	}
	for k, v in CALL(pairs, t1) do
		if UNIQUE_TYPES[CALL(type, v)] then
			if CALL(type, t2[k]) ~= CALL(type, v) then
				return false
			end
		elseif t2[k] ~= v then
			return false
		end
	end
	for k, v in CALL(pairs, t2) do
		if UNIQUE_TYPES[CALL(type, v)] then
			if CALL(type, t2[k]) ~= CALL(type, v) then
				return false
			end
		elseif t1[k] ~= v then
			return false
		end
	end
	return true
end
CALL(test, "checkcaller", {}, function()
	CALL(assert, CALL(checkcaller), "Main scope should return true")
end)
CALL(test, "clonefunction", {}, function()
	local test
	;
	test = function()
		return "success"
	end
	local copy = CALL(clonefunction, test)
	CALL(assert, CALL(test) == CALL(copy), "The clone should return the same value as the original")
	CALL(assert, test ~= copy, "The clone should not be equal to the original")
end)
CALL(test, "getcallingscript", {})
CALL(test, "getscriptclosure", {
	"getscriptfunction"
}, function()
	local module = game:GetService("CoreGui")["RobloxGui"]["Modules"]["Common"]["Constants"]
	local constants = CALL(CALL(getrenv)["require"], module)
	local generated = CALL(CALL(getscriptclosure, module))
	CALL(assert, constants ~= generated, "Generated module should not match the original")
	CALL(assert, CALL(shallowEqual, constants, generated), "Generated constant table should be shallow equal to the original")
end)
CALL(test, "hookfunction", {
	"replaceclosure"
}, function()
	local test
	;
	test = function()
		return true
	end
	local ref = CALL(hookfunction, test, function()
		return false
	end)
	CALL(assert, CALL(test) == false, "Function should return false")
	CALL(assert, CALL(ref) == true, "Original function should return true")
	CALL(assert, test ~= ref, "Original function should not be same as the reference")
end)
CALL(test, "iscclosure", {}, function()
	CALL(assert, CALL(iscclosure, print) == true, "Function 'print' should be a C closure")
	CALL(assert, CALL(iscclosure, function()end) == false, "Executor function should not be a C closure")
end)
CALL(test, "islclosure", {}, function()
	CALL(assert, CALL(islclosure, print) == false, "Function 'print' should not be a Lua closure")
	CALL(assert, CALL(islclosure, function()end) == true, "Executor function should be a Lua closure")
end)
CALL(test, "isexecutorclosure", {
	"checkclosure", 
	"isourclosure"
}, function()
	CALL(assert, CALL(isexecutorclosure, isexecutorclosure) == true, "Did not return true for an executor global")
	CALL(assert, CALL(isexecutorclosure, CALL(newcclosure, function()end)) == true, "Did not return true for an executor C closure")
	CALL(assert, CALL(isexecutorclosure, function()end) == true, "Did not return true for an executor Luau closure")
	CALL(assert, CALL(isexecutorclosure, print) == false, "Did not return false for a Roblox global")
end)
CALL(test, "loadstring", {}, function()
	local animate = game:GetService("Players")["LocalPlayer"]["Character"]["Animate"]
	local bytecode = CALL(getscriptbytecode, animate)
	local func = CALL(loadstring, bytecode)
	CALL(assert, CALL(type, func) ~= "function", "Luau bytecode should not be loadable!")
	CALL(assert, CALL(CALL(assert, CALL(loadstring, "return ... + 1")), 1) == 2, "Failed to do simple math")
	CALL(assert, CALL(type, CALL(select, 2, CALL(loadstring, "f"))) == "string", "Loadstring did not return anything for a compiler error")
end)
CALL(test, "newcclosure", {}, function()
	local test
	;
	test = function()
		return true
	end
	local testC = CALL(newcclosure, test)
	CALL(assert, CALL(test) == CALL(testC), "New C closure should return the same value as the original")
	CALL(assert, test ~= testC, "New C closure should not be same as the original")
	CALL(assert, CALL(iscclosure, testC), "New C closure should be a C closure")
end)
CALL(test, "rconsoleclear", {
	"consoleclear"
})
CALL(test, "rconsolecreate", {
	"consolecreate"
})
CALL(test, "rconsoledestroy", {
	"consoledestroy"
})
CALL(test, "rconsoleinput", {
	"consoleinput"
})
CALL(test, "rconsoleprint", {
	"consoleprint"
})
CALL(test, "rconsolesettitle", {
	"rconsolename", 
	"consolesettitle"
})
CALL(test, "crypt.base64encode", {
	"crypt.base64.encode", 
	"crypt.base64_encode", 
	"base64.encode", 
	"base64_encode"
}, function()
	CALL(assert, CALL(crypt["base64encode"], "test") == "dGVzdA==", "Base64 encoding failed")
end)
CALL(test, "crypt.base64decode", {
	"crypt.base64.decode", 
	"crypt.base64_decode", 
	"base64.decode", 
	"base64_decode"
}, function()
	CALL(assert, CALL(crypt["base64decode"], "dGVzdA==") == "test", "Base64 decoding failed")
end)
CALL(test, "crypt.encrypt", {}, function()
	local key = CALL(crypt["generatekey"])
	local encrypted, iv = CALL(crypt["encrypt"], "test", key, nil, "CBC")
	CALL(assert, iv, "crypt.encrypt should return an IV")
	local decrypted = CALL(crypt["decrypt"], encrypted, key, iv, "CBC")
	CALL(assert, decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)
CALL(test, "crypt.decrypt", {}, function()
	local key, iv = CALL(crypt["generatekey"]), CALL(crypt["generatekey"])
	local encrypted = CALL(crypt["encrypt"], "test", key, iv, "CBC")
	local decrypted = CALL(crypt["decrypt"], encrypted, key, iv, "CBC")
	CALL(assert, decrypted == "test", "Failed to decrypt raw string from encrypted data")
end)
CALL(test, "crypt.generatebytes", {}, function()
	local size = CALL(math["random"], 10, 100)
	local bytes = CALL(crypt["generatebytes"], size)
	CALL(assert, # CALL(crypt["base64decode"], bytes) == size, "The decoded result should be " .. size .. " bytes long (got " .. # CALL(crypt["base64decode"], bytes) .. " decoded, " .. # bytes .. " raw)")
end)
CALL(test, "crypt.generatekey", {}, function()
	local key = CALL(crypt["generatekey"])
	CALL(assert, # CALL(crypt["base64decode"], key) == 32, "Generated key should be 32 bytes long when decoded")
end)
CALL(test, "crypt.hash", {}, function()
	local algorithms = {
		"sha1", 
		"sha384", 
		"sha512", 
		"md5", 
		"sha256", 
		"sha3-224", 
		"sha3-256", 
		"sha3-512"
	}
	for _, algorithm in CALL(ipairs, algorithms) do
		local hash = CALL(crypt["hash"], "test", algorithm)
		CALL(assert, hash, "crypt.hash on algorithm '" .. algorithm .. "' should return a hash")
	end
end)
CALL(test, "debug.getconstant", {}, function()
	local test
	;
	test = function()
		CALL(print, "Hello, world!")
	end
	CALL(assert, CALL(debug["getconstant"], test, 1) == "print", "First constant must be print")
	CALL(assert, CALL(debug["getconstant"], test, 2) == nil, "Second constant must be nil")
	CALL(assert, CALL(debug["getconstant"], test, 3) == "Hello, world!", "Third constant must be 'Hello, world!'")
end)
CALL(test, "debug.getconstants", {}, function()
	local test
	;
	test = function()
		local num = 5000 .. 50000
		CALL(print, "Hello, world!", num, warn)
	end
	local constants = CALL(debug["getconstants"], test)
	CALL(assert, constants[1] == 50000, "First constant must be 50000")
	CALL(assert, constants[2] == "print", "Second constant must be print")
	CALL(assert, constants[3] == nil, "Third constant must be nil")
	CALL(assert, constants[4] == "Hello, world!", "Fourth constant must be 'Hello, world!'")
	CALL(assert, constants[5] == "warn", "Fifth constant must be warn")
end)
CALL(test, "debug.getinfo", {}, function()
	local types = {
		["source"] = "string", 
		["short_src"] = "string", 
		["func"] = "function", 
		["what"] = "string", 
		["currentline"] = "number", 
		["name"] = "string", 
		["nups"] = "number", 
		["numparams"] = "number", 
		["is_vararg"] = "number"
	}
	local test
	;
	test = function(...)
		CALL(print, ...)
	end
	local info = CALL(debug["getinfo"], test)
	for k, v in CALL(pairs, types) do
		CALL(assert, info[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		CALL(assert, CALL(type, info[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. CALL(type, info[k]) .. ")")
	end
end)
CALL(test, "debug.getproto", {}, function()
	local test
	;
	test = function()
		local proto
		;
		proto = function()
			return true
		end
	end
	local proto = CALL(debug["getproto"], test, 1, true)[1]
	local realproto = CALL(debug["getproto"], test, 1)
	CALL(assert, proto, "Failed to get the inner function")
	CALL(assert, CALL(proto) == true, "The inner function did not return anything")
	if not CALL(realproto) then
		return "Proto return values are disabled on this executor"
	end
end)
CALL(test, "debug.getprotos", {}, function()
	local test
	;
	test = function()
		local _1
		;
		_1 = function()
			return true
		end
		local _2
		;
		_2 = function()
			return true
		end
		local _3
		;
		_3 = function()
			return true
		end
	end
	for i in CALL(ipairs, CALL(debug["getprotos"], test)) do
		local proto = CALL(debug["getproto"], test, i, true)[1]
		local realproto = CALL(debug["getproto"], test, i)
		CALL(assert, CALL(proto), "Failed to get inner function " .. i)
		if not CALL(realproto) then
			return "Proto return values are disabled on this executor"
		end
	end
end)
CALL(test, "debug.getstack", {}, function()
	local _ = "a" .. "b"
	CALL(assert, CALL(debug["getstack"], 1, 1) == "ab", "The first item in the stack should be 'ab'")
	CALL(assert, CALL(debug["getstack"], 1)[1] == "ab", "The first item in the stack table should be 'ab'")
end)
CALL(test, "debug.getupvalue", {}, function()
	local upvalue = function()end
	local test
	;
	test = function()
		CALL(print, upvalue)
	end
	CALL(assert, CALL(debug["getupvalue"], test, 1) == upvalue, "Unexpected value returned from debug.getupvalue")
end)
CALL(test, "debug.getupvalues", {}, function()
	local upvalue = function()end
	local test
	;
	test = function()
		CALL(print, upvalue)
	end
	local upvalues = CALL(debug["getupvalues"], test)
	CALL(assert, upvalues[1] == upvalue, "Unexpected value returned from debug.getupvalues")
end)
CALL(test, "debug.setconstant", {}, function()
	local test
	;
	test = function()
		return "fail"
	end
	CALL(debug["setconstant"], test, 1, "success")
	CALL(assert, CALL(test) == "success", "debug.setconstant did not set the first constant")
end)
CALL(test, "debug.setstack", {}, function()
	local test
	;
	test = function()
		return "fail", CALL(debug["setstack"], 1, 1, "success")
	end
	CALL(assert, CALL(test) == "success", "debug.setstack did not set the first stack item")
end)
CALL(test, "debug.setupvalue", {}, function()
	local upvalue
	;
	upvalue = function()
		return "fail"
	end
	local test
	;
	test = function()
		return CALL(upvalue)
	end
	CALL(debug["setupvalue"], test, 1, function()
		return "success"
	end)
	CALL(assert, CALL(test) == "success", "debug.setupvalue did not set the first upvalue")
end)
if isfolder and makefolder and delfolder then
	if CALL(isfolder, ".tests") then
		CALL(delfolder, ".tests")
	end
	CALL(makefolder, ".tests")
end
CALL(test, "readfile", {}, function()
	CALL(writefile, ".tests/readfile.txt", "success")
	CALL(assert, CALL(readfile, ".tests/readfile.txt") == "success", "Did not return the contents of the file")
end)
CALL(test, "listfiles", {}, function()
	CALL(makefolder, ".tests/listfiles")
	CALL(writefile, ".tests/listfiles/test_1.txt", "success")
	CALL(writefile, ".tests/listfiles/test_2.txt", "success")
	local files = CALL(listfiles, ".tests/listfiles")
	CALL(assert, # files == 2, "Did not return the correct number of files")
	CALL(assert, CALL(isfile, files[1]), "Did not return a file path")
	CALL(assert, CALL(readfile, files[1]) == "success", "Did not return the correct files")
	CALL(makefolder, ".tests/listfiles_2")
	CALL(makefolder, ".tests/listfiles_2/test_1")
	CALL(makefolder, ".tests/listfiles_2/test_2")
	local folders = CALL(listfiles, ".tests/listfiles_2")
	CALL(assert, # folders == 2, "Did not return the correct number of folders")
	CALL(assert, CALL(isfolder, folders[1]), "Did not return a folder path")
end)
CALL(test, "writefile", {}, function()
	CALL(writefile, ".tests/writefile.txt", "success")
	CALL(assert, CALL(readfile, ".tests/writefile.txt") == "success", "Did not write the file")
	local requiresFileExt = CALL(pcall, function()
		CALL(writefile, ".tests/writefile", "success")
		CALL(assert, CALL(isfile, ".tests/writefile.txt"))
	end)
	if not requiresFileExt then
		return "This executor requires a file extension in writefile"
	end
end)
CALL(test, "makefolder", {}, function()
	CALL(makefolder, ".tests/makefolder")
	CALL(assert, CALL(isfolder, ".tests/makefolder"), "Did not create the folder")
end)
CALL(test, "appendfile", {}, function()
	CALL(writefile, ".tests/appendfile.txt", "su")
	CALL(appendfile, ".tests/appendfile.txt", "cce")
	CALL(appendfile, ".tests/appendfile.txt", "ss")
	CALL(assert, CALL(readfile, ".tests/appendfile.txt") == "success", "Did not append the file")
end)
CALL(test, "isfile", {}, function()
	CALL(writefile, ".tests/isfile.txt", "success")
	CALL(assert, CALL(isfile, ".tests/isfile.txt") == true, "Did not return true for a file")
	CALL(assert, CALL(isfile, ".tests") == false, "Did not return false for a folder")
	CALL(assert, CALL(isfile, ".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. CALL(tostring, CALL(isfile, ".tests/doesnotexist.exe")) .. ")")
end)
CALL(test, "isfolder", {}, function()
	CALL(assert, CALL(isfolder, ".tests") == true, "Did not return false for a folder")
	CALL(assert, CALL(isfolder, ".tests/doesnotexist.exe") == false, "Did not return false for a nonexistent path (got " .. CALL(tostring, CALL(isfolder, ".tests/doesnotexist.exe")) .. ")")
end)
CALL(test, "delfolder", {}, function()
	CALL(makefolder, ".tests/delfolder")
	CALL(delfolder, ".tests/delfolder")
	CALL(assert, CALL(isfolder, ".tests/delfolder") == false, "Failed to delete folder (isfolder = " .. CALL(tostring, CALL(isfolder, ".tests/delfolder")) .. ")")
end)
CALL(test, "delfile", {}, function()
	CALL(writefile, ".tests/delfile.txt", "Hello, world!")
	CALL(delfile, ".tests/delfile.txt")
	CALL(assert, CALL(isfile, ".tests/delfile.txt") == false, "Failed to delete file (isfile = " .. CALL(tostring, CALL(isfile, ".tests/delfile.txt")) .. ")")
end)
CALL(test, "dofile", {})
CALL(test, "isrbxactive", {
	"isgameactive"
}, function()
	CALL(assert, CALL(type, CALL(isrbxactive)) == "boolean", "Did not return a boolean value")
end)
CALL(test, "mouse1click", {})
CALL(test, "mouse1press", {})
CALL(test, "mouse1release", {})
CALL(test, "mouse2click", {})
CALL(test, "mouse2press", {})
CALL(test, "mouse2release", {})
CALL(test, "mousemoveabs", {})
CALL(test, "mousemoverel", {})
CALL(test, "mousescroll", {})
CALL(test, "fireclickdetector", {}, function()
	local detector = CALL(Instance["new"], "ClickDetector")
	CALL(fireclickdetector, detector, 50, "MouseHoverEnter")
end)
CALL(test, "getcallbackvalue", {}, function()
	local bindable = CALL(Instance["new"], "BindableFunction")
	local test
	;
	test = function()end
	bindable["OnInvoke"] = test
	CALL(assert, CALL(getcallbackvalue, bindable, "OnInvoke") == test, "Did not return the correct value")
end)
CALL(test, "getconnections", {}, function()
	local types = {
		["Enabled"] = "boolean", 
		["ForeignState"] = "boolean", 
		["LuaConnection"] = "boolean", 
		["Function"] = "function", 
		["Thread"] = "thread", 
		["Fire"] = "function", 
		["Defer"] = "function", 
		["Disconnect"] = "function", 
		["Disable"] = "function", 
		["Enable"] = "function"
	}
	local bindable = CALL(Instance["new"], "BindableEvent")
	bindable["Event"]:Connect(function()end)
	local connection = CALL(getconnections, bindable["Event"])[1]
	for k, v in CALL(pairs, types) do
		CALL(assert, connection[k] ~= nil, "Did not return a table with a '" .. k .. "' field")
		CALL(assert, CALL(type, connection[k]) == v, "Did not return a table with " .. k .. " as a " .. v .. " (got " .. CALL(type, connection[k]) .. ")")
	end
end)
CALL(test, "getcustomasset", {}, function()
	CALL(writefile, ".tests/getcustomasset.txt", "success")
	local contentId = CALL(getcustomasset, ".tests/getcustomasset.txt")
	CALL(assert, CALL(type, contentId) == "string", "Did not return a string")
	CALL(assert, # contentId > 0, "Returned an empty string")
	CALL(assert, CALL(string["match"], contentId, "rbxasset://") == "rbxasset://", "Did not return an rbxasset url")
end)
CALL(test, "gethiddenproperty", {}, function()
	local fire = CALL(Instance["new"], "Fire")
	local property, isHidden = CALL(gethiddenproperty, fire, "size_xml")
	CALL(assert, property == 5, "Did not return the correct value")
	CALL(assert, isHidden == true, "Did not return whether the property was hidden")
end)
CALL(test, "sethiddenproperty", {}, function()
	local fire = CALL(Instance["new"], "Fire")
	local hidden = CALL(sethiddenproperty, fire, "size_xml", 10)
	CALL(assert, hidden, "Did not return true for the hidden property")
	CALL(assert, CALL(gethiddenproperty, fire, "size_xml") == 10, "Did not set the hidden property")
end)
CALL(test, "gethui", {}, function()
	CALL(assert, CALL(typeof, CALL(gethui)) == "Instance", "Did not return an Instance")
end)
CALL(test, "getinstances", {}, function()
	CALL(assert, CALL(getinstances)[1]:IsA("Instance"), "The first value is not an Instance")
end)
CALL(test, "getnilinstances", {}, function()
	CALL(assert, CALL(getnilinstances)[1]:IsA("Instance"), "The first value is not an Instance")
	CALL(assert, CALL(getnilinstances)[1]["Parent"] == nil, "The first value is not parented to nil")
end)
CALL(test, "isscriptable", {}, function()
	local fire = CALL(Instance["new"], "Fire")
	CALL(assert, CALL(isscriptable, fire, "size_xml") == false, "Did not return false for a non-scriptable property (size_xml)")
	CALL(assert, CALL(isscriptable, fire, "Size") == true, "Did not return true for a scriptable property (Size)")
end)
CALL(test, "setscriptable", {}, function()
	local fire = CALL(Instance["new"], "Fire")
	local wasScriptable = CALL(setscriptable, fire, "size_xml", true)
	CALL(assert, wasScriptable == false, "Did not return false for a non-scriptable property (size_xml)")
	CALL(assert, CALL(isscriptable, fire, "size_xml") == true, "Did not set the scriptable property")
	fire = CALL(Instance["new"], "Fire")
	CALL(assert, CALL(isscriptable, fire, "size_xml") == false, "⚠️⚠️ setscriptable persists between unique instances ⚠️⚠️")
end)
CALL(test, "setrbxclipboard", {})
CALL(test, "getrawmetatable", {}, function()
	local metatable = {
		["__metatable"] = "Locked!"
	}
	local object = CALL(setmetatable, {}, metatable)
	CALL(assert, CALL(getrawmetatable, object) == metatable, "Did not return the metatable")
end)
CALL(test, "hookmetamethod", {}, function()
	local object = CALL(setmetatable, {}, {
		["__index"] = CALL(newcclosure, function()
			return false
		end), 
		["__metatable"] = "Locked!"
	})
	local ref = CALL(hookmetamethod, object, "__index", function()
		return true
	end)
	CALL(assert, object["test"] == true, "Failed to hook a metamethod and change the return value")
	CALL(assert, CALL(ref) == false, "Did not return the original function")
end)
CALL(test, "getnamecallmethod", {}, function()
	local method
	local ref
	ref = CALL(hookmetamethod, game, "__namecall", function(...)
		if not method then
			method = CALL(getnamecallmethod)
		end
		return CALL(ref, ...)
	end)
	game:GetService("Lighting")
	CALL(assert, method == "GetService", "Did not get the correct method (GetService)")
end)
CALL(test, "isreadonly", {}, function()
	local object = {}
	CALL(table["freeze"], object)
	CALL(assert, CALL(isreadonly, object), "Did not return true for a read-only table")
end)
CALL(test, "setrawmetatable", {}, function()
	local object = CALL(setmetatable, {}, {
		["__index"] = function()
			return false
		end, 
		["__metatable"] = "Locked!"
	})
	local objectReturned = CALL(setrawmetatable, object, {
		["__index"] = function()
			return true
		end
	})
	CALL(assert, object, "Did not return the original object")
	CALL(assert, object["test"] == true, "Failed to change the metatable")
	if objectReturned then
		return objectReturned == object and "Returned the original object" or "Did not return the original object"
	end
end)
CALL(test, "setreadonly", {}, function()
	local object = {
		["success"] = false
	}
	CALL(table["freeze"], object)
	CALL(setreadonly, object, false)
	object["success"] = true
	CALL(assert, object["success"], "Did not allow the table to be modified")
end)
CALL(test, "identifyexecutor", {
	"getexecutorname"
}, function()
	local name, version = CALL(identifyexecutor)
	CALL(assert, CALL(type, name) == "string", "Did not return a string for the name")
	return CALL(type, version) == "string" and "Returns version as a string" or "Does not return version"
end)
CALL(test, "lz4compress", {}, function()
	local raw = "Hello, world!"
	local compressed = CALL(lz4compress, raw)
	CALL(assert, CALL(type, compressed) == "string", "Compression did not return a string")
	CALL(assert, CALL(lz4decompress, compressed, # raw) == raw, "Decompression did not return the original string")
end)
CALL(test, "lz4decompress", {}, function()
	local raw = "Hello, world!"
	local compressed = CALL(lz4compress, raw)
	CALL(assert, CALL(type, compressed) == "string", "Compression did not return a string")
	CALL(assert, CALL(lz4decompress, compressed, # raw) == raw, "Decompression did not return the original string")
end)
CALL(test, "messagebox", {})
CALL(test, "queue_on_teleport", {
	"queueonteleport"
})
CALL(test, "request", {
	"http.request", 
	"http_request"
}, function()
	local response = CALL(request, {
		["Url"] = "https://httpbin.org/user-agent", 
		["Method"] = "GET"
	})
	CALL(assert, CALL(type, response) == "table", "Response must be a table")
	CALL(assert, response["StatusCode"] == 200, "Did not return a 200 status code")
	local data = game:GetService("HttpService"):JSONDecode(response["Body"])
	CALL(assert, CALL(type, data) == "table" and CALL(type, data["user-agent"]) == "string", "Did not return a table with a user-agent key")
	return "User-Agent: " .. data["user-agent"]
end)
CALL(test, "setclipboard", {
	"toclipboard"
})
CALL(test, "setfpscap", {}, function()
	local renderStepped = game:GetService("RunService")["RenderStepped"]
	local step
	;
	step = function()
		renderStepped:Wait()
		local sum = 0
		for _ = 1, 5 do
			sum = sum + 1 / renderStepped:Wait()
		end
		return CALL(math["round"], sum / 5)
	end
	CALL(setfpscap, 60)
	local step60 = CALL(step)
	CALL(setfpscap, 0)
	local step0 = CALL(step)
	return step60 .. "fps @60 • " .. step0 .. "fps @0"
end)
CALL(test, "getgc", {}, function()
	local gc = CALL(getgc)
	CALL(assert, CALL(type, gc) == "table", "Did not return a table")
	CALL(assert, # gc > 0, "Did not return a table with any values")
end)
CALL(test, "getgenv", {}, function()
	CALL(getgenv)["__TEST_GLOBAL"] = true
	CALL(assert, __TEST_GLOBAL, "Failed to set a global variable")
	CALL(getgenv)["__TEST_GLOBAL"] = nil
end)
CALL(test, "getloadedmodules", {}, function()
	local modules = CALL(getloadedmodules)
	CALL(assert, CALL(type, modules) == "table", "Did not return a table")
	CALL(assert, # modules > 0, "Did not return a table with any values")
	CALL(assert, CALL(typeof, modules[1]) == "Instance", "First value is not an Instance")
	CALL(assert, modules[1]:IsA("ModuleScript"), "First value is not a ModuleScript")
end)
CALL(test, "getrenv", {}, function()
	CALL(assert, _G ~= CALL(getrenv)["_G"], "The variable _G in the executor is identical to _G in the game")
end)
CALL(test, "getrunningscripts", {}, function()
	local scripts = CALL(getrunningscripts)
	CALL(assert, CALL(type, scripts) == "table", "Did not return a table")
	CALL(assert, # scripts > 0, "Did not return a table with any values")
	CALL(assert, CALL(typeof, scripts[1]) == "Instance", "First value is not an Instance")
	CALL(assert, scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)
CALL(test, "getscriptbytecode", {
	"dumpstring"
}, function()
	local animate = game:GetService("Players")["LocalPlayer"]["Character"]["Animate"]
	local bytecode = CALL(getscriptbytecode, animate)
	CALL(assert, CALL(type, bytecode) == "string", "Did not return a string for Character.Animate (a " .. animate["ClassName"] .. ")")
end)
CALL(test, "getscripthash", {}, function()
	local animate = game:GetService("Players")["LocalPlayer"]["Character"]["Animate"]:Clone()
	local hash = CALL(getscripthash, animate)
	local source = animate["Source"]
	animate["Source"] = "print('Hello, world!')"
	CALL(task["defer"], function()
		animate["Source"] = source
	end)
	local newHash = CALL(getscripthash, animate)
	CALL(assert, hash ~= newHash, "Did not return a different hash for a modified script")
	CALL(assert, newHash == CALL(getscripthash, animate), "Did not return the same hash for a script with the same source")
end)
CALL(test, "getscripts", {}, function()
	local scripts = CALL(getscripts)
	CALL(assert, CALL(type, scripts) == "table", "Did not return a table")
	CALL(assert, # scripts > 0, "Did not return a table with any values")
	CALL(assert, CALL(typeof, scripts[1]) == "Instance", "First value is not an Instance")
	CALL(assert, scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "First value is not a ModuleScript or LocalScript")
end)
CALL(test, "getsenv", {}, function()
	local animate = game:GetService("Players")["LocalPlayer"]["Character"]["Animate"]
	local env = CALL(getsenv, animate)
	CALL(assert, CALL(type, env) == "table", "Did not return a table for Character.Animate (a " .. animate["ClassName"] .. ")")
	CALL(assert, env["script"] == animate, "The script global is not identical to Character.Animate")
end)
CALL(test, "getthreadidentity", {
	"getidentity", 
	"getthreadcontext"
}, function()
	CALL(assert, CALL(type, CALL(getthreadidentity)) == "number", "Did not return a number")
end)
CALL(test, "setthreadidentity", {
	"setidentity", 
	"setthreadcontext"
}, function()
	CALL(setthreadidentity, 3)
	CALL(assert, CALL(getthreadidentity) == 3, "Did not set the thread identity")
end)
CALL(test, "Drawing", {})
CALL(test, "Drawing.new", {}, function()
	local drawing = CALL(Drawing["new"], "Square")
	drawing["Visible"] = false
	local canDestroy = CALL(pcall, function()
		drawing:Destroy()
	end)
	CALL(assert, canDestroy, "Drawing:Destroy() should not throw an error")
end)
CALL(test, "Drawing.Fonts", {}, function()
	CALL(assert, Drawing["Fonts"]["UI"] == 0, "Did not return the correct id for UI")
	CALL(assert, Drawing["Fonts"]["System"] == 1, "Did not return the correct id for System")
	CALL(assert, Drawing["Fonts"]["Plex"] == 2, "Did not return the correct id for Plex")
	CALL(assert, Drawing["Fonts"]["Monospace"] == 3, "Did not return the correct id for Monospace")
end)
CALL(test, "isrenderobj", {}, function()
	local drawing = CALL(Drawing["new"], "Image")
	drawing["Visible"] = true
	CALL(assert, CALL(isrenderobj, drawing) == true, "Did not return true for an Image")
	CALL(assert, CALL(isrenderobj, CALL(newproxy)) == false, "Did not return false for a blank table")
end)
CALL(test, "getrenderproperty", {}, function()
	local drawing = CALL(Drawing["new"], "Image")
	drawing["Visible"] = true
	CALL(assert, CALL(type, CALL(getrenderproperty, drawing, "Visible")) == "boolean", "Did not return a boolean value for Image.Visible")
	local success, result = CALL(pcall, function()
		return CALL(getrenderproperty, drawing, "Color")
	end)
	if not success or not result then
		return "Image.Color is not supported"
	end
end)
CALL(test, "setrenderproperty", {}, function()
	local drawing = CALL(Drawing["new"], "Square")
	drawing["Visible"] = true
	CALL(setrenderproperty, drawing, "Visible", false)
	CALL(assert, drawing["Visible"] == false, "Did not set the value for Square.Visible")
end)
CALL(test, "cleardrawcache", {}, function()
	CALL(cleardrawcache)
end)
CALL(test, "WebSocket", {})
CALL(test, "WebSocket.connect", {}, function()
	local types = {
		["Send"] = "function", 
		["Close"] = "function", 
		["OnMessage"] = {
			"table", 
			"userdata"
		}, 
		["OnClose"] = {
			"table", 
			"userdata"
		}
	}
	local ws = CALL(WebSocket["connect"], "wss://echo.websocket.org")
	CALL(assert, CALL(type, ws) == "table" or CALL(type, ws) == "userdata", "Did not return a table or userdata")
	for k, v in CALL(pairs, types) do
		if CALL(type, v) == "table" then
			CALL(assert, CALL(table["find"], v, CALL(type, ws[k])), "Did not return a " .. CALL(table["concat"], v, ", ") .. " for " .. k .. " (a " .. CALL(type, ws[k]) .. ")")
		else
			CALL(assert, CALL(type, ws[k]) == v, "Did not return a " .. v .. " for " .. k .. " (a " .. CALL(type, ws[k]) .. ")")
		end
	end
	ws:Close()
end)
CALL(task["defer"], function()
	repeat
		CALL(task["wait"])
	until running == 0
	local rate = CALL(math["round"], passes / (passes + fails) * 100)
	local outOf = passes .. " out of " .. (passes + fails)
	CALL(print, "\n")
	CALL(print, "UNC Summary")
	CALL(print, "✅ Tested with a " .. rate .. "% success rate (" .. outOf .. ")")
	CALL(print, "⛔ " .. fails .. " tests failed")
	CALL(print, "⚠️ " .. undefined .. " globals are missing aliases")
end)