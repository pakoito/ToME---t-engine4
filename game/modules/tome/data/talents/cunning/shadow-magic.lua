-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
	mana = 0,
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
		return ([[Channel raw magical energy into your melee attacks; each blow you land will do an additional %.2f darkness damage and cost %.2f mana.
		The damage will improve with your Spellpower.]]):
		format(damDesc(self, DamageType.DARKNESS, damage), manacost)
	end,
}

newTalent{
	name = "Shadow Cunning",
	type = {"cunning/shadow-magic", 2},
	mode = "passive",
	points = 5,
	require = cuns_req2,
	-- called in _M:combatSpellpower in mod\class\interface\Combat.lua
	getSpellpower = function(self, t) return self:combatTalentScale(t, 20, 40, 0.75) end,
	info = function(self, t)
		local spellpower = t.getSpellpower(self, t)
		return ([[Your preparations give you greater magical capabilities. You gain a bonus to Spellpower equal to %d%% of your Cunning.]]):
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
	getManaRegen = function(self, t) return self:combatTalentScale(t, 1.5/5, 1, 0.75) / (1 - t.getAtkSpeed(self, t)/100) end, -- scale with atk speed bonus to allow enough mana for one shadow combat proc per turn at talent level 5 
	getAtkSpeed = function(self, t) return self:combatTalentScale(t, 2.2, 11, 0.75) end,
	activate = function(self, t)
		local speed = t.getAtkSpeed(self, t)/100
		return {
			regen = self:addTemporaryValue("mana_regen", t.getManaRegen(self, t)),
			ps = self:addTemporaryValue("combat_physspeed", speed),
			ss = self:addTemporaryValue("combat_spellspeed", speed),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("mana_regen", p.regen)
		self:removeTemporaryValue("combat_physspeed", p.ps)
		self:removeTemporaryValue("combat_spellspeed", p.ss)
		return true
	end,
	info = function(self, t)
		local manaregen = t.getManaRegen(self, t)
		return ([[You draw energy from the depths of the shadows.
		While sustained, you regenerate %0.2f mana per turn, and your physical and spell attack speed increases by %0.1f%%.]]):
		format(manaregen, t.getAtkSpeed(self, t))
	end,
}

newTalent{
	name = "Shadowstep",
	type = {"cunning/shadow-magic", 4},
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	stamina = 30,
	require = cuns_req4,
	tactical = { CLOSEIN = 2, DISABLE = { stun = 1 } },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	direct_hit = true,
	requires_target = true,
	getDuration = function(self, t) return math.min(5, 2 + math.ceil(self:getTalentLevel(t) / 2)) end,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 1.2, 2.5) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "You cannot do that currently.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local nop, _, _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not (nop and game.level.map.seens(x, y)) then return nil end

		local tx, ty = util.findFreeGrid(x, y, 20, true, {[engine.Map.ACTOR]=true})
		self:move(tx, ty, true)

		-- Attack ?
		if target and target.x and core.fov.distance(self.x, self.y, target.x, target.y) == 1 then
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
		Dazed targets are significantly impaired, but any damage will free them.
		To Shadowstep, you need to be able to see the target.]]):
		format(duration, t.getDamage(self, t) * 100)
	end,
}

