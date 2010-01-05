require "engine.class"
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

_M.birth_descriptor_def = {}

--- Defines birth descriptors
-- Static!
function _M:loadDefinition(file)
	local f, err = loadfile(file)
	if not f and err then error(err) os.exit() end
	setfenv(f, setmetatable({
		ActorTalents = require("engine.interface.ActorTalents"),
		newBirthDescriptor = function(t) self:newBirthDescriptor(t) end,
		load = function(f) self:loadDefinition(f) end
	}, {__index=_G}))
	f()
end

--- Defines one birth descriptor
-- Static!
function _M:newBirthDescriptor(t)
	assert(t.name, "no birth name")
	assert(t.type, "no birth type")
	t.short_name = t.short_name or t.name
	t.short_name = t.short_name:upper():gsub("[ ]", "_")
	assert(t.desc, "no birth description")
	t.descriptor_choices = t.descriptor_choices or {}

	table.insert(self.birth_descriptor_def, t)
	t.id = #self.birth_descriptor_def
	self.birth_descriptor_def[t.type] = self.birth_descriptor_def[t.type] or {}
	self.birth_descriptor_def[t.type][t.name] = t
	table.insert(self.birth_descriptor_def[t.type], t)
end


--- Instanciates a birther for the given actor
function _M:init(actor, order, at_end)
	self.actor = actor
	self.order = order
	self.at_end = at_end
	engine.Dialog.init(self, "Character Creation: "..actor.name, 600, 400)

	self.descriptors = {}

	self.cur_order = 1
	self:next()

	self:keyCommands{
		_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list); self.changed = true end,
		_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list); self.changed = true end,
		_RETURN = function() self:next() end,
	}
	self:mouseZones{
		{ x=2, y=25, w=350, h=self.h, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			if ty < self.font_h*#self.list then
				self.sel = 1 + math.floor(ty / self.font_h)
				if button == "left" then self:next()
				elseif button == "right" then self:learn(false)
				end
			end
		end },
	}
end

function _M:selectType(type)
	self.list = {}
	-- Make up the list
	for i, d in ipairs(self.birth_descriptor_def[type]) do
		local allowed = true
		for j, od in ipairs(self.descriptors) do
			if od.descriptor_choices[type] then
				local what = od.descriptor_choices[type][d.name] or od.descriptor_choices[type].__ALL__
				if what and what == "allow" then
					allowed = true
				elseif what and what == "never" then
					allowed = false
				end
			end
		end

		-- Check it is allowed
		if allowed then
			table.insert(self.list, d)
		end
	end
	self.sel = 1
	self.current_type = type
end

function _M:next()
	self.changed = true
	if self.list then
		table.insert(self.descriptors, self.list[self.sel])

		self.cur_order = self.cur_order + 1
		if not self.order[self.cur_order] then
			game:unregisterDialog(self)
			self:apply()
			self.at_end()
			return
		end
	end
	self:selectType(self.order[self.cur_order])
	if #self.list == 1 then
		self:next()
	end
end

--- Apply all birth options to the actor
function _M:apply()
	self.actor.descriptor = {}
	for i, d in ipairs(self.descriptors) do
		print("[BIRTH] Applying descriptor "..d.name)
		self.actor.descriptor[d.type] = d.name

		-- Change stats
		if d.stats then
			for stat, inc in pairs(d.stats) do
				self.actor:incStat(stat, inc)
			end
		end
		if d.talents_types then
			for t, v in pairs(d.talents_types) do
				local mastery
				if type(v) == "table" then
					v, mastery = v[1], v[2]
				else
					v, mastery = v, 0
				end
				self.actor:learnTalentType(t, v)
				self.actor.talents_types_mastery[t] = (self.actor.talents_types_mastery[t] or 1) + mastery
				print(t)
			end
		end
		if d.talents then
			for tid, lev in pairs(d.talents) do
				for i = 1, lev do
					self.actor:learnTalent(tid, true)
				end
			end
		end
		if d.experience then self.actor.exp_mod = self.actor.exp_mod * d.experience end
		if d.body then
			self.actor.body = d.body
			self.actor:initBody()
		end
		if d.copy then
			table.merge(self.actor, d.copy, true)
		end
	end
end

function _M:drawDialog(s)
	if not self.list or not self.list[self.sel] then return end

	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)
	local birthhelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select a stat; #00FF00#right key#FFFFFF# to increase stat; #00FF00#left key#FFFFFF# to decrease a stat.
Mouse: #00FF00#Left click#FFFFFF# to increase a stat; #00FF00#right click#FFFFFF# to decrease a stat.
]]):splitLines(self.iw / 2 - 10, self.font)
	for i = 1, #birthhelp do
		s:drawColorString(self.font, birthhelp[i], self.iw / 2 + 5, 2 + (i-1) * self.font:lineSkip())
	end

	local lines = table.concat(self.list[self.sel].desc,"\n"):splitLines(self.iw / 2 - 10, self.font)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], self.iw / 2 + 5, 2 + (i + #birthhelp + 1) * self.font:lineSkip())
	end

	-- Stats
	s:drawColorString(self.font, "Selecting: "..self.current_type:capitalize(), 2, 2)
	self:drawWBorder(s, 2, 20, 200)

	self:drawSelectionList(s, 2, 25, self.font_h, self.list, self.sel, "name")
	self.changed = false
end
