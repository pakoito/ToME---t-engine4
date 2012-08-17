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

local basetrap = function(self, t, x, y, dur, add)
	local Trap = require "mod.class.Trap"
	local trap = {
		id_by_type=true, unided_name = "trap",
		display = '^',
		faction = self.faction,
		summoner = self, summoner_gain_exp = true,
		temporary = dur,
		x = x, y = y,
		canAct = false,
		energy = {value=0},
		act = function(self)
			self:realact()
			self:useEnergy()
			self.temporary = self.temporary - 1
			if self.temporary <= 0 then
				if game.level.map(self.x, self.y, engine.Map.TRAP) == self then game.level.map:remove(self.x, self.y, engine.Map.TRAP) end
				game.level:removeEntity(self)
			end
		end,
	}
	table.merge(trap, add)
	return Trap.new(trap)
end

newTalent{
	name = "Aether Beam",
	type = {"spell/aether", 1},
	require = spells_req_high1,
	mana = 20,
	points = 5,
	cooldown = 12,
	direct_hit = true,
	range = 6,
	requires_target = true,
	tactical = { ATTACKAREA = { ARCANE = 2 }, DISABLE = { silence = 1 } },
	target = function(self, t) return {type="hit", range=self:getTalentRange(t), talent=t} end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 150) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if game.level.map(x, y, Map.TRAP) then game.logPlayer(self, "You somehow fail to set the aether beam.") return nil end

		local t = basetrap(self, t, x, y, 44, {
			type = "aether", name = "aether beam", color=colors.VIOLET, image = "trap/trap_glyph_explosion_01_64.png",
			dam = self:spellCrit(t.getDamage(self, t)),
			triggered = function(self, x, y, who) return true, true end,
			combatSpellpower = function(self) return self.summoner:combatSpellpower() end,
			rad = 3,
			energy = {value=0, mod=4},
			on_added = function(self, level, x, y)
				self.x, self.y = x, y
				local tries = {}
				local list = {i=1}
				local sa = rng.range(0, 359)
				local dir = rng.percent(50) and 1 or -1
				for a = sa, sa + 359 * dir, dir do
					local rx, ry = math.floor(math.cos(math.rad(a)) * self.rad), math.floor(math.sin(math.rad(a)) * self.rad)
					if not tries[rx] or not tries[rx][ry] then
						tries[rx] = tries[rx] or {}
						tries[rx][ry] = true
						list[#list+1] = {x=rx+x, y=ry+y}
					end
				end
				self.list = list
				self.on_added = nil
			end,
			disarmed = function(self, x, y, who)
				game.level:removeEntity(self, true)
			end,
			realact = function(self)
				if game.level.map(self.x, self.y, engine.Map.TRAP) ~= self then game.level:removeEntity(self, true) return end

				local x, y = self.list[self.list.i].x, self.list[self.list.i].y
				self.list.i = util.boundWrap(self.list.i + 1, 1, #self.list)

				local tg = {type="beam", x=self.x, y=self.y, range=self.rad, selffire=self.summoner:spellFriendlyFire()}
				self.summoner:project(tg, x, y, engine.DamageType.ARCANE_SILENCE, {dam=self.dam, chance=25}, nil)
				local _ _, x, y = self:canProject(tg, x, y)
				game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
			end,
		})
		t:identify(true)

		t:resolve() t:resolve(nil, true)
		t:setKnown(self, true)
		game.level:addEntity(t)
		game.zone:addEntity(game.level, t, "trap", x, y)
		game.level.map:particleEmitter(x, y, 1, "summon")

		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[You focus the aether into a spinning beam of arcane energies doing %0.2f arcane damage and having 25%% chance to silence the creatures.
		The beam will work for 11 turns, doing two full rotations.
		The damage will increase with Spellpower.]]):
		format(damDesc(self, DamageType.ARCANE, dam))
	end,
}

newTalent{
	name = "Aether Breach",
	type = {"spell/aether", 2},
	require = spells_req_high2,
	points = 5,
	random_ego = "attack",
	mana = 50,
	cooldown = 8,
	tactical = { ATTACK = { ARCANE = 2 } },
	range = 7,
	radius = 2,
	direct_hit = function(self, t) if self:getTalentLevel(t) >= 3 then return true else return false end end,
	reflectable = true,
	requires_target = true,
	target = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), talent=t}
		return tg
	end,
	getNb = function(self, t) return 3 + math.floor(self:getTalentLevel(t) / 3) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 230) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local list = {}
		self:project(tg, x, y, function(px, py) list[#list+1] = {x=px, y=py} end)

		self:setEffect(self.EFF_AETHER_BREACH, t.getNb(self, t), {list=list, dam=self:spellCrit(t.getDamage(self, t))})

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Rupture reality to temporarily open a passage to the aether, triggering %d random arcane explosions in the target area.
		Each explosion does %0.2f arcane damage in radius 2 and will each trigger at one turn of interval.
		The damage will increase with your Spellpower.]]):
		format(t.getNb(self, t), damDesc(self, DamageType.ARCANE, damage))
	end,
}

newTalent{
	name = "Aether Avatar",
	type = {"spell/aether", 3},
	require = spells_req_high3,
	points = 5,
	mana = 35,
	cooldown = 12,
	range = 10,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	tactical = { ATTACK = { ARCANE = 2 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 340) / 6 end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return nil end

		target:setEffect(target.EFF_ARCANE_VORTEX, 6, {src=self, dam=t.getDamage(self, t)})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local dam = t.getDamage(self, t)
		return ([[Creates a vortex of arcane energies on the target for 6 turns. Each turn the vortex will look for an other foe in sight and fire a manathrust doing %0.2f arcane damage to all foes in line.
		If no foes are found the target will take 150%% more arcane damage.
		The damage will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.ARCANE, dam))
	end,
}

newTalent{
	name = "Pure Aether",
	type = {"spell/aether",4},
	require = spells_req_high4, no_sustain_autoreset = true,
	points = 5,
	mode = "sustained",
	cooldown = 30,
	sustain_mana = 10,
	no_energy = true,
	tactical = { MANA = 3, DEFEND = 2, },
	getManaRatio = function(self, t) return math.max(3 - self:combatTalentSpellDamage(t, 10, 200) / 100, 0.5) * (100 - util.bound(self:attr("shield_factor") or 0, 0, 70)) / 100 end,
	getArcaneResist = function(self, t) return 50 + self:combatTalentSpellDamage(t, 10, 500) / 10 end,
	on_pre_use = function(self, t) return self:getMana() / self:getMaxMana() <= 0.25 end,
	explode = function(self, t, dam)
		game.logSeen(self, "#VIOLET#%s's disruption shield collapses and then explodes in a powerful manastorm!", self.name:capitalize())

		-- Add a lasting map effect
		self:setEffect(self.EFF_ARCANE_STORM, 10, {power=t.getArcaneResist(self, t)})
		game.level.map:addEffect(self,
			self.x, self.y, 10,
			DamageType.ARCANE, dam / 10,
			3,
			5, nil,
			{type="arcanestorm", only_one=true},
			function(e) e.x = e.src.x e.y = e.src.y return true end,
			true
		)
	end,
	damage_feedback = function(self, t, p, src)
		if p.particle and p.particle._shader and p.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			p.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			p.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, t)
		local power = t.getManaRatio(self, t)
		self.disruption_shield_absorb = 0
		game:playSoundNear(self, "talents/arcane")

		local particle
		if core.shader.active() then
			particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.3}, {type="shield", time_factor=-2500, color={0.8, 0.1, 1.0}, impact_color = {0, 1, 0}, impact_time=800}))
		else
			particle = self:addParticles(Particles.new("disruption_shield", 1))
		end

		return {
			shield = self:addTemporaryValue("disruption_shield", power),
			particle = particle,
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("disruption_shield", p.shield)
		self.disruption_shield_absorb = nil
		return true
	end,
	info = function(self, t)
		return ([[Surround yourself with arcane forces, disrupting any attemps to harm you and instead generating mana.
		Generates %0.2f mana per damage point taken (Aegis Shielding talent affects the ratio).
		If your mana is brought too high by the shield, it will de-activate and the chain reaction will release a deadly arcane storm with radius 3 for 10 turns, dealing 10%% of the damage absorbed each turn.
		While the arcane storm rages you also get a %d%% arcane resistance.
		Only usable when bellow 25%% mana.
		The damage to mana ratio increases with your Spellpower.]]):
		format(t.getManaRatio(self, t), t.getArcaneResist(self, t))
	end,
}
