-- Turn on LuaJIT if available
pcall(require, "jit")
if jit then
	jit.on()
	require("jit.opt").start(2)
	print("LuaVM:", jit.version, jit.arch)
else
	print("LuaVM:", _VERSION)
end

-- Requiring "socketed" instead of "socket" makes sockets work
-- Thsi is due to the way luasocket is embeded statically in TE4
require "socketed"
