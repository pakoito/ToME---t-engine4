local print = print
local dofile = dofile
local socket = require("socket")

module("socketed")

if not socket.connect then
	print("First Socket require")
	dofile("/socket.lua")
end

return socket
