require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	self.actor_dup = actor:clone()
	engine.Dialog.init(self, "Talents Levelup: "..actor.name, 800, 600)

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 45) / self.font_h) - 1

	self:keyCommands(nil, {
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_LEFT = function() self:learn(false) self.changed = true end,
		MOVE_RIGHT = function() self:learn(true) self.changed = true end,
		ACCEPT = "EXIT",
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=2, y=45, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:learn(true)
			elseif button == "right" then self:learn(false)
			end
			self.changed = true
		end },
	}
end

function _M:generateList()
	-- Makes up the list
	local list, known = {}, {}
	for i, tt in ipairs(self.actor.talents_types_def) do
		if not tt.hide and not (self.actor.talents_types[tt.type] == nil) then
			local cat = tt.type:gsub("/.*", "")
			list[#list+1] = { name=cat:capitalize().." / "..tt.name:capitalize() ..(" (mastery %.02f)"):format(self.actor:getTalentTypeMastery(tt.type)), type=tt.type }
			if self.actor:knowTalentType(tt.type) then
				known[#known+1] = "#00FF00#known"

				-- Find all talents of this school
				for j, t in ipairs(tt.talents) do
					if not t.hide then
						local typename = "talent"
						if t.type[1]:find("^spell/") then typename = "spell" end
						list[#list+1] = { name="    "..t.name.." ("..typename..")", talent=t.id }
						if self.actor:getTalentLevelRaw(t.id) == t.points then
							known[#known+1] = "#00FF00#known"
						else
							if not self.actor:canLearnTalent(t) then
								known[#known+1] = "#FF0000#"..self.actor:getTalentLevelRaw(t.id).."/"..t.points
							else
								known[#known+1] = self.actor:getTalentLevelRaw(t.id).."/"..t.points
							end
						end
					end
				end
			else
				known[#known+1] = tt.points.." point(s)"
			end
		end
	end
	self.list = list
	self.list_known = known
end

function _M:learn(v)
	if self.list[self.sel].type then
		self:learnType(self.list[self.sel].type, v)
	else
		self:learnTalent(self.list[self.sel].talent, v)
	end
end

function _M:learnTalent(t_id, v)
	local t = self.actor:getTalentFromId(t_id)
	if v then
		if self.actor.unused_talents < 1 then
			self:simplePopup("Not enough talent points", "You have no talent points left!")
			return
		end
		if not self.actor:canLearnTalent(t) then
			self:simplePopup("Cannot learn talent", "Prerequisites not met!")
			return
		end
		if self.actor:getTalentLevelRaw(t_id) >= t.points then
			self:simplePopup("Already known", "You already fully know this talent!")
			return
		end
		self.actor:learnTalent(t_id)
		self.actor.unused_talents = self.actor.unused_talents - 1
	else
		if not self.actor:knowTalent(t_id) then
			self:simplePopup("Impossible", "You do not know this talent!")
			return
		end
		if self.actor_dup:getTalentLevelRaw(t_id) == self.actor:getTalentLevelRaw(t_id) then
			self:simplePopup("Impossible", "You cannot unlearn talents!")
			return
		end
		self.actor:unlearnTalent(t_id)
		self.actor.unused_talents = self.actor.unused_talents + 1
	end
	self:generateList()
end

function _M:learnType(tt, v)
	if v then
		if self.actor:knowTalentType(tt) then
			self:simplePopup("Impossible", "You do already know this talent category!")
			return
		end
		if self.actor.unused_talents_types == 0 then
			self:simplePopup("Not enough talent category points", "You have no talent category points left!")
			return
		end
		self.actor:learnTalentType(tt)
		self.actor.unused_talents_types = self.actor.unused_talents_types - 1
	else
		if self.actor_dup:knowTalentType(tt) == true and self.actor:knowTalentType(tt) == true then
			self:simplePopup("Impossible", "You cannot take out more points!")
			return
		end
		if not self.actor:knowTalentType(tt) then
			self:simplePopup("Impossible", "You do not know this talent category!")
			return
		end
		self.actor:unlearnTalentType(tt)
		self.actor.unused_talents_types = self.actor.unused_talents_types + 1
	end

	self:generateList()
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local talentshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to learn; #00FF00#left key#FFFFFF# to unlearn.
Mouse: #00FF00#Left click#FFFFFF# to learn; #00FF00#right click#FFFFFF# to unlearn.
]]):splitLines(self.iw / 2 - 10, self.font)

	local lines, helplines, reqlines = {}, {}, {}
	if self.list[self.sel].type then
		local str = ""
		str = str .. "#00FFFF#Talent Category\n"
		str = str .. "#00FFFF#A talent category allows you to learn talents of this category. You gain a talent category point every few levels. You may also find trainers or artifacts that allows you to learn more.\n\n"
		helplines = str:splitLines(self.iw / 2 - 10, self.font)
		lines = self.actor:getTalentTypeFrom(self.list[self.sel].type).description:splitLines(self.iw / 2 - 10, self.font)
	else
		local str = ""
		str = str .. "#00FFFF#Talent\n"
		str = str .. "#00FFFF#A talent allows you to perform new combat moves, cast spells, improve your character. You gain two talent point every level. You may also find trainers or artifacts that allows you to learn more.\n\n"
		helplines = str:splitLines(self.iw / 2 - 10, self.font)
		local t = self.actor:getTalentFromId(self.list[self.sel].talent)
		lines = self.actor:getTalentFullDescription(t):splitLines(self.iw / 2 - 10, self.font)
		local req = self.actor:getTalentReqDesc(self.list[self.sel].talent, 1)
		if req ~= "" then
			req = "Requirements for next point:\n"..req
			reqlines = req:splitLines(self.iw / 2 - 10, self.font)
		end
	end
	local h = 2
	for i = 1, #talentshelp do
		s:drawColorString(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #helplines do
		s:drawColorString(self.font, helplines[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	if #reqlines > 0 then
		h = h + self.font:lineSkip()
		self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
		for i = 1, #reqlines do
			s:drawColorString(self.font, reqlines[i], self.iw / 2 + 5, h)
			h = h + self.font:lineSkip()
		end
	end

	h = h + self.font:lineSkip()
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], self.iw / 2 + 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	-- Talents
	s:drawColorString(self.font, "Talent categories points left: #00FF00#"..self.actor.unused_talents_types, 2, 2)
	s:drawColorString(self.font, "Talents points left: #00FF00#"..self.actor.unused_talents, 2, 2 + self.font_h)
	self:drawWBorder(s, 2, 40, 200)

	self:drawSelectionList(s, 2, 45, self.font_h, self.list, self.sel, "name"     , self.scroll, self.max)
	self:drawSelectionList(s, 300, 45, self.font_h, self.list_known, self.sel, nil, self.scroll, self.max)

	self.changed = false
end
