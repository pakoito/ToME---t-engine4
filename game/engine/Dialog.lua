require "engine.class"

--- Handles dialog windows
module(..., package.seeall, class.make)

--- Create a calendar
-- @param definition the file to load that returns a table containing calendar months
-- @param datestring a string to format the date when requested, in the format "%s %s %s %d %d", standing for, day, month, year, hour, minute
function _M:init(title, w, h, x, y, alpha, font)
	self.title = title
	self.w, self.h = w, h
	self.x = x or (game.w - self.w) / 2
	self.y = y or (game.h - self.h) / 2
	self.font = font
	if not font then self.font = core.display.newFont("/data/font/VeraMono.ttf", 12) end
	self.surface = core.display.newSurface(w, h)
	self.internal_surface = core.display.newSurface(w, h - 5 - self.font:height())
	self.surface:alpha(alpha or 220)
	self.changed = true
end

function _M:display()
	if not self.changed then return self.surface end

	local s = self.surface
	s:erase()
	s:drawColorString(self.font, self.title, 2, 0, 255,255,255)

	self.internal_surface:erase()
	self:drawDialog(self.internal_surface)
	s:merge(self.internal_surface, 0, 5 + self.font:height())

	return self.surface
end

function _M:drawDialog(s)
end
