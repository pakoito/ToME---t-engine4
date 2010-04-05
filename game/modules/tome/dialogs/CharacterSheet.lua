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
require "engine.Dialog"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(actor)
	self.actor = actor
	engine.Dialog.init(self, "Character Sheet: "..self.actor.name, 800, 400, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:keyCommands(nil, {
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
	s:drawColorString(self.font, ("Spell Crit:  #00ff00#%3d"):format(game.player:combatSpellCrit()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorString(self.font, ("Spell Speed: #00ff00#%3d"):format(game.player:combatSpellSpeed()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.inc_damage[DamageType[t.type]] then
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
		if self.actor.resists[DamageType[t.type]] then
			s:drawColorString(self.font, ("%s Resist: #00ff00#%3d%%"):format(t.name:capitalize(), self.actor.resists[DamageType[t.type]]), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	h = 0
	w = 600
	s:drawColorString(self.font, ("#LIGHT_BLUE#Current effects:"):format(game.player.fatigue), w, h, 255, 255, 255) h = h + self.font_h
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
