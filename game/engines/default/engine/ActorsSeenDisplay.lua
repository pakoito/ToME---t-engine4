-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

module(..., package.seeall, class.make)

function _M:init(actor, x, y, w, h, bgcolor, fontname, fontsize)
	self.actor = actor
	if type(bgcolor) ~= "string" then
		self.bgcolor = bgcolor or {0,0,0}
	else
		self.bgcolor = {0,0,0}
		self.bg_image = bgcolor
	end
	self.font = core.display.newFont(fontname or "/data/font/DroidSansMono.ttf", fontsize or 10)
	self.font_h = self.font:lineSkip()
	self:resize(x, y, w, h)
	self.nb_cols = 1
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.surface = core.display.newSurface(w, h)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
	if self.actor then self.actor.changed = true end

	local cw, ch = self.font:size(" ")
	self.font_w = cw

	if self.bg_image then
		local fill = core.display.loadImage(self.bg_image)
		local fw, fh = fill:getSize()
		self.bg_surface = core.display.newSurface(w, h)
		self.bg_surface:erase(0, 0, 0)
		for i = 0, w, fw do for j = 0, h, fh do
			self.bg_surface:merge(fill, i, j)
		end end
	end
end

--- Sets the display into nb columns
function _M:setColumns(nb)
	self.nb_cols = nb
end

--- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])
	if self.bg_surface then self.surface:merge(self.bg_surface, 0, 0) end

	local list = {}

	-- initialize the array
	for i, act in ipairs(a.fov.actors_dist) do
		if a:canSee(act) and a ~= act then
			local n = act.name:capitalize()
			list[n] = list[n] or { name=n, nb=0, dist={} }
			list[n].nb = list[n].nb + 1
			list[n].dist[#list[n].dist+1] = math.floor(math.sqrt(a.fov.actors[act] and a.fov.actors[act].sqdist or 1))

			local r = a:reactionToward(act)
			if r > 0 then list[n].color={0,255,0}
			elseif r == 0 then list[n].color={176,196,222}
			elseif r < 0 then list[n].color={255,0,0} end
		end
	end
	local l = {}
	for _, a in pairs(list) do l[#l+1] = a end
	table.sort(l, function(a, b) return a.name < b.name end)

	local x, y = 0, 0
	for i, a in ipairs(l) do
		self.surface:drawColorStringBlended(self.font, ("%s (%d)#WHITE#; distance [%s]"):format(a.name, a.nb, table.concat(a.dist, ",")), x, y, a.color[1], a.color[2], a.color[3])
		y = y + self.font_h
		if y + self.font_h >= self.h then y = 0 x = x + math.floor(self.w / self.nb_cols) end
	end

	self.surface:updateTexture(self.texture)
	return self.surface
end

function _M:toScreen()
	self:display()
	self.texture:toScreenFull(self.display_x, self.display_y, self.w, self.h, self.texture_w, self.texture_h)
end
