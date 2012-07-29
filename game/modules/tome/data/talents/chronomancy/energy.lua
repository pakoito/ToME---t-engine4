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
	name = "Energy Decomposition",
	type = {"chronomancy/energy",1},
	mode = "sustained",
	require = chrono_req1,
	points = 5,
	sustain_paradox = 75,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getAbsorption = function(self, t) return self:combatTalentSpellDamage(t, 5, 50) end,
	on_damage = function(self, t, damtype, dam)
		if not DamageType:get(damtype).antimagic_resolve then return dam end
		local absorb = t.getAbsorption(self, t)
		-- works like armor with 30% hardiness for projected energy effects
		dam = math.max(dam * 0.3 - absorb, 0) + (dam * 0.7)
		print("[PROJECTOR] after static reduction dam", dam)
		return dam
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("temporal_focus", 1)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		return true
	end,
	info = function(self, t)
		local absorption = t.getAbsorption(self, t)
		return ([[Reduces all incoming energy damage (all except mind and physical damage) by 30%% up to a maximum of %d.
		The maximum damage reduction will scale with your Spellpower.]]):format(absorption)
	end,
}

newTalent{
	name = "Entropic Field",
	type = {"chronomancy/energy",2},
	mode = "sustained",
	require = chrono_req2,
	points = 5,
	sustain_paradox = 100,
	cooldown = 10,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return math.min(90, 10 + (self:combatTalentSpellDamage(t, 10, 50))) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/heal")
		return {
			particle = self:addParticles(Particles.new("time_shield", 1)),
			phys = self:addTemporaryValue("resists", {[DamageType.PHYSICAL]=t.getPower(self, t)/2}),
			proj = self:addTemporaryValue("slow_projectiles", t.getPower(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("resists", p.phys)
		self:removeTemporaryValue("slow_projectiles", p.proj)
		return true
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[You encase yourself in a field that slows incoming projectiles by %d%% and increases your physical resistance by %d%%.
		The effect will scale with your Spellpower.]]):format(power, power / 2)
	end,
}

newTalent{
	name = "Energy Absorption",
	type = {"chronomancy/energy", 3},
	require = chrono_req3,
	points = 5,
	paradox = 10,
	cooldown = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 6,
	getTalentCount = function(self, t) return 1 + math.floor(self:getTalentLevel(t) * getParadoxModifier(self, pm)/2) end,
	getCooldown = function(self, t) return 1 + math.ceil(self:getTalentLevel(t)/3) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		local _ _, tx, ty = self:canProject(tg, tx, ty)
		tx, ty = checkBackfire(self, tx, ty)
		local target = game.level.map(tx, ty, Map.ACTOR)
		if not target then return end

		if not self:checkHit(self:combatSpellpower(), target:combatSpellResist()) then
			game.logSeen(target, "%s resists!", target.name:capitalize())
			return true
		end

		local tids = {}
		for tid, lev in pairs(target.talents) do
			local t = target:getTalentFromId(tid)
			if t and not target.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end

		local count = 0
		local cdr = t.getCooldown(self, t)

		for i = 1, t.getTalentCount(self, t) do
			local t = rng.tableRemove(tids)
			if not t then break end
			target.talents_cd[t.id] = cdr
			game.logSeen(target, "%s's %s is disrupted by the Energy Absorption!", target.name:capitalize(), t.name)
			count = count + 1
		end

		if count >= 1 then
			local tids = {}
			for tid, _ in pairs(self.talents_cd) do
				local tt = self:getTalentFromId(tid)
				if tt.type[1]:find("^chronomancy/") then
					tids[#tids+1] = tid
				end
			end
			for i = 1, count do
				if #tids == 0 then break end
				local tid = rng.tableRemove(tids)
				self.talents_cd[tid] = self.talents_cd[tid] - cdr
			end
		end
		target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
		game.level.map:particleEmitter(tx, ty, 1, "generic_charge", {rm=10, rM=110, gm=10, gM=50, bm=20, bM=125, am=25, aM=255})
		game.level.map:particleEmitter(self.x, self.y, 1, "generic_charge", {rm=200, rM=255, gm=200, gM=255, bm=200, bM=255, am=125, aM=125})
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local cooldown = t.getCooldown(self, t)
		return ([[You sap the target's energy and add it to your own, placing up to %d random talents on cooldown for %d turns and reducing the cooldown of one of your chronomancy talents currently on cooldown by %d turns per enemy talent effected.
		The cooldown adjustment scales with your Paradox.]]):
		format(talentcount, cooldown, cooldown)
	end,
}

newTalent{
	name = "Redux",
	type = {"chronomancy/energy",4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 12,
	tactical = { BUFF = 2 },
	no_energy = true,
	getMaxLevel = function(self, t) return self:getTalentLevel(t) end,
	action = function(self, t)
		-- effect is handled in actor postUse
		self:setEffect(self.EFF_REDUX, 5, {})
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[You may recast the next activated chronomancy spell (up to talent level %0.1f) that you cast within the next 5 turns on the turn following its initial casting.
		The Paradox cost of the initial spell will be paid each time it is cast and the second casting will still consume a turn.
		This spell takes no time to cast.]]):
		format(maxlevel)
	end,
}
