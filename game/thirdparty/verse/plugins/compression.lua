-- Copyright (C) 2009-2010 Matthew Wild
-- Copyright (C) 2009-2010 Tobias Markmann
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local st = require "util.stanza";
local zlib = require "zlib";

local xmlns_compression_feature = "http://jabber.org/features/compress"
local xmlns_compression_protocol = "http://jabber.org/protocol/compress"
local xmlns_stream = "http://etherx.jabber.org/streams";

local compression_level = 9;

-- returns either nil or a fully functional ready to use inflate stream
local function get_deflate_stream(session)
	local status, deflate_stream = pcall(zlib.deflate, compression_level);
	if status == false then
		local error_st = st.stanza("failure", {xmlns=xmlns_compression_protocol}):tag("setup-failed");
		session:send(error_st);
		session:error("Failed to create zlib.deflate filter: %s", tostring(deflate_stream));
		return
	end
	return deflate_stream
end

-- returns either nil or a fully functional ready to use inflate stream
local function get_inflate_stream(session)
	local status, inflate_stream = pcall(zlib.inflate);
	if status == false then
		local error_st = st.stanza("failure", {xmlns=xmlns_compression_protocol}):tag("setup-failed");
		session:send(error_st);
		session:error("Failed to create zlib.inflate filter: %s", tostring(inflate_stream));
		return
	end
	return inflate_stream
end

-- setup compression for a stream
local function setup_compression(session, deflate_stream)
	function session:send(t)
			--TODO: Better code injection in the sending process
			local status, compressed, eof = pcall(deflate_stream, tostring(t), 'sync');
			if status == false then
				session:close({
					condition = "undefined-condition";
					text = compressed;
					extra = st.stanza("failure", {xmlns="http://jabber.org/protocol/compress"}):tag("processing-failed");
				});
				session:warn("Compressed send failed: %s", tostring(compressed));
				return;
			end
			session.conn:write(compressed);
		end;	
end

-- setup decompression for a stream
local function setup_decompression(session, inflate_stream)
	local old_data = session.data
	session.data = function(conn, data)
			session:debug("Decompressing data...");
			local status, decompressed, eof = pcall(inflate_stream, data);
			if status == false then
				session:close({
					condition = "undefined-condition";
					text = decompressed;
					extra = st.stanza("failure", {xmlns="http://jabber.org/protocol/compress"}):tag("processing-failed");
				});
				stream:warn("%s", tostring(decompressed));
				return;
			end
			return old_data(conn, decompressed);
		end;
end

function verse.plugins.compression(stream)
	local function handle_features(features)
		if not stream.compressed then
			-- does remote server support compression?
			local comp_st = features:child_with_name("compression");
			if comp_st then
				-- do we support the mechanism
				for a in comp_st:children() do
					local algorithm = a[1]
					if algorithm == "zlib" then
						stream:send(st.stanza("compress", {xmlns=xmlns_compression_protocol}):tag("method"):text("zlib"))
						stream:debug("Enabled compression using zlib.")
						return true;
					end
				end
				session:debug("Remote server supports no compression algorithm we support.")
			end
		end
	end
	local function handle_compressed(stanza)
		if stanza.name == "compressed" then
			stream:debug("Activating compression...")

			-- create deflate and inflate streams
			local deflate_stream = get_deflate_stream(stream);
			if not deflate_stream then return end
			
			local inflate_stream = get_inflate_stream(stream);
			if not inflate_stream then return end
			
			-- setup compression for stream.w
			setup_compression(stream, deflate_stream);
				
			-- setup decompression for stream.data
			setup_decompression(stream, inflate_stream);
			
			stream.compressed = true;
			stream:reopen();
		elseif stanza.name == "failure" then
			stream:warn("Failed to establish compression");
		end
	end
	stream:hook("stream-features", handle_features, 250);
	stream:hook("stream/"..xmlns_compression_protocol, handle_compressed);
end
