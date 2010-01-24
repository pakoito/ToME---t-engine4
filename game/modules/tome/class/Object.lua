require "engine.class"
require "engine.Object"
require "engine.interface.ObjectActivable"
require "engine.interface.ObjectIdentify"

local Stats = require("engine.interface.ActorStats")
local Talents = require("engine.interface.ActorTalents")
local DamageType = require("engine.DamageType")

module(..., package.seeall, class.inherit(
	engine.Object,
	engine.interface.ObjectActivable,
	engine.interface.ObjectIdentify
))

function _M:init(t, no_default)
	engine.Object.init(self, t, no_default)
	engine.interface.ObjectActivable.init(self, t)
	engine.interface.ObjectIdentify.init(self, t)
end

--- Can this object act at all
-- Most object will want to anwser false, only recharging and stuff needs them
function _M:canAct()
	if self.power_regen then return true end
	return false
end

--- Do something when its your turn
-- For objects this mostly is to recharge them
-- By default, does nothing at all
function _M:act()
	self:regenPower()
	self:useEnergy()
end

--- Use the object (quaff, read, ...)
function _M:use(who, typ)
	local types = {}
	if self:canUseObject() then types[#types+1] = "use" end

	if not typ and #types == 1 then typ = types[1] end

	if typ == "use" then
		who:useEnergy()
		return self:useObject(who)
	end
end

--- Returns a tooltip for the object
function _M:tooltip()
	return self:getDesc()
end

--- Describes an attribute, to expand object name
function _M:descAttribute(attr)
	if attr == "MASTERY" then
		local tms = {}
		for ttn, i in pairs(self.wielder.talents_types_mastery) do
			local tt = Talents.talents_types_def[ttn]
			local cat = tt.type:gsub("/.*", "")
			local name = cat:capitalize().." / "..tt.name:capitalize()
			tms[#tms+1] = ("%0.2f %s"):format(i, name)
		end
		return table.concat(tms, ",")
	elseif attr == "STATBONUS" then
		local stat, i = next(self.wielder.inc_stats)
		return i > 0 and "+"..i or tostring(i)
	elseif attr == "COMBAT" then
		local c = self.combat
		return c.dam.."-"..(c.dam*(c.damrange or 1.1)).." dam, "..(c.apr or 0).." apr"
	end
end

--- Gets the full name of the object
function _M:getName()
	local qty = 1
	local name = self.name

	if not self:isIdentified() and self:getUnidentifiedName() then name = self:getUnidentifiedName() end

	-- To extend later
	name = name:gsub("~", ""):gsub("&", "a"):gsub("#([^#]+)#", function(attr)
		return self:descAttribute(attr)
	end)

	if self.add_name and self:isIdentified() then
		name = name .. self.add_name:gsub("#([^#]+)#", function(attr)
			return self:descAttribute(attr)
		end)
	end

	return name
end

--- Gets the full desc of the object
function _M:getDesc()
	local c = ""
	if self.egoed then c = "#00FFFF#"
	elseif self.unique then c = "#FFFF00#"
	end
	local desc = { c..self:getName().."#FFFFFF#", self.desc }

	local reqs = self:getRequirementDesc(game.player)
	if reqs then
		desc[#desc+1] = reqs
	end

	if self.encumber then
		desc[#desc+1] = ("#67AD00#%0.2f Encumberance."):format(self.encumber)
	end

	-- Stop here if unided
	if not self:isIdentified() then return table.concat(desc, "\n") end


	if self.combat then
		local dm = {}
		for stat, i in pairs(self.combat.dammod or {}) do
			dm[#dm+1] = ("+%d%% %s"):format(i * 100, Stats.stats_def[stat].name)
		end
		desc[#desc+1] = ("%d Damage [Range %0.2f] (%s), %d Attack, %d Armor Peneration, Crit %d%%"):format(self.combat.dam or 0, self.combat.damrange or 1.1, table.concat(dm, ','), self.combat.atk or 0, self.combat.apr or 0, self.combat.physcrit or 0)
		desc[#desc+1] = ""
	end

	local w = self.wielder or {}
	if w.combat_atk or w.combat_dam or w.combat_apr then desc[#desc+1] = ("Attack %d, Armor Peneration %d, Physical Crit %d%%, Physical damage %d"):format(w.combat_atk or 0, w.combat_apr or 0, w.combat_physcrit or 0, w.combat_dam or 0) end
	if w.combat_armor or w.combat_def then desc[#desc+1] = ("Armor %d, Defense %d"):format(w.combat_armor or 0, w.combat_def or 0) end
	if w.fatigue then desc[#desc+1] = ("Fatigue %d%%"):format(w.fatigue) end

	if w.inc_stats then
		local dm = {}
		for stat, i in pairs(w.inc_stats) do
			dm[#dm+1] = ("%d %s"):format(i, Stats.stats_def[stat].name)
		end
		desc[#desc+1] = ("Increases stats: %s."):format(table.concat(dm, ','))
	end

	if w.resists then
		local rs = {}
		for res, i in pairs(w.resists) do
			rs[#rs+1] = ("%d%% %s"):format(i, DamageType.dam_def[res].name)
		end
		desc[#desc+1] = ("Increases resistances: %s."):format(table.concat(rs, ','))
	end

	if w.esp then
		local rs = {}
		for type, i in pairs(w.esp) do
			if type == "all" then rs[#rs+1] = "all"
			else
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				if st then
					rs[#rs+1] = st
				else
					rs[#rs+1] = t
				end
			end
		end
		desc[#desc+1] = ("Grants telepathy to %s."):format(table.concat(rs, ','))
	end

	if w.talents_types_mastery then
		local tms = {}
		for ttn, i in pairs(w.talents_types_mastery) do
			local tt = Talents.talents_types_def[ttn]
			local cat = tt.type:gsub("/.*", "")
			local name = cat:capitalize().." / "..tt.name:capitalize()
			tms[#tms+1] = ("%0.2f %s"):format(i, name)
		end
		desc[#desc+1] = ("Increases talent masteries: %s."):format(table.concat(tms, ','))
	end

	if w.combat_physresist then desc[#desc+1] = ("Increases physical resistance: %s."):format(w.combat_physresist) end
	if w.combat_spellresist then desc[#desc+1] = ("Increases spell resistance: %s."):format(w.combat_spellresist) end

	if w.life_regen then desc[#desc+1] = ("Regenerates %d hitpoints a turn."):format(w.life_regen) end
	if w.mana_regen then desc[#desc+1] = ("Regenerates %d mana a turn."):format(w.mana_regen) end

	if w.max_life then desc[#desc+1] = ("Maximun life %d"):format(w.max_life) end
	if w.max_mana then desc[#desc+1] = ("Maximun mana %d"):format(w.max_mana) end
	if w.max_stamina then desc[#desc+1] = ("Maximun stamina %d"):format(w.max_stamina) end

	if w.combat_spellpower or w.combat_spellcrit then desc[#desc+1] = ("Spellpower %d, Spell Crit %d%%"):format(w.combat_spellpower or 0, w.combat_spellcrit or 0) end

	if w.lite then desc[#desc+1] = ("Light radius %d"):format(w.lite) end

	local use_desc = self:getUseDesc()
	if use_desc then desc[#desc+1] = use_desc end

	return table.concat(desc, "\n")
end

local type_sort = {
	potion = 1,
	jewelry = 2,
	weapon = 100,
	armor = 101,
}

--- Sorting by type function
-- By default, sort by type name
function _M:getTypeOrder()
	if self.type and type_sort[self.type] then
		return type_sort[self.type]
	else
		return 99999
	end
end

--- Sorting by type function
-- By default, sort by subtype name
function _M:getSubtypeOrder()
	return self.subtype or ""
end
