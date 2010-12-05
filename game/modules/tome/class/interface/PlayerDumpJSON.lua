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
require "Json2"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.make)

function _M:getUUID()
	local uuid = profile:registerNewCharacter(game.__mod_info.short_name)
	if uuid then
		self.__te4_uuid = uuid
	end
end

function _M:saveUUID()
	if not self.__te4_uuid then return end
	local title, data = self:dumpToJSON()
	if not data or not title then return end
	profile:registerSaveChardump(game.__mod_info.short_name, self.__te4_uuid, title, data)
end

function _M:dumpToJSON()
	if not self.__te4_uuid then return end

	local nb_inscriptions = 0
	for i = 1, self.max_inscriptions do if self.inscriptions[i] then nb_inscriptions = nb_inscriptions + 1 end end

	local js = {}

	js.sections = {
		{display="character", table="char"},
		{display="primary stats", table="stats"},
		{display="resources", table="resources"},
		{display=("inscriptions (%d/%d)"):format(nb_inscriptions, self.max_inscriptions), table="inscriptions"},
		{display="offense", table="offense"},
		{display="defense", table="defense"},
	}

	local cur_exp, max_exp = self.exp, self:getExpChart(self.level+1)
	local title = ("%s the %s %s"):format(self.name, self.descriptor.subrace, self.descriptor.subclass)
	js.char = {
		{ game = string.format("%s (version %d.%d.%d)", game.__mod_info.long_name, game.__mod_info.version[1], game.__mod_info.version[2], game.__mod_info.version[3]) },
		{ name = self.name },
		{ sex = self.descriptor.sex },
		{ type = self.descriptor.subrace .. " " .. self.descriptor.subclass },
		{ campaign = self.descriptor.world },
		{ difficulty = self.descriptor.difficulty },
		{ level = self.level },
		{ exp = string.format("%d%%", 100 * cur_exp / max_exp) },
		{ gold = string.format("%d", self.money) },
		{ died = string.format("%d times (now %s)", self.died_times or 0, self.dead and "dead" or "alive") },
	}

	js.stats = {
		{ strength = self:getStr() },
		{ dexterity = self:getDex() },
		{ magic = self:getMag() },
		{ willpower = self:getWil() },
		{ cunning = self:getCun() },
		{ constitution = self:getCon() },
	}

	js.resources = { {life=string.format("%d/%d", self.life, self.max_life)} }
	if self:knowTalent(self.T_STAMINA_POOL) then js.resources[#js.resources+1] = {stamina=string.format("%d/%d", self.stamina, self.max_stamina)} end
	if self:knowTalent(self.T_MANA_POOL) then js.resources[#js.resources+1] = {mana=string.format("%d/%d", self.mana, self.max_mana)} end
	if self:knowTalent(self.T_POSITIVE_POOL) then js.resources[#js.resources+1] = {positive=string.format("%d/%d", self.positive, self.max_positive)} end
	if self:knowTalent(self.T_NEGATIVE_POOL) then js.resources[#js.resources+1] = {negative=string.format("%d/%d", self.negative, self.max_negative)} end
	if self:knowTalent(self.T_VIM_POOL) then js.resources[#js.resources+1] = {vim=string.format("%d/%d", self.vim, self.max_vim)} end
	if self:knowTalent(self.T_EQUILIBRIUM_POOL) then js.resources[#js.resources+1] = {equilibrium=string.format("%d", self.equilibrium)} end
	if self:knowTalent(self.T_HATE_POOL) then js.resources[#js.resources+1] = {hate=string.format("%0.2f/%0.2f", self.hate, self.max_hate)} end

	js.inscriptions = {}
	for i = 1, self.max_inscriptions do if self.inscriptions[i] then
		local t = self:getTalentFromId("T_"..self.inscriptions[i])
		local desc = self:getTalentFullDescription(t)
		local p = t.name:split(": ")
		js.inscriptions[#js.inscriptions+1] = {[p[1]] = p[2]}
	end end

	js.offense = {}
	local c = js.offense
	if self:getInven(self.INVEN_MAINHAND) then
		for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
			if o.combat then
				c[#c+1] = { ["attack (main hand)"] = string.format("%d", self:combatAttack(o.combat)) }
				c[#c+1] = { ["damage (main hand)"] = string.format("%d", self:combatDamage(o.combat)) }
				c[#c+1] = { ["APR (main hand)"] = string.format("%d", self:combatAPR(o.combat)) }
				c[#c+1] = { ["crit(main hand)"] = string.format("%d%%", self:combatCrit(o.combat)) }
				c[#c+1] = { ["speed(main hand)"] = string.format("%0.2f", self:combatSpeed(o.combat)) }
			end
		end
	end
	if self:getInven(self.INVEN_OFFHAND) then
		local offmult = self:getOffHandMult()
		for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
			if o.combat then
				c[#c+1] = { ["attack (off hand)"] = string.format("%d", self:combatAttack(o.combat)) }
				c[#c+1] = { ["damage (off hand)"] = string.format("%d", self:combatDamage(o.combat) * offmult) }
				c[#c+1] = { ["APR (off hand)"] = string.format("%d", self:combatAPR(o.combat)) }
				c[#c+1] = { ["crit(off hand)"] = string.format("%d%%", self:combatCrit(o.combat)) }
				c[#c+1] = { ["speed(off hand)"] = string.format("%0.2f", self:combatSpeed(o.combat)) }
			end
		end
	end
	c[#c+1] = { spellpower = self:combatSpellpower() }
	c[#c+1] = { ["spell crit"] = self:combatSpellCrit() }
	c[#c+1] = { ["spell speed"] = self:combatSpellSpeed() }

	if self.inc_damage.all then c[#c+1] = { ["all damage"] = string.format("%d%%", self.inc_damage.all) } end
	for i, t in ipairs(DamageType.dam_def) do
		if self.inc_damage[DamageType[t.type]] and self.inc_damage[DamageType[t.type]] ~= 0 then
			c[#c+1] = { [t.name.." damage"] = string.format("%d%%", self.inc_damage[DamageType[t.type]] + (self.inc_damage.all or 0)) }
		end
	end

	print(json.encode(js))
	return title, json.encode(js)
end
