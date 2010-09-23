local xmlns_roster = "jabber:iq:roster";

function verse.plugins.roster(stream)
	function stream:roster_add(jid, callback)
		self:send_iq(verse.iq({ type = "set" })
			:tag("query", { xmlns = xmlns_roster })
				:tag("item", { jid = jid }), function ()
					callback();
				end);
	end
	
	function stream:roster_fetch(callback)
		self:send_iq(verse.iq({type="get"}):tag("query", { xmlns = xmlns_roster }),
			function (result)
				--TODO: Pass parsed roster to callback
				callback(result);
			end);
	end
end
