local xmlns_blocking = "urn:xmpp:blocking";

function verse.plugins.blocking(stream)
	-- FIXME: Disco
	stream.blocking = {};
	function stream.blocking:block_jid(jid, callback)
		stream:send_iq(verse.iq{type="set"}
			:tag("block", { xmlns = xmlns_blocking })
				:tag("item", { jid = jid })
			, function () return callback and callback(true); end
			, function () return callback and callback(false); end
		);
	end
	function stream.blocking:unblock_jid(jid, callback)
		stream:send_iq(verse.iq{type="set"}
			:tag("unblock", { xmlns = xmlns_blocking })
				:tag("item", { jid = jid })
			, function () return callback and callback(true); end
			, function () return callback and callback(false); end
		);
	end
	function stream.blocking:unblock_all_jids(callback)
		stream:send_iq(verse.iq{type="set"}
			:tag("unblock", { xmlns = xmlns_blocking })
			, function () return callback and callback(true); end
			, function () return callback and callback(false); end
		);
	end
	function stream.blocking:get_blocked_jids(callback)
		stream:send_iq(verse.iq{type="get"}
			:tag("blocklist", { xmlns = xmlns_blocking })
			, function (result)
				local list = result:get_child("blocklist", xmlns_blocking);
				if not list then return callback and callback(false); end
				local jids = {};
				for item in list:childtags() do
					jids[#jids+1] = item.attr.jid;
				end
				return callback and callback(jids);
			  end
			, function (result) return callback and callback(false); end
		);
	end
end
