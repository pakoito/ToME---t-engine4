-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Arcane Eye",
	type = {"spell/divination", 1},
	require = spells_req1,
	points = 5,
	mana = 15,
	cooldown = 10,
	no_energy = true,
	no_npc_use = true,
	requires_target = true,
	getDuration = function(self, t) return math.floor(10 + self:getTalentLevel(t) * 3) end,
	getRadius = function(self, t) return math.floor(4 + self:getTalentLevel(t)) end,
	action = function(self, t)
		local tg = {type="hit", nolock=true, pass_terrain=true, nowarning=true, range=100, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		self:setEffect(self.EFF_ARCANE_EYE, t.getDuration(self, t), {x=x, y=y, track=(self:getTalentLevel(t) >= 4) and game.level.map(x, y, Map.ACTOR) or nil, radius=t.getRadius(self, t), true_seeing=self:getTalentLevel(t) >= 5})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local duration = t.getDuration(self, t)
		return ([[Summons an ethereal magical eye at the designated location that lasts for %d turns.
		The eye can not be seen or attacked by other creatures and possesses magical vision that allows it to see any creature in a %d range around it.
		It does not require light to do so but it can not see through walls.
		Casting the eye does not take a turn.
		Only one arcane eye can exist at any given time.
		At level 4 if cast on a creature it will follow it until it expires or until the creature dies.
		At level 5 it will place a magical marker on the creatures, negating invisibility and stealth effects.]]):
		format(duration, radius)
	end,
}

newTalent{
	name = "Keen Senses",
	type = {"spell/divination", 2},
	require = spells_req2,
	mode = "sustained",
	points = 5,
	sustain_mana = 40,
	tactical = { BUFF = 2 },
	cooldown = 30,
	getSeeInvisible = function(self, t) return self:combatTalentSpellDamage(t, 2, 45) end,
	getSeeStealth = function(self, t) return self:combatTalentSpellDamage(t, 2, 20) end,
	getCriticalChance = function(self, t) return self:combatTalentSpellDamage(t, 2, 12) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			invis = self:addTemporaryValue("see_invisible", t.getSeeInvisible(self, t)),
			stealth = self:addTemporaryValue("see_stealth", t.getSeeStealth(self, t)),
			crit = self:addTemporaryValue("combat_spellcrit", t.getCriticalChance(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("see_invisible", p.invis)
		self:removeTemporaryValue("see_stealth", p.stealth)
		self:removeTemporaryValue("combat_spellcrit", p.crit)
		return true
	end,
	info = function(self, t)
		local seeinvisible = t.getSeeInvisible(self, t)
		local seestealth = t.getSeeStealth(self, t)
		local criticalchance = t.getCriticalChance(self, t)
		return ([[You focus your senses, getting information from moments in the future.
		Improves see invisible +%d
		Improves see through stealth +%d
		Improves critical spell chance +%d%%
		The effects will improve with your Spellpower.]]):
		format(seeinvisible, seestealth, criticalchance)
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
	no_npc_use = true,
	getRadius = function(self, t) return 5 + self:combatTalentSpellDamage(t, 2, 12) end,
	action = function(self, t)
		self:magicMap(t.getRadius(self, t))
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		return ([[Form a map of your surroundings in your mind in a radius of %d]]):
		format(radius)
	end,
}

newTalent{
	name = "Premonition",
	type = {"spell/divination", 4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	sustain_mana = 120,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getResist = function(self, t) return 10 + self:combatTalentSpellDamage(t, 2, 25) end,
	on_damage = function(self, t, damtype)
		if damtype == DamageType.PHYSICAL then return end

		if not self:hasEffect(self.EFF_PREMONITION_SHIELD) then
			self:setEffect(self.EFF_PREMONITION_SHIELD, 5, {damtype=damtype, resist=t.getResist(self, t)})
			game.logPlayer(self, "#OLIVE_DRAB#Your premonition allows you to raise a shield just in time!")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
		}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		return ([[Echoes of the future flash before your eyes, allowing you to sense some incoming attacks.
		If the attack is elemental or magical you will erect a temporary shield that reduces all damage of this type by %d%% for 5 turns.
		This effect can only happen once every 5 turns and happens before damage is taken.
		The bonus will increase with your Spellpower.]]):format(resist)
	end,
}
