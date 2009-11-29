require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	self.actor_dup = actor:clone()
	engine.Dialog.init(self, "Talents Levelup: "..actor.name, 800, 600)

	-- Makes up the list
	local list, known = {}, {}
	for i, tt in ipairs(self.actor.talents_types_def) do
		local cat = tt.type:gsub("/.*", "")
		list[#list+1] = { name="<"..cat:capitalize().." / "..tt.name:capitalize()..">", type=tt.type }
		if actor:knowTalentType(tt.type) then known[#known+1] = "known" else known[#known+1] = "unknown" end

		-- Find all talents of this school
		for j, t in ipairs(tt.talents) do
			list[#list+1] = { name="    "..t.name, talent=t.id }
			if actor:knowTalent(t.id) then known[#known+1] = "known" else known[#known+1] = "unknown" end
		end
	end
	self.list = list
	self.list_known = known

	self.talentsel = 1
	self:keyCommands{
		_UP = function() self.talentsel = util.boundWrap(self.talentsel - 1, 1, #list) end,
		_DOWN = function() self.talentsel = util.boundWrap(self.talentsel + 1, 1, #list) end,
--		_LEFT = function() self:incStat(-1) end,
--		_RIGHT = function() self:incStat(1) end,
		_ESCAPE = function() game:unregisterDialog(self) end,
	}
	self:mouseZones{
		{ x=2, y=45, w=350, h=self.font_h*#list, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.talentsel = 1 + math.floor(ty / self.font_h)
--			if button == "left" then self:incStat(1)
--			elseif button == "right" then self:incStat(-1)
--			end
		end },
	}
end
--[[
function _M:incStat(v)
	if v == 1 then
		if self.actor.unused_talents == 0 then
			self:simplePopup("Not enough talent points", "You have no talent points left!")
			return
		end
	else
		if self.actor_dup:getStat(self.talentsel) == self.actor:getStat(self.talentsel) then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
	end

	self.actor:incStat(self.talentsel, v)
	self.actor.unused_stats = self.actor.unused_stats - v
end
]]
function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)
--[=[
	local statshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to increase stat; #00FF00#left key#FFFFFF# to decrease a stat.
Mouse: #00FF00#Left click#FFFFFF# to increase a stat; #00FF00#right click#FFFFFF# to decrease a stat.
]]):splitLines(self.iw / 2 - 10, self.font)
	local lines = self.actor.talents_def[self.talentsel].description:splitLines(self.iw / 2 - 10, self.font)
	for i = 1, #statshelp do
		s:drawColorString(self.font, statshelp[i], self.iw / 2 + 5, 2 + (i-1) * self.font:lineSkip())
	end
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], self.iw / 2 + 5, 2 + (i + #statshelp + 1) * self.font:lineSkip())
	end
]=]

	-- Talents
	s:drawColorString(self.font, "Talents types points left: #00FF00#"..self.actor.unused_talents_types, 2, 2)
	s:drawColorString(self.font, "Talents points left: #00FF00#"..self.actor.unused_talents, 2, 2 + self.font_h)
	self:drawWBorder(s, 2, 40, 200)

	self:drawSelectionList(s, 2, 45, self.font_h, self.list, self.talentsel, "name")
	self:drawSelectionList(s, 300, 45, self.font_h, self.list_known, self.talentsel)
end
