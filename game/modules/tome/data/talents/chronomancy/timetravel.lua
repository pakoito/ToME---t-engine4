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
	name = "Backtrack",
	type = {"chronomancy/timetravel", 1},
	require = chrono_req1,
	points = 5,
	random_ego = "utility",
	paradox = 3,
	cooldown = 8,
	no_energy = true,
	tactical = {
		ESCAPE = 4,
	},
	range = function(self, t) return (3 + self:getTalentLevel(t))*getParadoxModifier(self, pm) end,
	requires_target = true,
	direct_hit = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		if math.floor(core.fov.distance(self.x, self.y, tx, ty)) > self:getTalentRange(t) then return nil end
		if not self:canBe("teleport") or game.level.map.attrs(tx, ty, "no_teleport") then
			game.logSeen(self, "The spell fizzles!")
			return true
		end
		if self:hasLOS(tx, ty) and not game.level.map:checkEntity(tx, ty, Map.TERRAIN, "block_move") and not game.level.map:checkEntity(tx, ty, Map.ACTOR, "block_move") then
			self:move(tx, ty, true)
			game:playSoundNear(self, "talents/teleport")
		else
			game.logSeen(self, "You cannot move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		return ([[Instantly teleports you to up to %0.2f tiles away to any tile in line of sight.
		]]):format((3 + self:getTalentLevel(t))*getParadoxModifier(self, pm))
	end,
}

newTalent{
	name = "Temporal Reprieve",
	type = {"chronomancy/timetravel", 2},
	require = chrono_req2,
	points = 5,
	random_ego = "attack",
	paradox = 10,
	cooldown = 20,
	tactical = {
		UTILITY = 10,
	},
	message = "@Source@ manipulates the flow of time.",
	no_energy = true,
	action = function(self, t)
		for tid, cd in pairs(self.talents_cd) do
			self.talents_cd[tid] = cd - self:getTalentLevel(t)
		end
			return true
	end,
	info = function(self, t)
		return ([[All your talents currently on cooldown are %d turns closer to being off cooldown.]]):
		format(self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Time Skip",
	type = {"chronomancy/timetravel",3},
	require = chrono_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 50,
	tactical = {
		MOVEMENT = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic2")
		local ret = {
			encumb = self:addTemporaryValue("max_encumber", math.floor(self:combatTalentSpellDamage(t, 10, 110))),
			def = self:addTemporaryValue("combat_def_ranged", self:combatTalentSpellDamage(t, 4, 30)),
			lev = self:addTemporaryValue("levitation", 1),
		}
		self:checkEncumbrance()
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("max_encumber", p.encumb)
		self:removeTemporaryValue("combat_def_ranged", p.def)
		self:removeTemporaryValue("levitation", p.lev)
		self:checkEncumbrance()
		return true
	end,
	info = function(self, t)
		return ([[A gentle wind circles around the caster, increasing carrying capacity by %d and increasing defense against projectiles by %d.
		At level 4 it also makes you slightly levitate, allowing you to ignore some traps.]]):
		format(self:getTalentLevel(t) * self:combatSpellpower(0.15), 6 + self:combatSpellpower(0.07) * self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Rethread",
	type = {"chronomancy/timetravel", 4},
	require = chrono_req4,
	points = 5,
	paradox = 100,
	cooldown = 100,
	no_npc_use = true,
	on_learn = function(self, t)
		self:attr("level_cloning", 1)
	end,
	on_unlearn = function(self, t)
		self:attr("level_cloning", -1)
	end,
	action = function(self, t)
		if not game.level.backup then
			game.logSeen(self, "#LIGHT_RED#The spell fizzles.")
			return
		end

		game:onTickEnd(function()
			local level = game.level.backup
			level:cloneReloaded()
			-- Look for the "old" player
			for uid, e in pairs(level.entities) do
				if e.game_ender then
					game.level = level
					game.player:replaceWith(e)
					game.player:move(game.player.x, game.player.y, true)
					game.logPlayer(game.player, "#LIGHT_BLUE#You unfold the space time continuum to a previous state!")

					-- Manualy start the cooldown of the "old player"
					game.player:startTalentCooldown(t)
					return
				end
			end

			game.logPlayer(self, "#LIGHT_RED#The space time continuum seems to be too disturted to use.")
		end)
		return true
	end,
	info = function(self, t)
		return ([[Conjures a furious, raging lightning storm with a radius of 5 that follows you as long as this spell is active.
		Each turn a random lightning bolt will hit up to %d of your foes for 1 to %0.2f damage.
		This powerful spell will continuously drain mana while active.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), self:combatTalentSpellDamage(t, 15, 80))
	end,
}
