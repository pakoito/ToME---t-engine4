local ltn12 = require "ltn12";

local dirsep = package.config:sub(1,1);

local xmlns_jingle_ft = "urn:xmpp:jingle:apps:file-transfer:1";
local xmlns_si_file_transfer = "http://jabber.org/protocol/si/profile/file-transfer";

function verse.plugins.jingle_ft(stream)
	stream:hook("ready", function ()
		stream:add_disco_feature(xmlns_jingle_ft);
	end, 10);
	
	local ft_content = { name = "file" };
	
	function ft_content:generate_accept(description, options)
		if options and options.save_file then
			self.jingle:hook("connected", function ()
				local sink = ltn12.sink.file(io.open(options.save_file, "w+"));
				self.jingle:set_sink(sink);
			end);
		end
		
		return description;
	end
	
	local ft_mt = { __index = ft_content };
	stream:hook("jingle/content/"..xmlns_jingle_ft, function (jingle, description_tag)
		local file_tag = description_tag:get_child("offer"):get_child("file", xmlns_si_file_transfer);
		local file = {
			name = file_tag.attr.name;
			size = tonumber(file_tag.attr.size);
		};
		
		return setmetatable({ jingle = jingle, file = file }, ft_mt);
	end);
	
	stream:hook("jingle/describe/file", function (file_info)
		-- Return <description/>
		local date;
		if file_info.timestamp then
			date = os.date("!%Y-%m-%dT%H:%M:%SZ", file_info.timestamp);
		end
		return verse.stanza("description", { xmlns = xmlns_jingle_ft })
			:tag("offer")
				:tag("file", { xmlns = xmlns_si_file_transfer,
					name = file_info.filename, -- Mandatory
					size = file_info.size, -- Mandatory
					date = date,
					hash = file_info.hash,
				})
					:tag("desc"):text(file_info.description or "");
	end);

	function stream:send_file(to, filename)
		local file, err = io.open(filename);
		if not file then return file, err; end
		
		local file_size = file:seek("end", 0);
		file:seek("set", 0);
		
		local source = ltn12.source.file(file);
		
		local jingle = self:jingle(to);
		jingle:offer("file", {
			filename = filename:match("[^"..dirsep.."]+$");
			size = file_size;
		});
		jingle:hook("connected", function ()
			jingle:set_source(source, true);
		end);
		return jingle;
	end
end
