local stanza_mt = getmetatable(require "util.stanza".stanza());

local xmlns_stanzas = "urn:ietf:params:xml:ns:xmpp-stanzas";

function stanza_mt:get_error()
	local type, condition, text;
	
	local error_tag = self:get_child("error");
	if not error_tag then
		return nil, nil;
	end
	type = error_tag.attr.type;
	
	for child in error_tag:children() do
		if child.attr.xmlns == xmlns_stanzas then
			if child.name == "text" then
				text = child:get_text();
			else
				condition = child.name;
			end
			if condition and text then
				break;
			end
		end
	end
	return type, condition, text;
end
