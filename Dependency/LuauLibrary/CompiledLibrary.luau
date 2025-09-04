local getLibrary = require("../Utility").getLLibrary

return {
  string = getLibrary("String"),
  math = getLibrary("Math"),
  table = getLibrary("Table"),
  task = getLibrary("Task"),
  buffer = getLibrary("Buffer"),
  bit = getLibrary("Bit"),
  bit32 = bit32,
  os = os,
  coroutine = coroutine,
  utf8 = utf8
}
