-- ToME - Tales of Maj'Eyal
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
require "mod.class.interface.TooltipsData"
local Dialog = require "engine.Dialog"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"

module(..., package.seeall, class.inherit(engine.Dialog, mod.class.interface.TooltipsData))

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
	self:mouseZones{
	}
end

function _M:mouseTooltip(text, _, _, _, w, h, x, y)
	self:mouseZones({
		{ x=x, y=y, w=w, h=h, fct=function(button) game.tooltip_x, game.tooltip_y = 1, 1; game.tooltip:displayAtMap(nil, nil, game.w, game.h, text) end},
	}, true)
end

function _M:drawDialog(s)
	self.mouse:reset()
	self:mouseZones({
		{ x=0, y=0, w=game.w, h=game.h, norestrict=true, fct=function(button, _, _, _, _, _, _, event) game.tooltip_x, game.tooltip_y = nil, nil; if button == "left" and event == "button" then game:unregisterDialog(self) end end},
	}, true)

	local player = self.actor
	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)

	local h = 0
	local w = 0
	s:drawStringBlended(self.font, "Sex:   "..(player.descriptor.sex or (player.female and "Female" or "Male")), w, h, 0, 200, 255) h = h + self.font_h
	s:drawStringBlended(self.font, "Race:  "..(player.descriptor.subrace or player.type:capitalize()), w, h, 0, 200, 255) h = h + self.font_h
	s:drawStringBlended(self.font, "Class: "..(player.descriptor.subclass or player.subtype:capitalize()), w, h, 0, 200, 255) h = h + self.font_h
	h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_LEVEL, s:drawColorStringBlended(self.font, "Level: #00ff00#"..player.level, w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_LEVEL, s:drawColorStringBlended(self.font, ("Exp:  #00ff00#%2d%%"):format(100 * cur_exp / max_exp), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_GOLD, s:drawColorStringBlended(self.font, ("Gold: #00ff00#%0.2f"):format(player.money), w, h, 255, 255, 255)) h = h + self.font_h

	h = h + self.font_h

	self:mouseTooltip(self.TOOLTIP_LIFE, s:drawColorStringBlended(self.font, ("#c00000#Life:    #00ff00#%d/%d"):format(player.life, player.max_life), w, h, 255, 255, 255)) h = h + self.font_h
	if player:knowTalent(player.T_STAMINA_POOL) then
		self:mouseTooltip(self.TOOLTIP_STAMINA, s:drawColorStringBlended(self.font, ("#ffcc80#Stamina: #00ff00#%d/%d"):format(player:getStamina(), player.max_stamina), w, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_MANA_POOL) then
		self:mouseTooltip(self.TOOLTIP_MANA, s:drawColorStringBlended(self.font, ("#7fffd4#Mana:    #00ff00#%d/%d"):format(player:getMana(), player.max_mana), w, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_POSITIVE_POOL) then
		self:mouseTooltip(self.TOOLTIP_POSITIVE, s:drawColorStringBlended(self.font, ("#7fffd4#Positive:#00ff00#%d/%d"):format(player:getPositive(), player.max_positive), w, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		self:mouseTooltip(self.TOOLTIP_NEGATIVE, s:drawColorStringBlended(self.font, ("#7fffd4#Negative:#00ff00#%d/%d"):format(player:getNegative(), player.max_negative), w, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_VIM_POOL) then
		self:mouseTooltip(self.TOOLTIP_VIM, s:drawColorStringBlended(self.font, ("#904010#Vim:     #00ff00#%d/%d"):format(player:getVim(), player.max_vim), w, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		self:mouseTooltip(self.TOOLTIP_EQUILIBRIUM, s:drawColorStringBlended(self.font, ("#00ff74#Equi:    #00ff00#%d"):format(player:getEquilibrium()), w, h, 255, 255, 255)) h = h + self.font_h
	end
	if player:knowTalent(player.T_HATE_POOL) then
		self:mouseTooltip(self.TOOLTIP_HATE, s:drawColorStringBlended(self.font, ("#F53CBE#Hate:    #00ff00#%.1f/%d"):format(player:getHate(), 10), w, h, 255, 255, 255)) h = h + self.font_h
	end

	h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_STR, s:drawColorStringBlended(self.font, ("STR: #00ff00#%3d"):format(player:getStr()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_DEX, s:drawColorStringBlended(self.font, ("DEX: #00ff00#%3d"):format(player:getDex()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_MAG, s:drawColorStringBlended(self.font, ("MAG: #00ff00#%3d"):format(player:getMag()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_WIL, s:drawColorStringBlended(self.font, ("WIL: #00ff00#%3d"):format(player:getWil()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_CUN, s:drawColorStringBlended(self.font, ("CUN: #00ff00#%3d"):format(player:getCun()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_CON, s:drawColorStringBlended(self.font, ("CON: #00ff00#%3d"):format(player:getCon()), w, h, 255, 255, 255)) h = h + self.font_h

	h = 0
	w = 200
	-- All weapons in main hands
	if player:getInven(player.INVEN_MAINHAND) then
		for i, o in ipairs(player:getInven(player.INVEN_MAINHAND)) do
			if o.combat then
				self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Attack(Main Hand): #00ff00#%3d"):format(player:combatAttack(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage(Main Hand): #00ff00#%3d"):format(player:combatDamage(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_APR,    s:drawColorStringBlended(self.font, ("APR   (Main Hand): #00ff00#%3d"):format(player:combatAPR(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT,   s:drawColorStringBlended(self.font, ("Crit  (Main Hand): #00ff00#%3d%%"):format(player:combatCrit(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED,  s:drawColorStringBlended(self.font, ("Speed (Main Hand): #00ff00#%0.2f"):format(player:combatSpeed(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
			end
		end
	end
	h = h + self.font_h
	-- All wpeaons in off hands
	-- Offhand atatcks are with a damage penality, taht can be reduced by talents
	if player:getInven(player.INVEN_OFFHAND) then
		local offmult = (mult or 1) / 2
		if player:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
			offmult = (mult or 1) / (2 - (player:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
		end
		for i, o in ipairs(player:getInven(player.INVEN_OFFHAND)) do
			if o.combat then
				self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Attack (Off Hand): #00ff00#%3d"):format(player:combatAttack(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage (Off Hand): #00ff00#%3d"):format(player:combatDamage(o.combat) * offmult), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_APR   , s:drawColorStringBlended(self.font, ("APR    (Off Hand): #00ff00#%3d"):format(player:combatAPR(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT  , s:drawColorStringBlended(self.font, ("Crit   (Off Hand): #00ff00#%3d%%"):format(player:combatCrit(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
				self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED , s:drawColorStringBlended(self.font, ("Speed  (Off Hand): #00ff00#%0.2f"):format(player:combatSpeed(o.combat)), w, h, 255, 255, 255)) h = h + self.font_h
			end
		end
	end
	h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_SPELL_POWER, s:drawColorStringBlended(self.font, ("Spellpower:  #00ff00#%3d"):format(player:combatSpellpower()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_SPELL_CRIT, s:drawColorStringBlended(self.font, ("Spell Crit:  #00ff00#%3d%%"):format(player:combatSpellCrit()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_SPELL_SPEED, s:drawColorStringBlended(self.font, ("Spell Speed: #00ff00#%3d"):format(player:combatSpellSpeed()), w, h, 255, 255, 255)) h = h + self.font_h

	h = h + self.font_h
	if player.inc_damage.all then self:mouseTooltip(self.TOOLTIP_INC_DAMAGE_ALL, s:drawColorStringBlended(self.font, ("All damage: #00ff00#%3d%%"):format(player.inc_damage.all), w, h, 255, 255, 255)) h = h + self.font_h end
	for i, t in ipairs(DamageType.dam_def) do
		if player.inc_damage[DamageType[t.type]] and player.inc_damage[DamageType[t.type]] ~= 0 then
			self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("%s damage: #00ff00#%3d%%"):format(t.name:capitalize(), player.inc_damage[DamageType[t.type]] + (player.inc_damage.all or 0)), w, h, 255, 255, 255)) h = h + self.font_h
		end
	end

	h = 0
	w = 400
	self:mouseTooltip(self.TOOLTIP_FATIGUE, s:drawColorStringBlended(self.font, ("Fatigue:        #00ff00#%3d%%"):format(player.fatigue), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_ARMOR,   s:drawColorStringBlended(self.font, ("Armor:          #00ff00#%3d"):format(player:combatArmor()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_DEFENSE, s:drawColorStringBlended(self.font, ("Defense:        #00ff00#%3d"):format(player:combatDefense()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_RDEFENSE,s:drawColorStringBlended(self.font, ("Ranged Defense: #00ff00#%3d"):format(player:combatDefenseRanged()), w, h, 255, 255, 255)) h = h + self.font_h

	h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_PHYS_SAVE,   s:drawColorStringBlended(self.font, ("Physical Save: #00ff00#%3d"):format(player:combatPhysicalResist()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_SPELL_SAVE,  s:drawColorStringBlended(self.font, ("Spell Save:    #00ff00#%3d"):format(player:combatSpellResist()), w, h, 255, 255, 255)) h = h + self.font_h
	self:mouseTooltip(self.TOOLTIP_MENTAL_SAVE, s:drawColorStringBlended(self.font, ("Mental Save:   #00ff00#%3d"):format(player:combatMentalResist()), w, h, 255, 255, 255)) h = h + self.font_h

	h = h + self.font_h
	if player.resists.all then self:mouseTooltip(self.TOOLTIP_RESIST_ALL, s:drawColorStringBlended(self.font, ("All Resists(cap): #00ff00#%3d%%(%3d%%)"):format(player.resists.all, player.resists_cap.all or 0), w, h, 255, 255, 255)) h = h + self.font_h end
	for i, t in ipairs(DamageType.dam_def) do
		if player.resists[DamageType[t.type]] and player.resists[DamageType[t.type]] ~= 0 then
			self:mouseTooltip(self.TOOLTIP_RESIST, s:drawColorStringBlended(self.font, ("%s Resist(cap): #00ff00#%3d%%(%3d%%)"):format(t.name:capitalize(), player.resists[DamageType[t.type]] + (player.resists.all or 0), (player.resists_cap[DamageType[t.type]] or 0) + (player.resists_cap.all or 0)), w, h, 255, 255, 255)) h = h + self.font_h
		end
	end

	immune_type = "poison_immune" immune_name = "Poison Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "cut_immune" immune_name = "Bleed Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "confusion_immune" immune_name = "Confusion Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "blind_immune" immune_name = "Blind Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "silence_immune" immune_name = "Silence Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "disarm_immune" immune_name = "Disarm Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "pin_immune" immune_name = "Pinning Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "stun_immune" immune_name = "Stun Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "fear_immune" immune_name = "Fear Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "knockback_immune" immune_name = "Knockback Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "stone_immune" immune_name = "Stoning Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "instakill_immune" immune_name = "Instadeath Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end
	immune_type = "teleport_immune" immune_name = "Teleport Resistance" if player:attr(immune_type) then self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100)), w, h, 255, 255, 255)) h = h + self.font_h end

	h = 0
	w = 600
	s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Current effects:", w, h, 255, 255, 255) h = h + self.font_h
	for tid, act in pairs(player.sustain_talents) do
		if act then
			local t = player:getTalentFromId(tid)
			local desc = "#GOLD##{bold}#"..t.name.."#{normal}##WHITE#\n"..tostring(player:getTalentFullDescription(t))
			self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(player:getTalentFromId(tid).name), w, h, 255, 255, 255)) h = h + self.font_h
		end
	end
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		local desc = e.long_desc(player, p)
		if e.status == "detrimental" then
			self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_RED#%s"):format(e.desc), w, h, 255, 255, 255)) h = h + self.font_h
		else
			self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(e.desc), w, h, 255, 255, 255)) h = h + self.font_h
		end
	end

	self.changed = false
end

function _M:dump()
	local player = self.actor

	fs.mkdir("/character-dumps")
	local file = "/character-dumps/"..(player.name:gsub("[^a-zA-Z0-9_-.]", "_")).."-"..os.date("%Y%m%d-%H%M%S")..".txt"
	local fff = fs.open(file, "w")
	local labelwidth = 17
	local nl = function(s) s = s or "" fff:write(s:removeColorCodes()) fff:write("\n") end
	local nnl = function(s) s = s or "" fff:write(s:removeColorCodes()) end
	--prepare label and value
	local makelabel = function(s,r) while s:len() < labelwidth do s = s.." " end return ("%s: %s"):format(s, r) end

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
	nl("  [Tome 4.00 @ www.te4.org Character Dump]")
	nl()

	nnl(("%-32s"):format(makelabel("Sex", player.descriptor.sex or (player.female and "Female" or "Male"))))
	nl(("STR:  %d"):format(player:getStr()))

	nnl(("%-32s"):format(makelabel("Race", player.descriptor.subrace or player.type:capitalize())))
	nl(("DEX:  %d"):format(player:getDex()))

	nnl(("%-32s"):format(makelabel("Class", player.descriptor.subclass or player.subtype:capitalize())))
	nl(("MAG:  %d"):format(player:getMag()))

	nnl(("%-32s"):format(makelabel("Level", ("%d"):format(player.level))))
	nl(("WIL:  %d"):format(player:getWil()))

	nnl(("%-32s"):format(makelabel("Exp", ("%d%%"):format(100 * cur_exp / max_exp))))
	nl(("CUN:  %d"):format(player:getCun()))

	nnl(("%-32s"):format(makelabel("Gold", ("%.2f"):format(player.money))))
	nl(("CON:  %d"):format(player:getCon()))

	 -- All weapons in main hands

	local strings = {}
	for i = 1, 5 do strings[i]="" end
	if player:getInven(player.INVEN_MAINHAND) then
		for i, o in ipairs(player:getInven(player.INVEN_MAINHAND)) do
			if o.combat then
				strings[1] = ("Attack(Main Hand): %3d"):format(player:combatAttack(o.combat))
				strings[2] = ("Damage(Main Hand): %3d"):format(player:combatDamage(o.combat))
				strings[3] = ("APR   (Main Hand): %3d"):format(player:combatAPR(o.combat))
				strings[4] = ("Crit  (Main Hand): %3d%%"):format(player:combatCrit(o.combat))
				strings[5] = ("Speed (Main Hand): %0.2f"):format(player:combatSpeed(o.combat))
			end
		end
	end

	local enc, max = player:getEncumbrance(), player:getMaxEncumbrance()

	nl()
	nnl(("%-32s"):format(strings[1]))
	nnl(("%-32s"):format(makelabel("Life", ("    %d/%d"):format(player.life, player.max_life))))
	nl(makelabel("Encumbrance", enc .. "/" .. max))

	nnl(("%-32s"):format(strings[2]))
	if player:knowTalent(player.T_STAMINA_POOL) then
		nnl(("%-32s"):format(makelabel("Stamina", ("    %d/%d"):format(player:getStamina(), player.max_stamina))))
	else
		 nnl(("%-32s"):format(" "))
	end
	nl(makelabel("Difficulty", player.descriptor.difficulty))

	nnl(("%-32s"):format(strings[3]))
	if player:knowTalent(player.T_MANA_POOL) then
		nl(makelabel("Mana", ("    %d/%d"):format(player:getMana(), player.max_mana)))
	else
		nl()
	end
	nnl(("%-32s"):format(strings[4]))
	if player:knowTalent(player.T_POSITIVE_POOL) then
		nl(makelabel("Positive", ("    %d/%d"):format(player:getPositive(), player.max_positive)))
	else
		nl()
	end
	nnl(("%-32s"):format(strings[5]))
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		nl(makelabel("Negative", ("    %d/%d"):format(player:getNegative(), player.max_negative)))
	else
		nl()
	end
	nnl(("%-32s"):format(""))
	if player:knowTalent(player.T_VIM_POOL) then
		nl(makelabel("Vim", ("    %d/%d"):format(player:getVim(), player.max_vim)))
	else
		nl()
	end
	nnl(("%-32s"):format(""))
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		nl((makelabel("Equilibrium", ("    %d"):format(player:getEquilibrium()))))
	else
		nl()
	end

	-- All wpeaons in off hands
	-- Offhand atatcks are with a damage penality, taht can be reduced by talents
	if player:getInven(player.INVEN_OFFHAND) then
		local offmult = (mult or 1) / 2
		if player:knowTalent(Talents.T_DUAL_WEAPON_TRAINING) then
			offmult = (mult or 1) / (2 - (player:getTalentLevel(Talents.T_DUAL_WEAPON_TRAINING) / 6))
		end
		for i, o in ipairs(player:getInven(player.INVEN_OFFHAND)) do
			if o.combat then
				nl()
				nl(("Attack (Off Hand): %3d"):format(player:combatAttack(o.combat)))
				nl(("Damage (Off Hand): %3d"):format(player:combatDamage(o.combat) * offmult))
				nl(("APR    (Off Hand): %3d"):format(player:combatAPR(o.combat)))
				nl(("Crit   (Off Hand): %3d%%"):format(player:combatCrit(o.combat)))
				nl(("Speed  (Off Hand): %0.2f"):format(player:combatSpeed(o.combat)))
			end
		end
	end

	nl()
	nnl(("%-32s"):format(makelabel("Fatigue", player.fatigue .. "%")))
	nl(makelabel("Spellpower", player:combatSpellpower() ..""))
	nnl(("%-32s"):format(makelabel("Armor", player:combatArmor() .. "")))
	nl(makelabel("Spell Crit", player:combatSpellCrit() .."%"))
	nnl(("%-32s"):format(makelabel("Defense", player:combatDefense() .. "")))
	nl(makelabel("Spell Speed", player:combatSpellSpeed() ..""))
	nnl(("%-32s"):format(makelabel("Ranged Defense", player:combatDefenseRanged() .. "")))
	nl()

	nl()
	if player.inc_damage.all then nl(makelabel("All damage", player.inc_damage.all.."%")) end
	for i, t in ipairs(DamageType.dam_def) do
		if player.inc_damage[DamageType[t.type]] and player.inc_damage[DamageType[t.type]] ~= 0 then
			nl(makelabel(t.name:capitalize().." damage", (player.inc_damage[DamageType[t.type]] + (player.inc_damage.all or 0)).."%"))
		end
	end

	nl()
	nl(makelabel("Physical Save",player:combatPhysicalResist() ..""))
	nl(makelabel("Spell Save",player:combatSpellResist() ..""))
	nl(makelabel("Mental Save",player:combatMentalResist() ..""))

	nl()
	if player.resists.all then nl(("All Resists: %3d%%"):format(player.resists.all, player.resists_cap.all or 0)) end
	for i, t in ipairs(DamageType.dam_def) do
		if player.resists[DamageType[t.type]] and player.resists[DamageType[t.type]] ~= 0 then
			nl(("%s Resist(cap): %3d%%(%3d%%)"):format(t.name:capitalize(), player.resists[DamageType[t.type]] + (player.resists.all or 0), (player.resists_cap[DamageType[t.type]] or 0) + (player.resists_cap.all or 0)))
		end
	end

	immune_type = "poison_immune" immune_name = "Poison Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "cut_immune" immune_name = "Bleed Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "confusion_immune" immune_name = "Confusion Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "blind_immune" immune_name = "Blind Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "silence_immune" immune_name = "Silence Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "disarm_immune" immune_name = "Disarm Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "pin_immune" immune_name = "Pinning Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "stun_immune" immune_name = "Stun Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "fear_immune" immune_name = "Fear Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "knockback_immune" immune_name = "Knockback Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "stone_immune" immune_name = "Stoning Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "instakill_immune" immune_name = "Instadeath Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "teleport_immune" immune_name = "Teleport Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end

	nl()
	local most_kill, most_kill_max = "none", 0
	local total_kill = 0
	for name, nb in pairs(player.all_kills or {}) do
		if nb > most_kill_max then most_kill_max = nb most_kill = name end
		total_kill = total_kill + nb
	end
	nl(("Number of NPC killed: %s"):format(total_kill))
	nl(("Most killed NPC: %s (%d)"):format(most_kill, most_kill_max))

	if player.winner then
		nl()
		nl("  [Winner!]")
		nl()
		for i, line in ipairs(player.winner_text) do
			nl(("%s"):format(line:removeColorCodes()))
		end
	end

	-- Talents
	nl()
	nl("  [Talents Chart]")
	nl()

	for i, tt in ipairs(player.talents_types_def) do
		 local ttknown = player:knowTalentType(tt.type)
		if not (player.talents_types[tt.type] == nil) and ttknown then
			local cat = tt.type:gsub("/.*", "")
			local catname = ("%s / %s"):format(cat:capitalize(), tt.name:capitalize())
			nl((" - %-35s(mastery %.02f)"):format(catname, player:getTalentTypeMastery(tt.type)))

			-- Find all talents of this school
			if (ttknown) then
				for j, t in ipairs(tt.talents) do
					if not t.hide then
						local typename = "class"
						if t.generic then typename = "generic" end
						local skillname = ("    %s (%s)"):format(t.name, typename)
						nl(("%-37s %d/%d"):format(skillname, player:getTalentLevelRaw(t.id), t.points))
					end
				end
			end
		end
	end

	 -- Current Effects

	 nl()
	 nl("  [Current Effects]")
	 nl()

	for tid, act in pairs(player.sustain_talents) do
		if act then nl("- "..player:getTalentFromId(tid).name)	end
	end
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		if e.status == "detrimental" then
			 nl("+ "..e.desc)
		else
			 nl("- "..e.desc)
		end
	end

	-- Quests, Active and Completed

	local first = true
	for id, q in pairs(player.quests or {}) do
		if q:isEnded() then
			if first then
					nl()
					nl("  [Completed Quests]")
					nl()
					first=false
			end
			nl(" -- ".. q.name)
			nl(q:desc(player):gsub("#.-#", "   "))
		end
	end

	 first=true
	for id, q in pairs(player.quests or {}) do
		if not q:isEnded() then
			if first then
					first=false
					nl()
					nl("  [Active Quests]")
					nl()
				end
			nl(" -- ".. q.name)
			nl(q:desc(player):gsub("#.-#", "   "))
		end
	end


	--All Equipment
	nl()
	nl("  [Character Equipment]")
	nl()
	local index = 0
	for inven_id =  1, #player.inven_def do
		if player.inven[inven_id] and player.inven_def[inven_id].is_worn then
			nl((" %s"):format(player.inven_def[inven_id].name))

			for item, o in ipairs(player.inven[inven_id]) do
				if not self.filter or self.filter(o) then
					local char = string.char(string.byte('a') + index)
					nl(("%s) %s"):format(char, o:getName{force_id=true}))
					nl(("   %s"):format(tostring(o:getTextualDesc())))
					if o.droppedBy then
						nl(("   Dropped by %s"):format(o.droppedBy))
					end
					index = index + 1
				end
			end
		end
	end

	nl()
	nl("  [Player Achievements]")
	nl()
	local achs = {}
	for id, data in pairs(player.achievements or {}) do
		local a = world:getAchievementFromId(id)
		achs[#achs+1] = {id=id, data=data, name=a.name}
	end
	table.sort(achs, function(a, b) return a.name < b.name end)
	for i, d in ipairs(achs) do
		local a = world:getAchievementFromId(d.id)
		nl(("'%s' was achieved for %s At %s"):format(a.name, a.desc, d.data.when))
	end

	nl()
	nl("  [Character Inventory]")
	nl()
	for item, o in ipairs(player:getInven("INVEN")) do
		if not self.filter or self.filter(o) then
			local char = string.char(string.byte('a') + item - 1)
			nl(("%s) %s"):format(char, o:getName{force_id=true}))
			nl(("   %s"):format(tostring(o:getTextualDesc())))
			if o.droppedBy then
				nl(("   Dropped by %s"):format(o.droppedBy))
			end
		end
	end

	nl()
	nl("  [Last Messages]")
	nl()

	nl(table.concat(game.logdisplay:getLines(40), "\n"):removeColorCodes())

	fff:close()

	Dialog:simplePopup("Character dump complete", "File: "..fs.getRealPath(file))
end
