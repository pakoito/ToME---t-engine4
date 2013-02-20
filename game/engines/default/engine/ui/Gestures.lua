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
local KeyBind = require "engine.KeyBind"

module(..., package.seeall, class.make)

function _M:init(text, key_source, force_all)
	assert(key_source, "no key source")
	self.text = text or "Gesture: "
	self.gesture = ""
	self.gestures = {}
	self.font = core.display.newFont("/data/font/DroidSans.ttf", 12)

	local gesttext = self.text.."WWWWW"
	self.fontmax_w, self.font_h = self.font:size(gesttext)

	self.surface = core.display.newSurface(self.fontmax_w, self.font_h)
	self.surface:drawColorStringBlended(self.font, self.text, 0, 0, 255, 255, 255, true)
	self.texture, self.texture_w, self.texture_h = self.surface:glTexture()
	self.timeout = 1.7
	self.lastupdate = os.time()
	self.gesturing = false
	self.mousebuttondown = false
	self.distance = 0
	self.lastgesture = ""
	self.lastgesturename = ""

	self:loadGestures(key_source, force_all)
end

function _M:loadGestures(key_source, force_all)
	local l = {}

	for virtual, t in pairs(KeyBind.binds_def) do
		if (force_all or key_source.virtuals[virtual]) and t.group ~= "debug" then
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
		local bind3 = KeyBind:getBindTable(k)[3]
		local gesture = KeyBind:formatKeyString(util.getval(bind3))
		if k.name ~= "" and k.name~= "--" then
			self:addGesture(gesture, function() key_source:triggerVirtual(k.type) end, k.name)
		end
	end
end

function _M:mouseMove(mx, my)
	if #self.gesture >= 5 then return end
	if self.omx and self.omy then
		self.distance = self.distance + (self.omy - my)^2 + (self.omx - mx)^2
		if math.abs(self.omx - mx) > math.abs(self.omy - my) and self.distance > 100 then
			if self.omx > mx then
				if self.lastgesture~="L" then
					self.gesture = self.gesture.."L"
					self.lastgesture = "L"
				end
			else
				if self.lastgesture~="R" then
					self.gesture = self.gesture.."R"
					self.lastgesture = "R"
				end
			end
			self.gesturing = true
			self.lastupdate = os.time()
			self.distance = 0
		end
		if math.abs(self.omx - mx) < math.abs(self.omy - my) and self.distance > 100 then
			if self.omy > my then
				if self.lastgesture~="U" then
					self.gesture = self.gesture.."U"
					self.lastgesture = "U"
				end
			else
				if self.lastgesture~="D" then
					self.gesture = self.gesture.."D"
					self.lastgesture = "D"
				end
			end
			self.gesturing = true
			self.lastupdate = os.time()
			self.distance = 0
		end
	end

	self.omx = mx
	self.omy = my
end

function _M:isGesturing()
	return self.gesturing
end

function _M:isMouseButtonDown()
	return self.mousebuttondown
end

function _M:changeMouseButton(isDown)
	self.mousebuttondown = isDown
end

function _M:useGesture()
	if self.gestures[self.gesture] then
		self.gestures[self.gesture].func()
	end
end

function _M:reset()
	self.gesturing = false
	self.omx = nil
	self.omy = nil
	self.gesture = ""
	self.lastgesture = ""
	self.distance = 0
end

function _M:addGesture(gesture, func, name)
	self.gestures[gesture] = {}
	self.gestures[gesture].func = func
	self.gestures[gesture].name = name
end

function _M:removeGesture(gesture)
	if not self.gestures[gesture] then return end
	self.gestures[gesture] = nil
end

function _M:empty()
	self.gestures = {}
	self:reset()
end

function _M:setTimeout(timeout)
	self.timeout = timeout
end

function _M:getLastGesture()
	return self.gesture
end

function _M:update()
	local gesttxt = ""

	if self.gesturing == true then
		gesttxt = self.text
		if os.difftime(os.time(),  self.lastupdate) >= self.timeout then
			self:reset()
		end
	end

	gesttxt = gesttxt..self.gesture

	self.surface:erase(0,0,0,1)
	self.surface:drawColorStringBlended(self.font, gesttxt, 0, 0, 255, 255, 255, true)
	self.surface:updateTexture(self.texture)
end

function _M:display(display_x, display_y)
	self.texture:toScreenFull(display_x, display_y, self.fontmax_w, self.font_h, self.texture_w, self.texture_h)

	if self.gestures[self.gesture] then
		if self.gestures[self.gesture].name == self.lastgesturename and self.gesturenametexure then
			self.gesturenametexure:toScreenFull(display_x + self.fontmax_w, display_y, self.gesturenamefont_w , self.font_h, self.gesturenametexure_w, self.gesturenametexure_h)
		else
			self.gesturenamefont_w, _ = self.font:size(self.gestures[self.gesture].name)
			local s = core.display.newSurface(self.gesturenamefont_w, self.font_h)
			s:drawColorStringBlended(self.font, self.gestures[self.gesture].name, 0, 0, 255, 255, 255, true)
			self.gesturenametexure, self.gesturenametexure_w, self.gesturenametexure_h = s:glTexture()
			self.gesturenametexure:toScreenFull(display_x, display_y, self.fontmax_w, self.font_h, self.texture_w, self.texture_h)
		end
		self.lastgesturename = self.gestures[self.gesture].name
	end
end
