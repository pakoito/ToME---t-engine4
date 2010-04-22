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
local Dialog = require "engine.Dialog"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Character Sheet: "..self.actor.name.." (Press 'd' to save)", 800, 400, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:keyCommands({
		__TEXTINPUT = function(c)
			if c == 'd' or c == 'D' then
				self:dump()
			end
		end,
	}, {
		ACCEPT = "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
		end,
	})
end

function _M:drawDialog(s)
	local cur_exp, max_exp = game.player.exp, game.player:getExpChart(game.player.level+1)

	local h = 0
	local w = 0
	s:drawString(self.font, "Sex:   "..game.player.descriptor.sex, w, h, 0, 200, 255) h = h + self.font_h
	s:drawString(self.font, "Race:  "..game.player.descriptor.subrace, w, h, 0, 200, 255) h = h + self.font_h
	s:drawString(self.font, "Class: "..game.player.descriptor.subclass, w, h, 0, 200, 255) h = h + self.font_h
	h = h + self.font_h
	s:drawColorString(self.font, "Level: #00ff00#"..game.player.level, w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Exp:  #00ff00#%2d%%"):format(100 * cur_exp / max_exp), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Gold: #00ff00#%0.2f"):format(game.player.money), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h

	s:drawColorString(self.font, ("#c00000#Life:    #00ff00#%d/%d"):format(game.player.life, game.player.max_life), w, h, 255, 255, 255) h = h + self.font_h
	if game.player:knowTalent(game.player.T_STAMINA_POOL) then
		s:drawColorString(self.font, ("#ffcc80#Stamina: #00ff00#%d/%d"):format(game.player:getStamina(), game.player.max_stamina), w, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_MANA_POOL) then
		s:drawColorString(self.font, ("#7fffd4#Mana:    #00ff00#%d/%d"):format(game.player:getMana(), game.player.max_mana), w, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_SOUL_POOL) then
		s:drawColorString(self.font, ("#777777#Soul:    #00ff00#%d/%d"):format(game.player:getSoul(), game.player.max_soul), w, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_EQUILIBRIUM_POOL) then
		s:drawColorString(self.font, ("#00ff74#Equi:    #00ff00#%d"):format(game.player:getEquilibrium()), w, h, 255, 255, 255) h = h + self.font_h
	end

	h = h + self.font_h
	s:drawColorString(self.font, ("STR: #00ff00#%3d"):format(game.player:getStr()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("DEX: #00ff00#%3d"):format(game.player:getDex()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("MAG: #00ff00#%3d"):format(game.player:getMag()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("WIL: #00ff00#%3d"):format(game.player:getWil()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("CUN: #00ff00#%3d"):format(game.player:getCun()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("CON: #00ff00#%3d"):format(game.player:getCon()), w, h, 255, 255, 255) h = h + self.font_h

	h = 0
	w = 200
	-- All weapons in main hands
	if self.actor:getInven(self.actor.INVEN_MAINHAND) then
		for i, o in ipairs(self.actor:getInven(self.actor.INVEN_MAINHAND)) do
			if o.combat then
				s:drawColorString(self.font, ("Attack(Main Hand): #00ff00#%3d"):format(game.player:combatAttack(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("Damage(Main Hand): #00ff00#%3d"):format(game.player:combatDamage(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("APR   (Main Hand): #00ff00#%3d"):format(game.player:combatAPR(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("Crit  (Main Hand): #00ff00#%3d%%"):format(game.player:combatCrit(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("Speed (Main Hand): #00ff00#%0.2f"):format(game.player:combatSpeed(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
			end
		end
	end
	h = h + self.font_h
	-- All wpeaons in off hands
	-- Offhand atatcks are with a damage penality, taht can be reduced by talents
	if self.actor:getInven(self.actor.INVEN_OFFHAND) then
		local offmult = (mult or 1) / 2
		if self.actor:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
			offmult = (mult or 1) / (2 - (self.actor:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
		end
		for i, o in ipairs(self.actor:getInven(self.actor.INVEN_OFFHAND)) do
			if o.combat then
				s:drawColorString(self.font, ("Attack (Off Hand): #00ff00#%3d"):format(game.player:combatAttack(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("Damage (Off Hand): #00ff00#%3d"):format(game.player:combatDamage(o.combat) * offmult), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("APR    (Off Hand): #00ff00#%3d"):format(game.player:combatAPR(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("Crit   (Off Hand): #00ff00#%3d%%"):format(game.player:combatCrit(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorString(self.font, ("Speed  (Off Hand): #00ff00#%0.2f"):format(game.player:combatSpeed(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
			end
		end
	end
	h = h + self.font_h
	s:drawColorString(self.font, ("Spellpower:  #00ff00#%3d"):format(game.player:combatSpellpower()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Spell Crit:  #00ff00#%3d%%"):format(game.player:combatSpellCrit()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Spell Speed: #00ff00#%3d"):format(game.player:combatSpellSpeed()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.inc_damage[DamageType[t.type]] and self.actor.inc_damage[DamageType[t.type]] ~= 0 then
			s:drawColorString(self.font, ("%s damage: #00ff00#%3d%%"):format(t.name:capitalize(), self.actor.inc_damage[DamageType[t.type]]), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	h = 0
	w = 400
	s:drawColorString(self.font, ("Fatigue:        #00ff00#%3d%%"):format(game.player.fatigue), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Armor:          #00ff00#%3d"):format(game.player:combatArmor()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Defence:        #00ff00#%3d"):format(game.player:combatDefense()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Ranged Defence: #00ff00#%3d"):format(game.player:combatDefenseRanged()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	s:drawColorString(self.font, ("Physical Resist: #00ff00#%3d"):format(game.player:combatPhysicalResist()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Spell Resist:    #00ff00#%3d"):format(game.player:combatSpellResist()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Mental Resist:   #00ff00#%3d"):format(game.player:combatMentalResist()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.resists[DamageType[t.type]] and self.actor.resists[DamageType[t.type]] ~= 0 then
			s:drawColorString(self.font, ("%s Resist: #00ff00#%3d%%"):format(t.name:capitalize(), self.actor.resists[DamageType[t.type]]), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	h = 0
	w = 600
	s:drawColorString(self.font, "#LIGHT_BLUE#Current effects:", w, h, 255, 255, 255) h = h + self.font_h
	for tid, act in pairs(game.player.sustain_talents) do
		if act then s:drawColorString(self.font, ("#LIGHT_GREEN#%s"):format(game.player:getTalentFromId(tid).name), w, h, 255, 255, 255) h = h + self.font_h end
	end
	for eff_id, p in pairs(game.player.tmp) do
		local e = game.player.tempeffect_def[eff_id]
		if e.status == "detrimental" then
			s:drawColorString(self.font, ("#LIGHT_RED#%s"):format(e.desc), w, h, 255, 255, 255) h = h + self.font_h
		else
			s:drawColorString(self.font, ("#LIGHT_GREEN#%s"):format(e.desc), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	self.changed = false
end

function _M:dump()
	fs.mkdir("/character-dumps")
	local file = "/character-dumps/"..(game.player.name:gsub("[^a-zA-Z0-9_-.]", "_")).."-"..os.date("%Y%m%d-%H%M%S")..".txt"
	local fff = fs.open(file, "w")
	local nl = function(s) fff:write(s or "") fff:write("\n") end
	local nnl = function(s) fff:write(s or "") end

	nl("Sex:   "..game.player.descriptor.sex)
	nl("Race:  "..game.player.descriptor.subrace)
	nl("Class: "..game.player.descriptor.subclass)
	nl("Level: "..game.player.level)

	nl()
	local cur_exp, max_exp = game.player.exp, game.player:getExpChart(game.player.level+1)
	nl(("Exp:  %2d%%"):format(100 * cur_exp / max_exp))
	nl(("Gold: %0.2f"):format(game.player.money))

	nl()
	nl(("Life:    %d/%d"):format(game.player.life, game.player.max_life))
	if game.player:knowTalent(game.player.T_STAMINA_POOL) then
		nl(("Stamina: %d/%d"):format(game.player:getStamina(), game.player.max_stamina))
	end
	if game.player:knowTalent(game.player.T_MANA_POOL) then
		nl(("Mana:    %d/%d"):format(game.player:getMana(), game.player.max_mana))
	end
	if game.player:knowTalent(game.player.T_SOUL_POOL) then
		nl(("Soul:    %d/%d"):format(game.player:getSoul(), game.player.max_soul))
	end
	if game.player:knowTalent(game.player.T_EQUILIBRIUM_POOL) then
		nl(("Equi:    %d"):format(game.player:getEquilibrium()))
	end

	nl()
	nl(("STR: %3d"):format(game.player:getStr()))
	nl(("DEX: %3d"):format(game.player:getDex()))
	nl(("MAG: %3d"):format(game.player:getMag()))
	nl(("WIL: %3d"):format(game.player:getWil()))
	nl(("CUN: %3d"):format(game.player:getCun()))
	nl(("CON: %3d"):format(game.player:getCon()))

	-- All weapons in main hands
	if self.actor:getInven(self.actor.INVEN_MAINHAND) then
		for i, o in ipairs(self.actor:getInven(self.actor.INVEN_MAINHAND)) do
			if o.combat then
				nl()
				nl(("Attack(Main Hand): %3d"):format(game.player:combatAttack(o.combat)))
				nl(("Damage(Main Hand): %3d"):format(game.player:combatDamage(o.combat)))
				nl(("APR   (Main Hand): %3d"):format(game.player:combatAPR(o.combat)))
				nl(("Crit  (Main Hand): %3d%%"):format(game.player:combatCrit(o.combat)))
				nl(("Speed (Main Hand): %0.2f"):format(game.player:combatSpeed(o.combat)))
			end
		end
	end

	-- All wpeaons in off hands
	-- Offhand atatcks are with a damage penality, taht can be reduced by talents
	if self.actor:getInven(self.actor.INVEN_OFFHAND) then
		local offmult = (mult or 1) / 2
		if self.actor:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
			offmult = (mult or 1) / (2 - (self.actor:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
		end
		for i, o in ipairs(self.actor:getInven(self.actor.INVEN_OFFHAND)) do
			if o.combat then
				nl()
				nl(("Attack (Off Hand): %3d"):format(game.player:combatAttack(o.combat)))
				nl(("Damage (Off Hand): %3d"):format(game.player:combatDamage(o.combat) * offmult))
				nl(("APR    (Off Hand): %3d"):format(game.player:combatAPR(o.combat)))
				nl(("Crit   (Off Hand): %3d%%"):format(game.player:combatCrit(o.combat)))
				nl(("Speed  (Off Hand): %0.2f"):format(game.player:combatSpeed(o.combat)))
			end
		end
	end

	nl()
	nl(("Spellpower:  %3d"):format(game.player:combatSpellpower()))
	nl(("Spell Crit:  %3d%%"):format(game.player:combatSpellCrit()))
	nl(("Spell Speed: %3d"):format(game.player:combatSpellSpeed()))

	nl()
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.inc_damage[DamageType[t.type]] and self.actor.inc_damage[DamageType[t.type]] ~= 0 then
			nl(("%s damage: %3d%%"):format(t.name:capitalize(), self.actor.inc_damage[DamageType[t.type]]))
		end
	end

	nl()
	nl(("Fatigue:        %3d%%"):format(game.player.fatigue))
	nl(("Armor:          %3d"):format(game.player:combatArmor()))
	nl(("Defence:        %3d"):format(game.player:combatDefense()))
	nl(("Ranged Defence: %3d"):format(game.player:combatDefenseRanged()))

	nl()
	nl(("Physical Resist: %3d"):format(game.player:combatPhysicalResist()))
	nl(("Spell Resist:    %3d"):format(game.player:combatSpellResist()))
	nl(("Mental Resist:   %3d"):format(game.player:combatMentalResist()))

	nl()
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.resists[DamageType[t.type]] and self.actor.resists[DamageType[t.type]] ~= 0 then
			nl(("%s Resist: %3d%%"):format(t.name:capitalize(), self.actor.resists[DamageType[t.type]]))
		end
	end

	nl()
	local most_kill, most_kill_max = "none", 0
	local total_kill = 0
	for name, nb in pairs(game.player.all_kills or {}) do
		if nb > most_kill_max then most_kill_max = nb most_kill = name end
		total_kill = total_kill + nb
	end
	nl(("Number of NPC killed: %s"):format(total_kill))
	nl(("Most killed NPC: %s (%d)"):format(most_kill, most_kill_max))

	fff:close()

	Dialog:simplePopup("Character dump complete", "File: "..fs.getRealPath(file))
end
