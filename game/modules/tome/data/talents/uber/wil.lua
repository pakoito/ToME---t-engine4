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

uberTalent{
	name = "Draconic Will",
	cooldown = 15,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_DRACONIC_WILL, 5, {})
		return true
	end,
	require = { special={desc="Be close to the draconic world", fct=function(self) return self:attr("drake_touched") and self:attr("drake_touched") >= 2 end} },
	info = function(self, t)
		return ([[Your body is like that of a drake, easily resisting detrimental effects.
		For 5 turns no detrimental effects may target you.]])
		:format()
	end,
}

uberTalent{
	name = "Meteoric Crash",
	mode = "passive",
	cooldown = 15,
	getDamage = function(self, t) return 100 + self:combatSpellpower() * 4 end,
	require = { special={desc="Witness a meteoric crash", fct=function(self) return self:attr("meteoric_crash") end} },
	trigger = function(self, t, target)
		self:startTalentCooldown(t)
		local terrains = t.terrains or mod.class.Grid:loadList("/data/general/grids/lava.lua")
		t.terrains = terrains -- cache

		local meteor = function(src, x, y, dam)
			game.level.map:particleEmitter(x, y, 10, "meteor", {x=x, y=y}).on_remove = function(self)
				local x, y = self.args.x, self.args.y
				game.level.map:particleEmitter(x, y, 10, "ball_fire", {radius=2})
				game:playSoundNear(game.player, "talents/fireflash")

				for i = x-1, x+1 do for j = y-1, y+1 do
					local oe = game.level.map(i, j, Map.TERRAIN)
					if oe and not oe:attr("temporary") and
					(core.fov.distance(x, y, i, j) < 1 or rng.percent(40)) and (game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "dig") or game.level.map:checkEntity(i, j, engine.Map.TERRAIN, "grow")) then
						local g = terrains.LAVA_FLOOR:clone()
						g:resolve() g:resolve(nil, true)
						g.temporary = 8
						g.x = i g.y = j
						g.canAct = false
						g.energy = { value = 0, mod = 1 }
						g.old_feat = game.level.map(i, j, engine.Map.TERRAIN)
						g.useEnergy = mod.class.Trap.useEnergy
						g.act = function(self)
							self:useEnergy()
							self.temporary = self.temporary - 1
							if self.temporary <= 0 then
								game.level.map(self.x, self.y, engine.Map.TERRAIN, self.old_feat)
								game.level:removeEntity(self)
								game.nicer_tiles:updateAround(game.level, self.x, self.y)
							end
						end
						game.zone:addEntity(game.level, g, "terrain", i, j)
						game.level:addEntity(g)
					end
				end end
				for i = x-1, x+1 do for j = y-1, y+1 do
					game.nicer_tiles:updateAround(game.level, i, j)
				end end

				src:project({type="ball", radius=2, selffire=src:spellFriendlyFire()}, x, y, engine.DamageType.FIRE, dam/2)
				src:project({type="ball", radius=2, selffire=src:spellFriendlyFire()}, x, y, engine.DamageType.PHYSICAL, dam/2)
				src:project({type="ball", radius=2, selffile=src:spellFriendlyFire()}, x, y, function(px, py)
					local target = game.level.map(px, py, Map.ACTOR)
					if target then
						if target:canBe("stun") then
							target:setEffect(target.EFF_STUNNED, 3, {apply_power=src:combatSpellpower()})
						else
							game.logSeen(target, "%s resists the stun!", target.name:capitalize())
						end
					end
				end)
			end
		end

		meteor(self, target.x, target.y, t.getDamage(self, t))

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)/2
		return ([[With the release of your willpower when casting damaging spells you can call forth a meteor to crash down near your foes.
		The affected area is turned into lava for 8 turns and the crash will deal %0.2f fire and %0.2f physical damage.
		The meteor also stun affected creatures for 3 turns.]])
		:format(damDesc(self, DamageType.FIRE, dam), damDesc(self, DamageType.PHYSICAL, dam))
	end,
}

uberTalent{
	name = "Garkul's Revenge",
	mode = "passive",
	on_learn = function(self, t)
		self.inc_damage_actor_type = self.inc_damage_actor_type or {}
		self.inc_damage_actor_type.construct = (self.inc_damage_actor_type.construct or 0) + 500
	end,
	on_unlearn = function(self, t)
		self.inc_damage_actor_type.construct = (self.inc_damage_actor_type.construct or 0) - 500
	end,
	require = { special={desc="Possess and wear two of Garkul's artifacts and know all about Garkul's life", fct=function(self)
		local o1 = self:findInAllInventoriesBy("define_as", "SET_GARKUL_TEETH")
		local o2 = self:findInAllInventoriesBy("define_as", "HELM_OF_GARKUL")
		return o1 and o2 and o1.wielded and o2.wielded and
			game.player:knownLore("garkul-history-1") and
			game.player:knownLore("garkul-history-2") and
			game.player:knownLore("garkul-history-3") and
			game.player:knownLore("garkul-history-4") and
			game.player:knownLore("garkul-history-5")
	end} },
	info = function(self, t)
		return ([[Garkul's Spirit is with you, you now deal 500%% more damage to constructs.]])
		:format()
	end,
}

uberTalent{
	name = "Hidden Resources",
	cooldown = 15,
	no_energy = true,
	action = function(self, t)
		self:setEffect(self.EFF_HIDDEN_RESOURCES, 5, {})
		return true
	end,
	require = { special={desc="Have been close to death (killed a foe while below 1 HP)", fct=function(self) return self:attr("barely_survived") end} },
	info = function(self, t)
		return ([[You focus your mind on the task at hand.
		For 5 turns none of your talents use any resources.]])
		:format()
	end,
}
