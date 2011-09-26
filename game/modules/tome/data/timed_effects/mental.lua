-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Astar = require "engine.Astar"

newEffect{
	name = "SILENCED",
	desc = "Silenced",
	long_desc = function(self, eff) return "The target is silenced, preventing it from casting spells and using some vocal talents." end,
	type = "mental",
	subtype = { silence=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is silenced!", "+Silenced" end,
	on_lose = function(self, err) return "#Target# is not silenced anymore.", "-Silenced" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("silence", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("silence", eff.tmpid)
	end,
}

newEffect{
	name = "MEDITATION",
	desc = "Meditation",
	long_desc = function(self, eff) return "The target is meditating. Any damage will stop it." end,
	type = "mental",
	subtype = { focus=true },
	status = "detrimental",
	parameters = {},
	on_timeout = function(self, eff)
		self:incEquilibrium(-eff.per_turn)
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("dazed", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("dazed", eff.tmpid)
		if eff.dur <= 0 then
			self:incEquilibrium(-eff.final)
		end
	end,
}

newEffect{
	name = "SUMMON_CONTROL",
	desc = "Summon Control",
	long_desc = function(self, eff) return ("Reduces damage received by %d%% and increases summon time by %d."):format(eff.res, eff.incdur) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { res=10, incdur=10 },
	activate = function(self, eff)
		eff.resid = self:addTemporaryValue("resists", {all=eff.res})
		eff.durid = self:addTemporaryValue("summon_time", eff.incdur)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resid)
		self:removeTemporaryValue("summon_time", eff.durid)
	end,
	on_timeout = function(self, eff)
		eff.dur = self.summon_time
	end,
}

newEffect{
	name = "CONFUSED",
	desc = "Confused",
	long_desc = function(self, eff) return ("The target is confused, acting randomly (chance %d%%) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	subtype = { confusion=true },
	status = "detrimental",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target# wanders around!.", "+Confused" end,
	on_lose = function(self, err) return "#Target# seems more focused.", "-Confused" end,
	activate = function(self, eff)
		eff.power = eff.power - (self:attr("confusion_immune") or 0) / 2
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "DOMINANT_WILL",
	desc = "Dominated",
	long_desc = function(self, eff) return ("The target's mind has been shattered. Its body remains as a thrall to your mind.") end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target#'s mind is shattered." end,
	on_lose = function(self, err) return "#Target# collapses." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=-15})
		self.faction = eff.src.faction
		self.ai_state = self.ai_state or {}
		self.ai_state.tactic_leash = 100
		self.remove_from_party_on_death = true
		self.no_inventory_access = true
		self.move_others = true
		self.summoner = eff.src
		self.summoner_gain_exp = true
		game.party:addMember(self, {
			control="full",
			type="thrall",
			title="Thrall",
			orders = {leash=true, follow=true},
			on_control = function(self)
				self:hotkeyAutoTalents()
			end,
		})
	end,
	deactivate = function(self, eff)
		self:die(eff.src)
	end,
}

newEffect{
	name = "BATTLE_SHOUT",
	desc = "Battle Shout",
	long_desc = function(self, eff) return ("Increases maximum life and stamina by %d%%."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.life = self:addTemporaryValue("max_life", self.max_life * eff.power / 100)
		eff.stamina = self:addTemporaryValue("max_stamina", self.max_stamina * eff.power / 100)
		self:heal(self.max_life * eff.power / 100)
		self:incStamina(self.max_stamina * eff.power / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.life)
		self:removeTemporaryValue("max_stamina", eff.stamina)
	end,
}

newEffect{
	name = "BATTLE_CRY",
	desc = "Battle Cry",
	long_desc = function(self, eff) return ("The target's will to defend itself is shattered by the powerful battle cry, reducing defense by %d."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s will is shattered.", "+Battle Cry" end,
	on_lose = function(self, err) return "#Target# regains some of its will.", "-Battle Cry" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_def", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.tmpid)
	end,
}

newEffect{
	name = "WILLFUL_COMBAT",
	desc = "Willful Combat",
	long_desc = function(self, eff) return ("The target puts all its willpower into its blows, improving damage by %d."):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# lashes out with pure willpower." end,
	on_lose = function(self, err) return "#Target#'s willpower rush ends." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_dam", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.tmpid)
	end,
}

newEffect{
	name = "GLOOM_WEAKNESS",
	desc = "Gloom Weakness",
	long_desc = function(self, eff) return ("The gloom reduces the target's attack by %d and damage rating by %d."):format(eff.atk, eff.dam) end,
	type = "mental",
	subtype = { gloom=true },
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#F53CBE##Target# is weakened by the gloom." end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer weakened." end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_weakness", 1))
		eff.atkid = self:addTemporaryValue("combat_atk", -eff.atk)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.dam)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("combat_atk", eff.atkid)
		self:removeTemporaryValue("combat_dam", eff.damid)
	end,
}

newEffect{
	name = "GLOOM_SLOW",
	desc = "Slowed by the gloom",
	long_desc = function(self, eff) return ("The gloom reduces the target's global speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	subtype = { gloom=true, slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target# moves reluctantly!", "+Slow" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom.", "-Slow" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "GLOOM_STUNNED",
	desc = "Paralyzed by the gloom",
	long_desc = function(self, eff) return "The gloom has paralyzed the target, rendering it unable to act." end,
	type = "mental",
	subtype = { gloom=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is paralyzed with fear!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Paralyzed" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("paralyzed", eff.tmpid)
		if not self:attr("paralyzed") then self.paralyzed_counter = nil end
	end,
}

newEffect{
	name = "GLOOM_CONFUSED",
	desc = "Confused by the gloom",
	long_desc = function(self, eff) return ("The gloom has confused the target, making it act randomly (%d%% chance) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	subtype = { gloom=true, confusion=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is lost in despair!", "+Confused" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Confused" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "STALKER",
	desc = "Stalking",
	display_desc = function(self, eff)
		return ([[Stalking %d/%d +%d ]]):format(eff.target.life, eff.target.max_life, eff.bonus)
	end,
	long_desc = function(self, eff)
		local t = self:getTalentFromId(self.T_STALK)
		local effStalked = eff.target:hasEffect(eff.target.EFF_STALKED)
		local desc = ([[Stalking %s. Bonus level %d: +%d attack, +%d%% melee damage, +%0.3f hate/turn prey was hit.]]):format(
			eff.target.name, eff.bonus, t.getAttackChange(self, t, eff.bonus), t.getStalkedDamageMultiplier(self, t, eff.bonus) * 100 - 100, t.getHitHateChange(self, t, eff.bonus))
		if effStalked and effStalked.damageChange and effStalked.damageChange > 0 then
			desc = desc..([[" Prey damage modifier: %d%%."]]):format(effStalked.damageChange)
		end
		return desc
	end,
	type = "mental",
	subtype = { veil=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		game.logSeen(self, "#F53CBE#%s is being stalked by %s!", eff.target.name:capitalize(), self.name)
	end,
	deactivate = function(self, eff)
		game.logSeen(self, "#F53CBE#%s is no longer being stalked by %s.", eff.target.name:capitalize(), self.name)
	end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead or not eff.target:hasEffect(eff.target.EFF_STALKED) then
			self:removeEffect(self.EFF_STALKER)
		end
	end,
}

newEffect{
	name = "STALKED",
	desc = "Stalked",
	long_desc = function(self, eff)
		local effStalker = eff.source:hasEffect(eff.source.EFF_STALKER)
		local t = self:getTalentFromId(eff.source.T_STALK)
		local desc = ([[Being stalked by %s. Stalker bonus level %d: +%d attack, +%d%% melee damage, +%0.3f hate/turn prey was hit.]]):format(
			eff.source.name, effStalker.bonus, t.getAttackChange(eff.source, t, effStalker.bonus), t.getStalkedDamageMultiplier(eff.source, t, effStalker.bonus) * 100 - 100, t.getHitHateChange(eff.source, t, effStalker.bonus))
		if eff.damageChange and eff.damageChange > 0 then
			desc = desc..([[" Prey damage modifier: %d%%."]]):format(eff.damageChange)
		end
		return desc
	end,
	type = "mental",
	subtype = { veil=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		local effStalker = eff.source:hasEffect(eff.source.EFF_STALKER)
		eff.particleBonus = effStalker.bonus
		eff.particle = self:addParticles(Particles.new("stalked", 1, { bonus = eff.particleBonus }))
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		if eff.damageChangeId then self:removeTemporaryValue("inc_damage", eff.damageChangeId) end
	end,
	on_timeout = function(self, eff)
		if not eff.source or eff.source.dead or not eff.source:hasEffect(eff.source.EFF_STALKER) then
			self:removeEffect(self.EFF_STALKED)
		else
			local effStalker = eff.source:hasEffect(eff.source.EFF_STALKER)
			if eff.particleBonus ~= effStalker.bonus then
				eff.particleBonus = effStalker.bonus
				self:removeParticles(eff.particle)
				eff.particle = self:addParticles(Particles.new("stalked", 1, { bonus = eff.particleBonus }))
			end
		end
	end,
	updateDamageChange = function(self, eff)
		if eff.damageChangeId then
			self:removeTemporaryValue("inc_damage", eff.damageChangeId)
			eff.damageChangeId = nil
		end
		if eff.damageChange and eff.damageChange > 0 then
			eff.damageChangeId = eff.target:addTemporaryValue("inc_damage", {all=eff.damageChange})
		end
	end,
}

newEffect{
	name = "BECKONED",
	desc = "Beckoned",
	long_desc = function(self, eff)
		local message = ("The target has been beckoned by %s and is heeding the call. There is a %d%% chance of moving towards the beckoner each turn."):format(eff.source.name, eff.chance)
		if eff.spellpowerChangeId and eff.mindpowerChangeId then
			message = message..(" (spellpower: -%d, mindpower: -%d"):format(eff.spellpowerChange, eff.mindpowerChange)
		end
		return message
	end,
	type = "mental",
	status = "detrimental",
	parameters = { speedChange=0.5 },
	on_gain = function(self, err) return "#Target# has been beckoned.", "+Beckoned" end,
	on_lose = function(self, err) return "#Target# is no longer beckoned.", "-Beckoned" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("beckoned", 1))
		
		eff.spellpowerChangeId = self:addTemporaryValue("combat_spellpower", eff.spellpowerChange)
		eff.mindpowerChangeId = self:addTemporaryValue("combat_mindpower", eff.mindpowerChange)
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		
		if eff.spellpowerChangeId then self:removeTemporaryValue("combat_spellpower", eff.spellpowerChangeId) end
		if eff.mindpowerChangeId then self:removeTemporaryValue("combat_mindpower", eff.spellpowerChangeId) end
	end,
	on_timeout = function(self, eff)
		if eff.source.dead then return nil end
		
		local distance = core.fov.distance(self.x, self.y, eff.source.x, eff.source.y)
		if math.floor(distance) > 1 and distance <= eff.range then
			-- in range but not adjacent
			
			-- add debuffs
			if not eff.spellpowerChangeId then eff.spellpowerChangeId = self:addTemporaryValue("combat_spellpower", eff.spellpowerChange) end
			if not eff.mindpowerChangeId then eff.mindpowerChangeId = self:addTemporaryValue("combat_mindpower", eff.mindpowerChange) end
			
			-- custom pull logic (adapted from move_dmap; forces movement, pushes others aside, custom particles)
			if not self:attr("never_move") and rng.percent(eff.chance) then
				local source = eff.source
				local moveX, moveY = source.x, source.y -- move in general direction by default
				if not self:hasLOS(source.x, source.y) then
					-- move using dmap if available
					--local c = source:distanceMap(self.x, self.y)
					--if c then
					--	local dir = 5
					--	for i = 1, 9 do
					--		local sx, sy = util.coordAddDir(self.x, self.y, i)
					--		local cd = source:distanceMap(sx, sy)
					--		if cd and cd > c and self:canMove(sx, sy) then c = cd; dir = i end
					--	end
					--	if i ~= 5 then
					--		moveX, moveY = util.coordAddDir(self.x, self.y, dir)
					--	end
					--end
					
					-- move a-star (far more useful than dmap)
					local a = Astar.new(game.level.map, self)
					local path = a:calc(self.x, self.y, source.x, source.y)
					if path then
						moveX, moveY = path[1].x, path[1].y
					end
				end
				
				if moveX and moveY then
					local old_move_others, old_x, old_y = self.move_others, self.x, self.y
					self.move_others = true
					self:moveDirection(moveX, moveY, true)
					self.move_others = old_move_others
					if old_x ~= self.x or old_y ~= self.y then
						if not self.did_energy then
							self:useEnergy()
						end
						game.level.map:particleEmitter(self.x, self.y, 1, "beckoned_move", {power=power, dx=self.x - source.x, dy=self.y - source.y})
					end
				end
			end
		else
			-- adjacent or out of range..remove debuffs
			if eff.spellpowerChangeId then self:removeTemporaryValue("combat_spellpower", eff.spellpowerChangeId) end
			if eff.mindpowerChangeId then self:removeTemporaryValue("combat_mindpower", eff.spellpowerChangeId) end
		end
	end,
}

newEffect{
	name = "OVERWHELMED",
	desc = "Overwhelmed",
	long_desc = function(self, eff) return ("The target has been overwhemed by a furious assault, reducing attack by %d."):format( -eff.attackChange) end,
	type = "mental",
	status = "detrimental",
	parameters = { damageChange=0.1 },
	on_gain = function(self, err) return "#Target# has been overwhelmed.", "+Overwhelmed" end,
	on_lose = function(self, err) return "#Target# is no longer overwhelmed.", "-Overwhelmed" end,
	activate = function(self, eff)
		eff.attackChangeId = self:addTemporaryValue("combat_atk", eff.attackChange)
		eff.particle = self:addParticles(Particles.new("overwhelmed", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.attackChangeId)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "HARASSED",
	desc = "Harassed",
	long_desc = function(self, eff) return ("The target has been harassed by it's stalker, reducing damage by %d%%."):format( -eff.damageChange * 100) end,
	type = "mental",
	status = "detrimental",
	parameters = { damageChange=0.1 },
	on_gain = function(self, err) return "#Target# has been harassed.", "+Harassed" end,
	on_lose = function(self, err) return "#Target# is no longer harassed.", "-Harassed" end,
	activate = function(self, eff)
		eff.damageChangeId = self:addTemporaryValue("inc_damage", {all=eff.damageChange})
		eff.particle = self:addParticles(Particles.new("harassed", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.damageChangeId)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "BLINDSIDE_BONUS",
	desc = "Blindside Bonus",
	long_desc = function(self, eff) return ("The target has appeared out of nowhere! It's defense is boosted by %d."):format(eff.defenseChange) end,
	type = "physical",
	status = "beneficial",
	parameters = { defenseChange=10 },
	activate = function(self, eff)
		eff.defenseChangeId = self:addTemporaryValue("combat_def", eff.defenseChange)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_def", eff.defenseChangeId)
	end,
}

newEffect{
	name = "DOMINATED",
	desc = "Dominated",
	long_desc = function(self, eff) return ("The target is dominated, unable to move and losing %d armor, %d defense and suffering %d%% penetration for damage from its master."):format(-eff.armorChange, -eff.defenseChange, eff.resistPenetration) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	on_gain = function(self, err) return "#F53CBE##Target# has been dominated!", "+Dominated" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer dominated.", "-Dominated" end,
	parameters = { armorChange = -3, defenseChange = -3, physicalResistChange = -0.1 },
	activate = function(self, eff)
		eff.neverMoveId = self:addTemporaryValue("never_move", 1)
		eff.armorId = self:addTemporaryValue("combat_armor", eff.armorChange)
		eff.defenseId = self:addTemporaryValue("combat_def", eff.armorChange)
		
		eff.particle = self:addParticles(Particles.new("dominated", 1))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("never_move", eff.neverMoveId)
		self:removeTemporaryValue("combat_armor", eff.armorId)
		self:removeTemporaryValue("combat_def", eff.defenseId)
		
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "RADIANT_FEAR",
	desc = "Radiating Fear",
	long_desc = function(self, eff) return "The target is frightening, pushing away other creatures." end,
	type = "mental",
	subtype = { fear=true },
	status = "beneficial",
	parameters = { knockback = 1, radius = 3 },
	on_gain = function(self, err) return "#F53CBE##Target# is surrounded by fear!", "+Radiant Fear" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer surrounded by fear.", "-Radiant Fear" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("radiant_fear", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		self:project({type="ball", radius=eff.radius, selffire=false}, self.x, self.y, function(xx, yy)
			local target = game.level.map(xx, yy, game.level.map.ACTOR)
			if target and target ~= self and target ~= eff.source and target:canBe("knockback") and (target.never_move or 0) ~= 1 then
				-- attempt to move target away from self
				local currentDistance = core.fov.distance(self.x, self.y, xx, yy)
				local bestDistance, bestX, bestY
				for i = 0, 8 do
					local x = xx + (i % 3) - 1
					local y = yy + math.floor((i % 9) / 3) - 1
					if x ~= xx or y ~= yy then
						local distance = core.fov.distance(self.x, self.y, x, y)
						if distance > currentDistance and (not bestDistance or distance > maxDistance) then
							-- this is a move away, see if it works
							if game.level.map:isBound(x, y) and not game.level.map:checkAllEntities(x, y, "block_move", target) then
								bestDistance, bestX, bestY = distance, x, y
								break
							end
						end
					end
				end

				if bestDistance then
					target:move(bestX, bestY, true)
					if not target.did_energy then target:useEnergy() end
				end
			end
		end)
	end,
}

newEffect{
	name = "INVIGORATED",
	desc = "Invigorated",
	long_desc = function(self, eff) return ("The target is invigorated by death, increasing global speed by %d%%."):format(eff.speed) end,
	type = "mental",
	subtype = { morale=true, speed=true },
	status = "beneficial",
	parameters = { speed = 30, duration = 3 },
	on_gain = function(self, err) return nil, "+Invigorated" end,
	on_lose = function(self, err) return nil, "-Invigorated" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.speed * 0.01)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = math.min(old_eff.dur + new_eff.dur, 15)
		return old_eff
	end,
}

newEffect{
	name = "FEED",
	desc = "Feeding",
	long_desc = function(self, eff) return ("%s is feeding from %s."):format(self.name:capitalize(), eff.target.name) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "beneficial",
	parameters = { },
	activate = function(self, eff)
		eff.src = self

		-- hate
		if eff.hateGain and eff.hateGain > 0 then
			eff.hateGainId = self:addTemporaryValue("hate_regen", eff.hateGain)
		end

		-- health
		if eff.constitutionGain and eff.constitutionGain > 0 then
			eff.constitutionGainId = self:addTemporaryValue("inc_stats",
			{
				[Stats.STAT_CON] = eff.constitutionGain,
			})
			eff.constitutionLossId = eff.target:addTemporaryValue("inc_stats",
			{
				[Stats.STAT_CON] = -eff.constitutionGain,
			})
		end
		if eff.lifeRegenGain and eff.lifeRegenGain > 0 then
			eff.lifeRegenGainId = self:addTemporaryValue("life_regen", eff.lifeRegenGain)
			eff.lifeRegenLossId = eff.target:addTemporaryValue("life_regen", -eff.lifeRegenGain)
		end

		-- power
		if eff.damageGain and eff.damageGain > 0 then
			eff.damageGainId = self:addTemporaryValue("inc_damage", {all=eff.damageGain})
			eff.damageLossId = eff.target:addTemporaryValue("inc_damage", {all=eff.damageLoss})
		end

		-- strengths
		if eff.resistGain and eff.resistGain > 0 then
			local gainList = {}
			local lossList = {}
			for id, resist in pairs(eff.target.resists) do
				if resist > 0 then
					local amount = eff.resistGain * 0.01 * resist
					gainList[id] = amount
					lossList[id] = -amount
				end
			end

			eff.resistGainId = self:addTemporaryValue("resists", gainList)
			eff.resistLossId = eff.target:addTemporaryValue("resists", lossList)
		end

		eff.target:setEffect(eff.target.EFF_FED_UPON, eff.dur, { src = eff.src, target = eff.target })
	end,
	deactivate = function(self, eff)
		-- hate
		if eff.hateGainId then self:removeTemporaryValue("hate_regen", eff.hateGainId) end

		-- health
		if eff.constitutionGainId then self:removeTemporaryValue("inc_stats", eff.constitutionGainId) end
		if eff.constitutionLossId then eff.target:removeTemporaryValue("inc_stats", eff.constitutionLossId) end
		if eff.lifeRegenGainId then self:removeTemporaryValue("life_regen", eff.lifeRegenGainId) end
		if eff.lifeRegenLossId then eff.target:removeTemporaryValue("life_regen", eff.lifeRegenLossId) end

		-- power
		if eff.damageGainId then self:removeTemporaryValue("inc_damage", eff.damageGainId) end
		if eff.damageLossId then eff.target:removeTemporaryValue("inc_damage", eff.damageLossId) end

		-- strengths
		if eff.resistGainId then self:removeTemporaryValue("resists", eff.resistGainId) end
		if eff.resistLossId then eff.target:removeTemporaryValue("resists", eff.resistLossId) end

		if eff.particles then
			-- remove old particle emitter
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end

		eff.target:removeEffect(eff.target.EFF_FED_UPON)
	end,
	updateFeed = function(self, eff)
		local source = eff.src
		local target = eff.target

		if source.dead or target.dead or not game.level:hasEntity(source) or not game.level:hasEntity(target) or not source:hasLOS(target.x, target.y) then
			source:removeEffect(source.EFF_FEED)
			if eff.particles then
				game.level.map:removeParticleEmitter(eff.particles)
				eff.particles = nil
			end
			return
		end

		-- update particles position
		if not eff.particles or eff.particles.x ~= source.x or eff.particles.y ~= source.y or eff.particles.tx ~= target.x or eff.particles.ty ~= target.y then
			if eff.particles then
				game.level.map:removeParticleEmitter(eff.particles)
			end
			-- add updated particle emitter
			local dx, dy = target.x - source.x, target.y - source.y
			eff.particles = Particles.new("feed_hate", math.max(math.abs(dx), math.abs(dy)), { tx=dx, ty=dy })
			eff.particles.x = source.x
			eff.particles.y = source.y
			eff.particles.tx = target.x
			eff.particles.ty = target.y
			game.level.map:addParticleEmitter(eff.particles)
		end
	end
}

newEffect{
	name = "FED_UPON",
	desc = "Fed Upon",
	long_desc = function(self, eff) return ("%s is fed upon by %s."):format(self.name:capitalize(), eff.src.name) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "detrimental",
	remove_on_clone = true,
	parameters = { },
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.target == self and eff.src:hasEffect(eff.src.EFF_FEED) then
			eff.src:removeEffect(eff.src.EFF_FEED)
		end
	end,
}

newEffect{
	name = "AGONY",
	desc = "Agony",
	long_desc = function(self, eff) return ("%s is writhing in agony, suffering from %d to %d damage over %d turns."):format(self.name:capitalize(), eff.damage / eff.duration, eff.damage, eff.duration) end,
	type = "mental",
	subtype = { pain=true, mind=true },
	status = "detrimental",
	parameters = { damage=10, mindpower=10, range=10, minPercent=10 },
	on_gain = function(self, err) return "#Target# is writhing in agony!", "+Agony" end,
	on_lose = function(self, err) return "#Target# is no longer writhing in agony.", "-Agony" end,
	activate = function(self, eff)
		eff.power = 0
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		eff.turn = (eff.turn or 0) + 1

		local damage = math.floor(eff.damage * (eff.turn / eff.duration))
		if damage > 0 then
			DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, damage)
			game:playSoundNear(self, "talents/fire")
		end

		if self.dead then
			if eff.particle then self:removeParticles(eff.particle) end
			return
		end

		if eff.particle then self:removeParticles(eff.particle) end
		eff.particle = nil
		eff.particle = self:addParticles(Particles.new("agony", 1, { power = 10 * eff.turn / eff.duration }))
	end,
}

newEffect{
	name = "HATEFUL_WHISPER",
	desc = "Hateful Whisper",
	long_desc = function(self, eff) return ("%s has heard the hateful whisper."):format(self.name:capitalize()) end,
	type = "mental",
	subtype = { madness=true, mind=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# has heard the hateful whisper!", "+Hateful Whisper" end,
	on_lose = function(self, err) return "#Target# no longer hears the hateful whisper.", "-Hateful Whisper" end,
	activate = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.source, self.x, self.y, DamageType.MIND, eff.damage)

		if self.dead then
			-- only spread on activate if the target is dead
			self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			eff.duration = 0
		else
			eff.particle = self:addParticles(Particles.new("hateful_whisper", 1, { }))
		end

		game:playSoundNear(self, "talents/fire")
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		eff.duration = eff.duration - 1
		if eff.duration <= 0 then return false end

		if (eff.state or 0) == 0 then
			-- pause a turn before infecting others
			eff.state = 1
		elseif eff.state == 1 then
			self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			eff.state = 2
		end
	end,
	doSpread = function(self, eff)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, eff.jumpRange, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, game.level.map.ACTOR)
				if a and eff.source:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					if not a:hasEffect(a.EFF_HATEFUL_WHISPER) then
						targets[#targets+1] = a
					end
				end
			end
		end

		if #targets > 0 then
			local hitCount = 1
			if rng.percent(eff.extraJumpChance or 0) then hitCount = hitCount + 1 end

			-- Randomly take targets
			for i = 1, hitCount do
				local target = rng.tableRemove(targets)
				target:setEffect(target.EFF_HATEFUL_WHISPER, eff.duration, {
					source = eff.source,
					duration = eff.duration,
					damage = eff.damage,
					mindpower = eff.mindpower,
					jumpRange = eff.jumpRange,
					extraJumpChance = eff.extraJumpChance
				})

				game.level.map:particleEmitter(target.x, target.y, 1, "reproach", { dx = self.x - target.x, dy = self.y - target.y })

				if #targets == 0 then break end
			end
		end
	end,
}

newEffect{
	name = "MADNESS_SLOW",
	desc = "Slowed by madness",
	long_desc = function(self, eff) return ("Madness reduces the target's global speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	subtype = { madness=true, slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target# slows in the grip of madness!", "+Slow" end,
	on_lose = function(self, err) return "#Target# overcomes the madness.", "-Slow" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "MADNESS_STUNNED",
	desc = "Paralyzed by madness",
	long_desc = function(self, eff) return "Madness has paralyzed the target, rendering it unable to act." end,
	type = "mental",
	subtype = { madness=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is paralyzed by madness!", "+Paralyzed" end,
	on_lose = function(self, err) return "#Target# overcomes the madness", "-Paralyzed" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))
		eff.tmpid = self:addTemporaryValue("paralyzed", 1)
		-- Start the stun counter only if this is the first stun
		if self.paralyzed == 1 then self.paralyzed_counter = (self:attr("stun_immune") or 0) * 100 end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("paralyzed", eff.tmpid)
		if not self:attr("paralyzed") then self.paralyzed_counter = nil end
	end,
}

newEffect{
	name = "MADNESS_CONFUSED",
	desc = "Confused by madness",
	long_desc = function(self, eff) return ("Madness has confused the target, making it act randomly (%d%% chance) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	subtype = { madness=true, confusion=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is lost in madness!", "+Confused" end,
	on_lose = function(self, err) return "#Target# overcomes the madness", "-Confused" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
	end,
}

newEffect{
	name = "QUICKNESS",
	desc = "Quick",
	long_desc = function(self, eff) return ("Increases run speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	subtype = { telekinesis=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Quick" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Quick" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("movement_speed", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("movement_speed", eff.tmpid)
	end,
}
newEffect{
	name = "PSIFRENZY",
	desc = "Frenzied Psi-fighting",
	long_desc = function(self, eff) return ("Causes telekinetically-wielded weapons to hit up to %d targets each turn."):format(eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, frenzy=true },
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# enters a frenzy!", "+Frenzy" end,
	on_lose = function(self, err) return "#Target# is no longer frenzied.", "-Frenzy" end,
}

newEffect{
	name = "KINSPIKE_SHIELD",
	desc = "Spiked Kinetic Shield",
	long_desc = function(self, eff) return ("The target erects a powerful kinetic shield capable of absorbing %d/%d physical or acid damage before it crumbles."):format(self.kinspike_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful kinetic shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful kinetic shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("kinspike_shield", eff.power)
		self.kinspike_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("kinspike_shield", eff.tmpid)
		self.kinspike_shield_absorb = nil
	end,
}
newEffect{
	name = "THERMSPIKE_SHIELD",
	desc = "Spiked Thermal Shield",
	long_desc = function(self, eff) return ("The target erects a powerful thermal shield capable of absorbing %d/%d thermal damage before it crumbles."):format(self.thermspike_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful thermal shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful thermal shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("thermspike_shield", eff.power)
		self.thermspike_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("thermspike_shield", eff.tmpid)
		self.thermspike_shield_absorb = nil
	end,
}
newEffect{
	name = "CHARGESPIKE_SHIELD",
	desc = "Spiked Charged Shield",
	long_desc = function(self, eff) return ("The target erects a powerful charged shield capable of absorbing %d/%d lightning or blight damage before it crumbles."):format(self.chargespike_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful charged shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful charged shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("chargespike_shield", eff.power)
		self.chargespike_shield_absorb = eff.power
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("chargespike_shield", eff.tmpid)
		self.chargespike_shield_absorb = nil
	end,
}

newEffect{
	name = "CONTROL",
	desc = "Perfect control",
	long_desc = function(self, eff) return ("The target's combat attack and crit chance are improved by %d and %d%%, respectively."):format(eff.power, 0.5*eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, focus=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.attack = self:addTemporaryValue("combat_atk", eff.power)
		eff.crit = self:addTemporaryValue("combat_physcrit", 0.5*eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.attack)
		self:removeTemporaryValue("combat_physcrit", eff.crit)
	end,
}

newEffect{
	name = "PSI_REGEN",
	desc = "Matter is energy",
	long_desc = function(self, eff) return ("The gem's matter gradually transforms, granting %0.2f energy per turn."):format(eff.power) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "Energy starts pouring from the gem into #Target#.", "+Energy" end,
	on_lose = function(self, err) return "The flow of energy from #Target#'s gem ceases.", "-Energy" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("psi_regen", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("psi_regen", eff.tmpid)
	end,
}

newEffect{
	name = "MASTERFUL_TELEKINETIC_ARCHERY",
	desc = "Telekinetic Archery",
	long_desc = function(self, eff) return ("Your telekinetically-wielded bow automatically attacks the nearest target each turn.") end,
	type = "mental",
	subtype = { telekinesis=true },
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# enters a telekinetic archer's trance!", "+Telekinetic archery" end,
	on_lose = function(self, err) return "#Target# is no longer in a telekinetic archer's trance.", "-Telekinetic archery" end,
}

newEffect{
	name = "WEAKENED_MIND",
	desc = "Weakened Mind",
	long_desc = function(self, eff) return ("Decreases mind save by %d."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = { power=10 },
	activate = function(self, eff)
		eff.mindid = self:addTemporaryValue("combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mindid)
	end,
}

newEffect{
	name = "VOID_ECHOES",
	desc = "Void Echoes",
	long_desc = function(self, eff) return ("The target is seeing echoes from the void and will take %0.2f mind damage as well as some resource damage each turn it fails a mental save."):format(eff.power) end,
	type = "mental",
	subtype = { madness=true, mind=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is being driven mad by the void.", "+Void Echoes" end,
	on_lose = function(self, err) return "#Target# has survived the void madness.", "-Void Echoes" end,
	on_timeout = function(self, eff)
		local drain = DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, eff.power) / 2
		self:incMana(-drain)
		self:incVim(-drain * 0.5)
		self:incPositive(-drain * 0.25)
		self:incNegative(-drain * 0.25)
		self:incStamina(-drain * 0.65)
		self:incHate(-drain * 0.05)
		self:incPsi(-drain * 0.2)
	end,
}

newEffect{
	name = "WAKING_NIGHTMARE",
	desc = "Waking Nightmare",
	long_desc = function(self, eff) return ("The target is lost in a waking nightmare that deals %0.2f darkness damage each turn and has a %d%% chance to cause a random effect detrimental."):format(eff.dam, eff.chance) end,
	type = "mental",
	subtype = { madness=true, darkness=true },
	status = "detrimental",
	parameters = { chance=10, dam = 10 },
	on_gain = function(self, err) return "#Target# is lost in a waking nightmare.", "+Waking Nightmare" end,
	on_lose = function(self, err) return "#Target# is free from the nightmare.", "-Waking Nightmare" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
		if rng.percent(eff.chance or 0) then
			-- Pull random effect
			local chance = rng.range(1, 3)
			if chance == 1 then
				if self:canBe("blind") then
					self:setEffect(self.EFF_BLINDED, 3, {})
				end
			elseif chance == 2 then
				if self:canBe("stun") then
					self:setEffect(self.EFF_STUNNED, 3, {})
				end
			elseif chance == 3 then
				if self:canBe("confusion") then
					self:setEffect(self.EFF_CONFUSED, 3, {power=50})
				end
			end
			game.logSeen(self, "%s succumbs to the nightmare!", self.name:capitalize())
		end
	end,
}

newEffect{
	name = "INNER_DEMONS",
	desc = "Inner Demons",
	long_desc = function(self, eff) return ("The target is plagued by inner demons and each turn there's a %d%% chance that one will appear.  If the caster is killed or the target resists setting his demons loose the effect will end early."):format(eff.chance) end,
	type = "mental",
	subtype = { madness=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is plagued by inner demons!", "+Inner Demons" end,
	on_lose = function(self, err) return "#Target# is freed from the demons.", "-Inner Demons" end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then eff.dur = 0 return true end
		if rng.percent(eff.chance or 0) then
			if self:checkHit(eff.src:combatSpellpower(), self:combatSpellResist(), 0, 95, 5) then
				local t = eff.src:getTalentFromId(eff.src.T_INNER_DEMONS)
				t.summon_inner_demons(eff.src, self, t)
			else
				eff.dur = 0
			end
		end
	end,
}

newEffect{
	name = "PACIFICATION_HEX",
	desc = "Pacification Hex",
	long_desc = function(self, eff) return ("The target is hexed, granting it %d%% chance each turn to be dazed for 3 turns."):format(eff.chance) end,
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = {chance=10, power=10},
	on_gain = function(self, err) return "#Target# is hexed!", "+Pacification Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Pacification Hex" end,
	-- Damage each turn
	on_timeout = function(self, eff)
		if not self:hasEffect(self.EFF_DAZED) and rng.percent(eff.chance) then
			self:setEffect(self.EFF_DAZED, 3, {})
			if not self:checkHit(eff.power, self:combatSpellResist(), 0, 95, 15) then eff.dur = 0 end
		end
	end,
	activate = function(self, eff)
		self:setEffect(self.EFF_DAZED, 3, {})
	end,
}

newEffect{
	name = "BURNING_HEX",
	desc = "Burning Hex",
	long_desc = function(self, eff) return ("The target is hexed. Each time it uses an ability it takes %0.2f fire damage."):format(eff.dam) end,
	type = "mental",
	subtype = { hex=true, fire=true },
	status = "detrimental",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# is hexed!", "+Burning Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Burning Hex" end,
}

newEffect{
	name = "EMPATHIC_HEX",
	desc = "Empathic Hex",
	long_desc = function(self, eff) return ("The target is hexed, creating an empathic bond with its victims. It takes %d%% feedback damage from all damage done."):format(eff.power) end,
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# is hexed.", "+Empathic Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Empathic hex" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("martyrdom", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("martyrdom", eff.tmpid)
	end,
}

newEffect{
	name = "DOMINATION_HEX",
	desc = "Domination Hex",
	long_desc = function(self, eff) return ("The target is hexed, temporarily changing its faction to %s."):format(engine.Faction.factions[eff.faction].name) end,
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is hexed.", "+Domination Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Domination hex" end,
	activate = function(self, eff)
		eff.olf_faction = self.faction
		self.faction = eff.src.faction
	end,
	deactivate = function(self, eff)
		self.faction = eff.olf_faction
	end,
}

newEffect{
	name = "HALFLING_LUCK",
	desc = "Halflings's Luck",
	long_desc = function(self, eff) return ("The target's luck and cunning combine to grant it %d%% higher combat critical chance and %d%% higher spell critical chance."):format(eff.physical, eff.spell) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { spell=10, physical=10 },
	on_gain = function(self, err) return "#Target# seems more aware." end,
	on_lose = function(self, err) return "#Target#'s awareness returns to normal." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("combat_physcrit", eff.physical)
		eff.sid = self:addTemporaryValue("combat_spellcrit", eff.spell)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physcrit", eff.pid)
		self:removeTemporaryValue("combat_spellcrit", eff.sid)
	end,
}

newEffect{
	name = "ATTACK",
	desc = "Attack",
	long_desc = function(self, eff) return ("The target's combat attack is improved by %d."):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# aims carefully." end,
	on_lose = function(self, err) return "#Target# aims less carefully." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_atk", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
	end,
}

newEffect{
	name = "DEADLY_STRIKES",
	desc = "Deadly Strikes",
	long_desc = function(self, eff) return ("The target's armour penetration is increased by %d."):format(eff.power) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# aims carefully." end,
	on_lose = function(self, err) return "#Target# aims less carefully." end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("combat_apr", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_apr", eff.tmpid)
	end,
}

newEffect{
	name = "FRENZY",
	desc = "Frenzy",
	long_desc = function(self, eff) return ("Increases global action speed by %d%% and physical crit by %d%%.\nAdditionally the target will continue to fight until it's hit points reach -%d%%."):format(eff.power * 100, eff.crit, eff.dieat * 100) end,
	type = "mental",
	subtype = { frenzy=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# goes into a killing frenzy.", "+Frenzy" end,
	on_lose = function(self, err) return "#Target# calms down.", "-Frenzy" end,
	on_merge = function(self, old_eff, new_eff)
		-- use on merge so reapplied frenzy doesn't kill off creatures with negative life
		old_eff.dur = new_eff.dur
		old_eff.power = new_eff.power
		old_eff.crit = new_eff.crit
		return old_eff
	end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
		eff.critid = self:addTemporaryValue("combat_physcrit", eff.crit)
		eff.dieatid = self:addTemporaryValue("die_at", -self.max_life * eff.dieat)
	end,
	deactivate = function(self, eff)
		-- check negative life first incase the creature has healing
		if self.life <= 0 then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "Falls dead!", {255,0,255})
			game.logSeen(self, "%s dies when its frenzy ends!", self.name:capitalize())
			self:die(self)
		end
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeTemporaryValue("combat_physcrit", eff.critid)
		self:removeTemporaryValue("die_at", eff.dieatid)
	end,
}

newEffect{
	name = "BLOODBATH",
	desc = "Bloodbath",
	long_desc = function(self, eff) return ("The thrill of combat improves the target's maximum life by %d, life regeneration by %d%% and stamina regeneration by %d%%."):format(eff.hp, eff.regen, eff.regen) end,
	type = "mental",
	subtype = { frenzy=true, heal=true },
	status = "beneficial",
	parameters = { hp=10, regen=10 },
	on_gain = function(self, err) return nil, "+Bloodbath" end,
	on_lose = function(self, err) return nil, "-Bloodbath" end,
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("max_life", old_eff.life_id)
		self:removeTemporaryValue("life_regen", old_eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", old_eff.stamina_regen_id)

		-- Take the new values, dont heal, otherwise you get a free heal each crit .. which is totaly broken
		local v = new_eff.hp * self.max_life / 100
		new_eff.life_id = self:addTemporaryValue("max_life", v)
		new_eff.life_regen_id = self:addTemporaryValue("life_regen", new_eff.regen * self.life_regen / 100)
		new_eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", new_eff.regen * self.stamina_regen / 100)
		return new_eff
	end,
	activate = function(self, eff)
		local v = eff.hp * self.max_life / 100
		eff.life_id = self:addTemporaryValue("max_life", v)
		self:heal(v)
		eff.life_regen_id = self:addTemporaryValue("life_regen", eff.regen * self.life_regen / 100)
		eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", eff.regen * self.stamina_regen / 100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("max_life", eff.life_id)
		self:removeTemporaryValue("life_regen", eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", eff.stamina_regen_id)
	end,
}

newEffect{
	name = "BLOODRAGE",
	desc = "Bloodrage",
	long_desc = function(self, eff) return ("The target's strength is increased by %d by the thrill of combat."):format(eff.inc) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { inc=1, max=10 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("inc_stats", old_eff.tmpid)
		old_eff.cur_inc = math.min(old_eff.cur_inc + new_eff.inc, new_eff.max)
		old_eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = old_eff.cur_inc})

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_inc = eff.inc
		eff.tmpid = self:addTemporaryValue("inc_stats", {[Stats.STAT_STR] = eff.inc})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_stats", eff.tmpid)
	end,
}

newEffect{
	name = "UNSTOPPABLE",
	desc = "Unstoppable",
	long_desc = function(self, eff) return ("The target is unstoppable! It refuses to die, and at the end it will heal %d Life."):format(eff.kills * eff.hp_per_kill * self.max_life / 100) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { hp_per_kill=2 },
	activate = function(self, eff)
		eff.kills = 0
		eff.tmpid = self:addTemporaryValue("unstoppable", 1)
		eff.healid = self:addTemporaryValue("no_life_regen", 1)
	end,
	deactivate = function(self, eff)
		self:heal(eff.kills * eff.hp_per_kill * self.max_life / 100)
		self:removeTemporaryValue("unstoppable", eff.tmpid)
		self:removeTemporaryValue("no_life_regen", eff.healid)
	end,
}

newEffect{
	name = "INCREASED_LIFE",
	desc = "Increased Life",
	long_desc = function(self, eff) return ("The target's maximum life is increased by %d."):format(eff.life) end,
	type = "mental",
	subtype = { frenzy=true, heal=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target# gains extra life.", "+Life" end,
	on_lose = function(self, err) return "#Target# loses extra life.", "-Life" end,
	parameters = { life = 50 },
	activate = function(self, eff)
		self.max_life = self.max_life + eff.life
		self.life = self.life + eff.life
		self.changed = true
	end,
	deactivate = function(self, eff)
		self.max_life = self.max_life - eff.life
		self.life = self.life - eff.life
		self.changed = true
		if self.life <= 0 then
			self.life = 1
			self:setEffect(self.EFF_STUNNED, 3, {})
			game.logSeen(self, "%s's increased life wears off and is stunned by the change.", self.name:capitalize())
		end
	end,
}

newEffect{
	name = "RAMPAGE",
	desc = "Rampaging",
	long_desc = function(self, eff) return "The target is rampaging!" end,
	type = "mental",
	subtype = { frenzy=true, speed=true, evade=true },
	status = "beneficial",
	parameters = { hateLoss = 0, critical = 0, damage = 0, speed = 0, attack = 0, evasion = 0 }, -- use percentages not fractions
	on_gain = function(self, err) return "#F53CBE##Target# begins rampaging!", "+Rampage" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer rampaging.", "-Rampage" end,
	activate = function(self, eff)
		if eff.hateLoss or 0 > 0 then eff.hateLossId = self:addTemporaryValue("hate_regen", -eff.hateLoss) end
		if eff.critical or 0 > 0 then eff.criticalId = self:addTemporaryValue("combat_physcrit", eff.critical) end
		if eff.damage or 0 > 0 then eff.damageId = self:addTemporaryValue("inc_damage", {[DamageType.PHYSICAL]=eff.damage}) end
		if eff.speed or 0 > 0 then eff.speedId = self:addTemporaryValue("global_speed_add", eff.speed * 0.01) end
		if eff.attack or 0 > 0 then eff.attackId = self:addTemporaryValue("combat_atk", self:combatAttack() * eff.attack * 0.01) end
		if eff.evasion or 0 > 0 then eff.evasionId = self:addTemporaryValue("evasion", eff.evasion) end

		eff.particle = self:addParticles(Particles.new("rampage", 1))
	end,
	deactivate = function(self, eff)
		if eff.hateLossId then self:removeTemporaryValue("hate_regen", eff.hateLossId) end
		if eff.criticalId then self:removeTemporaryValue("combat_physcrit", eff.criticalId) end
		if eff.damageId then self:removeTemporaryValue("inc_damage", eff.damageId) end
		if eff.speedId then self:removeTemporaryValue("global_speed_add", eff.speedId) end
		if eff.attackId then self:removeTemporaryValue("combat_atk", eff.attackId) end
		if eff.evasionId then self:removeTemporaryValue("evasion", eff.evasionId) end

		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "ORC_FURY",
	desc = "Orcish Fury",
	long_desc = function(self, eff) return ("The target enters a destructive fury, increasing all damage done by %d%%."):format(eff.power) end,
	type = "mental",
	subtype = { frenzy=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target# enters a state of bloodlust." end,
	on_lose = function(self, err) return "#Target# calms down." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=eff.power})
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("inc_damage", eff.pid)
	end,
}