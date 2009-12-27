require "engine.class"
require "engine.Object"

local Stats = require("engine.interface.ActorStats")

module(..., package.seeall, class.inherit(engine.Object))

function _M:init(t, no_default)
	engine.Object.init(self, t, no_default)
end

function _M:tooltip()
	return self:getDesc()
end

--- Gets the full name of the object
function _M:getName()
	local qty = 1
	local name = self.name
	-- To extend later
	name = name:gsub("~", ""):gsub("#[1-9]#", ""):gsub("&", "a")
	return name
end

--- Gets the full desc of the object
function _M:getDesc()
	local c = ""
	if self.egoed then c = "#00FFFF#"
	elseif self.unique then c = "#FFFF00#"
	end
	local desc = { c..self:getName().."#FFFFFF#", self.desc }

	if self.combat then
		local dm = {}
		for stat, i in pairs(self.combat.dammod or {}) do
			dm[#dm+1] = ("+%d%% %s"):format(i * 100, Stats.stats_def[stat].name)
		end
		desc[#desc+1] = ("%d Damage (%s), %d Attack, %d Armor Peneration, Crit %d%%"):format(self.combat.dam or 0, table.concat(dm, ','), self.combat.atk or 0, self.combat.apr or 0, self.combat.physcrit or 0)
		desc[#desc+1] = ""
	end

	local w = self.wielder or {}
	if w.combat_armor or w.combat_def then desc[#desc+1] = ("Armor %d, Defense %d"):format(w.combat_armor or 0, w.combat_def or 0) end

	if w.combat_spellpower or w.combat_spellcrit then desc[#desc+1] = ("Spellpower %d, Spell Crit %d%%"):format(w.combat_spellpower or 0, w.combat_spellcrit or 0) end

	if w.lite then desc[#desc+1] = ("Light radius %d"):format(w.lite) end

	return table.concat(desc, "\n")
end
