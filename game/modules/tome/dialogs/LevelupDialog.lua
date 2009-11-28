require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	self.actor_dup = actor:clone()
	engine.Dialog.init(self, "Levelup: "..actor.name, 600, 400)

--	self.statstpl = self:loadDisplayTemplate()
	self.statsel = 1

	self:keyCommands{
		_UP = function() self.statsel = util.boundWrap(self.statsel - 1, 1, 6) end,
		_DOWN = function() self.statsel = util.boundWrap(self.statsel + 1, 1, 6) end,
		_LEFT = function() self:incStat(-1) end,
		_RIGHT = function() self:incStat(1) end,
		_ESCAPE = function() game:unregisterDialog(self) end,
	}
	self:mouseZones{
		{ x=2, y=25, w=130, h=self.font_h*6, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.statsel = 1 + math.floor(ty / self.font_h)
			if button == "left" then self:incStat(1)
			elseif button == "right" then self:incStat(-1)
			end
		end },
	}
end

function _M:incStat(v)
	if v == 1 then
		if self.actor.unused_stats == 0 then
			self:simplePopup("Not enough stat points", "You have no stat poins left!")
			return
		end
	else
		if self.actor_dup:getStat(self.statsel) == self.actor:getStat(self.statsel) then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
	end

	self.actor:incStat(self.statsel, v)
	self.actor.unused_stats = self.actor.unused_stats - v
end

function _M:drawDialog(s, w, h)
	-- Description part
	self:drawHBorder(s, self.w / 2, 2, self.h - 4)
	local lines = self.actor.stats_def[self.statsel].description:splitLines(self.w / 2 - 10, self.font)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], self.w / 2 + 5, 2 + i * self.font:lineSkip())
	end

	-- Stats
	s:drawColorString(self.font, "Stats points left: #00FF00#"..self.actor.unused_stats, 2, 2)
	self:drawWBorder(s, 2, 20, 200)

	self:drawSelectionList(s, 2, 25, self.font_h, {
		"Strength", "Dexterity", "Magic", "Willpower", "Cunning", "Constitution"
	}, self.statsel)
	self:drawSelectionList(s, 100, 25, self.font_h, {
		self.actor:getStr(), self.actor:getDex(), self.actor:getMag(), self.actor:getWil(), self.actor:getCun(), self.actor:getCon(),
	}, self.statsel)
end
