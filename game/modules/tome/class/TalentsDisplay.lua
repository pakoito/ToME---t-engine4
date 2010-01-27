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

	local hks = {}
	for i = 1, 36 do
		if a.hotkey[i] and a.hotkey[i][1] == "talent" then
			hks[#hks+1] = {a.hotkey[i][2], i, "talent"}
		elseif a.hotkey[i] and a.hotkey[i][1] == "inventory" then
			hks[#hks+1] = {a.hotkey[i][2], i, "inventory"}
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local x = 0
	local y = 0

	for ii, ts in ipairs(hks) do
		local s
		local i = ts[2]
		if ts[3] == "talent" then
			local tid = ts[1]
			local t = a:getTalentFromId(tid)
			if a:isTalentCoolingDown(t) then
				local txt = ("%d) %s (%d)"):format(i, t.name, a:isTalentCoolingDown(t))
				local w, h = self.font:size(txt)
				s = core.display.newSurface(w + 4, h + 4)
--				s:erase(40, 40, 40)

				s:alpha(128)
				s:drawString(self.font, txt, 2, 2, 255, 0, 0)
			elseif a:isTalentActive(t.id) then
				local txt = ("%d) %s"):format(i, t.name)
				local w, h = self.font:size(txt)
				s = core.display.newSurface(w + 4, h + 4)
--				s:erase(40, 40, 40)

				s:alpha(255)
				s:drawString(self.font, txt, 2, 2, 255, 255, 0)
			else
				local txt = ("%d) %s"):format(i, t.name)
				local w, h = self.font:size(txt)
				s = core.display.newSurface(w + 4, h + 4)
--				s:erase(40, 40, 40)

				s:alpha(255)
				s:drawString(self.font, txt, 2, 2, 0, 255, 0)
			end
		elseif ts[3] == "inventory" then
			local o = a:findInInventory(a:getInven("INVEN"), ts[1])
			local cnt = 0
			if o then cnt = o:getNumber() end
			local txt = ("%d) %s (%d)"):format(i, ts[1], cnt)
			local w, h = self.font:size(txt)
			s = core.display.newSurface(w + 4, h + 4)
--			s:erase(40, 40, 40)

			s:alpha(255)
			if cnt > 0 then
				s:drawString(self.font, txt, 2, 2, 0, 255, 0)
			else
				s:drawString(self.font, txt, 2, 2, 128, 128, 128)
			end
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
