require "engine.class"

module(..., package.seeall, class.make)

function _M:init(x, y, w, h, bgcolor)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.surface = core.display.newSurface(w, h)
	self.bgcolor = bgcolor
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 8)
	self.font_h = self.font:lineSkip()
end

-- Displays the talents, keybinds & cooldowns
-- This could use some optimisation, to not redraw everything every time
function _M:display()
	local a = game.player
	if not a.changed then return self.surface end
	a.changed = false

	local talents = {}
	for tid, _ in pairs(a.talents) do
		if a:getTalentFromId(tid).mode ~= "passive" then
			talents[#talents+1] = tid
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local acode = string.byte('1')

	for i, tid in ipairs(talents) do
		local t = a:getTalentFromId(tid)
		local s
		if a:isTalentCoolingDown(t) then
			local txt = ("%s) %s (%d)"):format(string.char(acode + i - 1), t.name, a:isTalentCoolingDown(t))
			local w, h = self.font:size(txt)
			s = core.display.newSurface(w + 4, h + 4)
			s:erase(40, 40, 40)

			s:alpha(128)
			s:drawString(self.font, txt, 2, 2, 255, 0, 0)
		else
			local txt = ("%s) %s"):format(string.char(acode + i - 1), t.name)
			local w, h = self.font:size(txt)
			s = core.display.newSurface(w + 4, h + 4)
			s:erase(40, 40, 40)

			s:alpha(255)
			s:drawString(self.font, txt, 2, 2, 0, 255, 0)
		end

		self.surface:merge(s, 0, (i-1) * 20)
	end

	return self.surface
end
