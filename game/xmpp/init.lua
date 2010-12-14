print("TE4Online starting...")

require "socket"

local sock = socket.connect("te4.org", 5122)
if not sock then return end
