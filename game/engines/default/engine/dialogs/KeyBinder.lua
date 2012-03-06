-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

require "engine.class"
local Dialog = require "engine.ui.Dialog"
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local KeyBind = require "engine.KeyBind"
local Gestures = require "engine.ui.Gestures"
local GetText = require "engine.dialogs.GetText"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(key_source, force_all, gesture_source)
	Dialog.init(self, "Key bindings", 800, game.h * 0.9)
	self.gesture = gesture_source
	self.key_source = key_source

	self:generateList(key_source, force_all)

	if self.gesture then
		self.c_tree = TreeList.new{width=self.iw, height=self.ih, sel_by_col=true, scrollbar=true, columns={
			{width=40, display_prop="name"},
			{width=20, display_prop="b1"},
			{width=20, display_prop="b2"},
			{width=20, display_prop="g"},
		}, tree=self.tree,
			fct=function(item, sel, v) self:use(item, sel, v) end,
		}
	else
		self.c_tree = TreeList.new{width=self.iw, height=self.ih, sel_by_col=true, scrollbar=true, columns={
			{width=40, display_prop="name"},
			{width=30, display_prop="b1"},
			{width=30, display_prop="b2"},
		}, tree=self.tree,
			fct=function(item, sel, v) self:use(item, sel, v) end,
		}
	end

	self:loadUI{
		{left=0, top=0, ui=self.c_tree},
	}
	self:setupUI()

	self.key:addBinds{
		EXIT = function()
			game:unregisterDialog(self)
			key_source:bindKeys()
			KeyBind:saveRemap()
		end,
	}
end

function _M:use(item)
	local t = item
	local curcol = self.c_tree.cur_col - 1
	if not item or item.nodes or curcol < 1 or curcol > 3 then return end

	--
	-- Make a dialog to ask for the key
	--
	if curcol == 1 or curcol == 2 then
		local title = "Press a key (or escape) for: "..tostring(t.name)
		local font = self.font
		local w, h = font:size(title)
		local d = engine.Dialog.new(title, w + 8, h + 25, nil, nil, nil, font)
		d:keyCommands{__DEFAULT=function(sym, ctrl, shift, alt, meta, unicode)
			-- Modifier keys are not treated
			if not t.single_key and (sym == KeyBind._LCTRL or sym == KeyBind._RCTRL or
			   sym == KeyBind._LSHIFT or sym == KeyBind._RSHIFT or
			   sym == KeyBind._LALT or sym == KeyBind._RALT or
			   sym == KeyBind._LMETA or sym == KeyBind._RMETA) then
				return
			end

			if sym == KeyBind._BACKSPACE then
				KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
				KeyBind.binds_remap[t.type][curcol] = nil
			elseif sym ~= KeyBind._ESCAPE then
				local ks = KeyBind:makeKeyString(sym, ctrl, shift, alt, meta, unicode)
				print("Binding", t.name, "to", ks, "::", curcol)

				KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
				KeyBind.binds_remap[t.type][curcol] = ks
			end
			self.c_tree:drawItem(item)
			game:unregisterDialog(d)
		end}

		d:mouseZones{ norestrict=true,
			{ x=0, y=0, w=game.w, h=game.h, fct=function(button, x, y, xrel, yrel, tx, ty)
				if xrel or yrel then return end
				if button == "right" then return end

				local ks = KeyBind:makeMouseString(
					button,
					core.key.modState("ctrl") and true or false,
					core.key.modState("shift") and true or false,
					core.key.modState("alt") and true or false,
					core.key.modState("meta") and true or false
				)
				print("Binding", t.name, "to", ks)

				KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
				KeyBind.binds_remap[t.type][curcol] = ks
				self.c_tree:drawItem(item)
				game:unregisterDialog(d)
			end },
		}

		d.drawDialog = function(self, s)
			s:drawColorStringBlendedCentered(self.font, curcol == 1 and "Bind key" or "Bind alternate key", 2, 2, self.iw - 2, self.ih - 2)
		end
		game:registerDialog(d)
	elseif curcol == 3 then
		local title = "Make gesture (using right mouse button) or type it (or escape) for: "..tostring(t.name)
		local font = self.font
		local w, h = font:size(title)
		local d = GetText.new(title, "Gesture", 0, 5,
			function(gesture)
				if item.g and item.g ~= "--" then
					self.gesture:removeGesture(item.g)
				end
				KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
				if gesture == "" then
					KeyBind.binds_remap[t.type][curcol] = nil
				else
					KeyBind.binds_remap[t.type][curcol] = KeyBind:makeGestureString(gesture)
					self.gesture:addGesture(gesture, function() self.key_source:triggerVirtual(t.type) end, t.sortname)
				end
				self.c_tree:drawItem(item)
			end,
			function()

			end,
		true)

		d.c_box.filter = function(c)
			c=string.upper(c)
			local text = table.concat(d.c_box.tmp)
			if (c =="U" or c=="D" or c=="L" or c=="R") and c:byte(1)~=text:byte(d.c_box.cursor-1) and c:byte(1)~=text:byte(d.c_box.cursor) then
				return c
			else
				return nil
			end
		end
		d.mouse:registerZone(0, 0, game.w, game.h, function(button, mx, my, xrel, yrel, bx, by, event)
				if button == "right" then
					if event == "motion" then
						self.gesture:changeMouseButton(true)
						self.gesture:mouseMove(mx, my)
						local text = table.concat(d.c_box.tmp)
						if #text < 5 and self.gesture.lastgesture~="" and self.gesture.lastgesture:byte(1)~=text:byte(d.c_box.cursor-1) and self.gesture.lastgesture:byte(1) ~= text:byte(d.c_box.cursor) then
							table.insert(d.c_box.tmp, d.c_box.cursor, self.gesture.lastgesture)
							d.c_box.cursor = d.c_box.cursor + 1
							d.c_box:updateText()
						end
					elseif event == "button" then
						self.gesture:changeMouseButton(false)
						self.gesture:reset()
					end
				end

				d:mouseEvent(button, mx, my, xrel, yrel, bx - d.display_x, by - d.display_y, event)
			end)

		game:registerDialog(d)
	end
end

function _M:generateList(key_source, force_all)
	local l = {}

	for virtual, t in pairs(KeyBind.binds_def) do
		if (force_all or key_source.virtuals[virtual]) then
			l[#l+1] = t
		end
	end
	table.sort(l, function(a,b)
		if a.group ~= b.group then
			return a.group < b.group
		else
			return a.order < b.order
		end
	end)

	-- Makes up the list
	local tree = {}
	local groups = {}
	for _, k in ipairs(l) do
		if not k.only_on_cheat or config.settings.cheat then
			local item = {
				k = k,
				name = tstring{{"font","italic"}, {"color","AQUAMARINE"}, k.name, {"font","normal"}},
				sortname = k.name;
				type = k.type,
				single_key = k.single_key,
				bind1 = function(item) return KeyBind:getBindTable(k)[1] end,
				bind2 = function(item) return KeyBind:getBindTable(k)[2] end,
				bind3 = function(item) return KeyBind:getBindTable(k)[3] end,
				b1 = function(item) return KeyBind:formatKeyString(util.getval(item.bind1, item)) end,
				b2 = function(item) return KeyBind:formatKeyString(util.getval(item.bind2, item)) end,
				g = function(item) return KeyBind:formatKeyString(util.getval(item.bind3, item)) end,
			}
			groups[k.group] = groups[k.group] or {}
			table.insert(groups[k.group], item)
		end
	end

	for group, data in pairs(groups) do
		tree[#tree+1] = {
			name = tstring{{"font","bold"}, {"color","GOLD"}, group:capitalize(), {"font","normal"}},
			sortname = group:capitalize(),
			b1 = "", b2 = "", g = "",
			shown = true,
			nodes = data,
		}
	end
	table.sort(tree, function(a, b) return a.sortname < b.sortname end)

	self.tree = tree
end
