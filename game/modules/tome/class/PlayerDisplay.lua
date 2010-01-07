require "engine.class"

module(..., package.seeall, class.make)

function _M:init(x, y, w, h, bgcolor)
	self.display_x = x
	self.display_y = y
	self.w, self.h = w, h
	self.bgcolor = bgcolor
	self.font = core.display.newFont("/data/font/VeraMono.ttf", 14)
	self.font_h = self.font:lineSkip()
	self.surface = core.display.newSurface(w, h)
end

--- Resize the display area
function _M:resize(x, y, w, h)
	self.display_x, self.display_y = x, y
	self.w, self.h = w, h
	self.surface = core.display.newSurface(w, h)
	self.changed = true
end

-- Displays the stats
function _M:display()
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local cur_exp, max_exp = game.player.exp, game.player:getExpChart(game.player.level+1)

	local h = 0
	self.surface:drawString(self.font, game.player.name, 0, h, 0, 200, 255) h = h + self.font_h
	self.surface:drawString(self.font, game.player.descriptor.race or "", 0, h, 0, 200, 255) h = h + self.font_h
	h = h + self.font_h
	self.surface:drawColorString(self.font, "Level: #00ff00#"..game.player.level, 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorString(self.font, ("Exp: #00ff00#%2d%%"):format(100 * cur_exp / max_exp), 0, h, 255, 255, 255) h = h + self.font_h
	h = h + self.font_h
	self.surface:drawColorString(self.font, ("#c00000#Life:    #00ff00#%d/%d"):format(game.player.life, game.player.max_life), 0, h, 255, 255, 255) h = h + self.font_h
	if game.player:knowTalent(game.player.T_MANA_POOL) then
		self.surface:drawColorString(self.font, ("#7fffd4#Mana:    #00ff00#%d/%d"):format(game.player:getMana(), game.player.max_mana), 0, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_STAMINA_POOL) then
		self.surface:drawColorString(self.font, ("#ffcc80#Stamina: #00ff00#%d/%d"):format(game.player:getStamina(), game.player.max_stamina), 0, h, 255, 255, 255) h = h + self.font_h
	end
	h = h + self.font_h
	self.surface:drawColorString(self.font, ("STR: #00ff00#%3d"):format(game.player:getStr()), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorString(self.font, ("DEX: #00ff00#%3d"):format(game.player:getDex()), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorString(self.font, ("MAG: #00ff00#%3d"):format(game.player:getMag()), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorString(self.font, ("WIL: #00ff00#%3d"):format(game.player:getWil()), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorString(self.font, ("CUN: #00ff00#%3d"):format(game.player:getCun()), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawColorString(self.font, ("CON: #00ff00#%3d"):format(game.player:getCon()), 0, h, 255, 255, 255) h = h + self.font_h
	h = h + self.font_h
	self.surface:drawString(self.font, ("Fatigue %3d%%"):format(game.player.fatigue), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawString(self.font, ("Armor %3d"):format(game.player:combatArmor()), 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawString(self.font, ("Defence %3d"):format(game.player:combatDefense()), 0, h, 255, 255, 255) h = h + self.font_h

	if game.zone and game.level then
		self.surface:drawString(self.font, ("%s (%d)"):format(game.zone.name, game.level.level), 0, self.h - self.font_h, 0, 255, 255) h = h + self.font_h
	end

	return self.surface
end
