require "util.xstanza";

local xmlns_ping = "urn:xmpp:ping";

function verse.plugins.ping(stream)
	function stream:ping(jid, callback)
		local t = socket.gettime();
		stream:send_iq(verse.iq{ to = jid, type = "get" }:tag("ping", { xmlns = xmlns_ping }), 
			function (reply)
				if reply.attr.type == "error" then
					local type, condition, text = reply:get_error();
					if condition ~= "service-unavailable" and condition ~= "feature-not-implemented" then
						callback(nil, jid, { type = type, condition = condition, text = text });
						return;
					end
				end
				callback(socket.gettime()-t, jid);
			end);
	end
	return true;
end
