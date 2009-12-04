require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Use Talents: "..actor.name, game.w / 2, game.h / 2)

	self:generateList()

	self.talentsel = 1
	self:keyCommands{
		_UP = function() self.talentsel = util.boundWrap(self.talentsel - 1, 1, #self.list) end,
		_DOWN = function() self.talentsel = util.boundWrap(self.talentsel + 1, 1, #self.list) end,
		_RETURN = function() self:use() end,
		_ESCAPE = function() game:unregisterDialog(self) end,
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.talentsel = 1 + string.byte(c) - string.byte('a')
				self:use()
			end
		end,
	}
	self:mouseZones{
		{ x=2, y=5, w=350, h=self.font_h*#self.list, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.talentsel = 1 + math.floor(ty / self.font_h)
			if button == "left" then self:use()
			elseif button == "right" then
			end
		end },
	}
end

function _M:use()
	game:unregisterDialog(self)
	self.actor:useTalent(self.list[self.talentsel].talent)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0
	for tid, _ in pairs(self.actor.talents) do
		local t = self.actor:getTalentFromId(tid)
		if t and t.mode ~= "passive" then
			local typename = "talent"
			if t.type[1]:find("^spell/") then typename = "spell" end
			list[#list+1] = { name=string.char(string.byte('a') + i)..")  "..t.name.." ("..typename..")", talent=t.id }
			i = i + 1
		end
	end
	self.list = list
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local talentshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to learn; #00FF00#left key#FFFFFF# to unlearn.
Mouse: #00FF00#Left click#FFFFFF# to learn; #00FF00#right click#FFFFFF# to unlearn.
]]):splitLines(self.iw / 2 - 10, self.font)

	local lines = {}
	lines = self.actor:getTalentFromId(self.list[self.talentsel].talent).info(self.actor):splitLines(self.iw / 2 - 10, self.font)
	local h = 2
	for i = 1, #talentshelp do
		s:drawColorString(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], self.iw / 2 + 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	-- Talents
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.talentsel, "name")
end
