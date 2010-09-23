
local xmlns_pubsub = "http://jabber.org/protocol/pubsub";
local xmlns_pubsub_event = xmlns_pubsub.."#event";

function verse.plugins.pep(stream)
	stream.pep = {};
	
	stream:hook("message", function (message)
		local event = message:get_child("event", xmlns_pubsub_event);
		if not event then return; end
		local items = event:get_child("items");
		if not items then return; end
		local node = items.attr.node;
		for item in items:childtags() do
			if item.name == "item" and item.attr.xmlns == xmlns_pubsub_event then
				stream:event("pep/"..node, {
					from = message.attr.from,
					item = item.tags[1],
				});
			end
		end
	end);
	
	function stream:hook_pep(node, callback, priority)
		stream:hook("pep/"..node, callback, priority);
		stream:add_disco_feature(node.."+notify");
	end
	
	function stream:unhook_pep(node, callback)
		stream:unhook("pep/"..node, callback);
		local handlers = stream.events._handlers["pep/"..node];
		if not(handlers) or #handlers == 0 then
			stream:remove_disco_feature(node.."+notify");
		end
	end
	
	function stream:publish_pep(item, node)
		local publish = verse.iq({ type = "set" })
			:tag("pubsub", { xmlns = xmlns_pubsub })
				:tag("publish", { node = node or item.attr.xmlns })
					:tag("item")
						:add_child(item);
		return stream:send_iq(publish);
	end
end
