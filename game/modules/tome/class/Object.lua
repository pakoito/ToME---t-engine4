-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
-- Most object will want to answer false, only recharging and stuff needs them
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
		local ret = {self:useObject(who, inven, item)}
		if ret[1] then
			if self.use_sound then game:playSoundNear(who, self.use_sound) end
			who:useEnergy(game.energy_to_act * (inven.use_speed or 1))
		end
		return unpack(ret)
	end
end

--- Returns a tooltip for the object
function _M:tooltip(x, y)
	local str = self:getDesc({do_color=true}, game.player:getInven(self:wornInven()))
	if config.settings.cheat then str:add(true, "UID: "..self.uid, true, self.image) end
	local nb = game.level.map:getObjectTotal(x, y)
	if nb == 2 then str:add(true, "---", true, "You see one more object.")
	elseif nb > 2 then str:add(true, "---", true, "You see "..(nb-1).." more objects.")
	end
	return str
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
		return (i and i > 0 and "+"..i or tostring(i)).."%"
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
		return (self.wielder and self.wielder.combat_atk or 0).." accuracy, "..(self.wielder and self.wielder.combat_apr or 0).." apr, "..(self.wielder and self.wielder.combat_dam or 0).." power"
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
	elseif attr == "INSCRIPTION" then
		game.player.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		local desc = t.short_info(game.player, t)
		game.player.__inscription_data_fake = nil
		return ("%s"):format(desc)
	end
end

--- Gets the "power rank" of an object
-- Possible values are 0 (normal, lore), 1 (ego), 2 (greater ego), 3 (artifact)
function _M:getPowerRank()
	if self.godslayer then return 10 end
	if self.unique then return 3 end
	if self.egoed and self.greater_ego then return 2 end
	if self.egoed then return 1 end
	return 0
end

--- Gets the color in which to display the object in lists
function _M:getDisplayColor()
	if not self:isIdentified() then return {180, 180, 180}, "#B4B4B4#" end
	if self.lore then return {0, 128, 255}, "#0080FF#"
	elseif self.egoed then
		if self.greater_ego then
			if self.greater_ego > 1 then
				return {0x8d, 0x55, 0xff}, "#8d55ff#"
			else
				return {0, 0x80, 255}, "#0080FF#"
			end
		else
			return {0, 255, 128}, "#00FF80#"
		end
	elseif self.unique then
		if self.randart then
			return {255, 0x77, 0}, "#FF7700#"
		elseif self.godslayer then
			return {0xAA, 0xD5, 0x00}, "#AAD500#"
		else
			return {255, 215, 0}, "#FFD700#"
		end
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

	if not t.no_add_name and self.add_name and self:isIdentified() then
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
		local ds = t.no_image and "" or self:getDisplayString()
		if qty == 1 or t.no_count then return c..ds..name.."#LAST#"
		else return c..qty.." "..ds..name.."#LAST#"
		end
	end
end

--- Gets the full textual desc of the object without the name and requirements
function _M:getTextualDesc(compare_with)
	compare_with = compare_with or {}
	local desc = tstring{}

	if self.quest then desc:add({"color", "VIOLET"},"[Plot Item]", {"color", "LAST"}, true) end

	desc:add(("Type: %s / %s"):format(rawget(self, 'type') or "unknown", self.subtype or "unknown"), true)
	if self.slot_forbid == "OFFHAND" then desc:add("It must be held with both hands.", true) end
	desc:add(true)

	-- Stop here if unided
	if not self:isIdentified() then return desc end

	local compare_fields = function(item1, items, infield, field, outformat, text, mod, isinversed)
		mod = mod or 1
		isinversed = isinversed or false
		local ret = tstring{}
		local added = 0
		local add = false
		ret:add(text)
		if isinversed then
			ret:add((item1[field] or 0) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((item1[field] or 0) * mod), {"color", "LAST"})
		else
			ret:add((item1[field] or 0) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((item1[field] or 0) * mod), {"color", "LAST"})
		end
		if item1[field] then
			add = true
		end
		for i=1, #items do
			if items[i][infield] and items[i][infield][field] and items[i][infield][field] ~= (item1[field] or 0) then
				if added == 0 then
					ret:add(" (")
				elseif added > 1 then
					ret:add(" / ")
				end
				added = added + 1
				add = true
				if isinversed then
					ret:add(items[i][infield][field] < (item1[field] or 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format(((item1[field] or 0) - items[i][infield][field]) * mod), {"color", "LAST"})
				else
					ret:add(items[i][infield][field] > (item1[field] or 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format(((item1[field] or 0) - items[i][infield][field]) * mod), {"color", "LAST"})
				end
			end
			if added > 0 then
				ret:add(")")
			end
		end
		if add then
			desc:merge(ret)
			desc:add(true)
		end
	end

	local desc_combat = function(combat, compare_with, field)
		compare_with = compare_with or {}
		local dm = {}
		local total_power = 0
		for stat, i in pairs(combat.dammod or {}) do
			dm[#dm+1] = ("%d%% %s"):format(i * 100, Stats.stats_def[stat].short_name:capitalize())
			total_power = total_power + game.player:getStat(stat) * i
		end
		if #dm > 0 or combat.dam then
			desc:add(("Base power: %.1f - %.1f"):format(combat.dam or 0, (combat.damrange or 1.1) * (combat.dam or 0)), true)
			desc:add(("Uses stat%s: %s"):format(#dm > 1 and "s" or "",table.concat(dm, ', ')), true)
			local col = lpeg.match("#" * lpeg.C((lpeg.R"AZ" + "_")^3) * "#", combat.damtype and DamageType:get(combat.damtype) and DamageType:get(combat.damtype).text_color or "#GREY#")

			desc:add("Damage type: ",col and {"color",col} or {"color","GREY"},DamageType:get(combat.damtype or DamageType.PHYSICAL).name:capitalize(),{"color","LAST"}, true)
		end

		compare_fields(combat, compare_with, field, "atk", "%+d", "Accuracy: ")
		compare_fields(combat, compare_with, field, "apr", "%+d", "Armor Penetration: ")
		compare_fields(combat, compare_with, field, "physcri", "%+d%%", "Physical crit. chance: ")

		compare_fields(combat, compare_with, field, "range", "%+d", "Firing range: ")

		if combat.talent_on_hit then
			for tid, data in pairs(combat.talent_on_hit) do
				desc:add(("Talent on hit(melee): %d%% chance %s (level %d)."):format(data.chance, self:getTalentFromId(tid).name, data.level), true)
			end
		end

		if combat.special_on_hit then
			desc:add("Special effect on hit: "..combat.special_on_hit.desc, true)
		end

		if combat.no_stealth_break then
			desc:add("When used from stealth a simple attack with it will not break stealth.", true)
		end

		compare_fields(combat, compare_with, field, "travel_speed", "%+d%%", "Travel speed: ")

		if combat.melee_project then
			desc:add("Damage on strike(melee):")
			local count = 0
			for typ, dam in pairs(combat.melee_project) do
				local color = DamageType.dam_def[typ].text_color and DamageType.dam_def[typ].text_color:gsub("#","") or "GREY"
				desc:add({"color",color})
				desc:add(("%s%d %s"):format((count > 0) and " / " or "",dam, DamageType.dam_def[typ].name))
				desc:add({"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		if combat.inc_damage_type then
			local idt = {}
			for type, i in pairs(combat.inc_damage_type) do
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				if st and st ~= "" then
					idt[#idt+1] = st.." (+"..i.."%)"
				else
					idt[#idt+1] = t.." (+"..i.."%)"
				end
			end
			if #idt > 0 then
				desc:add(("Deals more damage against: %s."):format(table.concat(idt, ', ')), true)
			end
		end
	end

	local desc_wielder = function(w, compare_with, field)
		compare_fields(w, compare_with, field, "combat_atk", "%+d", "Accuracy: ")
		compare_fields(w, compare_with, field, "combat_apr", "%+d", "Armor penetration: ")
		compare_fields(w, compare_with, field, "combat_physcrit", "%+d%%", "Physical crit. chance: ")
		compare_fields(w, compare_with, field, "combat_dam", "%+d", "Physical power: ")

		compare_fields(w, compare_with, field, "combat_armor", "%+d", "Armor: ")
		compare_fields(w, compare_with, field, "combat_def", "%+d", "Defense: ")
		compare_fields(w, compare_with, field, "combat_def_ranged", "%+d", "Ranged Defense: ")

		compare_fields(w, compare_with, field, "fatigue", "%+d%%", "Fatigue: ", 1, true)

		if w.inc_stats then
			desc:add("Changes stats: ")
			local count = 0
			for stat, i in pairs(w.inc_stats) do
				desc:add(("%s"):format((count > 0) and " / " or ""), (i > 0) and {"color","LIGHT_GREEN"} or {"color","RED"}, ("%+d "):format(i), {"color","LAST"}, ("%s"):format(Stats.stats_def[stat].short_name:capitalize()))
				count = count + 1
			end
			desc:add(true)
		end

		if w.melee_project then
			desc:add("Damage on hit(melee): ")
			local count = 0
			for typ, dam in pairs(w.melee_project) do
				local color = DamageType.dam_def[typ].text_color and DamageType.dam_def[typ].text_color:gsub("#","") or "GREY"
				desc:add({"color",color})
				desc:add(("%s%d %s"):format((count > 0) and " / " or "",dam, DamageType.dam_def[typ].name))
				desc:add({"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		if w.ranged_project then
			desc:add("Damage on hit(ranged): ")
			local count = 0
			for typ, dam in pairs(w.ranged_project) do
				local color = DamageType.dam_def[typ].text_color and DamageType.dam_def[typ].text_color:gsub("#","") or "GREY"
				desc:add({"color",color})
				desc:add(("%s%d %s"):format((count > 0) and " / " or "",dam, DamageType.dam_def[typ].name))
				desc:add({"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		if w.on_melee_hit then
			desc:add("Damage when hit: ")
			local count = 0
			for typ, dam in pairs(w.on_melee_hit) do
				local color = DamageType.dam_def[typ].text_color and DamageType.dam_def[typ].text_color:gsub("#","") or "GREY"
				desc:add({"color",color})
				desc:add(("%s %d %s"):format((count > 0) and " / " or "",dam, DamageType.dam_def[typ].name))
				desc:add({"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		if w.resists then
			desc:add("Changes resistances: ")
			local count = 0
			for typ, dam in pairs(w.resists) do
				local col = lpeg.match("#" * lpeg.C((lpeg.R"AZ" + "_")^3) * "#", DamageType.dam_def[typ] and DamageType.dam_def[typ].text_color or "#GREY#")
				desc:add(("%s"):format((count > 0) and " / " or ""), (dam < 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, ("%+d%% "):format(dam), {"color","LAST"})
				desc:add(col and {"color",col} or {"color","GREY"}, ("%s"):format(typ == "all" and "all" or DamageType.dam_def[typ].name), {"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		if w.resists_cap then
			desc:add("Changes resistances cap: ")
			local count = 0
			for typ, dam in pairs(w.resists_cap) do
				local col = lpeg.match("#" * lpeg.C((lpeg.R"AZ" + "_")^3) * "#", DamageType.dam_def[typ] and DamageType.dam_def[typ].text_color or "#GREY#")
				desc:add(("%s"):format((count > 0) and " / " or ""), (dam < 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, ("%+d%% "):format(dam), {"color","LAST"})
				desc:add(col and {"color",col} or {"color","GREY"}, ("%s"):format(typ == "all" and "all" or DamageType.dam_def[typ].name), {"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		if w.inc_damage then
			desc:add("Changes damage: ")
			local count = 0
			for typ, dam in pairs(w.inc_damage) do
				local col = lpeg.match("#" * lpeg.C((lpeg.R"AZ" + "_")^3) * "#", DamageType.dam_def[typ] and DamageType.dam_def[typ].text_color or "#GREY#")
				desc:add(("%s"):format((count > 0) and " / " or ""), (dam < 0) and {"color","RED"} or {"color","LIGHT_GREEN"}, ("%+d%% "):format(dam), {"color","LAST"})
				desc:add(col and {"color",col} or {"color","GREY"}, ("%s"):format(typ == "all" and "all" or DamageType.dam_def[typ].name), {"color","LAST"})
				count = count + 1
			end
			desc:add(true)
		end

		local esps = {}
		if w.esp_all then esps[#esps+1] = "all" end
		if w.esp_range then esps[#esps+1] = "change range by "..w.esp_range end
		if w.esp then
			for type, i in pairs(w.esp) do
				local _, _, t, st = type:find("^([^/]+)/?(.*)$")
				if st and st ~= "" then
					esps[#esps+1] = st
				else
					esps[#esps+1] = t
				end
			end
		end
		if #esps > 0 then
			desc:add(("Grants telepathy: %s."):format(table.concat(esps, ', ')), true)
		end

		if w.talents_types_mastery then
			local tms = {}
			for ttn, i in pairs(w.talents_types_mastery) do
				local tt = Talents.talents_types_def[ttn]
				local cat = tt.type:gsub("/.*", "")
				local name = cat:capitalize().." / "..tt.name:capitalize()
				tms[#tms+1] = ("%+.2f %s"):format(i, name)
			end
			desc:add(("Increases talent masteries: %s."):format(table.concat(tms, ', ')), true)
		end

		if w.talent_cd_reduction then
			local tcds = {}
			for tid, cd in pairs(w.talent_cd_reduction) do
				tcds[#tcds+1] = ("%s (%+d turn%s)"):format(Talents.talents_def[tid].name, -cd, (cd > 1) and "s" or "")
			end
			desc:add(("Talent cooldowns: %s."):format(table.concat(tcds, ', ')), true)
		end

		if w.can_breath then
			local ts = {}
			for what, _ in pairs(w.can_breath) do
				ts[#ts+1] = what
			end
			desc:add(("Allows you to breathe in: %s."):format(table.concat(ts, ', ')), true)
		end

		compare_fields(w, compare_with, field, "combat_critical_power", "%+.2f%%", "Critical mult.: ")

		compare_fields(w, compare_with, field, "disarm_bonus", "%+d", "Trap disarming bonus: ")
		compare_fields(w, compare_with, field, "inc_stealth", "%+d", "Stealth bonus: ")
		compare_fields(w, compare_with, field, "max_encumber", "%+d", "Maximum encumberance: ")

		compare_fields(w, compare_with, field, "combat_physresist", "%+d", "Physical save: ")
		compare_fields(w, compare_with, field, "combat_spellresist", "%+d", "Spell save: ")
		compare_fields(w, compare_with, field, "combat_mentalresist", "%+d", "Mental save: ")

		compare_fields(w, compare_with, field, "blind_immune", "%+d%%", "Blindness immunity: ", 100)
		compare_fields(w, compare_with, field, "poison_immune", "%+d%%", "Poison immunity: ", 100)
		compare_fields(w, compare_with, field, "disease_immune", "%+d%%", "Disease immunity: ", 100)
		compare_fields(w, compare_with, field, "cut_immune", "%+d%%", "Cut immunity: ", 100)

		compare_fields(w, compare_with, field, "silence_immune", "%+d%%", "Silence immunity: ", 100)
		compare_fields(w, compare_with, field, "disarm_immune", "%+d%%", "Disarm immunity: ", 100)
		compare_fields(w, compare_with, field, "confusion_immune", "%+d%%", "Confusion immunity: ", 100)
		compare_fields(w, compare_with, field, "pin_immune", "%+d%%", "Pinning immunity: ", 100)

		compare_fields(w, compare_with, field, "stun_immune", "%+d%%", "Stun immunity: ", 100)
		compare_fields(w, compare_with, field, "fear_immune", "%+d%%", "Fear immunity: ", 100)
		compare_fields(w, compare_with, field, "knockback_immune", "%+d%%", "Knockback immunity: ", 100)
		compare_fields(w, compare_with, field, "instakill_immune", "%+d%%", "Instant-death immunity: ", 100)
		compare_fields(w, compare_with, field, "teleport_immune", "%+d%%", "Teleport immunity: ", 100)

		compare_fields(w, compare_with, field, "life_regen", "%+.2f", "Hitpoints each turn: ")
		compare_fields(w, compare_with, field, "stamina_regen", "%+.2f", "Stamina each turn: ")
		compare_fields(w, compare_with, field, "mana_regen", "%+.2f", "Mana each turn: ")

		compare_fields(w, compare_with, field, "stamina_regen_on_hit", "%+.2f", "Stamina when hit: ")
		compare_fields(w, compare_with, field, "mana_regen_on_hit", "%+.2f", "Mana when hit: ")
		compare_fields(w, compare_with, field, "equilibrium_regen_on_hit", "%+.2f", "Equilibrium when hit: ")

		compare_fields(w, compare_with, field, "max_life", "%+.2f", "Maximum life: ")
		compare_fields(w, compare_with, field, "max_mana", "%+.2f", "Maximum mana: ")
		compare_fields(w, compare_with, field, "max_stamina", "%+.2f", "Maximum stamina: ")

		compare_fields(w, compare_with, field, "combat_spellpower", "%+d", "Spellpower: ")
		compare_fields(w, compare_with, field, "combat_spellcrit", "%+d%%", "Spell crit. chance: ")

		compare_fields(w, compare_with, field, "lite", "%+d", "Light radius: ")
		compare_fields(w, compare_with, field, "infravision", "%+d", "Infravision radius: ")
		compare_fields(w, compare_with, field, "heightened_senses", "%+d", "Heightened senses radius: ")

		compare_fields(w, compare_with, field, "see_invisible", "%+d", "See invisible: ")
		compare_fields(w, compare_with, field, "invisible", "%+d", "Invisibility: ")

		compare_fields(w, compare_with, field, "movement_speed", "%+d%%", "Movement speed: ", 100)
		compare_fields(w, compare_with, field, "combat_physspeed", "%+d%%", "Combat speed: ", 100)
		compare_fields(w, compare_with, field, "combat_spellspeed", "%+d%%", "Casting speed: ", 100)

		compare_fields(w, compare_with, field, "healing_factor", "%+d%%", "Healing: ", 100)

		compare_fields(w, compare_with, field, "life_leech_chance", "%+d%%", "Life leech chance: ")
		compare_fields(w, compare_with, field, "life_leech_value", "%+d%%", "Life leech: ")

		compare_fields(w, compare_with, field, "size_category", "%+d", "Size category: ")

		--compare_fields(w, compare_with, field, "mana_regen", "%+d", "a: ")

		if w.combat then
			desc:add({"color","YELLOW"}, "When used to modify unarmed attacks:", {"color", "LAST"}, true)

			-- clone the table to show modified values
			local unarmed = table.clone(w.combat)
			if unarmed.damrange then unarmed.damrange = unarmed.damrange + 1.1 end
			if unarmed.dammod.str then unarmed.dammod.str = unarmed.dammod.str + 1 end

			desc_combat(unarmed)

			-- subtract the modified values to keep the tooltips correct
			if unarmed.damrange then unarmed.damrange = unarmed.damrange - 1.1 end
			if unarmed.dammod.str then unarmed.dammod.str = unarmed.dammod.str - 1 end

		end

	end

	if self.combat then desc_combat(self.combat, compare_with, "combat") end

	if self.special_combat then
		desc:add({"color","YELLOW"}, "When used to attack (with talents):", {"color", "LAST"}, true)
		desc_combat(self.special_combat, compare_with, "special_combat")
	end

	if self.no_teleport then
		desc:add("It is immune to teleportation, if you teleport it will fall on the ground.", true)
	end

	if self.basic_ammo then
		desc:add({"color","YELLOW"}, "Default ammo(infinite):", {"color", "LAST"}, true)
		desc_combat(self.basic_ammo, compare_with, "basic_ammo")
	end

	if self.wielder then
		desc:add({"color","YELLOW"}, "When wielded/worn:", {"color", "LAST"}, true)
		desc_wielder(self.wielder, compare_with, "wielder")
	end

	if self.carrier then
		desc:add({"color","YELLOW"}, "When carried:", {"color", "LAST"}, true)
		desc_wielder(self.carrier, compare_with, "carrier")
	end

	if self.imbue_powers then
		desc:add({"color","YELLOW"}, "When used to imbue an object:", {"color", "LAST"}, true)
		desc_wielder(self.imbue_powers, compare_with, "imbue_powers")
	end

	if self.alchemist_bomb then
		local a = self.alchemist_bomb
		desc:add({"color","YELLOW"}, "When used as an alchemist bomb:", {"color", "LAST"}, true)
		if a.power then desc:add(("Bomb damage +%d%%"):format(a.power), true) end
		if a.range then desc:add(("Bomb thrown range +%d"):format(a.range), true) end
		if a.mana then desc:add(("Mana regain %d"):format(a.mana), true) end
		if a.daze then desc:add(("%d%% chance to daze for %d turns"):format(a.daze.chance, a.daze.dur), true) end
		if a.stun then desc:add(("%d%% chance to stun for %d turns"):format(a.stun.chance, a.stun.dur), true) end
		if a.splash then desc:add(("Additional %d %s damage"):format(a.splash.dam, DamageType:get(DamageType[a.splash.type]).name), true) end
		if a.leech then desc:add(("Life regen %d%% of max life"):format(a.leech), true) end
	end

	if self.inscription_data and self.inscription_talent then
		game.player.__inscription_data_fake = self.inscription_data
		local t = self:getTalentFromId("T_"..self.inscription_talent.."_1")
		local tdesc = game.player:getTalentFullDescription(t)
		game.player.__inscription_data_fake = nil
		desc:add({"color","YELLOW"}, "When inscribed on your body:", {"color", "LAST"}, true)
		desc:merge(tdesc)
		desc:add(true)
	end

	local use_desc = self:getUseDesc()
	if use_desc then desc:add(use_desc) end

	return desc
end

--- Gets the full desc of the object
function _M:getDesc(name_param, compare_with)
	local desc = tstring{}
	name_param = name_param or {}
	name_param.do_color = true
	compare_with = compare_with or {}
	if not self:isIdentified() then
		desc:merge(self:getName(name_param):toTString())
		desc:add({"color", "WHITE"}, true)
	else
		desc:merge(self:getName(name_param):toTString())
		desc:add({"color", "WHITE"}, true)
		desc:add(true)
		desc:add({"color", "ANTIQUE_WHITE"})
		desc:merge(self.desc:toTString())
		desc:add(true, true)
		desc:add({"color", "WHITE"})
	end

	local reqs = self:getRequirementDesc(game.player)
	if reqs then
		desc:merge(reqs)
	end

	if self.power_source then
		if self.power_source.arcane then desc:add("Powered by ", {"color", "VIOLET"}, "arcane forces", {"color", "LAST"}, true) end
		if self.power_source.nature then desc:add("Infused by ", {"color", "OLIVE_DRAB"}, "nature", {"color", "LAST"}, true) end
		if self.power_source.antimagic then desc:add("Infused by ", {"color", "ORCHID"}, "arcane disrupting forces", {"color", "LAST"}, true) end
		if self.power_source.technique then desc:add("Crafted by ", {"color", "LIGHT_UMBER"}, "a master", {"color", "LAST"}, true) end
		if self.power_source.psionic then desc:add("Infused by ", {"color", "YELLOW"}, "psionic forces", {"color", "LAST"}, true) end
		if self.power_source.unknown then desc:add("Powered by ", {"color", "CRIMSON"}, "unknown forces", {"color", "LAST"}, true) end
	end

	if self.encumber then
		desc:add({"color",0x67,0xAD,0x00}, ("%0.2f Encumbrance."):format(self.encumber), {"color", "LAST"})
	end

	desc:add(true, true)

	local could_compare = false
	if not name_param.force_compare and not core.key.modState("ctrl") then
		if compare_with[1] then could_compare = true end
		compare_with = {}
	end

	desc:merge(self:getTextualDesc(compare_with))

	if could_compare then desc:add(true, {"font","italic"}, {"color","GOLD"}, "Press <control> to compare", {"color","LAST"}, {"font","normal"}) end

	return desc
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
	if self.quest and who ~= game.party:findMember{main=true} then
		return true
	end
	if who.player and self.lore then
		game.level.map:removeObject(who.x, who.y, idx)
		who:learnLore(self.lore)
		return true
	end
	if who.player and self.force_lore_artifact then
		game.player:additionalLore(self.unique, self:getName(), "artifacts", self.desc)
		game.player:learnLore(self.unique)
	end
end

--- Can it stacks with others of its kind ?
function _M:canStack(o)
	-- Can only stack known things
	if not self:isIdentified() or not o:isIdentified() then return false end
	return engine.Object.canStack(self, o)
end

--- On identification, add to lore
function _M:on_identify()
	if self.on_id_lore then
		game.player:learnLore(self.on_id_lore)
	end
	if self.unique and self.desc and not self.no_unique_lore then
		game.player:additionalLore(self.unique, self:getName(), "artifacts", self.desc)
		game.player:learnLore(self.unique)
	end
end
