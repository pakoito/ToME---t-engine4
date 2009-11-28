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

-- Displays the stats
function _M:display()
	self.surface:erase(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3])

	local cur_exp, max_exp = game.player.exp, game.player:getExpChart(game.player.level+1)

	local h = 0
	self.surface:drawString(self.font, game.player.name, 0, h, 0, 200, 255) h = h + self.font_h
	self.surface:drawString(self.font, "Human", 0, h, 0, 200, 255) h = h + self.font_h
	h = h + self.font_h
	self.surface:drawString(self.font, "Level: "..game.player.level, 0, h, 255, 255, 255) h = h + self.font_h
	self.surface:drawString(self.font, ("Exp: %2d%%"):format(100 * cur_exp / max_exp), 0, h, 255, 255, 255) h = h + self.font_h


	return self.surface
end
