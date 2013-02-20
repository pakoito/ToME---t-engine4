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

--- Make a UI element clickable
module(..., package.seeall, class.make)

can_focus = true
focus_decay_max = 8
focus_decay_max_d = 8
one_by_focus_decay = 1/32

function _M:setFocus(v)
	local prev_focus = self.focused
	self.focused = v
	if not v then self.focus_decay = self.focus_decay_max end
	if v ~= prev_focus and self.on_focus_change then self:on_focus_change(v) end
	if self.on_focus then self:on_focus(v) end
end

--while focused
function _M:on_focus(id, ui)
end

--while not focused
function _M:no_focus()
end

--focus change
function _M:on_focus_change(status)
end
