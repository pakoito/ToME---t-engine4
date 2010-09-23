local st = require "util.stanza";
local xmlns_bind = "urn:ietf:params:xml:ns:xmpp-bind";

function verse.plugins.bind(stream)
	local function handle_features(features)
		if stream.bound then return; end
		stream:debug("Binding resource...");
		stream:send_iq(st.iq({ type = "set" }):tag("bind", {xmlns=xmlns_bind}):tag("resource"):text(stream.resource),
			function (reply)
				if reply.attr.type == "result" then
					local result_jid = reply
						:get_child("bind", xmlns_bind)
							:get_child("jid")
								:get_text();
					stream.username, stream.host, stream.resource = jid.split(result_jid);
					stream.jid, stream.bound = result_jid, true;
					stream:event("bind-success", full_jid);
				elseif reply.attr.type == "error" then
					local err = reply:child_with_name("error");
					local type, condition, text = reply:get_error();
					stream:event("bind-failure", { error = condition, text = text, type = type });
				end
			end);
	end
	stream:hook("stream-features", handle_features, 200);
	return true;
end

