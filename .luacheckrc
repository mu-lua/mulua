stds.mulua = {}
std = "luajit+mulua"

-- Rerun tests only if their modification time changed.
cache = true

-- Don't report unused self arguments of methods.
self = false

ignore = {
  "121", -- setting read-only global variable
  "122", -- setting read-only field of global variable
}

-- Global objects defined by the C code
read_globals = {
  "mulua",
}

globals = {
  "mulua.opts"
}

exclude_files = {
  '**/eval.lua',
}

files["**/preload.lua"]
{
}

-- vim: ft=lua tw=80 sw=2 et