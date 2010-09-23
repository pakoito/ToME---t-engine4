print("XMPP thread starting...")

local jid, password = "test@online.te4.org", "test"

require "verse" -- Verse main library
require "verse.client" -- XMPP client library

-- We always connect at least to the general channel
local channels = { general = true }

c = verse.new()
c:add_plugin("version")
c:add_plugin("disco")
c:add_plugin("pep")

-- Add some hooks for debugging
c:hook("opened", function()
	print("Stream opened!")
end)
c:hook("closed", function()
	print("Stream closed!")
end)
c:hook("stanza", function(stanza)
--	print("Stanza:", stanza)
end)

-- This one prints all received data
--c:hook("incoming-raw", print, 1000)

-- Print a message after authentication
c:hook("authentication-success", function() print("Logged in!") end)
c:hook("authentication-failure", function(err) print("Failed to log in! Error: "..tostring(err.condition)) end)

-- Print a message and exit when disconnected
c:hook("disconnected", function()
	print("Disconnected!")
end)

-- Now, actually start the connection:
c:connect_client(jid, password)

-- Catch the "ready" event to know when the stream is ready to use
c:hook("ready", function()
	print("Stream ready!")
	c.version:set{name = "T-Engine4 XMPP Client"}

	c:hook_pep("http://jabber.org/protocol/te4chat", function(event)
		if channels[event.item.tags[1][1]] then
			print(event.from, "says", event.item.tags[2][1])
		end
--		core.xmpp.
	end)
	c:send(verse.presence():add_child(c:caps()))
end)

verse.loop()
