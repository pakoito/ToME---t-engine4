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
	s:drawStringBlended(self.font, "Sex:   "..game.player.descriptor.sex, w, h, 0, 200, 255) h = h + self.font_h
	s:drawStringBlended(self.font, "Race:  "..game.player.descriptor.subrace, w, h, 0, 200, 255) h = h + self.font_h
	s:drawStringBlended(self.font, "Class: "..game.player.descriptor.subclass, w, h, 0, 200, 255) h = h + self.font_h
	h = h + self.font_h
	s:drawColorStringBlended(self.font, "Level: #00ff00#"..game.player.level, w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Exp:  #00ff00#%2d%%"):format(100 * cur_exp / max_exp), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Gold: #00ff00#%0.2f"):format(game.player.money), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h

	s:drawColorStringBlended(self.font, ("#c00000#Life:    #00ff00#%d/%d"):format(game.player.life, game.player.max_life), w, h, 255, 255, 255) h = h + self.font_h
	if game.player:knowTalent(game.player.T_STAMINA_POOL) then
		s:drawColorStringBlended(self.font, ("#ffcc80#Stamina: #00ff00#%d/%d"):format(game.player:getStamina(), game.player.max_stamina), w, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_MANA_POOL) then
		s:drawColorStringBlended(self.font, ("#7fffd4#Mana:    #00ff00#%d/%d"):format(game.player:getMana(), game.player.max_mana), w, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_SOUL_POOL) then
		s:drawColorStringBlended(self.font, ("#777777#Soul:    #00ff00#%d/%d"):format(game.player:getSoul(), game.player.max_soul), w, h, 255, 255, 255) h = h + self.font_h
	end
	if game.player:knowTalent(game.player.T_EQUILIBRIUM_POOL) then
		s:drawColorStringBlended(self.font, ("#00ff74#Equi:    #00ff00#%d"):format(game.player:getEquilibrium()), w, h, 255, 255, 255) h = h + self.font_h
	end

	h = h + self.font_h
	s:drawColorStringBlended(self.font, ("STR: #00ff00#%3d"):format(game.player:getStr()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("DEX: #00ff00#%3d"):format(game.player:getDex()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("MAG: #00ff00#%3d"):format(game.player:getMag()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("WIL: #00ff00#%3d"):format(game.player:getWil()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("CUN: #00ff00#%3d"):format(game.player:getCun()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("CON: #00ff00#%3d"):format(game.player:getCon()), w, h, 255, 255, 255) h = h + self.font_h

	h = 0
	w = 200
	-- All weapons in main hands
	if self.actor:getInven(self.actor.INVEN_MAINHAND) then
		for i, o in ipairs(self.actor:getInven(self.actor.INVEN_MAINHAND)) do
			if o.combat then
				s:drawColorStringBlended(self.font, ("Attack(Main Hand): #00ff00#%3d"):format(game.player:combatAttack(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("Damage(Main Hand): #00ff00#%3d"):format(game.player:combatDamage(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("APR   (Main Hand): #00ff00#%3d"):format(game.player:combatAPR(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("Crit  (Main Hand): #00ff00#%3d%%"):format(game.player:combatCrit(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("Speed (Main Hand): #00ff00#%0.2f"):format(game.player:combatSpeed(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
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
				s:drawColorStringBlended(self.font, ("Attack (Off Hand): #00ff00#%3d"):format(game.player:combatAttack(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("Damage (Off Hand): #00ff00#%3d"):format(game.player:combatDamage(o.combat) * offmult), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("APR    (Off Hand): #00ff00#%3d"):format(game.player:combatAPR(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("Crit   (Off Hand): #00ff00#%3d%%"):format(game.player:combatCrit(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
				s:drawColorStringBlended(self.font, ("Speed  (Off Hand): #00ff00#%0.2f"):format(game.player:combatSpeed(o.combat)), w, h, 255, 255, 255) h = h + self.font_h
			end
		end
	end
	h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Spellpower:  #00ff00#%3d"):format(game.player:combatSpellpower()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Spell Crit:  #00ff00#%3d%%"):format(game.player:combatSpellCrit()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Spell Speed: #00ff00#%3d"):format(game.player:combatSpellSpeed()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	if self.actor.inc_damage.all then s:drawColorStringBlended(self.font, ("All damage: #00ff00#%3d%%"):format(self.actor.inc_damage.all), w, h, 255, 255, 255) h = h + self.font_h end
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.inc_damage[DamageType[t.type]] and self.actor.inc_damage[DamageType[t.type]] ~= 0 then
			s:drawColorStringBlended(self.font, ("%s damage: #00ff00#%3d%%"):format(t.name:capitalize(), self.actor.inc_damage[DamageType[t.type]]), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	h = 0
	w = 400
	s:drawColorStringBlended(self.font, ("Fatigue:        #00ff00#%3d%%"):format(game.player.fatigue), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Armor:          #00ff00#%3d"):format(game.player:combatArmor()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Defense:        #00ff00#%3d"):format(game.player:combatDefense()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Ranged Defense: #00ff00#%3d"):format(game.player:combatDefenseRanged()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Physical Resist: #00ff00#%3d"):format(game.player:combatPhysicalResist()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Spell Resist:    #00ff00#%3d"):format(game.player:combatSpellResist()), w, h, 255, 255, 255) h = h + self.font_h
	s:drawColorStringBlended(self.font, ("Mental Resist:   #00ff00#%3d"):format(game.player:combatMentalResist()), w, h, 255, 255, 255) h = h + self.font_h

	h = h + self.font_h
	if self.actor.resists.all then s:drawColorStringBlended(self.font, ("All Resists: #00ff00#%3d%%"):format(self.actor.resists.all), w, h, 255, 255, 255) h = h + self.font_h end
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.resists[DamageType[t.type]] and self.actor.resists[DamageType[t.type]] ~= 0 then
			s:drawColorStringBlended(self.font, ("%s Resist: #00ff00#%3d%%"):format(t.name:capitalize(), self.actor.resists[DamageType[t.type]]), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	h = 0
	w = 600
	s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Current effects:", w, h, 255, 255, 255) h = h + self.font_h
	for tid, act in pairs(game.player.sustain_talents) do
		if act then s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(game.player:getTalentFromId(tid).name), w, h, 255, 255, 255) h = h + self.font_h end
	end
	for eff_id, p in pairs(game.player.tmp) do
		local e = game.player.tempeffect_def[eff_id]
		if e.status == "detrimental" then
			s:drawColorStringBlended(self.font, ("#LIGHT_RED#%s"):format(e.desc), w, h, 255, 255, 255) h = h + self.font_h
		else
			s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(e.desc), w, h, 255, 255, 255) h = h + self.font_h
		end
	end

	self.changed = false
end

function _M:dump()
	fs.mkdir("/character-dumps")
	local file = "/character-dumps/"..(game.player.name:gsub("[^a-zA-Z0-9_-.]", "_")).."-"..os.date("%Y%m%d-%H%M%S")..".txt"
	local fff = fs.open(file, "w")
	local labelwidth = 17
	local nl = function(s) fff:write(s or "") fff:write("\n") end
	local nnl = function(s) fff:write(s or "") end
	--prepare label and value
	local makelabel = function(s,r) while s:len() < labelwidth do s = s.." " end return ("%s: %s"):format(s, r) end

	local cur_exp, max_exp = game.player.exp, game.player:getExpChart(game.player.level+1)
	nl("  [Tome 4.00 @ www.te4.org Character Dump]")
	nl()

	nnl(("%-32s"):format(makelabel("Sex", game.player.descriptor.sex)))
	nl(("STR:  %d"):format(game.player:getStr()))

	nnl(("%-32s"):format(makelabel("Race", game.player.descriptor.subrace)))
	nl(("DEX:  %d"):format(game.player:getDex()))

	nnl(("%-32s"):format(makelabel("Class", game.player.descriptor.subclass)))
	nl(("MAG:  %d"):format(game.player:getMag()))

	nnl(("%-32s"):format(makelabel("Level", ("%d"):format(game.player.level))))
	nl(("WIL:  %d"):format(game.player:getWil()))

	nnl(("%-32s"):format(makelabel("Exp", ("%d%%"):format(100 * cur_exp / max_exp))))
	nl(("CUN:  %d"):format(game.player:getCun()))

	 nnl(("%-32s"):format(makelabel("Gold", ("%.2f"):format(game.player.money))))
	nl(("CON:  %d"):format(game.player:getCon()))

	 -- All weapons in main hands

	local strings = {}
	for i = 1, 5 do strings[i]="" end
	if self.actor:getInven(self.actor.INVEN_MAINHAND) then
		for i, o in ipairs(self.actor:getInven(self.actor.INVEN_MAINHAND)) do
			if o.combat then
				strings[1] = ("Attack(Main Hand): %3d"):format(game.player:combatAttack(o.combat))
				strings[2] = ("Damage(Main Hand): %3d"):format(game.player:combatDamage(o.combat))
				strings[3] = ("APR	(Main Hand): %3d"):format(game.player:combatAPR(o.combat))
				strings[4] = ("Crit  (Main Hand): %3d%%"):format(game.player:combatCrit(o.combat))
				strings[5] = ("Speed (Main Hand): %0.2f"):format(game.player:combatSpeed(o.combat))
			end
		end
	end

	local enc, max = game.player:getEncumbrance(), game.player:getMaxEncumbrance()

	nl()
	nnl(("%-32s"):format(strings[1]))
	nnl(("%-32s"):format(makelabel("Life", ("    %d/%d"):format(game.player.life, game.player.max_life))))
	nl(makelabel("Encumbrance", enc .. "/" .. max))

	nnl(("%-32s"):format(strings[2]))
	if game.player:knowTalent(game.player.T_STAMINA_POOL) then
		nnl(("%-32s"):format(makelabel("Stamina", ("    %d/%d"):format(game.player:getStamina(), game.player.max_stamina))))
	else
		 nnl(("%-32s"):format(" "))
	end
	nl(makelabel("Difficulty", game.player.descriptor.difficulty))

	nnl(("%-32s"):format(strings[3]))
	if game.player:knowTalent(game.player.T_MANA_POOL) then
		nl(makelabel("Mana", ("    %d/%d"):format(game.player:getMana(), game.player.max_mana)))
	else
		nl()
	end
	nnl(("%-32s"):format(strings[4]))
	if game.player:knowTalent(game.player.T_SOUL_POOL) then
		nl(makelabel("Soul", ("    %d/%d"):format(game.player:getSoul(), game.player.max_soul)))
	 else
		nl()
	end
	nnl(("%-32s"):format(strings[5]))
	if game.player:knowTalent(game.player.T_EQUILIBRIUM_POOL) then
		nl((makelabel("Equilibrium", ("    %d"):format(game.player:getEquilibrium()))))
	else
		nl()
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
				nl(("APR	 (Off Hand): %3d"):format(game.player:combatAPR(o.combat)))
				nl(("Crit	(Off Hand): %3d%%"):format(game.player:combatCrit(o.combat)))
				nl(("Speed  (Off Hand): %0.2f"):format(game.player:combatSpeed(o.combat)))
			end
		end
	end

	nl()
	nnl(("%-32s"):format(makelabel("Fatigue", game.player.fatigue .. "%")))
	nl(makelabel("Spellpower", game.player:combatSpellpower() ..""))
	nnl(("%-32s"):format(makelabel("Armor", game.player:combatArmor() .. "")))
	nl(makelabel("Spell Crit", game.player:combatSpellCrit() .."%"))
	nnl(("%-32s"):format(makelabel("Defense", game.player:combatDefense() .. "")))
	nl(makelabel("Spell Speed", game.player:combatSpellSpeed() ..""))
	nnl(("%-32s"):format(makelabel("Ranged Defense", game.player:combatDefenseRanged() .. "")))
	nl()

	nl()
	if self.actor.inc_damage.all then nl(makelabel("All damage", self.actor.inc_damage.all.."%")) end
	for i, t in ipairs(DamageType.dam_def) do
		if self.actor.inc_damage[DamageType[t.type]] and self.actor.inc_damage[DamageType[t.type]] ~= 0 then
			nl(makelabel(t.name:capitalize().." damage", self.actor.inc_damage[DamageType[t.type]].."%"))
		end
	end

	nl()
	nl(makelabel("Physical Resist",game.player:combatPhysicalResist() ..""))
	nl(makelabel("Spell Resist",game.player:combatSpellResist() ..""))
	nl(makelabel("Mental Resist",game.player:combatMentalResist() ..""))

	nl()
	if self.actor.resists.all then nl(("All Resists: %3d%%"):format(self.actor.resists.all)) end
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

	-- Talents
	nl()
	nl("  [Talents Chart]")
	nl()

	for i, tt in ipairs(self.actor.talents_types_def) do
		 local ttknown = self.actor:knowTalentType(tt.type)
		if not (self.actor.talents_types[tt.type] == nil) and ttknown then
			local cat = tt.type:gsub("/.*", "")
			local catname = ("%s / %s"):format(cat:capitalize(), tt.name:capitalize())
			nl((" - %-35s(mastery %.02f)"):format(catname, self.actor:getTalentTypeMastery(tt.type)))

			-- Find all talents of this school
			if (ttknown) then
				for j, t in ipairs(tt.talents) do
					if not t.hide then
						local typename = "class"
						if t.skill then typename = "generic" end
						local skillname = ("    %s (%s)"):format(t.name, typename)
						nl(("%-37s %d/%d"):format(skillname, self.actor:getTalentLevelRaw(t.id), t.points))
					end
				end
			end
		end
	end

	 -- Current Effects

	 nl()
	 nl("  [Current Effects]")
	 nl()

	for tid, act in pairs(game.player.sustain_talents) do
		if act then nl("- "..game.player:getTalentFromId(tid).name)	end
	end
	for eff_id, p in pairs(game.player.tmp) do
		local e = game.player.tempeffect_def[eff_id]
		if e.status == "detrimental" then
			 nl("+ "..e.desc)
		else
			 nl("- "..e.desc)
		end
	end

	-- Quests, Active and Completed

	local first = true
	for id, q in pairs(self.actor.quests or {}) do
		if q:isEnded() then
			 if first then
					 nl()
					 nl("  [Completed Quests]")
					 nl()
					 first=false
			 end
			  nl(" -- ".. q.name)
			  nl(q:desc(self.actor):gsub("#.-#", "   "))
		end
	end

	 first=true
	for id, q in pairs(self.actor.quests or {}) do
		if not q:isEnded() then
			if first then
					 first=false
					 nl()
					nl("  [Active Quests]")
					 nl()
				end
			  nl(" -- ".. q.name)
			  nl(q:desc(self.actor):gsub("#.-#", "   "))
		end
	end


	--All Equipment
	nl()
	nl("  [Character Equipment]")
	nl()
	local index = 0
	for inven_id =  1, #self.actor.inven_def do
		if self.actor.inven[inven_id] and self.actor.inven_def[inven_id].is_worn then
			nl((" %s"):format(self.actor.inven_def[inven_id].name))

			for item, o in ipairs(self.actor.inven[inven_id]) do
				if not self.filter or self.filter(o) then
					local char = string.char(string.byte('a') + index)
					nl(("%s) %s"):format(char, o:getName{force_id=true}))
					nl(("   %s"):format(table.concat(o:getTextualDesc(), "\n    ")))
					index = index + 1
				end
			end
		end
	end

	nl()
	nl("  [Character Inventory]")
	nl()
	for item, o in ipairs(self.actor:getInven("INVEN")) do
		if not self.filter or self.filter(o) then
			local char = string.char(string.byte('a') + item - 1)
			nl(("%s) %s"):format(char, o:getName{force_id=true}))
			nl(("   %s"):format(table.concat(o:getTextualDesc(), "\n    ")))
		end
	end

	nl()
	nl("  [Last Messages]")
	nl()

	nl(table.concat(game.logdisplay:getLines(40), "\n"):gsub("#.-#", "   "))

	fff:close()

	Dialog:simplePopup("Character dump complete", "File: "..fs.getRealPath(file))
end
