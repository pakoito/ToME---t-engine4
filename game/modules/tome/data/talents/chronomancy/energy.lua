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
	name = "Entropy",
	type = {"chronomancy/energy", 1},
	require = chrono_req1,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 6,
	getCooldown = function(self, t) return 2 + math.ceil(self:getTalentLevel(t) * getParadoxModifier(self, pm)) end,
	getTalentCount = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = checkBackfire(self, tx, ty)
		if game.level.map(tx, ty, Map.ACTOR) then
			target = game.level.map(tx, ty, Map.ACTOR)
		end
		
		if not self:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
			game.logSeen(target, "%s resists!", target.name:capitalize())
			return true
		end
		
		local tids = {}
		for tid, _ in pairs(target.talents) do
			local tt = target:getTalentFromId(tid)
			if tt.type[1]:find("^inscriptions/") and not target.talents_cd[tid] then
				tids[#tids+1] = tid
			end
		end
		
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			target.talents_cd[tid] = t.getCooldown(self, t)
		end
		self.changed = true
		
		game.logSeen(target, "%s feels the effects of entropy!", target.name:capitalize())
		game.level.map:particleEmitter(tx, ty, 1, "entropythrust")
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local cooldown = t.getCooldown(self, t)
		return ([[You sap the energy out of %d of the targets runes or infusions, placing them on cooldown for %d turns.]]):
		format(talentcount, cooldown)
	end,
}

newTalent{
	name = "Entropic Field",
	type = {"chronomancy/energy", 2},
	mode = "sustained",
	require = chrono_req2,
	points = 5,
	sustain_paradox = 150,
	cooldown = 20,
	tactical = { BUFF = 2 },
	getPower = function(self, t) return 10 + (self:combatTalentSpellDamage(t, 10, 50)) end,
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
		return ([[You encase yourself in a field that slows incoming projectiles by %d%% and grants you %d%% physical resistance.
		The effect will scale with the Magic stat.]]):format(power, power / 2)
	end,
}

newTalent{
	name = "Energy Decomposition",
	type = {"chronomancy/energy",3},
	require = chrono_req3,
	points = 5,
	paradox = 15,
	cooldown = 24,
	tactical = { DISABLE = 2 },
	direct_hit = true,
	requires_target = true,
	range = 6,
	getRemoveCount = function(self, t) return math.floor(self:getTalentLevel(t)*getParadoxModifier(self, pm)) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local tx, ty = self:getTarget(tg)
		if not tx or not ty then return nil end
		tx, ty = checkBackfire(self, tx, ty)
		if game.level.map(tx, ty, Map.ACTOR) then
			target = game.level.map(tx, ty, Map.ACTOR)
		end
		
		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
		local e = target.tempeffect_def[eff_id]
			if e.type == "magical" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Go through all sustained spells
		for tid, act in pairs(target.sustain_talents) do
		local talent = target:getTalentFromId(tid)
			if talent.is_spell then
				effs[#effs+1] = {"talent", tid}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)
			
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			else
				target:forceUseTalent(eff[2], {ignore_energy=true})
			end
		end
		game.level.map:particleEmitter(tx, ty, 1, "entropythrust")
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[Removes up to %d magical effects or sustained spells (both good and bad) from the target.
		The number of effects removed will scale with your Paradox.]]):
		format(count)
	end,
}

newTalent{
	name = "Redux",
	type = {"chronomancy/energy",4},
	require = chrono_req4,
	points = 5,
	paradox = 30,
	cooldown = 50,
	tactical = { BUFF = 2 },
	getTalentCount = function(self, t) return math.ceil(self:getTalentLevel(t) + 2) end,
	getMaxLevel = function(self, t) return self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if tt.type[2] <= t.getMaxLevel(self, t) and tt.type[1]:find("^chronomancy/") then
				tids[#tids+1] = tid
			end
		end
		for i = 1, t.getTalentCount(self, t) do
			if #tids == 0 then break end
			local tid = rng.tableRemove(tids)
			self.talents_cd[tid] = nil
		end
		self.changed = true
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local talentcount = t.getTalentCount(self, t)
		local maxlevel = t.getMaxLevel(self, t)
		return ([[Your mastery of energy allows you to reset the cooldown of %d of your chronomantic spells of level %d or less.]]):
		format(talentcount, maxlevel)
	end,
}