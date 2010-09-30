-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

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
	engine.interface.ObjectIdentify,
	engine.interface.ActorTalents
))

function _M:init(t, no_default)
	t.encumber = t.encumber or 0

	engine.Object.init(self, t, no_default)
	engine.interface.ObjectActivable.init(self, t)
	engine.interface.ObjectIdentify.init(self, t)
	engine.interface.ActorTalents.init(self, t)
end

--- Can this object act at all
-- Most object will want to anwser false, only recharging and stuff needs them
function _M:canAct()
	if self.power_regen or self.use_talent then return true end
	return false
end

--- Do something when its your turn
-- For objects this mostly is to recharge them
-- By default, does nothing at all
function _M:act()
	self:regenPower()
	self:cooldownTalents()
	self:useEnergy()
end

--- Use the object (quaff, read, ...)
function _M:use(who, typ, inven, item)
	inven = who:getInven(inven)

	if self.use_no_blind and who:attr("blind") then
		game.logPlayer(who, "You cannot see!")
		return
	end
	if self.use_no_silence and who:attr("silence") then
		game.logPlayer(who, "You are silenced!")
		return
	end
	if self:wornInven() and not self.wielded and not self.use_no_wear then
		game.logPlayer(who, "You must wear this object to use it!")
		return
	end
	if who:hasEffect(self.EFF_UNSTOPPABLE) then
		game.logPlayer(who, "You can not use items during a battle frenzy!")
		return
	end

	local types = {}
	if self:canUseObject() then types[#types+1] = "use" end

	if not typ and #types == 1 then typ = types[1] end

	if typ == "use" then
		who:useEnergy(game.energy_to_act * (inven.use_speed or 1))
		if self.use_sound then game:playSoundNear(who, self.use_sound) end
		return self:useObject(who, inven, item)
	end
end

--- Returns a tooltip for the object
function _M:tooltip()
	return self:getDesc{do_color=true}
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
	elseif attr == "DAMBONUS" then
		local stat, i = next(self.wielder.inc_damage)
		return (i > 0 and "+"..i or tostring(i)).."%"
	elseif attr == "RESIST" then
		local stat, i = next(self.wielder.resists)
		return (i > 0 and "+"..i or tostring(i)).."%"
	elseif attr == "REGEN" then
		local i = self.wielder.mana_regen or self.wielder.stamina_regen or self.wielder.life_regen
		return ("%s%0.2f/turn"):format(i > 0 and "+" or "-", math.abs(i))
	elseif attr == "COMBAT" then
		local c = self.combat
		return c.dam.."-"..(c.dam*(c.damrange or 1.1)).." power, "..(c.apr or 0).." apr"
	elseif attr == "COMBAT_DAMTYPE" then
		local c = self.combat
		return c.dam.."-"..(c.dam*(c.damrange or 1.1)).." power, "..(c.apr or 0).." apr, "..DamageType:get(c.damtype).name.." damage"
	elseif attr == "ARMOR" then
		return (self.wielder and self.wielder.combat_def or 0).." def, "..(self.wielder and self.wielder.combat_armor or 0).." armor"
	elseif attr == "ATTACK" then
		return (self.wielder and self.wielder.combat_atk or 0).." attack, "..(self.wielder and self.wielder.combat_apr or 0).." apr, "..(self.wielder and self.wielder.combat_dam or 0).." power"
	elseif attr == "MONEY" then
		return ("worth %0.2f"):format(self.money_value / 10)
	elseif attr == "USE_TALENT" then
		return self:getTalentFromId(self.use_talent.id).name:lower()
	elseif attr == "DIGSPEED" then
		return ("dig speed %d turns"):format(self.digspeed)
	elseif attr == "CHARGES" then
		if self.use_power then
			return (" (%d/%d)"):format(math.floor(self.power / self.use_power.power), math.floor(self.max_power / self.use_power.power))
		else
			return ""
		end
	end
end

--- Gets the color in which to display the object in lists
function _M:getDisplayColor()
	if not self:isIdentified() then return {180, 180, 180}, "#B4B4B4#" end
	if self.lore then return {0, 128, 255}, "#0080FF#"
	elseif self.egoed then return {0, 255, 128}, "#00FF80#"
	elseif self.unique then return {255, 255, 0}, "#FFFF00#"
	else return {255, 255, 255}, "#FFFFFF#"
	end
end

--- Gets the full name of the object
function _M:getName(t)
	t = t or {}
	local qty = self:getNumber()
	local name = self.name

	if not self:isIdentified() and not t.force_id and self:getUnidentifiedName() then name = self:getUnidentifiedName() end

	-- To extend later
	name = name:gsub("~", ""):gsub("&", "a"):gsub("#([^#]+)#", function(attr)
		return self:descAttribute(attr)
	end)

	if self.add_name and self:isIdentified() then
		name = name .. self.add_name:gsub("#([^#]+)#", function(attr)
			return self:descAttribute(attr)
		end)
	end

	if not t.do_color then
		if qty == 1 or t.no_count then return name
		else return qty.." "..name
		end
	else
		local _, c = self:getDisplayColor()
		local ds = self:getDisplayString()
		if qty == 1 or t.no_count then return c..ds..name.."#LAST#"
		else return c..qty.." "..ds..name.."#LAST#"
		end
	end
end

--- Gets the full textual desc of the object without the name and requirements
function _M:getTextualDesc()
	local desc = {}

	desc[#desc+1] = ("Type: %s / %s"):format(self.type, self.subtype)

	-- Stop here if unided
	if not self:isIdentified() then return desc end

	if self.combat then
		local dm = {}
		for stat, i in pairs(self.combat.dammod or {}) do
			dm[#dm+1] = ("+%d%% %s"):format(i * 100, Stats.stats_def[stat].name)
		end
		desc[#desc+1] = ("%d Power [Range %0.2f] (%s), %d Attack, %d Armor Penetration, Crit %d%%"):format(self.combat.dam or 0, self.combat.damrange or 1.1, table.concat(dm, ','), self.combat.atk or 0, self.combat.apr or 0, self.combat.physcrit or 0)
		desc[#desc+1] = "Damage type: "..DamageType:get(self.combat.damtype or DamageType.PHYSICAL).name
		if self.combat.range then desc[#desc+1] = "Firing range: "..self.combat.range end
		desc[#desc+1] = ""

		if self.combat.talent_on_hit then
			for tid, data in pairs(self.combat.talent_on_hit) do
				desc[#desc+1] = ("Talent on hit(melee): %d%% chance %s (level %d)."):format(data.chance, self:getTalentFromId(tid).name, data.level)
			end
		end
	end

	local desc_wielder = function(w)
	if w.combat_atk or w.combat_dam or w.combat_apr then desc[#desc+1] = ("Attack %d, Armor Penetration %d, Physical Crit %d%%, Physical power %d"):format(w.combat_atk or 0, w.combat_apr or 0, w.combat_physcrit or 0, w.combat_dam or 0) end
	if w.combat_armor or w.combat_def then desc[#desc+1] = ("Armor %d, Defense %d"):format(w.combat_armor or 0, w.combat_def or 0) end
	if w.fatigue then desc[#desc+1] = ("Fatigue %d%%"):format(w.fatigue) end

	if w.inc_stats then
		local dm = {}
		for stat, i in pairs(w.inc_stats) do
			dm[#dm+1] = ("%d %s"):format(i, Stats.stats_def[stat].name)
		end
		desc[#desc+1] = ("Increases stats: %s."):format(table.concat(dm, ','))
	end

	if w.melee_project then
		local rs = {}
		for typ, dam in pairs(w.melee_project) do
			rs[#rs+1] = ("%d %s"):format(dam, DamageType.dam_def[typ].name)
		end
		desc[#desc+1] = ("Damage on hit(melee): %s."):format(table.concat(rs, ','))
	end

	if w.ranged_project then
		local rs = {}
		for typ, dam in pairs(w.ranged_project) do
			rs[#rs+1] = ("%d %s"):format(dam, DamageType.dam_def[typ].name)
		end
		desc[#desc+1] = ("Damage on hit(ranged): %s."):format(table.concat(rs, ','))
	end

	if w.on_melee_hit then
		local rs = {}
		for typ, dam in pairs(w.on_melee_hit) do
			rs[#rs+1] = ("%d %s"):format(dam, DamageType.dam_def[typ].name)
		end
		desc[#desc+1] = ("Damage when hit: %s."):format(table.concat(rs, ','))
	end

	if w.resists then
		local rs = {}
		for res, i in pairs(w.resists) do
			rs[#rs+1] = ("%d%% %s"):format(i, res == "all" and "all" or DamageType.dam_def[res].name)
		end
		desc[#desc+1] = ("Increases resistances: %s."):format(table.concat(rs, ','))
	end

	if w.inc_damage then
		local rs = {}
		for res, i in pairs(w.inc_damage) do
			rs[#rs+1] = ("%d%% %s"):format(i, res == "all" and "all" or DamageType.dam_def[res].name)
		end
		desc[#desc+1] = ("Increases damage type: %s."):format(table.concat(rs, ','))
	end

	if w.esp then
		local rs = {}
		for type, i in pairs(w.esp) do
			if type == "all" then rs[#rs+1] = "all"
			elseif type == "range" then rs[#rs+1] = "increase range by "..i
			else
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				if st and st ~= "" then
					rs[#rs+1] = st
				else
					rs[#rs+1] = t
				end
			end
		end
		desc[#desc+1] = ("Grants telepathy: %s."):format(table.concat(rs, ','))
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

	if w.talent_cd_reduction then
		local tcds = {}
		for tid, cd in pairs(w.talent_cd_reduction) do
			tcds[#tcds+1] = ("%s (%d)"):format(Talents.talents_def[tid].name, cd)
		end
		desc[#desc+1] = ("Reduces talent cooldowns: %s."):format(table.concat(tcds, ','))
	end

	if w.can_breath then
		local ts = {}
		for what, _ in pairs(w.can_breath) do
			ts[#ts+1] = what
		end
		desc[#desc+1] = ("Allows you to breathe in: %s."):format(table.concat(ts, ','))
	end

	if w.combat_critical_power then desc[#desc+1] = ("Increases critical damage modifier: +%d%%."):format(w.combat_critical_power) end

	if w.disarm_bonus then desc[#desc+1] = ("Increases trap disarming bonus: %d."):format(w.disarm_bonus) end
	if w.inc_stealth then desc[#desc+1] = ("Increases stealth bonus: %d."):format(w.inc_stealth) end
	if w.max_encumber then desc[#desc+1] = ("Increases maximum encumberance: %d."):format(w.max_encumber) end

	if w.combat_physresist then desc[#desc+1] = ("Increases physical save: %s."):format(w.combat_physresist) end
	if w.combat_spellresist then desc[#desc+1] = ("Increases spell save: %s."):format(w.combat_spellresist) end
	if w.combat_mentalresist then desc[#desc+1] = ("Increases mental save: %s."):format(w.combat_mentalresist) end

	if w.blind_immune then desc[#desc+1] = ("Increases blindness immunity: %d%%."):format(w.blind_immune * 100) end
	if w.poison_immune then desc[#desc+1] = ("Increases poison immunity: %d%%."):format(w.poison_immune * 100) end
	if w.cut_immune then desc[#desc+1] = ("Increases cut immunity: %d%%."):format(w.cut_immune * 100) end
	if w.silence_immune then desc[#desc+1] = ("Increases silence immunity: %d%%."):format(w.silence_immune * 100) end
	if w.disarm_immune then desc[#desc+1] = ("Increases disarm immunity: %d%%."):format(w.disarm_immune * 100) end
	if w.confusion_immune then desc[#desc+1] = ("Increases confusion immunity: %d%%."):format(w.confusion_immune * 100) end
	if w.pin_immune then desc[#desc+1] = ("Increases pinning immunity: %d%%."):format(w.pin_immune * 100) end
	if w.stun_immune then desc[#desc+1] = ("Increases stun immunity: %d%%."):format(w.stun_immune * 100) end
	if w.fear_immune then desc[#desc+1] = ("Increases fear immunity: %d%%."):format(w.fear_immune * 100) end
	if w.knockback_immune then desc[#desc+1] = ("Increases knockback immunity: %d%%."):format(w.knockback_immune * 100) end
	if w.instakill_immune then desc[#desc+1] = ("Increases instant-death immunity: %d%%."):format(w.instakill_immune * 100) end

	if w.life_regen then desc[#desc+1] = ("Regenerates %0.2f hitpoints each turn."):format(w.life_regen) end
	if w.stamina_regen then desc[#desc+1] = ("Regenerates %0.2f stamina each turn."):format(w.stamina_regen) end
	if w.mana_regen then desc[#desc+1] = ("Regenerates %0.2f mana each turn."):format(w.mana_regen) end

	if w.stamina_regen_on_hit then desc[#desc+1] = ("Regenerates %0.2f stamina when hit."):format(w.stamina_regen_on_hit) end
	if w.mana_regen_on_hit then desc[#desc+1] = ("Regenerates %0.2f mana when hit."):format(w.mana_regen_on_hit) end
	if w.equilibrium_regen_on_hit then desc[#desc+1] = ("Regenerates %0.2f equilibrium when hit."):format(w.equilibrium_regen_on_hit) end

	if w.max_life then desc[#desc+1] = ("Maximum life %d"):format(w.max_life) end
	if w.max_mana then desc[#desc+1] = ("Maximum mana %d"):format(w.max_mana) end
	if w.max_stamina then desc[#desc+1] = ("Maximum stamina %d"):format(w.max_stamina) end

	if w.combat_spellpower or w.combat_spellcrit then desc[#desc+1] = ("Spellpower %d, Spell Crit %d%%"):format(w.combat_spellpower or 0, w.combat_spellcrit or 0) end

	if w.lite then desc[#desc+1] = ("Light radius %d"):format(w.lite) end
	if w.infravision then desc[#desc+1] = ("Infravision radius %d"):format(w.infravision) end
	if w.heightened_senses then desc[#desc+1] = ("Heightened senses radius %d"):format(w.heightened_senses) end

	if w.see_invisible then desc[#desc+1] = ("See invisible: %d"):format(w.see_invisible) end
	if w.invisible then desc[#desc+1] = ("Invisibility: %d"):format(w.invisible) end

	if w.movement_speed then desc[#desc+1] = ("Movement speed: %d%%"):format((1 - w.movement_speed) * 100) end

	end

	if self.wielder then
		desc[#desc+1] = "#YELLOW#When wielded/worn:#LAST#"
		desc_wielder(self.wielder)
	end

	if self.carrier then
		desc[#desc+1] = "#YELLOW#When carried:#LAST#"
		desc_wielder(self.carrier)
	end

	if self.imbue_powers then
		desc[#desc+1] = "#YELLOW#When used to imbue an object:#LAST#"
		desc_wielder(self.imbue_powers)
	end

	if self.alchemist_bomb then
		local a = self.alchemist_bomb
		desc[#desc+1] = "#YELLOW#When used as an alchemist bomb:#LAST#"
		if a.power then desc[#desc+1] = ("Bomb damage +%d%%"):format(a.power) end
		if a.range then desc[#desc+1] = ("Bomb thrown range +%d"):format(a.range) end
		if a.mana then desc[#desc+1] = ("Mana regain %d"):format(a.mana) end
		if a.daze then desc[#desc+1] = ("%d%% chance to daze for %d turns"):format(a.daze.chance, a.daze.dur) end
		if a.stun then desc[#desc+1] = ("%d%% chance to stun for %d turns"):format(a.stun.chance, a.stun.dur) end
		if a.splash then desc[#desc+1] = ("Additional %d %s damage"):format(a.splash.dam, DamageType:get(DamageType[a.splash.type]).name) end
		if a.leech then desc[#desc+1] = ("Life regen %d%% of max life"):format(a.leech) end
	end

	local use_desc = self:getUseDesc()
	if use_desc then desc[#desc+1] = use_desc end

	return desc
end

--- Gets the full desc of the object
function _M:getDesc(name_param)
	local _, c = self:getDisplayColor()
	local desc
	if not self:isIdentified() then
		desc = { c..self:getName(name_param).."#FFFFFF#" }
	else
		desc = { c..self:getName(name_param).."#FFFFFF#", self.desc }
	end

	local reqs = self:getRequirementDesc(game.player)
	if reqs then
		desc[#desc+1] = reqs
	end

	if self.encumber then
		desc[#desc+1] = ("#67AD00#%0.2f Encumbrance.#LAST#"):format(self.encumber)
	end

	local textdesc = table.concat(self:getTextualDesc(), "\n")

	return table.concat(desc, "\n").."\n"..textdesc
end

local type_sort = {
	potion = 1,
	scroll = 1,
	jewelry = 3,
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

--- Get item cost
function _M:getPrice()
	return self.cost or 0
end

--- Called when trying to pickup
function _M:on_prepickup(who, idx)
	if self.lore then
		game.level.map:removeObject(who.x, who.y, idx)
		who:learnLore(self.lore)
		return true
	end
end

--- Can it stacks with others of its kind ?
function _M:canStack(o)
	-- Can only stack known things
	if not self:isIdentified() or not o:isIdentified() then return false end
	return engine.Object.canStack(self, o)
end
