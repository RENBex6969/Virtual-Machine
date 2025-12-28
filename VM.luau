local VM = require("./Sandbox")
local FileSystem = require("@lune/fs")

VM:Run(FileSystem.readFile("input.luau"))