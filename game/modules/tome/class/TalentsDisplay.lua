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
	self.display_x, self.display_y = x, y
	self.w, self.h = w, h
	self.surface = core.display.newSurface(w, h)
	self.actor.changed = true

	local cw, ch = self.font:size(" ")
	self.font_w = cw
	self.max_char_w = math.floor(w / self.font_w)
end

local page_to_hotkey = {"", "SECOND_", "THIRD_"}

-- Displays the talents, keybinds & cooldowns
-- This could use some optimisation, to not redraw everything every time
function _M:display()
	local a = self.actor
	if not a.changed then return self.surface end
	a.changed = false

	local hks = {}
	for i = 1, 12 do
		local j = i + (12 * (a.hotkey_page - 1))
		local ks = game.key:formatKeyString(game.key:findBoundKeys("HOTKEY_"..page_to_hotkey[a.hotkey_page]..i))
		if a.hotkey[j] and a.hotkey[j][1] == "talent" then
			hks[#hks+1] = {a.hotkey[j][2], j, "talent", ks}
		elseif a.hotkey[j] and a.hotkey[j][1] == "inventory" then
			hks[#hks+1] = {a.hotkey[j][2], j, "inventory", ks}
		end
	end

	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local x = 0
	local y = 0

	for ii, ts in ipairs(hks) do
		local s
		local i = ts[2]
		local txt, color = "", {0,255,0}
		if ts[3] == "talent" then
			local tid = ts[1]
			local t = a:getTalentFromId(tid)
			if a:isTalentCoolingDown(t) then
				txt = ("%s (%d)"):format(t.name, a:isTalentCoolingDown(t))
				color = {255,0,0}
			elseif a:isTalentActive(t.id) then
				txt = t.name
				color = {255,255,0}
			else
				txt = t.name
				color = {0,255,0}
			end
		elseif ts[3] == "inventory" then
			local o = a:findInInventory(a:getInven("INVEN"), ts[1])
			local cnt = 0
			if o then cnt = o:getNumber() end
			txt = ("%s (%d)"):format(ts[1], cnt)
			if cnt == 0 then
				color = {128,128,128}
			end
		end

		txt = ("%2d) %-"..(self.max_char_w-4-24).."s Key: %s"):format(i, txt, ts[4])
		local w, h = self.font:size(txt)
		s = core.display.newSurface(w + 4, h + 4)
		s:alpha(255)
		s:drawString(self.font, txt, 2, 2, color[1], color[2], color[3])

		self.surface:merge(s, x, y)
		if y + self.font_h * 2 > self.h then
			x = x + self.w / 2
			y = 0
		else
			y = y + self.font_h
		end
	end

	return self.surface
end
