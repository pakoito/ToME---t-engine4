local print = print
local dofile = dofile
local socket = require("socket")

module("socketed")

if not socket.connect then
	dofile("/socket.lua")
end

return socket
