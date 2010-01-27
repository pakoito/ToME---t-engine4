require "engine.class"

module(..., package.seeall, class.make)

function _M:init(x, y, w, h, bgcolor)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.surface = core.display.newSurface(w, h)
	self.bgcolor = bgcolor
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 12)
	self.font_h = self.font:lineSkip()
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.w, self.h = w, h
	self.surface = core.display.newSurface(w, h)
	game.player.changed = true
end

-- Displays the talents, keybinds & cooldowns
-- This could use some optimisation, to not redraw everything every time
function _M:display()
	local a = game.player
	if not a.changed then return self.surface end
	a.changed = false

	local talents = {}
	for i = 1, 36 do
		if a.hotkey[i] and a.hotkey[i][1] == "talent" then
			talents[#talents+1] = {a.hotkey[i][2], i}
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local x = 0
	local y = 0

	for ii, ts in ipairs(talents) do
		local tid = ts[1]
		local i = ts[2]
		local t = a:getTalentFromId(tid)
		local s
		if a:isTalentCoolingDown(t) then
			local txt = ("%d) %s (%d)"):format(i, t.name, a:isTalentCoolingDown(t))
			local w, h = self.font:size(txt)
			s = core.display.newSurface(w + 4, h + 4)
			s:erase(40, 40, 40)

			s:alpha(128)
			s:drawString(self.font, txt, 2, 2, 255, 0, 0)
		elseif a:isTalentActive(t.id) then
			local txt = ("%d) %s"):format(i, t.name)
			local w, h = self.font:size(txt)
			s = core.display.newSurface(w + 4, h + 4)
			s:erase(40, 40, 40)

			s:alpha(255)
			s:drawString(self.font, txt, 2, 2, 255, 255, 0)
		else
			local txt = ("%d) %s"):format(i, t.name)
			local w, h = self.font:size(txt)
			s = core.display.newSurface(w + 4, h + 4)
			s:erase(40, 40, 40)

			s:alpha(255)
			s:drawString(self.font, txt, 2, 2, 0, 255, 0)
		end

		self.surface:merge(s, x, y)
		if y + self.font_h * 2 > self.h then
			x = x + self.w / 3
			y = 0
		else
			y = y + self.font_h
		end
	end

	return self.surface
end
