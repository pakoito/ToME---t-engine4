-- Verse XMPP Library
-- Copyright (C) 2010 Hubert Chathi <hubert@uhoreg.ca>
-- Copyright (C) 2010 Matthew Wild <mwild1@gmail.com>
-- 
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local st = require "util.stanza"
local b64 = require("mime").b64
local sha1 = require("util.sha1").sha1

local xmlns_disco = "http://jabber.org/protocol/disco";
local xmlns_disco_info = xmlns_disco.."#info";
local xmlns_disco_items = xmlns_disco.."#items";

function verse.plugins.disco(stream)
	stream.disco = { cache = {}, info = {} }
	stream.disco.info.identities = {
		{category = 'client', type='pc', name='Verse'},
	}
	stream.disco.info.features = {
		{var = 'http://jabber.org/protocol/caps'},
		{var = 'http://jabber.org/protocol/disco#info'},
		{var = 'http://jabber.org/protocol/disco#items'},
	}
	stream.disco.items = {}
	stream.disco.nodes = {}

	stream.caps = {}
	stream.caps.node = 'http://code.matthewwild.co.uk/verse/'

	local function cmp_identity(item1, item2)
		if item1.category < item2.category then
			return true;
		elseif item2.category < item1.category then
			return false;
		end
		if item1.type < item2.type then
			return true;
		elseif item2.type < item1.type then
			return false;
		end
		if (not item1['xml:lang'] and item2['xml:lang']) or
			 (item2['xml:lang'] and item1['xml:lang'] < item2['xml:lang']) then
			return true
		end
		return false
	end

	local function cmp_feature(item1, item2)
		return item1.var < item2.var
	end

	local function calculate_hash()
		table.sort(stream.disco.info.identities, cmp_identity)
		table.sort(stream.disco.info.features, cmp_feature)
		local S = ''
		for key,identity in pairs(stream.disco.info.identities) do
			S = S .. string.format(
				'%s/%s/%s/%s', identity.category, identity.type,
				identity['xml:lang'] or '', identity.name or ''
			) .. '<'
		end
		for key,feature in pairs(stream.disco.info.features) do
			S = S .. feature.var .. '<'
		end
		-- FIXME: make sure S is utf8-encoded
		--stream:debug("Computed hash string: "..S);
		--stream:debug("Computed hash string (sha1): "..sha1(S, true));
		--stream:debug("Computed hash string (sha1+b64): "..b64(sha1(S)));
		return (b64(sha1(S)))
	end

	setmetatable(stream.caps, {
		__call = function (...) -- vararg: allow calling as function or member
			-- retrieve the c stanza to insert into the
			-- presence stanza
			local hash = calculate_hash()
			return st.stanza('c', {
				xmlns = 'http://jabber.org/protocol/caps',
				hash = 'sha-1',
				node = stream.caps.node,
				ver = hash
			})
		end
	})
	
	function stream:add_disco_feature(feature)
		table.insert(self.disco.info.features, {var=feature});		
	end
	
	function stream:remove_disco_feature(feature)
		for idx, disco_feature in ipairs(self.disco.info.features) do
			if disco_feature.var == feature then
				table.remove(self.disco.info.features, idx);
				return true;
			end
		end
	end

	function stream:add_disco_item(item, node)
		local disco_items = self.disco.items;
		if node then
			disco_items = self.disco.nodes[node];
			if not disco_items then
				disco_items = { features = {}, items = {} };
				self.disco.nodes[node] = disco_items;
				disco_items = disco_items.items;
			else
				disco_items = disco_items.items;
			end
		end
		table.insert(disco_items, item);
	end

	function stream:jid_has_identity(jid, category, type)
		local cached_disco = self.disco.cache[jid];
		if not cached_disco then
			return nil, "no-cache";
		end
		local identities = self.disco.cache[jid].identities;
		if type then
			return identities[category.."/"..type] or false;
		end
		-- Check whether we have any identities with this category instead
		for identity in pairs(identities) do
			if identity:match("^(.*)/") == category then
				return true;
			end
		end
	end

	function stream:jid_supports(jid, feature)
		local cached_disco = self.disco.cache[jid];
		if not cached_disco or not cached_disco.features then
			return nil, "no-cache";
		end
		return cached_disco.features[feature] or false;
	end
	
	function stream:get_local_services(category, type)
		local host_disco = self.disco.cache[self.host];
		if not(host_disco) or not(host_disco.items) then
			return nil, "no-cache";
		end
		
		local results = {};
		for _, service in ipairs(host_disco.items) do
			if self:jid_has_identity(service.jid, category, type) then
				table.insert(results, service.jid);
			end
		end
		return results;
	end
	
	function stream:disco_local_services(callback)
		self:disco_items(self.host, nil, function (items)
			local n_items = 0;
			local function item_callback()
				n_items = n_items - 1;
				if n_items == 0 then
					return callback(items);
				end
			end
			
			for _, item in ipairs(items) do
				if item.jid then
					n_items = n_items + 1;
					self:disco_info(item.jid, nil, item_callback);
				end
			end
			if n_items == 0 then
				return callback(items);
			end
		end);
	end
	
	function stream:disco_info(jid, node, callback)
		local disco_request = verse.iq({ to = jid, type = "get" })
			:tag("query", { xmlns = xmlns_disco_info, node = node });
		self:send_iq(disco_request, function (result)
			if result.attr.type == "error" then
				return callback(nil, result:get_error());
			end
			
			local identities, features = {}, {};
			
			for tag in result:get_child("query", xmlns_disco_info):childtags() do
				if tag.name == "identity" then
					identities[tag.attr.category.."/"..tag.attr.type] = tag.attr.name or true;
				elseif tag.name == "feature" then
					features[tag.attr.var] = true;
				end
			end
			

			if not self.disco.cache[jid] then
				self.disco.cache[jid] = { nodes = {} };
			end

			if node then
				if not self.disco.cache[jid].nodes[node] then
					self.disco.cache[jid].nodes[node] = { nodes = {} };
				end
				self.disco.cache[jid].nodes[node].identities = identities;
				self.disco.cache[jid].nodes[node].features = features;
			else
				self.disco.cache[jid].identities = identities;
				self.disco.cache[jid].features = features;
			end
			return callback(self.disco.cache[jid]);
		end);
	end
	
	function stream:disco_items(jid, node, callback)
		local disco_request = verse.iq({ to = jid, type = "get" })
			:tag("query", { xmlns = xmlns_disco_items, node = node });
		self:send_iq(disco_request, function (result)
			if result.attr.type == "error" then
				return callback(nil, result:get_error());
			end
			local disco_items = { };
			for tag in result:get_child("query", xmlns_disco_items):childtags() do
				if tag.name == "item" then
					table.insert(disco_items, {
						name = tag.attr.name;
						jid = tag.attr.jid;
						node = tag.attr.node;
					});
				end
			end
			
			if not self.disco.cache[jid] then
				self.disco.cache[jid] = { nodes = {} };
			end
			
			if node then
				if not self.disco.cache[jid].nodes[node] then
					self.disco.cache[jid].nodes[node] = { nodes = {} };
				end
				self.disco.cache[jid].nodes[node].items = disco_items;
			else
				self.disco.cache[jid].items = disco_items;
			end
			return callback(disco_items);
		end);
	end
	
	stream:hook("iq/http://jabber.org/protocol/disco#info", function (stanza)
		if stanza.attr.type == 'get' then
			local query = stanza:child_with_name('query')
			if not query then return; end
			-- figure out what identities/features to send
			local identities
			local features
			if query.attr.node then
				local hash = calculate_hash()
				local node = stream.disco.nodes[query.attr.node]
				if node and node.info then
					identities = node.info.identities or {}
					features = node.info.identities or {}
				elseif query.attr.node == stream.caps.node..'#'..hash then
					-- matches caps hash, so use the main info
					identities = stream.disco.info.identities
					features = stream.disco.info.features
				else
					-- unknown node: give an error
					local response = st.stanza('iq',{
						to = stanza.attr.from,
						from = stanza.attr.to,
						id = stanza.attr.id,
						type = 'error'
					})
					response:tag('query',{xmlns = 'http://jabber.org/protocol/disco#info'}):reset()
					response:tag('error',{type = 'cancel'}):tag(
						'item-not-found',{xmlns = 'urn:ietf:params:xml:ns:xmpp-stanzas'}
					)
					stream:send(response)
					return true
				end
			else
				identities = stream.disco.info.identities
				features = stream.disco.info.features
			end
			-- construct the response
			local result = st.stanza('query',{
				xmlns = 'http://jabber.org/protocol/disco#info',
				node = query.attr.node
			})
			for key,identity in pairs(identities) do
				result:tag('identity', identity):reset()
			end
			for key,feature in pairs(features) do
				result:tag('feature', feature):reset()
			end
			stream:send(st.stanza('iq',{
				to = stanza.attr.from,
				from = stanza.attr.to,
				id = stanza.attr.id,
				type = 'result'
			}):add_child(result))
			return true
		end
	end);

	stream:hook("iq/http://jabber.org/protocol/disco#items", function (stanza)
		if stanza.attr.type == 'get' then
			local query = stanza:child_with_name('query')
			if not query then return; end
			-- figure out what items to send
			local items
			if query.attr.node then
				local node = stream.disco.nodes[query.attr.node]
				if node then
					items = node.items or {}
				else
					-- unknown node: give an error
					local response = st.stanza('iq',{
						to = stanza.attr.from,
						from = stanza.attr.to,
						id = stanza.attr.id,
						type = 'error'
					})
					response:tag('query',{xmlns = 'http://jabber.org/protocol/disco#items'}):reset()
					response:tag('error',{type = 'cancel'}):tag(
						'item-not-found',{xmlns = 'urn:ietf:params:xml:ns:xmpp-stanzas'}
					)
					stream:send(response)
					return true
				end
			else
				items = stream.disco.items
			end
			-- construct the response
			local result = st.stanza('query',{
				xmlns = 'http://jabber.org/protocol/disco#items',
				node = query.attr.node
			})
			for key,item in pairs(items) do
				result:tag('item', item):reset()
			end
			stream:send(st.stanza('iq',{
				to = stanza.attr.from,
				from = stanza.attr.to,
				id = stanza.attr.id,
				type = 'result'
			}):add_child(result))
			return true
		end
	end);
	
	local initial_disco_started;
	stream:hook("ready", function ()
		if initial_disco_started then return; end
		initial_disco_started = true;
		stream:disco_local_services(function (services)
			for _, service in ipairs(services) do
				for identity in pairs(stream.disco.cache[service.jid].identities) do
					local category, type = identity:match("^(.*)/(.*)$");
					stream:event("disco/service-discovered/"..category, {
						type = type, jid = service.jid;
					});
				end
			end
			stream:event("ready");
		end);
		return true;
	end, 5);
end

-- end of disco.lua
