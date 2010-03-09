require "engine.class"

module(..., package.seeall, class.make)

function _M:init(fontname, fontsize)
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 12)
	self.bigfont = core.display.newFont(fontname or "/data/font/VeraBd.ttf", fontsize or 18)
	self.font_h = self.font:lineSkip()
	self.flyers = {}
end

function _M:add(x, y, duration, xvel, yvel, str, color, bigfont)
	assert(x, "no x flyer")
	assert(y, "no y flyer")
	assert(str, "no str flyer")
	color = color or {255,255,255}
	local s = core.display.drawStringNewSurface(bigfont and self.bigfont or self.font, str, color[1], color[2], color[3])
	if not s then return end
	local f = {
		x=x,
		y=y,
		duration=duration or 10,
		xvel = xvel or 0,
		yvel = yvel or 0,
		s = s
	}
	self.flyers[f] = true
	return f
end

function _M:empty()
	self.flyers = {}
end

function _M:display()
	if not next(self.flyers) then return end

	local dels = {}

	for fl, _ in pairs(self.flyers) do
		fl.s:toScreen(fl.x, fl.y)
		fl.x = fl.x + fl.xvel
		fl.y = fl.y + fl.yvel
		fl.duration = fl.duration - 1

		-- Delete the flyer
		if fl.duration == 0 then
			dels[#dels+1] = fl
		end
	end

	for i, fl in ipairs(dels) do self.flyers[fl] = nil end
end
