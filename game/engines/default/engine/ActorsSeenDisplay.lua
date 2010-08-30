-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

function _M:init(actor, x, y, w, h, bgcolor)
	self.actor = actor
	self.bgcolor = bgcolor
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 10)
	self.font_h = self.font:lineSkip()
	self:resize(x, y, w, h)
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = math.floor(x), math.floor(y)
	self.w, self.h = math.floor(w), math.floor(h)
	self.surface = core.display.newSurface(w, h)
	if self.actor then self.actor.changed = true end

	local cw, ch = self.font:size(" ")
	self.font_w = cw
end

-- Displays the hotkeys, keybinds & cooldowns
function _M:display()
	local a = self.actor
	if not a or not a.changed then return self.surface end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local list = {}

	-- initialize the array
	for i, act in ipairs(a.fov.actors_dist) do
		if a:canSee(act) then
			local n = act.name:capitalize()
			list[n] = list[n] or { name=n, nb=0, dist={} }
			list[n].nb = list[n].nb + 1
			list[n].dist[#list[n].dist+1] = math.floor(math.sqrt(a.fov.actors[act].sqdist))

			local r = a:reactionToward(act)
			if r > 0 then list[n].color={0,255,0}
			elseif r == 0 then list[n].color={176,196,222}
			elseif r < 0 then list[n].color={255,0,0} end
		end
	end
	local l = {}
	for _, a in pairs(list) do l[#l+1] = a end
	table.sort(l, function(a, b) return a.name < b.name end)

	for i, a in ipairs(l) do
		self.surface:drawColorStringBlended(self.font, ("%s (%d)#WHITE#; distance [%s]"):format(a.name, a.nb, table.concat(a.dist, ",")), 0, (i - 1) * self.font_h, a.color[1], a.color[2], a.color[3])
	end

	return self.surface
end
