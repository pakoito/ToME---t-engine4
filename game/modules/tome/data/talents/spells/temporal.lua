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

newTalent{
	name = "Time Prison",
	type = {"spell/temporal", 1},
	require = spells_req1,
	points = 5,
	mana = 30,
	cooldown = 30,
	tactical = {
		DEFENSE = 10,
	},
	range = 20,
	reflectable = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.TIME_PRISON, 4 + self:combatSpellpower(0.03) * self:getTalentLevel(t), {type="manathrust"})
		game:playSound("talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Removes the target from the flow of time for %d turns. In this state the target can neither act or be harmed.
		The duration will increase with the Magic stat]]):format(4 + self:combatSpellpower(0.03) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Congeal Time",
	type = {"spell/temporal",2},
	require = spells_req2,
	points = 5,
	mana = 20,
	cooldown = 30,
	tactical = {
		BUFF = 10,
	},
	reflectable = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.SLOW, util.bound((self:combatSpellpower(0.15) * self:getTalentLevel(t)) / 100, 0.1, 0.4), {type="manathrust"})
		game:playSound("talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Decreases the target global speed by %.2f for 7 turns.
		The speed decreases with the Magic stat]]):format(util.bound((self:combatSpellpower(0.15) * self:getTalentLevel(t)) / 100, 0.1, 0.4))
	end,
}

newTalent{
	name = "Essence of Speed",
	type = {"spell/temporal",3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	sustain_mana = 450,
	cooldown = 30,
	tactical = {
		BUFF = 10,
	},
	activate = function(self, t)
		game:playSound("talents/spell_generic")
		local power = util.bound((self:combatSpellpower(0.5) * self:getTalentLevel(t)) / 100, 0.1, 2)
		return {
			speed = self:addTemporaryValue("energy", {mod=power}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("energy", p.speed)
		return true
	end,
	info = function(self, t)
		return ([[Increases the caster global speed by %.2f.
		The speed increases with the Magic stat]]):format(util.bound((self:combatSpellpower(0.5) * self:getTalentLevel(t)) / 100, 0.1, 2))
	end,
}

newTalent{
	name = "Time Shield",
	type = {"spell/temporal", 4},
	require = spells_req4,
	points = 5,
	mana = 150,
	cooldown = 200,
	tactical = {
		DEFENSE = 10,
	},
	range = 20,
	action = function(self, t)
		local dur = util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15)
		local power = 50 + self:combatSpellpower(0.5) * self:getTalentLevel(t)
		self:setEffect(self.EFF_TIME_SHIELD, dur, {power=power})
		game:playSound("talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[This intricate spell erects a time shield around the caster, preventing any incomming damage and sending it forward in time.
		Once the maximun damage (%d) is absorbed or the time runs out (%d turns) the stored damage will come back as a damage over time (5 turns).
		The duration and max absorption will increase with the Magic stat]]):format(50 + self:combatSpellpower(0.5) * self:getTalentLevel(t), util.bound(5 + math.floor(self:getTalentLevel(t)), 5, 15))
	end,
}
