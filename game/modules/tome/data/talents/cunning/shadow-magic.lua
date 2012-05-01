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
	name = "Shadow Combat",
	type = {"cunning/shadow-magic", 1},
	mode = "sustained",
	points = 5,
	require = cuns_req1,
	sustain_stamina = 20,
	cooldown = 5,
	tactical = { BUFF = 2 },
	getDamage = function(self, t) return 2 + self:combatTalentSpellDamage(t, 2, 50) end,
	getManaCost = function(self, t) return 2 end,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local manacost = t.getManaCost(self, t)
		return ([[Channel raw magical energy into your melee attacks, each doing %.2f darkness damage and costing %.2f mana.]]):
		format(damDesc(self, DamageType.DARKNESS, damage), manacost)
	end,
}

newTalent{
	name = "Shadow Cunning",
	type = {"cunning/shadow-magic", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	getSpellpower = function(self, t) return 15 + self:getTalentLevel(t) * 5 end,
	info = function(self, t)
		local spellpower = t.getSpellpower(self, t)
		return ([[The user gains a bonus to spellpower equal to %d%% of their cunning.]]):
		format(spellpower)
	end,
}

newTalent{
	name = "Shadow Feed",
	type = {"cunning/shadow-magic", 3},
	mode = "sustained",
	points = 5,
	cooldown = 5,
	sustain_stamina = 40,
	require = cuns_req3,
	range = 10,
	tactical = { BUFF = 2 },
	getManaRegen = function(self, t) return self:getTalentLevel(t) / 14 end,
	activate = function(self, t)
		return {
			regen = self:addTemporaryValue("mana_regen", t.getManaRegen(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.regen)
		return true
	end,
	info = function(self, t)
		local manaregen = t.getManaRegen(self, t)
		return ([[Regenerates %0.2f mana per turn while active.]]):
		format(manaregen)
	end,
}

newTalent{
	name = "Shadowstep",
	type = {"cunning/shadow-magic", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 5,
	stamina = 30,
	require = cuns_req4,
	tactical = { CLOSEIN = 2, DISABLE = { stun = 1 } },
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t)) end,
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.2) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "You can not do that currently.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > self:getTalentRange(t) then return nil end
		if not game.level.map.seens(x, y) then return nil end

		local tx, ty = util.findFreeGrid(x, y, 20, true, {[engine.Map.ACTOR]=true})
		self:move(tx, ty, true)

		-- Attack ?
		if core.fov.distance(self.x, self.y, x, y) == 1 then
			self:attackTarget(target, DamageType.DARKNESS, t.getDamage(self, t), true)
			if target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, t.getDuration(self, t), {})
			else
				game.logSeen(target, "%s is not dazed!", target.name:capitalize())
			end
		end
		return true
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[Step through the shadows to your target, dazing it for %d turns and hitting it with all your weapons for %d%% darkness weapon damage.
		Dazed targets can not act, but any damage will free them.
		To shadowstep you need to be able to see the target.]]):
		format(duration, t.getDamage(self, t) * 100)
	end,
}

