-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

newInscription = function(t)
	-- Warning, up that if more than 5 inscriptions are ever allowed
	for i = 1, 6 do
		local tt = table.clone(t)
		tt.short_name = tt.name:upper():gsub("[ ]", "_").."_"..i
		tt.display_name = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.item_name then
				local n = tstring{t.name, " ["}
				n:merge(data.item_name)
				n:add("]")
				return n
			else
				return t.name
			end
		end
		if tt.type[1] == "inscriptions/infusions" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_INFUSION_COOLDOWN) end
		elseif tt.type[1] == "inscriptions/runes" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_RUNE_COOLDOWN) end
		elseif tt.type[1] == "inscriptions/taints" then tt.auto_use_check = function(self, t) return not self:hasEffect(self.EFF_TAINT_COOLDOWN) end
		end
		tt.auto_use_warning = "- will only auto use when no saturation effect exists"
		tt.cooldown = function(self, t)
			local data = self:getInscriptionData(t.short_name)
			return data.cooldown
		end
		tt.old_info = tt.info
		tt.info = function(self, t)
			local ret = t.old_info(self, t)
			local data = self:getInscriptionData(t.short_name)
			if data.use_stat and data.use_stat_mod then
				ret = ret..("\nIts effects scale with your %s stat."):format(self.stats_def[data.use_stat].name)
			end
			return ret
		end
		if not tt.image then
			tt.image = "talents/"..(t.short_name or t.name):lower():gsub("[^a-z0-9_]", "_")..".png"
		end
		tt.no_unlearn_last = true
		tt.is_inscription = true
		newTalent(tt)
	end
end

-----------------------------------------------------------------------
-- Infusions
-----------------------------------------------------------------------
newInscription{
	name = "Infusion: Regeneration",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	on_pre_use = function(self, t) return not self:hasEffect(self.EFF_REGENERATION) end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_REGENERATION, data.dur, {power=(data.heal + data.inc_stat) / data.dur})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to heal yourself for %d life over %d turns.]]):format(data.heal + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[heal %d over %d turns]]):format(data.heal + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Infusion: Healing",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { HEAL = 2 },
	is_heal = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:attr("allow_on_heal", 1)
		self:heal(data.heal + data.inc_stat, t)
		self:attr("allow_on_heal", -1)
		if core.shader.active(4) then
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=true , size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=2.0}))
			self:addParticles(Particles.new("shader_shield_temp", 1, {toback=false, size_factor=1.5, y=-0.3, img="healgreen", life=25}, {type="healing", time_factor=2000, beamsCount=20, noup=1.0}))
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to heal yourself for %d life.]]):format(data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[heal %d]]):format(data.heal + data.inc_stat)
	end,
}

newInscription{
	name = "Infusion: Wild",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if data.what[e.type] and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local force = {}
		local known = false

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if data.what[e.type] and e.status == "detrimental" and e.subtype["cross tier"] then
				force[#force+1] = {"effect", eff_id}
			elseif data.what[e.type] and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Cross tier effects are always removed and not part of the random game, otherwise it is a huge nerf to wild infusion
		for i = 1, #force do
			local eff = force[i]
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end

		for i = 1, 1 do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		self:setEffect(self.EFF_PAIN_SUPPRESSION, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[Activate the infusion to cure yourself of %s effects and reduce all damage taken by %d%% for %d turns.]]):format(what, data.power+data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[resist %d%%; cure %s]]):format(data.power + data.inc_stat, what)
	end,
}

-- fixedart wild variant
newInscription{
	name = "Infusion: Primal", image = "talents/infusion__wild.png",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = {
		DEFEND = 3,
		CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if data.what[e.type] and e.status == "detrimental" then
					nb = nb + 1
				end
			end
			return nb
		end
	},
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)

		local target = self
		local effs = {}
		local force = {}
		local known = false

		-- Go through all temporary effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if data.what[e.type] and e.status == "detrimental" and e.subtype["cross tier"] then
				force[#force+1] = {"effect", eff_id}
			elseif data.what[e.type] and e.status == "detrimental" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		-- Cross tier effects are always removed and not part of the random game, otherwise it is a huge nerf to wild infusion
		for i = 1, #force do
			local eff = force[i]
			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end

		for i = 1, 1 do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
				known = true
			end
		end
		if known then
			game.logSeen(self, "%s is cured!", self.name:capitalize())
		end
		self:setEffect(self.EFF_PRIMAL_ATTUNEMENT, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[Activate the infusion to cure yourself of %s effects and increase affinity for all damage by %d%% for %d turns.]]):format(what, data.power+data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local what = table.concat(table.keys(data.what), ", ")
		return ([[affinity %d%%; cure %s]]):format(data.power + data.inc_stat, what)
	end,
}

newInscription{
	name = "Infusion: Movement",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { DEFEND = 1 },
	on_pre_use = function(self, t) return not self:attr("never_move") end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_FREE_ACTION, data.dur, {power=1})
		game:onTickEnd(function() self:setEffect(self.EFF_WILD_SPEED, 1, {power=data.speed + data.inc_stat}) end)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to increase movement speed by %d%% for 1 game turn.
		Any actions other than movement will cancel the effect.
		Also prevent stuns, dazes and pinning effects for %d turns.
		Note: since you will be moving very fast, game turns will pass very slowly.]]):format(data.speed + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d%% speed; %d turns]]):format(data.speed + data.inc_stat, data.dur)
	end,
}



newInscription{
	name = "Infusion: Sun",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = 1, DISABLE = { blind = 2 } },
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, engine.DamageType.BLINDCUSTOMMIND, {power=data.power + data.inc_stat, turns=data.turns})
		self:project(tg, self.x, self.y, engine.DamageType.BREAK_STEALTH, {power=(data.power + data.inc_stat)/2, turns=data.turns})
		tg.selffire = true
		self:project(tg, self.x, self.y, engine.DamageType.LITE, data.power >= 19 and 100 or 1)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to brighten the area in a radius of %d and illuminate stealthy creatures, possibly revealing them (reduces stealth power by %d).%s
		It will also blind any creatures caught inside (power %d) for %d turns.]]):
		format(data.range, (data.power + data.inc_stat)/2, data.power >= 19 and "\nThe light is so powerful it will also banish magical darkness" or "", data.power + data.inc_stat, data.turns)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[rad %d; power %d; turns %d%s]]):format(data.range, data.power + data.inc_stat, data.turns, data.power >= 19 and "; dispells darkness" or "")
	end,
}

newInscription{
	name = "Infusion: Heroism",
	type = {"inscriptions/infusions", 1},
	points = 1,
	no_energy = true,
	tactical = { BUFF = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_HEROISM, data.dur, {power=data.power + data.inc_stat, die_at=data.die_at + data.inc_stat * 30})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to increase three of your primary stats by %d for %d turns.
		Also while Heroism is active, you will only die when reaching -%d life. However, when below 0 you cannot see how much life you have left.
		It will always increase your three highest stats.]]):format(data.power + data.inc_stat, data.dur, data.die_at + data.inc_stat * 30)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[+%d for %d turns, die at -%d]]):format(data.power + data.inc_stat, data.dur, data.die_at + data.inc_stat * 30)
	end,
}

newInscription{
	name = "Infusion: Insidious Poison",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACK = { NATURE = 1 }, DISABLE=1, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_slime", trail="slimetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.INSIDIOUS_POISON, {dam=data.power + data.inc_stat, dur=7, heal_factor=data.heal_factor}, {type="slime"})
		self:removeEffectsFilter({status="detrimental", type="magical", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the infusion to spit a bolt of poison doing %0.2f nature damage per turns for 7 turns, and reducing the target's healing received by %d%%.
		The sudden stream of natural forces also strips you of one random detrimental magical effect.]]):format(damDesc(self, DamageType.NATURE, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d nature damage, %d%% healing reduction]]):format(damDesc(self, DamageType.NATURE, data.power + data.inc_stat) / 7, data.heal_factor)
	end,
}

-- Opportunity cost for this is HUGE, it should not hit friendly, also buffed duration
newInscription{
	name = "Infusion: Wild Growth",
	type = {"inscriptions/infusions", 1},
	points = 1,
	tactical = { ATTACKAREA = { PHYSICAL = 1, NATURE = 1 }, DISABLE = 3 },
	range = 0,
	radius = 5,
	direct_hit = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire = false, talent=t}
	end,
	getDamage = function(self, t) return 10 + self:combatMindpower() * 3.6 end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local dam = t.getDamage(self, t)
		local tg = self:getTalentTarget(t)
		self:project(tg, self.x, self.y, function(tx, ty)
			DamageType:get(DamageType.ENTANGLE).projector(self, tx, ty, DamageType.ENTANGLE, dam)
		end)
		self:setEffect(self.EFF_THORNY_SKIN, data.dur, {hard=data.hard or 30, ac=data.armor or 50})
		game:playSoundNear(self, "talents/earth")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local damage = t.getDamage(self, t)
		return ([[Causes thick vines to spring from the ground and entangle all targets within %d squares for %d turns, pinning them in place and dealing %0.2f physical damage and %0.2f nature damage.
		The vines also grow all around you, increasing your armour by %d and armour hardiness by %d.]]):
		format(self:getTalentRadius(t), data.dur, damDesc(self, DamageType.PHYSICAL, damage)/3, damDesc(self, DamageType.NATURE, 2*damage)/3, data.armor or 50, data.hard or 30)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Rad %d for %d turns]]):format(self:getTalentRadius(t), data.dur)
	end,
}

-----------------------------------------------------------------------
-- Runes
-----------------------------------------------------------------------
newInscription{
	name = "Rune: Phase Door",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:setEffect(self.EFF_OUT_OF_PHASE, data.dur or 3, {
			defense=(data.power or data.range) + data.inc_stat * 3,
			resists=(data.power or data.range) + data.inc_stat * 3,
			effect_reduction=(data.power or data.range) + data.inc_stat * 3,
		})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = (data.power or data.range) + data.inc_stat * 3
		return ([[Activate the rune to teleport randomly in a range of %d.
		Afterwards you stay out of phase for %d turns. In this state all new negative status effects duration is reduced by %d%%, your defense is increased by %d and all your resistances by %d%%.]]):
		format(data.range + data.inc_stat, data.dur or 3, power, power, power)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local power = (data.power or data.range) + data.inc_stat * 3
		return ([[range %d; power %d; dur %d]]):format(data.range + data.inc_stat, power, data.dur or 3)
	end,
}

newInscription{
	name = "Rune: Controlled Phase Door",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { CLOSEIN = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=data.range + data.inc_stat, radius=3, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)

		-- Check LOS
		local rad = 3
		if not self:hasLOS(x, y) and rng.percent(35 + (game.level.map.attrs(self.x, self.y, "control_teleport_fizzle") or 0)) then
			game.logPlayer(self, "The targetted phase door fizzles and works randomly!")
			x, y = self.x, self.y
			rad = tg.range
		end

		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport in a range of %d.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[range %d]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Teleportation",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	is_teleport = true,
	tactical = { ESCAPE = 3 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		self:teleportRandom(self.x, self.y, data.range + data.inc_stat, 15)
		game.level.map:particleEmitter(self.x, self.y, 1, "teleport")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to teleport randomly in a range of %d with a minimum range of 15.]]):format(data.range + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[range %d]]):format(data.range + data.inc_stat)
	end,
}

newInscription{
	name = "Rune: Shielding",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	allow_autocast = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, data.dur, {power=data.power + data.inc_stat})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to create a protective shield absorbing at most %d damage for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[absorb %d for %d turns]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Reflection Shield",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	allow_autocast = true,
	no_energy = true,
	tactical = { DEFEND = 2 },
	on_pre_use = function(self, t)
		return not self:hasEffect(self.EFF_DAMAGE_SHIELD)
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 5, {power=100+5*self:getMag(), reflect=100})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to create a protective shield absorbing and reflecting at most %d damage for %d turns.
The effect will scale with your magic stat.]]):format(100+1.5*self:getMag(), 5)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[absorb and reflect %d for %d turns]]):format(100+5*self:getMag(), 5)
	end,
}

newInscription{
	name = "Rune: Invisibility",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DEFEND = 3, ESCAPE = 2 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_INVISIBILITY, data.dur, {power=data.power + data.inc_stat, penalty=0.4})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to become invisible (power %d) for %d turns.
		As you become invisible you fade out of phase with reality, all your damage is reduced by 40%%.
		]]):format(data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[power %d for %d turns]]):format(data.power + data.inc_stat, data.dur)
	end,
}

newInscription{
	name = "Rune: Speed",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_energy = true,
	tactical = { BUFF = 4 },
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:setEffect(self.EFF_SPEED, data.dur, {power=(data.power + data.inc_stat) / 100})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to increase your global speed by %d%% for %d turns.]]):format(data.power + data.inc_stat, data.dur)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[speed %d%% for %d turns]]):format(data.power + data.inc_stat, data.dur)
	end,
}


newInscription{
	name = "Rune: Vision",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	no_npc_use = true,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:magicMap(data.range, self.x, self.y, function(x, y)
			local g = game.level.map(x, y, Map.TERRAIN)
			if g and (g.always_remember or g:check("block_move")) then
				for _, coord in pairs(util.adjacentCoords(x, y)) do
					local g2 = game.level.map(coord[1], coord[2], Map.TERRAIN)
					if g2 and not g2:check("block_move") then return true end
				end
			end
		end)
		self:setEffect(self.EFF_SENSE_HIDDEN, data.dur, {power=data.power + data.inc_stat})
		self:setEffect(self.EFF_RECEPTIVE_MIND, data.dur, {what=data.esp or "humanoid"})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to get a vision of the area surrounding you (%d radius) and to allow you to see invisible and stealthed creatures (power %d) for %d turns.
		Your mind will become more receptive for %d turns, allowing you to sense any %s around.]]):
		format(data.range, data.power + data.inc_stat, data.dur, data.dur, data.esp or "humanoid")
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[radius %d; dur %d; see %s]]):format(data.range, data.dur, data.esp or "humanoid")
	end,
}

local function attack_rune(self, btid)
	for tid, lev in pairs(self.talents) do
		if tid ~= btid and self.talents_def[tid].is_attack_rune and not self.talents_cd[tid] then
			self.talents_cd[tid] = 1
		end
	end
end

newInscription{
	name = "Rune: Heat Beam",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { FIRE = 1 }, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "physical" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIREBURN, {dur=5, initial=0, dam=data.power + data.inc_stat})
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
		self:removeEffectsFilter({status="detrimental", type="physical", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/fire")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to fire a beam of heat, doing %0.2f fire damage over 5 turns
		The intensity of the heat will also remove one random detrimental physical effect from you.]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d fire damage]]):format(damDesc(self, DamageType.FIRE, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Frozen Spear",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { COLD = 1 }, DISABLE = { stun = 1 }, CURE = function(self, t, target)
			local nb = 0
			local data = self:getInscriptionData(t.short_name)
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "mental" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end },
	requires_target = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_ice", trail="icetrail"}}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ICE, data.power + data.inc_stat, {type="freeze"})
		self:removeEffectsFilter({status="detrimental", type="mental", ignore_crosstier=true}, 1)
		game:playSoundNear(self, "talents/ice")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to fire a bolt of ice, doing %0.2f cold damage with a chance to freeze the target.
		The deep cold also crystalizes your mind, removing one random detrimental mental effect from you.]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d cold damage]]):format(damDesc(self, DamageType.COLD, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Acid Wave",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACKAREA = { ACID = 1 } },
	requires_target = true,
	direct_hit = true,
	range = 0,
	radius = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local pow = data.reduce or 15
		self:project(tg, self.x, self.y, DamageType.ACID_CORRODE, {dam=data.power + data.inc_stat, dur=data.dur or 3, atk=pow, armor=pow, defense=pow})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_acid", {radius=tg.radius})
		game:playSoundNear(self, "talents/slime")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local pow = data.reduce or 15
		return ([[Activate the rune to fire a self-centered acid wave of radius %d, doing %0.2f acid damage.
		The corrosive acid will also reduce accuracy, defense and armour by %d for %d turns.]]):
		format(self:getTalentRadius(t), damDesc(self, DamageType.ACID, data.power + data.inc_stat), pow, data.dur or 3)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local pow = data.reduce or 15
		return ([[%d acid damage; power %d; dur %d]]):format(damDesc(self, DamageType.ACID, data.power + data.inc_stat), pow, data.dur or 3)
	end,
}

newInscription{
	name = "Rune: Lightning",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_attack_rune = true,
	no_energy = true,
	is_spell = true,
	tactical = { ATTACK = { LIGHTNING = 1 } },
	requires_target = true,
	direct_hit = true,
	range = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return data.range
	end,
	target = function(self, t)
		return {type="beam", range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = data.power + data.inc_stat
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		self:setEffect(self.EFF_ELEMENTAL_SURGE_LIGHTNING, 2, {})
		game:playSoundNear(self, "talents/lightning")
		attack_rune(self, t.id)
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local dam = damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat)
		return ([[Activate the rune to fire a beam of lightning, doing %0.2f to %0.2f lightning damage.
		Also transform you into pure lightning for %d turns; any damage will teleport you to an adjacent tile and ignore the damage (can only happen once per turn)]]):
		format(dam / 3, dam, 2)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d lightning damage]]):format(damDesc(self, DamageType.LIGHTNING, data.power + data.inc_stat))
	end,
}

newInscription{
	name = "Rune: Manasurge",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { MANA = 1 },
	on_pre_use = function(self, t)
		return self:knowTalent(self.T_MANA_POOL) and not self:hasEffect(self.EFF_MANASURGE)
	end,
	on_learn = function(self, t)
		self.mana_regen_on_rest = (self.mana_regen_on_rest or 0) + 0.5
	end,
	on_unlearn = function(self, t)
		self.mana_regen_on_rest = (self.mana_regen_on_rest or 0) - 0.5
	end,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		self:incMana((data.mana + data.inc_stat) / 20)
		if self.mana_regen > 0 then
			self:setEffect(self.EFF_MANASURGE, data.dur, {power=self.mana_regen * (data.mana + data.inc_stat) / 100})
		else
			if self.mana_regen < 0 then
				game.logPlayer(self, "Your negative mana regeneration rate is unaffected by the rune.")
			else
				game.logPlayer(self, "Your nonexistant mana regeneration rate is unaffected by the rune.")
			end
		end
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the rune to unleash a manasurge upon yourself, increasing mana regeneration by %d%% over %d turns and instantly restoring %d mana.
			Also when resting your mana will regenerate at 0.5 per turn.]]):format(data.mana + data.inc_stat, data.dur, (data.mana + data.inc_stat) / 20)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d%% regen over %d turns; %d instant mana]]):format(data.mana + data.inc_stat, data.dur, (data.mana + data.inc_stat) / 20)
	end,
}

-- This is mostly a copy of Time Skip :P
newInscription{
	name = "Rune of the Rift",
	type = {"inscriptions/runes", 1},
	points = 1,
	is_spell = true,
	tactical = { DISABLE = 2, ATTACK = { TEMPORAL = 1 } },
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	range = 4,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), talent=t}
	end,
	getDamage = function(self, t) return 150 + self:getWil() * 4 end,
	getDuration = function(self, t) return 4 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, Map.ACTOR)
		if not target then return end

		if target:attr("timetravel_immune") then
			game.logSeen(target, "%s is immune!", target.name:capitalize())
			return
		end

		local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
		if not hit then game.logSeen(target, "%s resists!", target.name:capitalize()) return true end

		self:project(tg, x, y, DamageType.TEMPORAL, self:spellCrit(t.getDamage(self, t)))
		game.level.map:particleEmitter(x, y, 1, "temporal_thrust")
		game:playSoundNear(self, "talents/arcane")
		self:incParadox(-60)
		if target.dead or target.player then return true end
		target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		
		-- Replace the target with a temporal instability for a few turns
		local oe = game.level.map(target.x, target.y, engine.Map.TERRAIN)
		if not oe or oe:attr("temporary") then return true end
		local e = mod.class.Object.new{
			old_feat = oe, type = oe.type, subtype = oe.subtype,
			name = "temporal instability", image = oe.image, add_mos = {{image="object/temporal_instability.png"}},
			display = '&', color=colors.LIGHT_BLUE,
			temporary = t.getDuration(self, t),
			canAct = false,
			target = target,
			act = function(self)
				self:useEnergy()
				self.temporary = self.temporary - 1
				-- return the rifted actor
				if self.temporary <= 0 then
					game.level.map(self.target.x, self.target.y, engine.Map.TERRAIN, self.old_feat)
					game.level:removeEntity(self, true)
					local mx, my = util.findFreeGrid(self.target.x, self.target.y, 20, true, {[engine.Map.ACTOR]=true})
					local old_levelup = self.target.forceLevelup
					self.target.forceLevelup = function() end
					game.zone:addEntity(game.level, self.target, "actor", mx, my)
					self.target.forceLevelup = old_levelup
				end
			end,
			summoner_gain_exp = true, summoner = self,
		}
		
		game.logSeen(target, "%s has moved forward in time!", target.name:capitalize())
		game.level:removeEntity(target, true)
		game.level:addEntity(e)
		game.level.map(x, y, Map.TERRAIN, e)
		game.nicer_tiles:updateAround(game.level, x, y)
		game.level.map:updateMap(x, y)
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[Inflicts %0.2f temporal damage.  If your target survives, it will be sent %d turns into the future.
		It will also lower your paradox by 60 (if you have any).
		Note that messing with the spacetime continuum may have unforeseen consequences.]]):format(damDesc(self, DamageType.TEMPORAL, damage), duration)
	end,
	short_info = function(self, t)
		return ("%0.2f temporal damage, removed from time %d turns"):format(t.getDamage(self, t), t.getDuration(self, t))
	end,
}

-----------------------------------------------------------------------
-- Taints
-----------------------------------------------------------------------
newInscription{
	name = "Taint: Devourer",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	tactical = { ATTACK = 1, HEAL=1 },
	requires_target = true,
	direct_hit = true,
	no_energy = true,
	range = 5,
	action = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" or e.type == "physical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					effs[#effs+1] = {"talent", tid}
				end
			end

			local nb = data.effects
			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				else
					target:forceUseTalent(eff[2], {ignore_energy=true})
				end
				self:attr("allow_on_heal", 1)
				self:heal(data.heal + data.inc_stat, t)
				self:attr("allow_on_heal", -1)
				if core.shader.active(4) then
					self:addParticles(Particles.new("shader_shield_temp", 1, {size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=2.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
					self:addParticles(Particles.new("shader_shield_temp", 1, {size_factor=1.5, y=-0.3, img="healdark", life=25}, {type="healing", time_factor=6000, beamsCount=15, noup=1.0, beamColor1={0xcb/255, 0xcb/255, 0xcb/255, 1}, beamColor2={0x35/255, 0x35/255, 0x35/255, 1}}))
				end
			end

			game.level.map:particleEmitter(px, py, 1, "shadow_zone")
		end)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Activate the taint on a foe, removing %d effects from it and healing you for %d for each effect.]]):format(data.effects, data.heal + data.inc_stat)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[%d effects / %d heal]]):format(data.effects, data.heal + data.inc_stat)
	end,
}


newInscription{
	name = "Taint: Telepathy",
	type = {"inscriptions/taints", 1},
	points = 1,
	is_spell = true,
	range = 10,
	action = function(self, t)
		local rad = self:getTalentRange(t)
		self:setEffect(self.EFF_SENSE, 5, {
			range = rad,
			actor = 1,
		})
		self:setEffect(self.EFF_WEAKENED_MIND, 10, {save=10, power=35})
		return true
	end,
	info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Strip the protective barriers from your mind for %d turns, allowing in the thoughts all creatures within %d squares but reducing mind save by %d and increasing your mindpower by %d for 10 turns.]]):format(data.dur, self:getTalentRange(t), 10, 35)
	end,
	short_info = function(self, t)
		local data = self:getInscriptionData(t.short_name)
		return ([[Range %d telepathy for %d turns]]):format(self:getTalentRange(t), data.dur)
	end,
}

