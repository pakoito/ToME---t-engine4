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

newTalent{
	name = "Sense",
	type = {"spell/divination", 1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 10,
	cooldown = 10,
	action = function(self, t)
		local rad = 10 + self:combatSpellpower(0.1) * self:getTalentLevel(t)
		self:setEffect(self.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
			object = (self:getTalentLevel(t) >= 2) and 1 or 0,
			trap = (self:getTalentLevel(t) >= 5) and 1 or 0,
		})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Sense foes around you in a radius of %d.
		At level 2 it detects objects.
		At level 5 it detects traps.
		The radius will increase with the Magic stat]]):format(10 + self:combatSpellpower(0.1) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Arcane Eye",
	type = {"spell/divination", 2},
	require = spells_req2,
	points = 5,
	mana = 15,
	cooldown = 10,
	no_energy = true,
	action = function(self, t)
		local tg = {type="hit", nolock=true, pass_terrain=true, nowarning=true, range=100, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		local dur = math.floor(10 + self:getTalentLevel(t) * 3)
		local radius = math.floor(4 + self:getTalentLevel(t) * 3)
		self:setEffect(self.EFF_ARCANE_EYE, dur, {x=x, y=y, radius=radius, true_seeing=self:getTalentLevel(t) >= 5})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Summons an etheral magical eye at the designated location that lasts for %d turns.
		The eye can not be seen or attacked by other creatures and posses magical vision that allows it to see any creature in a %d range around it.
		It does not require light to do so but it can not see through walls.
		Casting the eye does not take a turn.
		Only one arcane eye can exist at any given time.
		At level 5 its vision can see through invisibility, stealth and all other sight affecting effects.
		]]):
		format(math.floor(10 + self:getTalentLevel(t) * 3), math.floor(4 + self:getTalentLevel(t) * 3))
	end,
}

newTalent{
	name = "Vision",
	type = {"spell/divination", 3},
	require = spells_req3,
	points = 5,
	random_ego = "utility",
	mana = 20,
	cooldown = 20,
	action = function(self, t)
		self:magicMap(5 + self:combatTalentSpellDamage(t, 2, 12))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Form a map of your surroundings in your mind in a radius of %d.]]):format(5 + self:combatTalentSpellDamage(t, 2, 12))
	end,
}

newTalent{
	name = "Telepathy",
	type = {"spell/divination", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 200,
	cooldown = 30,
	activate = function(self, t)
		-- There is an implicit +10, as it is the default radius
		local rad = self:combatTalentSpellDamage(t, 2, 10)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			esp = self:addTemporaryValue("esp", {range=rad, all=1}),
			drain = self:addTemporaryValue("mana_regen", -3 * self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("esp", p.esp)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Allows you to sense the presence of foes, in a radius of %d.
		This powerful spell will continuously drain mana while active.
		The bonus will increase with the Magic stat]]):format(10 + self:combatTalentSpellDamage(t, 2, 10))
	end,
}
