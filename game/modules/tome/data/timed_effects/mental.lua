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

local Stats = require "engine.interface.ActorStats"
local Particles = require "engine.Particles"
local Entity = require "engine.Entity"
local Chat = require "engine.Chat"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Astar = require "engine.Astar"

newEffect{
	name = "SILENCED", image = "effects/silenced.png",
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
	name = "SUMMON_CONTROL", image = "talents/summon_control.png",
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
	name = "CONFUSED", image = "effects/confused.png",
	desc = "Confused",
	long_desc = function(self, eff) return ("The target is confused, acting randomly (chance %d%%) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	subtype = { confusion=true },
	status = "detrimental",
	parameters = { power=50 },
	on_gain = function(self, err) return "#Target# wanders around!.", "+Confused" end,
	on_lose = function(self, err) return "#Target# seems more focused.", "-Confused" end,
	activate = function(self, eff)
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "DOMINANT_WILL", image = "talents/yeek_will.png",
	desc = "Mental Domination",
	long_desc = function(self, eff) return ("The target's mind has been shattered. Its body remains as a thrall to %s."):format(eff.src.name:capitalize()) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target#'s mind is shattered." end,
	activate = function(self, eff)
		eff.pid = self:addTemporaryValue("inc_damage", {all=-15})
		self.ai_state = self.ai_state or {}
		eff.oldstate = {
			faction = self.faction,
			ai_state = table.clone(self.ai_state, true),
			remove_from_party_on_death = self.remove_from_party_on_death,
			no_inventory_access = self.no_inventory_access,
			move_others = self.move_others,
			summoner = self.summoner,
			summoner_gain_exp = self.summoner_gain_exp,
			ai = self.ai,
		}
		self.faction = eff.src.faction
		
		self.ai_state.tactic_leash = 100
		self.remove_from_party_on_death = true
		self.no_inventory_access = true
		self.move_others = true
		self.summoner = eff.src
		self.summoner_gain_exp = true
		if self.dead then return end
		game.party:addMember(self, {
			control="full",
			type="thrall",
			title="Thrall",
			orders = {leash=true, follow=true},
			on_control = function(self)
				self:hotkeyAutoTalents()
			end,
			leave_level = function(self, party_def) -- Cancel control and restore previous actor status.
				local eff = self:hasEffect(self.EFF_DOMINANT_WILL)
				local uid = self.uid
				eff.survive_domination = true
				self:removeTemporaryValue("inc_damage", eff.pid)
				game.party:removeMember(self)
				self:replaceWith(require("mod.class.NPC").new(self))
				self.uid = uid
				__uids[uid] = self
				self.faction = eff.oldstate.faction
				self.ai_state = eff.oldstate.ai_state
				self.ai = eff.oldstate.ai
				self.remove_from_party_on_death = eff.oldstate.remove_from_party_on_death
				self.no_inventory_access = eff.oldstate.no_inventory_access
				self.move_others = eff.oldstate.move_others
				self.summoner = eff.oldstate.summoner
				self.summoner_gain_exp = eff.oldstate.summoner_gain_exp
				self:removeEffect(self.EFF_DOMINANT_WILL)
			end,
		})
	end,
	deactivate = function(self, eff)
		if eff.survive_domination then
			game.logSeen(self, "%s's mind recovers from the domination.",self.name:capitalize())
		else
			game.logSeen(self, "%s collapses.",self.name:capitalize())
			self:die(eff.src)
		end
	end,
}

newEffect{
	name = "BATTLE_SHOUT", image = "talents/battle_shout.png",
	desc = "Battle Shout",
	long_desc = function(self, eff) return ("Increases maximum life and stamina by %d%%. When the effect ends, the extra life and stamina will be lost."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		local lifeb = self.max_life * eff.power/100
		local stamb = self.max_stamina * eff.power/100
		eff.max_lifeID = self:addTemporaryValue("max_life", lifeb) --Avoid healing effects
		eff.lifeID = self:addTemporaryValue("life",lifeb)
		eff.max_stamina = self:addTemporaryValue("max_stamina", stamb)
		self:incStamina(stamb)
		eff.stamina = stamb
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("life", eff.lifeID)
		self:removeTemporaryValue("max_life", eff.max_lifeID)
		self:removeTemporaryValue("max_stamina", eff.max_stamina)
		self:incStamina(-eff.stamina)
	end,
}

newEffect{
	name = "BATTLE_CRY", image = "talents/battle_cry.png",
	desc = "Battle Cry",
	long_desc = function(self, eff) return ("The target's will to defend itself is shattered by the powerful battle cry, reducing defense by %d."):format(eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#Target#'s will is shattered.", "+Battle Cry" end,
	on_lose = function(self, err) return "#Target# regains some of its will.", "-Battle Cry" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_def", -eff.power)
		self:effectTemporaryValue(eff, "no_evasion", 1)
		self:effectTemporaryValue(eff, "blind_fighted", 1)
	end,
}

newEffect{
	name = "WILLFUL_COMBAT", image = "talents/willful_combat.png",
	desc = "Willful Combat",
	long_desc = function(self, eff) return ("The target puts all its willpower into its blows, improving physical power by %d."):format(eff.power) end,
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
	name = "GLOOM_WEAKNESS", image = "effects/gloom_weakness.png",
	desc = "Gloom Weakness",
	long_desc = function(self, eff) return ("The gloom reduces damage the target inflicts by %d%%."):format(-eff.incDamageChange) end,
	type = "mental",
	subtype = { gloom=true },
	status = "detrimental",
	parameters = { atk=10, dam=10 },
	on_gain = function(self, err) return "#F53CBE##Target# is weakened by the gloom." end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer weakened." end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_weakness", 1))
		eff.incDamageId = self:addTemporaryValue("inc_damage", {all = eff.incDamageChange})
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("inc_damage", eff.incDamageId)
	end,
}

newEffect{
	name = "GLOOM_SLOW", image = "effects/gloom_slow.png",
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
	name = "GLOOM_STUNNED", image = "effects/gloom_stunned.png",
	desc = "Stunned by the gloom",
	long_desc = function(self, eff) return ("The gloom has stunned the target, reducing damage by 70%%, putting random talents on cooldown and reducing movement speed by 50%%. While stunned talents do not cooldown."):format() end,
	type = "mental",
	subtype = { gloom=true, stun=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is stunned with fear!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Stunned" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))

		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate and util.getval(t.no_energy, self, t) ~= true then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)

		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "GLOOM_CONFUSED", image = "effects/gloom_confused.png",
	desc = "Confused by the gloom",
	long_desc = function(self, eff) return ("The gloom has confused the target, making it act randomly (%d%% chance) and unable to perform complex actions."):format(eff.power) end,
	type = "mental",
	subtype = { gloom=true, confusion=true },
	status = "detrimental",
	parameters = { power = 10 },
	on_gain = function(self, err) return "#F53CBE##Target# is lost in despair!", "+Confused" end,
	on_lose = function(self, err) return "#Target# overcomes the gloom", "-Confused" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
		if eff.power <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player then self:updateMainShader() end
	end,
}

newEffect{
	name = "DISMAYED", image = "talents/dismay.png",
	desc = "Dismayed",
	long_desc = function(self, eff) return ("The target is dismayed. The next melee attack against the target will be a guaranteed critical hit.") end,
	type = "mental",
	subtype = { gloom=true, confusion=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is dismayed!", "+Dismayed" end,
	on_lose = function(self, err) return "#Target# overcomes the dismay", "-Dismayed" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("dismayed", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "STALKER", image = "talents/stalk.png",
	desc = "Stalking",
	display_desc = function(self, eff)
		return ([[Stalking %d/%d +%d ]]):format(eff.target.life, eff.target.max_life, eff.bonus)
	end,
	long_desc = function(self, eff)
		local t = self:getTalentFromId(self.T_STALK)
		local effStalked = eff.target:hasEffect(eff.target.EFF_STALKED)
		local desc = ([[Stalking %s. Bonus level %d: +%d attack, +%d%% melee damage, +%0.2f hate/turn prey was hit.]]):format(
			eff.target.name, eff.bonus, t.getAttackChange(self, t, eff.bonus), t.getStalkedDamageMultiplier(self, t, eff.bonus) * 100 - 100, t.getHitHateChange(self, t, eff.bonus))
		if effStalked and effStalked.damageChange and effStalked.damageChange > 0 then
			desc = desc..("Prey damage modifier: %d%%."):format(effStalked.damageChange)
		end
		return desc
	end,
	type = "mental",
	subtype = { veil=true },
	status = "beneficial",
	parameters = {},
	activate = function(self, eff)
		self:logCombat(eff.target, "#F53CBE##Target# is being stalked by #Source#!")
	end,
	deactivate = function(self, eff)
		self:logCombat(eff.target, "#F53CBE##Target# is no longer being stalked by #Source#.")
	end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead or not eff.target:hasEffect(eff.target.EFF_STALKED) then
			self:removeEffect(self.EFF_STALKER)
		end
	end,
}

newEffect{
	name = "STALKED", image = "effects/stalked.png",
	desc = "Stalked",
	long_desc = function(self, eff)
		local effStalker = eff.src:hasEffect(eff.src.EFF_STALKER)
		if not effStalker then return "Being stalked." end
		local t = self:getTalentFromId(eff.src.T_STALK)
		local desc = ([[Being stalked by %s. Stalker bonus level %d: +%d attack, +%d%% melee damage, +%0.2f hate/turn prey was hit.]]):format(
			eff.src.name, effStalker.bonus, t.getAttackChange(eff.src, t, effStalker.bonus), t.getStalkedDamageMultiplier(eff.src, t, effStalker.bonus) * 100 - 100, t.getHitHateChange(eff.src, t, effStalker.bonus))
		if eff.damageChange and eff.damageChange > 0 then
			desc = desc..(" Prey damage modifier: %d%%."):format(eff.damageChange)
		end
		return desc
	end,
	type = "mental",
	subtype = { veil=true },
	status = "detrimental",
	parameters = {},
	activate = function(self, eff)
		local effStalker = eff.src:hasEffect(eff.src.EFF_STALKER)
		eff.particleBonus = effStalker.bonus
		eff.particle = self:addParticles(Particles.new("stalked", 1, { bonus = eff.particleBonus }))
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
		if eff.damageChangeId then self:removeTemporaryValue("inc_damage", eff.damageChangeId) end
	end,
	on_timeout = function(self, eff)
		if not eff.src or eff.src.dead or not eff.src:hasEffect(eff.src.EFF_STALKER) then
			self:removeEffect(self.EFF_STALKED)
		else
			local effStalker = eff.src:hasEffect(eff.src.EFF_STALKER)
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
	name = "BECKONED", image = "talents/beckon.png",
	desc = "Beckoned",
	long_desc = function(self, eff)
		local message = ("The target has been beckoned by %s and is heeding the call. There is a %d%% chance of moving towards the beckoner each turn."):format(eff.src.name, eff.chance)
		if eff.spellpowerChangeId and eff.mindpowerChangeId then
			message = message..(" (spellpower: %d, mindpower: %d"):format(eff.spellpowerChange, eff.mindpowerChange)
		end
		return message
	end,
	type = "mental",
	subtype = { dominate=true },
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

		if eff.spellpowerChangeId then
			self:removeTemporaryValue("combat_spellpower", eff.spellpowerChangeId)
			eff.spellpowerChangeId = nil
		end
		if eff.mindpowerChangeId then
			self:removeTemporaryValue("combat_mindpower", eff.mindpowerChangeId)
			eff.mindpowerChangeId = nil
		end
	end,
	on_timeout = function(self, eff)
	end,
	do_act = function(self, eff)
		if eff.src.dead then
			self:removeEffect(self.EFF_BECKONED)
			return
		end
		if not self:enoughEnergy() then return nil end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.src:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.chance * 0.5
			game.logSeen(self, "#F53CBE#%s struggles against the beckoning.", self.name:capitalize())
		else
			eff.timer = eff.timer + eff.chance
		end

		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local distance = self.x and eff.src.x and core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) or 1000
			if math.floor(distance) > 1 and distance <= eff.range then
				-- in range but not adjacent

				-- add debuffs
				if not eff.spellpowerChangeId then eff.spellpowerChangeId = self:addTemporaryValue("combat_spellpower", eff.spellpowerChange) end
				if not eff.mindpowerChangeId then eff.mindpowerChangeId = self:addTemporaryValue("combat_mindpower", eff.mindpowerChange) end

				-- custom pull logic (adapted from move_dmap; forces movement, pushes others aside, custom particles)

				if not self:attr("never_move") then
					local source = eff.src
					local moveX, moveY = source.x, source.y -- move in general direction by default
					if not self:hasLOS(source.x, source.y) then
						local a = Astar.new(game.level.map, self)
						local path = a:calc(self.x, self.y, source.x, source.y)
						if path then
							moveX, moveY = path[1].x, path[1].y
						end
					end

					if moveX and moveY then
						local old_move_others, old_x, old_y = self.move_others, self.x, self.y
						self.move_others = true
						local old = rawget(self, "aiCanPass")
						self.aiCanPass = mod.class.NPC.aiCanPass
						mod.class.NPC.moveDirection(self, moveX, moveY, false)
						self.aiCanPass = old
						self.move_others = old_move_others
						if old_x ~= self.x or old_y ~= self.y then
							game.level.map:particleEmitter(self.x, self.y, 1, "beckoned_move", {power=power, dx=self.x - source.x, dy=self.y - source.y})
						end
					end
				end
			else
				-- adjacent or out of range..remove debuffs
				if eff.spellpowerChangeId then
					self:removeTemporaryValue("combat_spellpower", eff.spellpowerChangeId)
					eff.spellpowerChangeId = nil
				end
				if eff.mindpowerChangeId then
					self:removeTemporaryValue("combat_mindpower", eff.mindpowerChangeId)
					eff.mindpowerChangeId = nil
				end
			end
		end
	end,
	do_onTakeHit = function(self, eff, dam)
		eff.resistChance = (eff.resistChance or 0) + math.min(100, math.max(0, dam / self.max_life * 100))
		if rng.percent(eff.resistChance) then
			game.logSeen(self, "#F53CBE#%s is jolted to attention by the damage and is no longer being beckoned.", self.name:capitalize())
			self:removeEffect(self.EFF_BECKONED)
		end

		return dam
	end,
}

newEffect{
	name = "OVERWHELMED", image = "talents/frenzy.png",
	desc = "Overwhelmed",
	long_desc = function(self, eff) return ("The target has been overwhemed by a furious assault, reducing attack by %d."):format( -eff.attackChange) end,
	type = "mental",
	subtype = { fear=true },
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
	name = "HARASSED", image = "talents/harass_prey.png",
	desc = "Harassed",
	long_desc = function(self, eff) return ("The target has been harassed by its stalker, reducing damage by %d%%."):format( -eff.damageChange * 100) end,
	type = "mental",
	subtype = { fear=true },
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
	name = "DOMINATED", image = "talents/dominate.png",
	desc = "Dominated",
	long_desc = function(self, eff) return ("The target has been dominated.  It is unable to move and has lost %d armor and %d defense. Attacks from %s gain %d%% damage penetration."):format(-eff.armorChange, -eff.defenseChange, eff.src.name:capitalize(), eff.resistPenetration) end,
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
	name = "FEED", image = "talents/feed.png",
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
			eff.constitutionGainId = self:addTemporaryValue("inc_stats", { [Stats.STAT_CON] = eff.constitutionGain })
		end
		if eff.lifeRegenGain and eff.lifeRegenGain > 0 then
			eff.lifeRegenGainId = self:addTemporaryValue("life_regen", eff.lifeRegenGain)
		end

		-- power
		if eff.damageGain and eff.damageGain > 0 then
			eff.damageGainId = self:addTemporaryValue("inc_damage", {all=eff.damageGain})
		end

		-- strengths
		if eff.resistGain and eff.resistGain > 0 then
			local gainList = {}
			for id, resist in pairs(eff.target.resists) do
				if resist > 0 and id ~= "all" then
					gainList[id] = eff.resistGain * 0.01 * resist
				end
			end

			eff.resistGainId = self:addTemporaryValue("resists", gainList)
		end

		eff.target:setEffect(eff.target.EFF_FED_UPON, eff.dur, { src = eff.src, target = eff.target, constitutionLoss = -eff.constitutionGain, lifeRegenLoss = -eff.lifeRegenGain, damageLoss = -eff.damageGain, resistLoss = -eff.resistGain })
	end,
	deactivate = function(self, eff)
		-- hate
		if eff.hateGainId then self:removeTemporaryValue("hate_regen", eff.hateGainId) end

		-- health
		if eff.constitutionGainId then self:removeTemporaryValue("inc_stats", eff.constitutionGainId) end
		if eff.lifeRegenGainId then self:removeTemporaryValue("life_regen", eff.lifeRegenGainId) end

		-- power
		if eff.damageGainId then self:removeTemporaryValue("inc_damage", eff.damageGainId) end

		-- strengths
		if eff.resistGainId then self:removeTemporaryValue("resists", eff.resistGainId) end

		if eff.particles then
			-- remove old particle emitter
			game.level.map:removeParticleEmitter(eff.particles)
			eff.particles = nil
		end

		eff.target:removeEffect(eff.target.EFF_FED_UPON, false, true)
	end,
	updateFeed = function(self, eff)
		local source = eff.src
		local target = eff.target

		if source.dead or target.dead or not game.level:hasEntity(source) or not game.level:hasEntity(target) or not source:hasLOS(target.x, target.y) or core.fov.distance(self.x, self.y, target.x, target.y) > (eff.range or 10) then
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
	name = "FED_UPON", image = "effects/fed_upon.png",
	desc = "Fed Upon",
	long_desc = function(self, eff) return ("%s is fed upon by %s."):format(self.name:capitalize(), eff.src.name) end,
	type = "mental",
	subtype = { psychic_drain=true },
	status = "detrimental",
	remove_on_clone = true,
	no_remove = true,
	parameters = { },
	activate = function(self, eff)
		-- health
		if eff.constitutionLoss and eff.constitutionLoss < 0 then
			eff.constitutionLossId = self:addTemporaryValue("inc_stats", { [Stats.STAT_CON] = eff.constitutionLoss })
		end
		if eff.lifeRegenLoss and eff.lifeRegenLoss < 0 then
			eff.lifeRegenLossId = self:addTemporaryValue("life_regen", eff.lifeRegenLoss)
		end

		-- power
		if eff.damageLoss and eff.damageLoss < 0 then
			eff.damageLossId = self:addTemporaryValue("inc_damage", {all=eff.damageLoss})
		end

		-- strengths
		if eff.resistLoss and eff.resistLoss < 0 then
			local lossList = {}
			for id, resist in pairs(self.resists) do
				if resist > 0 and id ~= "all" then
					lossList[id] = eff.resistLoss * 0.01 * resist
				end
			end

			eff.resistLossId = self:addTemporaryValue("resists", lossList)
		end
	end,
	deactivate = function(self, eff)
		-- health
		if eff.constitutionLossId then self:removeTemporaryValue("inc_stats", eff.constitutionLossId) end
		if eff.lifeRegenLossId then self:removeTemporaryValue("life_regen", eff.lifeRegenLossId) end

		-- power
		if eff.damageLossId then self:removeTemporaryValue("inc_damage", eff.damageLossId) end

		-- strengths
		if eff.resistLossId then self:removeTemporaryValue("resists", eff.resistLossId) end

		if eff.target == self and eff.src:hasEffect(eff.src.EFF_FEED) then
			eff.src:removeEffect(eff.src.EFF_FEED)
		end
	end,
	on_timeout = function(self, eff)
		-- no_remove prevents targets from dispelling feeding, make sure this gets removed if something goes wrong
		if eff.dur <= 0 or eff.src.dead then
			self:removeEffect(eff.src.EFF_FED_UPON, false, true)
		end
	end,
}

newEffect{
	name = "AGONY", image = "talents/agony.png",
	desc = "Agony",
	long_desc = function(self, eff) return ("%s is writhing in agony, suffering from %d to %d damage over %d turns."):format(self.name:capitalize(), eff.damage / eff.duration, eff.damage, eff.duration) end,
	type = "mental",
	subtype = { pain=true, psionic=true },
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
			DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, { dam=damage, crossTierChance=25 })
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
	name = "HATEFUL_WHISPER", image = "talents/hateful_whisper.png",
	desc = "Hateful Whisper",
	long_desc = function(self, eff) return ("%s has heard the hateful whisper."):format(self.name:capitalize()) end,
	type = "mental",
	subtype = { madness=true, psionic=true },
	status = "detrimental",
	parameters = { },
	on_gain = function(self, err) return "#Target# has heard the hateful whisper!", "+Hateful Whisper" end,
	on_lose = function(self, err) return "#Target# no longer hears the hateful whisper.", "-Hateful Whisper" end,
	activate = function(self, eff)
		if not eff.src.dead and eff.src:knowTalent(eff.src.T_HATE_POOL) then
			eff.src:incHate(eff.hateGain)
		end
		DamageType:get(DamageType.MIND).projector(eff.src, self.x, self.y, DamageType.MIND, { dam=eff.damage, crossTierChance=25 })

		if self.dead then
			-- only spread on activate if the target is dead
			if eff.jumpCount > 0 then
				eff.jumpCount = eff.jumpCount - 1
				self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			end
		else
			eff.particle = self:addParticles(Particles.new("hateful_whisper", 1, { }))
		end

		game:playSoundNear(self, "talents/fire")

		eff.firstTurn = true
	end,
	deactivate = function(self, eff)
		if eff.particle then self:removeParticles(eff.particle) end
	end,
	on_timeout = function(self, eff)
		if self.dead then return false end

		if eff.firstTurn then
			-- pause a turn before infecting others
			eff.firstTurn = false
		elseif eff.jumpDuration > 0 then
			-- limit the total duration of all spawned effects
			eff.jumpDuration = eff.jumpDuration - 1

			if eff.jumpCount > 0 then
				-- guaranteed jump
				eff.jumpCount = eff.jumpCount - 1
				self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			elseif rng.percent(eff.jumpChance) then
				-- per turn chance of a jump
				self.tempeffect_def[self.EFF_HATEFUL_WHISPER].doSpread(self, eff)
			end
		end
	end,
	doSpread = function(self, eff)
		local targets = {}
		local grids = core.fov.circle_grids(self.x, self.y, eff.jumpRange, true)
		for x, yy in pairs(grids) do
			for y, _ in pairs(grids[x]) do
				local a = game.level.map(x, y, game.level.map.ACTOR)
				if a and eff.src:reactionToward(a) < 0 and self:hasLOS(a.x, a.y) then
					if not a:hasEffect(a.EFF_HATEFUL_WHISPER) then
						targets[#targets+1] = a
					end
				end
			end
		end

		if #targets > 0 then
			local target = rng.table(targets)
			target:setEffect(target.EFF_HATEFUL_WHISPER, eff.duration, {
				src = eff.src,
				duration = eff.duration,
				damage = eff.damage,
				mindpower = eff.mindpower,
				jumpRange = eff.jumpRange,
				jumpCount = 0, -- secondary effects do not get automatic spreads
				jumpChance = eff.jumpChance,
				jumpDuration = eff.jumpDuration,
				hateGain = eff.hateGain
			})

			game.level.map:particleEmitter(target.x, target.y, 1, "reproach", { dx = self.x - target.x, dy = self.y - target.y })
		end
	end,
}

newEffect{
	name = "MADNESS_SLOW", image = "effects/madness_slowed.png",
	desc = "Slowed by madness",
	long_desc = function(self, eff) return ("Madness reduces the target's global speed by %d%% and lowers mind resistance by %d%%."):format(eff.power * 100, -eff.mindResistChange) end,
	type = "mental",
	subtype = { madness=true, slow=true },
	status = "detrimental",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#F53CBE##Target# slows in the grip of madness!", "+Slow" end,
	on_lose = function(self, err) return "#Target# overcomes the madness.", "-Slow" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_slow", 1))
		eff.mindResistChangeId = self:addTemporaryValue("resists", { [DamageType.MIND]=eff.mindResistChange })
		eff.tmpid = self:addTemporaryValue("global_speed_add", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.mindResistChangeId)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "MADNESS_STUNNED", image = "effects/madness_stunned.png",
	desc = "Stunned by madness",
	long_desc = function(self, eff) return ("Madness has stunned the target, reducing damage by 70%%, lowering mind resistance by %d%%, putting random talents on cooldown and reducing movement speed by 50%%. While stunned talents do not cooldown."):format(eff.mindResistChange) end,
	type = "mental",
	subtype = { madness=true, stun=true },
	status = "detrimental",
	parameters = {mindResistChange = -10},
	on_gain = function(self, err) return "#F53CBE##Target# is stunned by madness!", "+Stunned" end,
	on_lose = function(self, err) return "#Target# overcomes the madness", "-Stunned" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_stunned", 1))

		eff.mindResistChangeId = self:addTemporaryValue("resists", { [DamageType.MIND]=eff.mindResistChange })
		eff.tmpid = self:addTemporaryValue("stunned", 1)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		eff.speedid = self:addTemporaryValue("movement_speed", -0.5)

		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end
		for i = 1, 4 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1 -- Just set cooldown to 1 since cooldown does not decrease while stunned
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)

		self:removeTemporaryValue("resists", eff.mindResistChangeId)
		self:removeTemporaryValue("stunned", eff.tmpid)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
		self:removeTemporaryValue("movement_speed", eff.speedid)
	end,
}

newEffect{
	name = "MADNESS_CONFUSED", image = "effects/madness_confused.png",
	desc = "Confused by madness",
	long_desc = function(self, eff) return ("Madness has confused the target, lowering mind resistance by %d%% and making it act randomly (%d%% chance) and unable to perform complex actions."):format(eff.mindResistChange, eff.power) end,
	type = "mental",
	subtype = { madness=true, confusion=true },
	status = "detrimental",
	parameters = { power=10 },
	on_gain = function(self, err) return "#F53CBE##Target# is lost in madness!", "+Confused" end,
	on_lose = function(self, err) return "#Target# overcomes the madness", "-Confused" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("gloom_confused", 1))
		eff.mindResistChangeId = self:addTemporaryValue("resists", { [DamageType.MIND]=eff.mindResistChange })
		eff.power = math.floor(math.max(eff.power - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.power = util.bound(eff.power, 0, 50)
		eff.tmpid = self:addTemporaryValue("confused", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.mindResistChangeId)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("confused", eff.tmpid)
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "MALIGNED", image = "talents/getsture_of_malice.png",
	desc = "Maligned",
	long_desc = function(self, eff) return ("The target is under a malign influence. All resists have been lowered by %d%%."):format(-eff.resistAllChange) end,
	type = "mental",
	subtype = { curse=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# has been maligned!", "+Maligned" end,
	on_lose = function(self, err) return "#Target# is no longer maligned", "-Maligned" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("maligned", 1))
		eff.resistAllChangeId = self:addTemporaryValue("resists", { all=eff.resistAllChange })
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.resistAllChangeId)
		self:removeParticles(eff.particle)
	end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.dur = new_eff.dur
		return old_eff
	end,
}

local function updateFearParticles(self)
	local hasParticles = false
	if self:hasEffect(self.EFF_PARANOID) then hasParticles = true end
	if self:hasEffect(self.EFF_DISPAIR) then hasParticles = true end
	if self:hasEffect(self.EFF_TERRIFIED) then hasParticles = true end
	if self:hasEffect(self.EFF_DISTRESSED) then hasParticles = true end
	if self:hasEffect(self.EFF_HAUNTED) then hasParticles = true end
	if self:hasEffect(self.EFF_TORMENTED) then hasParticles = true end

	if not self.fearParticlesId and hasParticles then
		self.fearParticlesId = self:addParticles(Particles.new("fear_blue", 1))
	elseif self.fearParticlesId and not hasParticles then
		self:removeParticles(self.fearParticlesId)
		self.fearParticlesId = nil
	end
end

newEffect{
	name = "PARANOID", image = "effects/paranoid.png",
	desc = "Paranoid",
	long_desc = function(self, eff) return ("Paranoia has gripped the target, causing a %d%% chance they will physically attack anyone nearby, friend or foe. Targets of the attack may become paranoid themselves."):format(eff.attackChance) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# becomes paranoid!", "+Paranoid" end,
	on_lose = function(self, err) return "#Target# is no longer paranoid", "-Paranoid" end,
	activate = function(self, eff)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	do_act = function(self, eff)
		if not self:enoughEnergy() then return nil end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.src:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.attackChance * 0.5
			game.logSeen(self, "#F53CBE#%s struggles against the paranoia.", self.name:capitalize())
		else
			eff.timer = eff.timer + eff.attackChance
		end
		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				if (self.x ~= x or self.y ~= y) then
					local target = game.level.map(x, y, Map.ACTOR)
					if target then
						self:logCombat(target, "#F53CBE##Source# attacks #Target# in a fit of paranoia.")
						if self:attackTarget(target, nil, 1, false) and target ~= eff.src then
							if not target:canBe("fear") then
								game.logSeen(target, "#F53CBE#%s ignores the fear!", target.name:capitalize())
							elseif not target:checkHit(eff.mindpower, target:combatMentalResist()) then
								game.logSeen(target, "%s resists the fear!", target.name:capitalize())
							else
								target:setEffect(target.EFF_PARANOID, eff.duration, {src=eff.src, attackChance=eff.attackChance, mindpower=eff.mindpower, duration=eff.duration })
							end
						end
						return
					end
				end
			end
		end
	end,
}

newEffect{
	name = "DISPAIR", image = "effects/despair.png",
	desc = "Despair",
	long_desc = function(self, eff) return ("The target is in despair, reducing all damage reduction by %d%%."):format(-eff.resistAllChange) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# is in despair!", "+Despair" end,
	on_lose = function(self, err) return "#Target# is no longer in despair", "-Despair" end,
	activate = function(self, eff)
		eff.damageId = self:addTemporaryValue("resists", { all=eff.resistAllChange })
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("resists", eff.damageId)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
}

newEffect{
	name = "TERRIFIED", image = "effects/terrified.png",
	desc = "Terrified",
	long_desc = function(self, eff) return ("The target is terrified, causing talents and attacks to fail %d%% of the time."):format(eff.actionFailureChance) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# becomes terrified!", "+Terrified" end,
	on_lose = function(self, err) return "#Target# is no longer terrified", "-Terrified" end,
	activate = function(self, eff)
		eff.terrifiedId = self:addTemporaryValue("terrified", eff.actionFailureChance)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		eff.terrifiedId = self:removeTemporaryValue("terrified", eff.terrifiedId)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
}

newEffect{
	name = "DISTRESSED", image = "effects/distressed.png",
	desc = "Distressed",
	long_desc = function(self, eff) return ("The target is distressed, reducing all saves by %d."):format(-eff.saveChange) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# becomes distressed!", "+Distressed" end,
	on_lose = function(self, err) return "#Target# is no longer distressed", "-Distressed" end,
	activate = function(self, eff)
		eff.physicalId = self:addTemporaryValue("combat_physresist", eff.saveChange)
		eff.mentalId = self:addTemporaryValue("combat_mentalresist", eff.saveChange)
		eff.spellId = self:addTemporaryValue("combat_spellresist", eff.saveChange)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_physresist", eff.physicalId)
		self:removeTemporaryValue("combat_mentalresist", eff.mentalId)
		self:removeTemporaryValue("combat_spellresist", eff.spellId)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
}

newEffect{
	name = "HAUNTED", image = "effects/haunted.png",
	desc = "Haunted",
	long_desc = function(self, eff) return ("The target is haunted by a feeling of dread, causing each existing or new fear effect to inflict %d mind damage."):format(eff.damage) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {damage=10},
	on_gain = function(self, err) return "#F53CBE##Target# becomes haunted!", "+Haunted" end,
	on_lose = function(self, err) return "#Target# is no longer haunted", "-Haunted" end,
	activate = function(self, eff)
		for e, p in pairs(self.tmp) do
			local def = self.tempeffect_def[e]
			if def.subtype and def.subtype.fear then
				if not self.dead then
					game.logSeen(self, "#F53CBE#%s is struck by fear of the %s effect.", self.name:capitalize(), def.desc)
					eff.src:project({type="hit", x=self.x,y=self.y}, self.x, self.y, DamageType.MIND, { dam=eff.damage,alwaysHit=true,criticals=false,crossTierChance=0 })
				end
			end
		end
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	on_setFearEffect = function(self, e)
		local eff = self:hasEffect(self.EFF_HAUNTED)
		game.logSeen(self, "#F53CBE#%s is struck by fear of the %s effect.", self.name:capitalize(), util.getval(e.desc, self, e))
		eff.src:project({type="hit", x=self.x,y=self.y}, self.x, self.y, DamageType.MIND, { dam=eff.damage,alwaysHit=true,criticals=false,crossTierChance=0 })
	end,
}

newEffect{
	name = "TORMENTED", image = "effects/tormented.png",
	desc = "Tormented",
	long_desc = function(self, eff) return ("The target's mind is being tormented, causing %d apparitions to manifest and attack the target, inflicting %d mind damage each before disappearing."):format(eff.count, eff.damage) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {count=1, damage=10},
	on_gain = function(self, err) return "#F53CBE##Target# becomes tormented!", "+Tormented" end,
	on_lose = function(self, err) return "#Target# is no longer tormented", "-Tormented" end,
	activate = function(self, eff)
		updateFearParticles(self)
	end,
	deactivate = function(self, eff)
		updateFearParticles(self)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	npcTormentor = {
		name = "tormentor",
		display = "h", color=colors.DARK_GREY, image="npc/horror_eldritch_nightmare_horror.png",
		blood_color = colors.BLACK,
		desc = "A vision of terror that wracks the mind.",
		type = "horror", subtype = "eldritch",
		rank = 2,
		size_category = 2,
		body = { INVEN = 10 },
		no_drops = true,
		autolevel = "summoner",
		level_range = {1, nil}, exp_worth = 0,
		ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, ai_move="move_ghoul", },
		stats = { str=10, dex=20, wil=20, con=10, cun=30 },
		infravision = 10,
		can_pass = {pass_wall=20},
		resists = { all = 100, [DamageType.MIND]=-100 },
		no_breath = 1,
		fear_immune = 1,
		blind_immune = 1,
		infravision = 10,
		see_invisible = 80,
		max_life = resolvers.rngavg(50, 80),
		combat_armor = 1, combat_def = 50,
		combat = { dam=1 },
		resolvers.talents{
		},
		on_act = function(self)
			local target = self.ai_target.actor
			if not target or target.dead then
				self:die()
			else
				game.logSeen(self, "%s is tormented by a vision!", target.name:capitalize())
				self:project({type="hit", x=target.x,y=target.y}, target.x, target.y, engine.DamageType.MIND, { dam=self.tormentedDamage,alwaysHit=true,crossTierChance=75 })
				self:die()
			end
		end,
	},
	on_timeout = function(self, eff)
		if eff.src.dead then return true end

		-- tormentors per turn are pre-calculated in a table, but ordered, so take a random one
		local count = rng.tableRemove(eff.counts)
		for c = 1, count do
			local start = rng.range(0, 8)
			for i = start, start + 8 do
				local x = self.x + (i % 3) - 1
				local y = self.y + math.floor((i % 9) / 3) - 1
				if game.level.map:isBound(x, y) and not game.level.map(x, y, Map.ACTOR) then
					local def = self.tempeffect_def[self.EFF_TORMENTED]
					local m = require("mod.class.NPC").new(def.npcTormentor)
					m.faction = eff.src.faction
					m.summoner = eff.src
					m.summoner_gain_exp = true
					m.summon_time = 3
					m.tormentedDamage = eff.damage
					m:resolve() m:resolve(nil, true)
					m:forceLevelup(self.level)
					m:setTarget(self)

					game.zone:addEntity(game.level, m, "actor", x, y)

					break
				end
			end
		end
	end,
}

newEffect{
	name = "PANICKED", image = "talents/panic.png",
	desc = "Panicked",
	long_desc = function(self, eff) return ("The target has been panicked by %s, causing them to have a %d%% chance of fleeing in terror instead of acting."):format(eff.src.name, eff.chance) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#F53CBE##Target# becomes panicked!", "+Panicked" end,
	on_lose = function(self, err) return "#Target# is no longer panicked", "-Panicked" end,
	activate = function(self, eff)
		eff.particlesId = self:addParticles(Particles.new("fear_violet", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particlesId)

		local tInstillFear = self:getTalentFromId(self.T_INSTILL_FEAR)
		tInstillFear.endEffect(self, tInstillFear)
	end,
	do_act = function(self, eff)
		if not self:enoughEnergy() then return nil end
		if eff.src.dead then return true end

		-- apply periodic timer instead of random chance
		if not eff.timer then
			eff.timer = rng.float(0, 100)
		end
		if not self:checkHit(eff.src:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
			eff.timer = eff.timer + eff.chance * 0.5
			game.logSeen(self, "#F53CBE#%s struggles against the panic.", self.name:capitalize())
		else
			eff.timer = eff.timer + eff.chance
		end
		if eff.timer > 100 then
			eff.timer = eff.timer - 100

			local distance = core.fov.distance(self.x, self.y, eff.src.x, eff.src.y)
			if distance <= eff.range then
				-- in range
				if not self:attr("never_move") then
					local sourceX, sourceY = eff.src.x, eff.src.y

					local bestX, bestY
					local bestDistance = 0
					local start = rng.range(0, 8)
					for i = start, start + 8 do
						local x = self.x + (i % 3) - 1
						local y = self.y + math.floor((i % 9) / 3) - 1

						if x ~= self.x or y ~= self.y then
							local distance = core.fov.distance(x, y, sourceX, sourceY)
							if distance > bestDistance
									and game.level.map:isBound(x, y)
									and not game.level.map:checkAllEntities(x, y, "block_move", self)
									and not game.level.map(x, y, Map.ACTOR) then
								bestDistance = distance
								bestX = x
								bestY = y
							end
						end
					end

					if bestX then
						self:move(bestX, bestY, false)
						game.logPlayer(self, "#F53CBE#You panic and flee from %s.", eff.src.name)
					else
						self:logCombat(eff.src, "#F53CBE##Source# panics but fails to flee from #Target#.")
						self:useEnergy(game.energy_to_act * self:combatMovementSpeed(bestX, bestY))
					end
				end
			end
		end
	end,
}

newEffect{
	name = "QUICKNESS", image = "effects/quickness.png",
	desc = "Quick",
	long_desc = function(self, eff) return ("Increases global speed by %d%%."):format(eff.power * 100) end,
	type = "mental",
	subtype = { telekinesis=true, speed=true },
	status = "beneficial",
	parameters = { power=0.1 },
	on_gain = function(self, err) return "#Target# speeds up.", "+Quick" end,
	on_lose = function(self, err) return "#Target# slows down.", "-Quick" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("global_speed_add", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
	end,
}

newEffect{
	name = "PSIFRENZY", image = "talents/frenzied_focus.png",
	desc = "Frenzied Focus",
	long_desc = function(self, eff) return ("Causes telekinetically-wielded weapons to hit up to %d targets each turn."):format(eff.power) end,
	type = "mental",
	subtype = { telekinesis=true, frenzy=true },
	status = "beneficial",
	parameters = {dam=10},
	on_gain = function(self, err) return "#Target# enters a frenzy!", "+Frenzy" end,
	on_lose = function(self, err) return "#Target# is no longer frenzied.", "-Frenzy" end,
}

newEffect{
	name = "KINSPIKE_SHIELD", image = "talents/kinetic_shield.png",
	desc = "Spiked Kinetic Shield",
	long_desc = function(self, eff)
		local tl = self:getTalentLevel(self.T_ABSORPTION_MASTERY)
		local xs = (tl>=3 and ", nature" or "")..(tl>=6 and ", temporal" or "")
		return ("The target erects a powerful kinetic shield capable of absorbing %d/%d physical%s or acid damage before it crumbles."):format(self.kinspike_shield_absorb, eff.power, xs)
	end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful kinetic shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful kinetic shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("kinspike_shield", eff.power)
		self.kinspike_shield_absorb = eff.power

		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={1, 0, 0.3, 0.6}, auraColor={1, 0, 0.3, 1}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0, b=0.3, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("kinspike_shield", eff.tmpid)
		self.kinspike_shield_absorb = nil
	end,
}
newEffect{
	name = "THERMSPIKE_SHIELD", image = "talents/thermal_shield.png",
	desc = "Spiked Thermal Shield",
	long_desc = function(self, eff)
		local tl = self:getTalentLevel(self.T_ABSORPTION_MASTERY)
		local xs = (tl>=3 and ", light" or "")..(tl>=6 and ", arcane" or "")
		return ("The target erects a powerful thermal shield capable of absorbing %d/%d fire%s or cold damage before it crumbles."):format(self.thermspike_shield_absorb, eff.power, xs)
	end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful thermal shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful thermal shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("thermspike_shield", eff.power)
		self.thermspike_shield_absorb = eff.power

		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={0.3, 1, 1, 0.6}, auraColor={0.3, 1, 1, 1}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.3, g=1, b=1, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("thermspike_shield", eff.tmpid)
		self.thermspike_shield_absorb = nil
	end,
}
newEffect{
	name = "CHARGESPIKE_SHIELD", image = "talents/charged_shield.png",
	desc = "Spiked Charged Shield",
	long_desc = function(self, eff)
		local tl = self:getTalentLevel(self.T_ABSORPTION_MASTERY)
		local xs = (tl>=3 and ", darkness" or "")..(tl>=6 and ", mind" or "")
		return ("The target erects a powerful charged shield capable of absorbing %d/%d lightning%s or blight damage before it crumbles."):format(self.chargespike_shield_absorb, eff.power, xs)
	end,
	type = "mental",
	subtype = { telekinesis=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A powerful charged shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The powerful charged shield around #target# crumbles.", "-Shield" end,
	activate = function(self, eff)
		eff.tmpid = self:addTemporaryValue("chargespike_shield", eff.power)
		self.chargespike_shield_absorb = eff.power

		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield5"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor={0.8, 1, 0.2, 0.6}, auraColor={0.8, 1, 0.2, 1}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0.8, g=1, b=0.2, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("chargespike_shield", eff.tmpid)
		self.chargespike_shield_absorb = nil
	end,
}

newEffect{
	name = "CONTROL", image = "talents/perfect_control.png",
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
	name = "PSI_REGEN", image = "talents/matter_is_energy.png",
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
	name = "MASTERFUL_TELEKINETIC_ARCHERY", image = "talents/masterful_telekinetic_archery.png",
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
	name = "WEAKENED_MIND", image = "talents/taint__telepathy.png",
	desc = "Receptive Mind",
	long_desc = function(self, eff) return ("Decreases mind save by %d and increases mindpower by %d."):format(eff.save, eff.power) end,
	type = "mental",
	subtype = { morale=true },
	status = "detrimental",
	parameters = { power=10, save=10 },
	activate = function(self, eff)
		eff.mindid = self:addTemporaryValue("combat_mentalresist", -eff.save)
		eff.powdid = self:addTemporaryValue("combat_mindpower", eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.mindid)
		self:removeTemporaryValue("combat_mindpower", eff.powdid)
	end,
}

newEffect{
	name = "VOID_ECHOES", image = "talents/echoes_from_the_void.png",
	desc = "Void Echoes",
	long_desc = function(self, eff) return ("The target is seeing echoes from the void and will take %0.2f mind damage as well as some resource damage each turn it fails a mental save."):format(eff.power) end,
	type = "mental",
	subtype = { madness=true, psionic=true },
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
		self:incHate(-drain * 0.2)
		self:incPsi(-drain * 0.2)
	end,
}

newEffect{
	name = "WAKING_NIGHTMARE", image = "talents/waking_nightmare.png",
	desc = "Waking Nightmare",
	long_desc = function(self, eff) return ("The target is lost in a nightmare that deals %0.2f mind damage each turn and has a %d%% chance to cause a random detrimental effect."):format(eff.dam, eff.chance) end,
	type = "mental",
	subtype = { nightmare=true, darkness=true },
	status = "detrimental",
	parameters = { chance=10, dam = 10 },
	on_gain = function(self, err) return "#F53CBE##Target# is lost in a nightmare.", "+Night Terrors" end,
	on_lose = function(self, err) return "#Target# is free from the nightmare.", "-Night Terrors" end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
		local chance = eff.chance
		if self:attr("sleep") then chance = 100-(100-chance)/2 end -- Half normal chance to avoid effect
		if rng.percent(chance) then
			-- Pull random effect
			chance = rng.range(1, 3)
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
			game.logSeen(self, "#F53CBE#%s succumbs to the nightmare!", self.name:capitalize())
		end
	end,
}

newEffect{
	name = "INNER_DEMONS", image = "talents/inner_demons.png",
	desc = "Inner Demons",
	long_desc = function(self, eff) return ("The target is plagued by inner demons and each turn there's a %d%% chance that one will appear.  If the caster is killed or the target resists setting his demons loose the effect will end early."):format(eff.chance) end,
	type = "mental",
	subtype = { nightmare=true },
	status = "detrimental",
	remove_on_clone = true,
	parameters = {chance=0},
	on_gain = function(self, err) return "#F53CBE##Target# is plagued by inner demons!", "+Inner Demons" end,
	on_lose = function(self, err) return "#Target# is freed from the demons.", "-Inner Demons" end,
	on_timeout = function(self, eff)
		if eff.src.dead or not game.level:hasEntity(eff.src) then eff.dur = 0 return true end
		local t = eff.src:getTalentFromId(eff.src.T_INNER_DEMONS)
		local chance = eff.chance
		if self:attr("sleep") then chance = 100-(100-chance)/2 end -- Half normal chance not to manifest
		if rng.percent(chance) then
			if self:attr("sleep") or self:checkHit(eff.src:combatMindpower(), self:combatMentalResist(), 0, 95, 5) then
				t.summon_inner_demons(eff.src, self, t)
			else
				eff.dur = 0
			end
		end
	end,
}

newEffect{
	name = "PACIFICATION_HEX", image = "talents/pacification_hex.png",
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
		if not self:hasEffect(self.EFF_DAZED) and rng.percent(eff.chance) and self:canBe("stun") then
			self:setEffect(self.EFF_DAZED, 3, {})
			if not self:checkHit(eff.power, self:combatSpellResist(), 0, 95, 15) then eff.dur = 0 end
		end
	end,
	activate = function(self, eff)
		if self:canBe("stun") then
			self:setEffect(self.EFF_DAZED, 3, {})
		end
	end,
}

newEffect{
	name = "BURNING_HEX", image = "talents/burning_hex.png",
	desc = "Burning Hex",
	long_desc = function(self, eff) return ("The target is hexed.  Each time it uses an ability it takes %0.2f fire damage, and talent cooldowns are increased by %s plus 1 turn."):
		format(eff.dam, eff.power and ("%d%%"):format((eff.power-1)*100) or "")
	end,
	type = "mental",
	subtype = { hex=true, fire=true },
	status = "detrimental",
	-- _M:getTalentCooldown(t) in mod.class.Actor.lua references this table to compute cooldowns
	parameters = {dam=10, power = 1},
	on_gain = function(self, err) return "#Target# is hexed!", "+Burning Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Burning Hex" end,
}

newEffect{
	name = "EMPATHIC_HEX", image = "talents/empathic_hex.png",
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
	name = "DOMINATION_HEX", image = "talents/domination_hex.png",
	desc = "Domination Hex",
	long_desc = function(self, eff) return ("The target is hexed, temporarily changing its faction to %s."):format(engine.Faction.factions[eff.faction].name) end,
	type = "mental",
	subtype = { hex=true, dominate=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is hexed.", "+Domination Hex" end,
	on_lose = function(self, err) return "#Target# is free from the hex.", "-Domination hex" end,
	activate = function(self, eff)
		self:setTarget() -- clear ai target
		eff.olf_faction = self.faction
		self.faction = eff.src.faction
	end,
	deactivate = function(self, eff)
		self.faction = eff.olf_faction
	end,
}


newEffect{
	name = "DOMINATE_ENTHRALL", image = "talents/yeek_will.png",
	desc = "Enthralled",
	long_desc = function(self, eff) return ("The target is enthralled, temporarily changing its faction.") end,-- to %s.")--:format(engine.Faction.factions[eff.faction].name) end,
	type = "mental",
	subtype = { dominate=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return "#Target# is entralled.", "+Enthralled" end,
	on_lose = function(self, err) return "#Target# is free from the domination.", "-Enthralled" end,
	activate = function(self, eff)
		eff.olf_faction = self.faction
		self.faction = eff.src.faction
	end,
	deactivate = function(self, eff)
		self.faction = eff.olf_faction
	end,
}

newEffect{
	name = "HALFLING_LUCK", image = "talents/halfling_luck.png",
	desc = "Halflings's Luck",
	long_desc = function(self, eff) return ("The target's luck and cunning combine to grant it %d%% higher combat critical chance, %d%% higher mental critical chance, and %d%% higher spell critical chance."):format(eff.physical, eff.mind, eff.spell) end,
	type = "mental",
	subtype = { focus=true },
	status = "beneficial",
	parameters = { spell=10, physical=10 },
	on_gain = function(self, err) return "#Target# seems more aware." end,
	on_lose = function(self, err) return "#Target#'s awareness returns to normal." end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "combat_physcrit", eff.physical)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.spell)
		self:effectTemporaryValue(eff, "combat_mindcrit", eff.mind)
		self:effectTemporaryValue(eff, "combat_physresist", eff.physical)
		self:effectTemporaryValue(eff, "combat_spellresist", eff.spell)
		self:effectTemporaryValue(eff, "combat_mentalresist", eff.mind)
	end,
}

newEffect{
	name = "ATTACK", image = "talents/perfect_strike.png",
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
		eff.bid = self:addTemporaryValue("blind_fight", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_atk", eff.tmpid)
		self:removeTemporaryValue("blind_fight", eff.bid)
	end,
}

newEffect{
	name = "DEADLY_STRIKES", image = "talents/deadly_strikes.png",
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
	name = "FRENZY", image = "effects/frenzy.png",
	desc = "Frenzy",
	long_desc = function(self, eff) return ("Increases global action speed by %d%% and physical crit by %d%%.\nAdditionally the target will continue to fight until its Life reaches -%d%%."):format(eff.power * 100, eff.crit, eff.dieat * 100) end,
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
		self:removeTemporaryValue("global_speed_add", eff.tmpid)
		self:removeTemporaryValue("combat_physcrit", eff.critid)
		self:removeTemporaryValue("die_at", eff.dieatid)

		-- check negative life first incase the creature has healing
		if self.life <= (self.die_at or 0) then
			local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
			game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(-2.5, -1.5), "Falls dead!", {255,0,255})
			game.logSeen(self, "%s dies when its frenzy ends!", self.name:capitalize())
			self:die(self)
		end
	end,
}

newEffect{
	name = "BLOODBATH", image = "talents/bloodbath.png",
	desc = "Bloodbath",
	long_desc = function(self, eff) return ("The thrill of combat improves the target's maximum life by %d%%, life regeneration by %0.2f, and stamina regeneration by %0.2f."):format(eff.hp, eff.cur_regen or eff.regen, eff.cur_regen/5 or eff.regen/5) end,
	type = "mental",
	subtype = { frenzy=true, heal=true },
	status = "beneficial",
	parameters = { hp=10, regen=10, max=50 },
	on_gain = function(self, err) return nil, "+Bloodbath" end,
	on_lose = function(self, err) return nil, "-Bloodbath" end,
	on_merge = function(self, old_eff, new_eff)
		if old_eff.cur_regen + new_eff.regen < new_eff.max then	game.logSeen(self, "%s's blood frenzy intensifies!", self.name:capitalize()) end
		new_eff.templife_id = old_eff.templife_id
		self:removeTemporaryValue("max_life", old_eff.life_id)
		self:removeTemporaryValue("life_regen", old_eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", old_eff.stamina_regen_id)
		new_eff.particle1 = old_eff.particle1
		new_eff.particle2 = old_eff.particle2

		-- Take the new values, dont heal, otherwise you get a free heal each crit .. which is totaly broken
		local v = new_eff.hp * self.max_life / 100
		new_eff.life_id = self:addTemporaryValue("max_life", v)
		new_eff.cur_regen = math.min(old_eff.cur_regen + new_eff.regen, new_eff.max)
		new_eff.life_regen_id = self:addTemporaryValue("life_regen", new_eff.cur_regen)
		new_eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", new_eff.cur_regen/5)
		return new_eff
	end,
	activate = function(self, eff)
		local v = eff.hp * self.max_life / 100
		eff.life_id = self:addTemporaryValue("max_life", v)
		eff.templife_id = self:addTemporaryValue("life",v) -- Prevent healing_factor affecting activation
		eff.cur_regen = eff.regen
		eff.life_regen_id = self:addTemporaryValue("life_regen", eff.regen)
		eff.stamina_regen_id = self:addTemporaryValue("stamina_regen", eff.regen /5)
		game.logSeen(self, "%s revels in the spilt blood and grows stronger!",self.name:capitalize())

		if core.shader.active(4) then
			eff.particle1 = self:addParticles(Particles.new("shader_shield", 1, {toback=true,  size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=2.0, beamColor1={0xff/255, 0x22/255, 0x22/255, 1}, beamColor2={0xff/255, 0x60/255, 0x60/255, 1}, circleColor={0,0,0,0}, beamsCount=8}))
			eff.particle2 = self:addParticles(Particles.new("shader_shield", 1, {toback=false, size_factor=1.5, y=-0.3, img="healarcane"}, {type="healing", time_factor=4000, noup=1.0, beamColor1={0xff/255, 0x22/255, 0x22/255, 1}, beamColor2={0xff/255, 0x60/255, 0x60/255, 1}, circleColor={0,0,0,0}, beamsCount=8}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle1)
		self:removeParticles(eff.particle2)

		self:removeTemporaryValue("max_life", eff.life_id)
		self:removeTemporaryValue("life_regen", eff.life_regen_id)
		self:removeTemporaryValue("stamina_regen", eff.stamina_regen_id)
		
		self:removeTemporaryValue("life",eff.templife_id) -- remove extra hps to prevent excessive heals at high level
		game.logSeen(self, "%s no longer revels in blood quite so much.",self.name:capitalize())
	end,
}

newEffect{
	name = "BLOODRAGE", image = "talents/bloodrage.png",
	desc = "Bloodrage",
	long_desc = function(self, eff) return ("The target's strength is increased by %d by the thrill of combat."):format(eff.cur_inc) end,
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
	name = "UNSTOPPABLE", image = "talents/unstoppable.png",
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
		self:removeTemporaryValue("unstoppable", eff.tmpid)
		self:removeTemporaryValue("no_life_regen", eff.healid)
		self:heal(eff.kills * eff.hp_per_kill * self.max_life / 100, eff)
	end,
}

newEffect{
	name = "INCREASED_LIFE", image = "effects/increased_life.png",
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
			game.logSeen(self, "%s's increased life fades, leaving it stunned by the loss.", self.name:capitalize())
		end
	end,
}

newEffect{
	name = "GESTURE_OF_GUARDING", image = "talents/gesture_of_guarding.png",
	desc = "Guarded",
	long_desc = function(self, eff)
		local xs = ""
		local dam, deflects = eff.dam, eff.deflects
		if deflects < 1 then -- Partial deflect has reduced effectiveness
			dam = dam*math.max(0,deflects)
			deflects = 1
		end
		if self:isTalentActive(self.T_GESTURE_OF_PAIN) then xs = (" with a %d%% chance to counterattack"):format(self:callTalent(self.T_GESTURE_OF_GUARDING,"getCounterAttackChance")) end
		return ("Guarding against melee damage:  Will dismiss up to %d damage from the next %0.1f attack(s)%s."):format(dam, deflects, xs)
	end,
	charges = function(self, eff) return "#LIGHT_GREEN#"..math.ceil(eff.deflects) end,
	type = "mental",
	subtype = { curse=true },
	status = "beneficial",
	decrease = 0,
	no_stop_enter_worlmap = true, no_stop_resting = true,
	parameters = {dam = 1, deflects = 1},
	activate = function(self, eff)
		eff.dam = self:callTalent(self.T_GESTURE_OF_GUARDING,"getDamageChange")
		eff.deflects = self:callTalent(self.T_GESTURE_OF_GUARDING,"getDeflects")
		if eff.dam <= 0 or eff.deflects <= 0 then eff.dur = 0 end
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "RAMPAGE", image = "talents/rampage.png",
	desc = "Rampaging",
	long_desc = function(self, eff)
		local desc = ("The target is rampaging! (+%d%% movement speed, +%d%% attack speed"):format(eff.movementSpeedChange * 100, eff.combatPhysSpeedChange * 100)
		if eff.physicalDamageChange > 0 then
			desc = desc..(", +%d%% physical damage, +%d physical save, +%d mental save"):format(eff.physicalDamageChange, eff.combatPhysResistChange, eff.combatMentalResistChange)
		end
		if eff.damageShieldMax > 0 then
			desc = desc..(", %d/%d damage shrugged off this turn"):format(math.max(0, eff.damageShieldMax - eff.damageShield), eff.damageShieldMax)
		end
		desc = desc..")"
		return desc
	end,
	type = "mental",
	subtype = { frenzy=true, speed=true, evade=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#F53CBE##Target# begins rampaging!", "+Rampage" end,
	on_lose = function(self, err) return "#F53CBE##Target# is no longer rampaging.", "-Rampage" end,
	activate = function(self, eff)
		if eff.movementSpeedChange or 0 > 0 then eff.movementSpeedId = self:addTemporaryValue("movement_speed", eff.movementSpeedChange) end
		if eff.combatPhysSpeedChange or 0 > 0 then eff.combatPhysSpeedId = self:addTemporaryValue("combat_physspeed", eff.combatPhysSpeedChange) end
		if eff.physicalDamageChange or 0 > 0 then eff.physicalDamageId = self:addTemporaryValue("inc_damage", { [DamageType.PHYSICAL] = eff.physicalDamageChange }) end
		if eff.combatPhysResistChange or 0 > 0 then eff.combatPhysResistId = self:addTemporaryValue("combat_physresist", eff.combatPhysResistChange) end
		if eff.combatMentalResistChange or 0 > 0 then eff.combatMentalResistId = self:addTemporaryValue("combat_mentalresist", eff.combatMentalResistChange) end

		if not self:addShaderAura("rampage", "awesomeaura", {time_factor=5000, alpha=0.7}, "particles_images/bloodwings.png") then
			eff.particle = self:addParticles(Particles.new("rampage", 1))
		end
	end,
	deactivate = function(self, eff)
		if eff.movementSpeedId then self:removeTemporaryValue("movement_speed", eff.movementSpeedId) end
		if eff.combatPhysSpeedId then self:removeTemporaryValue("combat_physspeed", eff.combatPhysSpeedId) end
		if eff.physicalDamageId then self:removeTemporaryValue("inc_damage", eff.physicalDamageId) end
		if eff.combatPhysResistId then self:removeTemporaryValue("combat_physresist", eff.combatPhysResistId) end
		if eff.combatMentalResistId then self:removeTemporaryValue("combat_mentalresist", eff.combatMentalResistId) end

		self:removeShaderAura("rampage")
		self:removeParticles(eff.particle)
	end,
	on_timeout = function(self, eff)
		-- restore damage shield
		if eff.damageShieldMax and eff.damageShield ~= eff.damageShieldMax and not self.dead then
			eff.damageShieldUsed = (eff.damageShieldUsed or 0) + eff.damageShieldMax - eff.damageShield
			game.logSeen(self, "%s has shrugged off %d damage and is ready for more.", self.name:capitalize(), eff.damageShieldMax - eff.damageShield)
			eff.damageShield = eff.damageShieldMax

			if eff.damageShieldBonus and eff.damageShieldUsed >= eff.damageShieldBonus and eff.actualDuration < eff.maxDuration then
				eff.actualDuration = eff.actualDuration + 1
				eff.dur = eff.dur + 1
				eff.damageShieldBonus = nil

				game.logPlayer(self, "#F53CBE#Your rampage is invigorated by the intense onslaught! (+1 duration)")
			end
		end
	end,
	do_onTakeHit = function(self, eff, dam)
		if not eff.damageShieldMax or eff.damageShield <= 0 then return dam end

		local absorb = math.min(eff.damageShield, dam)
		eff.damageShield = eff.damageShield - absorb

		--game.logSeen(self, "%s shrugs off %d damage.", self.name:capitalize(), absorb)

		return dam - absorb
	end,
	do_postUseTalent = function(self, eff)
		if eff.dur > 0 then
			eff.dur = eff.dur - 1

			game.logPlayer(self, "#F53CBE#You feel your rampage slowing down. (-1 duration)")
		end
	end,
}

newEffect{
	name = "PREDATOR", image = "effects/predator.png",
	desc = "Predator",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	long_desc = function(self, eff)
		local desc = ([[The target is hunting creatures of type / sub-type: %s / %s with %d%% effectiveness. Kills: %d / %d kills, Damage: %+d%% / %+d%%]]):format(eff.type, eff.subtype, (eff.effectiveness * 100) or 0, eff.typeKills, eff.subtypeKills, (eff.typeDamageChange * 100) or 0, (eff.subtypeDamageChange * 100) or 0)
		if eff.subtypeAttackChange or 0 > 0 then
			desc = desc..([[, Attack: %+d / %+d, Stun: -- / %0.1f%%, Outmaneuver: %0.1f%% / %0.1f%%]]):format(eff.typeAttackChange or 0, eff.subtypeAttackChange or 0, eff.subtypeStunChance or 0, eff.typeOutmaneuverChance or 0, eff.subtypeOutmaneuverChance or 0)
		end
		return desc
	end,
	type = "mental",
	subtype = { predator=true },
	status = "beneficial",
	parameters = { power=10 },
	on_gain = function(self, eff) return ("#Target# begins hunting %s / %s."):format(eff.type, eff.subtype) end,
	on_lose = function(self, eff) return ("#Target# is no longer hunting %s / %s."):format(eff.type, eff.subtype) end,
	activate = function(self, eff)
		local e = self.tempeffect_def[self.EFF_PREDATOR]
		e.updateEffect(self, eff)
	end,
	deactivate = function(self, eff)
	end,
	addKill = function(self, target, e, eff)
		if target.type == eff.type then
			local isSubtype = (target.subtype == eff.subtype)
			if isSubtype then
				eff.subtypeKills = eff.subtypeKills + 1
				eff.killExperience = eff.killExperience + 1
			else
				eff.typeKills = eff.typeKills + 1
				eff.killExperience = eff.killExperience + 0.25
			end

			e.updateEffect(self, eff)

			-- apply hate bonus
			if isSubtype and self:knowTalent(self.T_HATE_POOL) then
				self:incHate(eff.hateBonus)
				game.logPlayer(self, "#F53CBE#The death of your prey feeds your hate. (+%d hate)", eff.hateBonus)
			end

			-- apply mimic effect
			if isSubtype and self:knowTalent(self.T_MIMIC) then
				local tMimic = self:getTalentFromId(self.T_MIMIC)
				self:setEffect(self.EFF_MIMIC, 1, { target = target, maxIncrease = math.ceil(tMimic.getMaxIncrease(self, tMimic) * eff.effectiveness) })
			end
		end
	end,
	updateEffect = function(self, eff)
		local tMarkPrey = self:getTalentFromId(self.T_MARK_PREY)
		eff.maxKillExperience = tMarkPrey.getMaxKillExperience(self, tMarkPrey)
		eff.effectiveness = math.min(1, eff.killExperience / eff.maxKillExperience)
		eff.subtypeDamageChange = tMarkPrey.getSubtypeDamageChange(self, tMarkPrey) * eff.effectiveness
		eff.typeDamageChange = tMarkPrey.getTypeDamageChange(self, tMarkPrey) * eff.effectiveness

		local tAnatomy = self:getTalentFromId(self.T_ANATOMY)
		if tAnatomy and self:getTalentLevelRaw(tAnatomy) > 0 then
			eff.subtypeAttackChange = tAnatomy.getSubtypeAttackChange(self, tAnatomy) * eff.effectiveness
			eff.typeAttackChange = tAnatomy.getTypeAttackChange(self, tAnatomy) * eff.effectiveness
			eff.subtypeStunChance = tAnatomy.getSubtypeStunChance(self, tAnatomy) * eff.effectiveness
		else
			eff.subtypeAttackChange = 0
			eff.typeAttackChange = 0
			eff.subtypeStunChance = 0
		end

		local tOutmaneuver = self:getTalentFromId(self.T_OUTMANEUVER)
		if tOutmaneuver and self:getTalentLevelRaw(tOutmaneuver) > 0 then
			eff.typeOutmaneuverChance = tOutmaneuver.getTypeChance(self, tOutmaneuver) * eff.effectiveness
			eff.subtypeOutmaneuverChance = tOutmaneuver.getSubtypeChance(self, tOutmaneuver) * eff.effectiveness
		else
			eff.typeOutmaneuverChance = 0
			eff.subtypeOutmaneuverChance = 0
		end

		eff.hateBonus = tMarkPrey.getHateBonus(self, tMarkPrey)
	end,
}

newEffect{
	name = "OUTMANEUVERED", image = "talents/outmaneuver.png",
	desc = "Outmaneuvered",
	long_desc = function(self, eff)
		local desc = ("The target has been outmaneuvered. (%d%% physical resistance, "):format(eff.physicalResistChange)
		local first = true
		for id, value in pairs(eff.incStats) do
			if not first then desc = desc..", " end
			first = false
			desc = desc..("%+d %s"):format(value, Stats.stats_def[id].name:capitalize())
		end
		desc = desc..")"
		return desc
	end,
	type = "mental",
	subtype = { predator=true },
	status = "detrimental",
	on_gain = function(self, eff) return "#Target# is outmaneuvered." end,
	on_lose = function(self, eff) return "#Target# is no longer outmaneuvered." end,
	addEffect = function(self, eff)
		if eff.physicalResistId then self:removeTemporaryValue("resists", eff.physicalResistId) end
		eff.physicalResistId = self:addTemporaryValue("resists", { [DamageType.PHYSICAL]=eff.physicalResistChange })

		local maxId
		local maxValue = 0
		for id, def in ipairs(self.stats_def) do
			if def.id ~= self.STAT_LCK then
				local value = self:getStat(id, nil, nil, false)
				if value > maxValue then
					maxId = id
					maxValue = value
				end
			end
		end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
		eff.incStats = eff.incStats or {}
		eff.incStats[maxId] = (eff.incStats[maxId] or 0) - eff.statReduction
		eff.incStatsId = self:addTemporaryValue("inc_stats", eff.incStats)
		game.logSeen(self, ("%s has lost %d %s."):format(self.name:capitalize(), eff.statReduction, Stats.stats_def[maxId].name:capitalize()))
	end,
	activate = function(self, eff)
		self.tempeffect_def[self.EFF_OUTMANEUVERED].addEffect(self, eff)
	end,
	deactivate = function(self, eff)
		if eff.physicalResistId then self:removeTemporaryValue("resists", eff.physicalResistId) end
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
	end,
	on_merge = function(self, old_eff, new_eff)
		-- spread old effects over new duration
		old_eff.physicalResistChange = math.min(50, new_eff.physicalResistChange + (old_eff.physicalResistChange * old_eff.dur / new_eff.dur))
		for id, value in pairs(old_eff.incStats) do
			old_eff.incStats[id] = math.ceil(value * old_eff.dur / new_eff.dur)
		end
		old_eff.dur = new_eff.dur

		-- add new effect
		self.tempeffect_def[self.EFF_OUTMANEUVERED].addEffect(self, old_eff)

		return old_eff
	end,
}

newEffect{
	name = "MIMIC", image = "talents/mimic.png",
	desc = "Mimic",
	long_desc = function(self, eff)
		if not eff.incStatsId then return "The target is mimicking a previous victim. (no gains)." end

		local desc = "The target is mimicking a previous victim. ("
		local first = true
		for id, value in pairs(eff.incStats) do
			if not first then desc = desc..", " end
			first = false
			desc = desc..("%+d %s"):format(value, Stats.stats_def[id].name:capitalize())
		end
		desc = desc..")"
		return desc
	end,
	type = "mental",
	subtype = { predator=true },
	status = "beneficial",
	no_stop_enter_worlmap = true,
	decrease = 0,
	no_remove = true,
	cancel_on_level_change = true,
	parameters = { },
	on_lose = function(self, eff) return "#Target# is no longer mimicking a previous victim." end,
	activate = function(self, eff)
		-- old version used difference from target stats and self stats; new version just uses target stats
		local sum = 0
		local values = {}
		for id, def in ipairs(self.stats_def) do
			if def.id and def.id ~= self.STAT_LCK then
				--local diff = eff.target:getStat(def.id, nil, nil, true) - self:getStat(def.id, nil, nil, true)
				local diff = eff.target:getStat(def.id, nil, nil, false)
				if diff > 0 then
					table.insert(values, { def.id, diff })
					sum = sum + diff
				end
			end
		end

		if sum > 0 then
			eff.incStats = {}
			if sum <= eff.maxIncrease then
				-- less than maximum; apply all stat differences
				for i, value in ipairs(values) do
					eff.incStats[value[1]] = value[2]
				end
			else
				-- distribute stats based on fractions and calculate what the remainder will be
				local sumIncrease = 0
				for i, value in ipairs(values) do
					value[2] = eff.maxIncrease * value[2] / sum
					sumIncrease = sumIncrease + math.floor(value[2])
				end
				local remainder = eff.maxIncrease - sumIncrease

				-- sort on fractional amount for distributing the remainder points
				table.sort(values, function(a,b) return a[2] % 1 > b[2] % 1 end)

				-- convert fractions to stat increases and apply remainder
				for i, value in ipairs(values) do
					eff.incStats[value[1]] = math.floor(value[2]) + (i <= remainder and 1 or 0)
				end
			end
			eff.incStatsId = self:addTemporaryValue("inc_stats", eff.incStats)
		end

		if not eff.incStatsId then
			self:logCombat(eff.target, "#Source# is mimicking #Target#. (no gains).")
		else
			local desc = "#Source# is mimicking #Target#. ("
			local first = true
			for id, value in pairs(eff.incStats) do
				if not first then desc = desc..", " end
				first = false
				desc = desc..("%+d %s"):format(value, Stats.stats_def[id].name:capitalize())
			end
			desc = desc..")"
			self:logCombat(eff.target, desc)
		end
	end,
	deactivate = function(self, eff)
		if eff.incStatsId then self:removeTemporaryValue("inc_stats", eff.incStatsId) end
		eff.incStats = nil
	end,
	on_merge = function(self, old_eff, new_eff)
		if old_eff.incStatsId then self:removeTemporaryValue("inc_stats", old_eff.incStatsId) end
		old_eff.incStats = nil
		old_eff.incStatsId = nil

		self.tempeffect_def[self.EFF_MIMIC].activate(self, new_eff)

		return new_eff
	end
}

newEffect{
	name = "ORC_FURY", image = "talents/orc_fury.png",
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

newEffect{
	name = "INTIMIDATED",
	desc = "Intimidated",
	long_desc = function(self, eff) return ("The target's morale is weakened, reducing its attack power, mind power, and spellpower by %d."):format(eff.power) end,
	type = "mental",
	subtype = { fear=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#'s morale has been lowered.", "+Intimidated" end,
	on_lose = function(self, err) return "#Target# has regained its confidence.", "-Intimidated" end,
	parameters = { power=1 },
	activate = function(self, eff)
		eff.damid = self:addTemporaryValue("combat_dam", -eff.power)
		eff.spellid = self:addTemporaryValue("combat_spellpower", -eff.power)
		eff.mindid = self:addTemporaryValue("combat_mindpower", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_dam", eff.damid)
		self:removeTemporaryValue("combat_spellpower", eff.spellid)
		self:removeTemporaryValue("combat_mindpower", eff.mindid)
	end,
}

newEffect{
	name = "BRAINLOCKED",
	desc = "Brainlocked",
	long_desc = function(self, eff) return ("Renders a random talent unavailable. No talents will cool down until the effect has worn off."):format() end,
	type = "mental",
	subtype = { ["cross tier"]=true },
	status = "detrimental",
	parameters = {},
	on_gain = function(self, err) return nil, "+Brainlocked" end,
	on_lose = function(self, err) return nil, "-Brainlocked" end,
	activate = function(self, eff)
		eff.tcdid = self:addTemporaryValue("no_talents_cooldown", 1)
		local tids = {}
		for tid, lev in pairs(self.talents) do
			local t = self:getTalentFromId(tid)
			if t and not self.talents_cd[tid] and t.mode == "activated" and not t.innate then tids[#tids+1] = t end
		end
		for i = 1, 1 do
			local t = rng.tableRemove(tids)
			if not t then break end
			self.talents_cd[t.id] = 1
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_talents_cooldown", eff.tcdid)
	end,
}

newEffect{
	name = "FRANTIC_SUMMONING", image = "talents/frantic_summoning.png",
	desc = "Frantic Summoning",
	long_desc = function(self, eff) return ("Reduces the time taken for summoning by %d%%."):format(eff.power) end,
	type = "mental",
	subtype = { summon=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target# starts summoning at high speed.", "+Frantic Summoning" end,
	on_lose = function(self, err) return "#Target#'s frantic summoning ends.", "-Frantic Summoning" end,
	parameters = { power=20 },
	activate = function(self, eff)
		eff.failid = self:addTemporaryValue("no_equilibrium_summon_fail", 1)
		eff.speedid = self:addTemporaryValue("fast_summons", eff.power)

		-- Find a cooling down summon talent and enable it
		local list = {}
		for tid, dur in pairs(self.talents_cd) do
			local t = self:getTalentFromId(tid)
			if t.is_summon then
				list[#list+1] = t
			end
		end
		if #list > 0 then
			local t = rng.table(list)
			self.talents_cd[t.id] = nil
			if self.onTalentCooledDown then self:onTalentCooledDown(t.id) end
		end
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("no_equilibrium_summon_fail", eff.failid)
		self:removeTemporaryValue("fast_summons", eff.speedid)
	end,
}

newEffect{
	name = "WILD_SUMMON", image = "talents/wild_summon.png",
	desc = "Wild Summon",
	long_desc = function(self, eff) return ("%d%% chance to get a more powerful summon."):format(eff.chance) end,
	type = "mental",
	subtype = { summon=true },
	status = "beneficial",
	parameters = { chance=100 },
	activate = function(self, eff)
		eff.tid = self:addTemporaryValue("wild_summon", eff.chance)
	end,
	on_timeout = function(self, eff)
		eff.chance = eff.chance or 100
		eff.chance = math.floor(eff.chance * 0.66)
		self:removeTemporaryValue("wild_summon", eff.tid)
		eff.tid = self:addTemporaryValue("wild_summon", eff.chance)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("wild_summon", eff.tid)
	end,
}

newEffect{
	name = "LOBOTOMIZED", image = "talents/psychic_lobotomy.png",
	desc = "Lobotomized (confused)",
	long_desc = function(self, eff) return ("The target's mental faculties have been severely impaired, making it act randomly each turn (%d%% chance) and reducing its cunning by %d."):format(eff.confuse, eff.power/2) end,
	type = "mental",
	subtype = { confusion=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target# higher mental functions have been imparied.", "+Lobotomized" end,
	on_lose = function(self, err) return "#Target#'s regains its senses.", "-Lobotomized" end,
	parameters = { power=1, confuse=10, dam=1 },
	activate = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, {dam=eff.dam, alwaysHit=true})
		eff.confuse = math.floor(math.max(eff.confuse - (self:attr("confusion_immune") or 0) * 100, 10))
		eff.confuse = util.bound(eff.confuse, 0, 50) -- Confusion cap of 50%
		eff.tmpid = self:addTemporaryValue("confused", eff.confuse)
		eff.cid = self:addTemporaryValue("inc_stats", {[Stats.STAT_CUN]=-eff.power/2})
		if eff.power <= 0 then eff.dur = 0 end
		eff.particles = self:addParticles(engine.Particles.new("generic_power", 1, {rm=100, rM=125, gm=100, gM=125, bm=100, bM=125, am=200, aM=255}))
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("confused", eff.tmpid)
		self:removeTemporaryValue("inc_stats", eff.cid)
		if eff.particles then self:removeParticles(eff.particles) end
		if self == game.player and self.updateMainShader then self:updateMainShader() end
	end,
}

newEffect{
	name = "PSIONIC_SHIELD", image = "talents/kinetic_shield.png",
	desc = "Psionic Shield",
	display_desc = function(self, eff) return eff.kind:capitalize().." Psionic Shield" end,
	long_desc = function(self, eff) return ("Reduces all incoming %s damage by %d."):format(eff.what, eff.power) end,
	type = "mental",
	subtype = { psionic=true, shield=true },
	status = "beneficial",
	parameters = { power=10, kind="kinetic" },
	activate = function(self, eff)
		if eff.kind == "kinetic" then
			eff.sid = self:addTemporaryValue("flat_damage_armor", {
				[DamageType.PHYSICAL] = eff.power,
				[DamageType.ACID] = eff.power,
				[DamageType.NATURE] = eff.power,
				[DamageType.TEMPORAL] = eff.power,
			})
			eff.what = "physical, nature, acid, temporal"
		elseif eff.kind == "thermal" then
			eff.sid = self:addTemporaryValue("flat_damage_armor", {
				[DamageType.FIRE] = eff.power, 
				[DamageType.COLD] = eff.power,
				[DamageType.LIGHT] = eff.power,
				[DamageType.ARCANE] = eff.power,
				})
			eff.what = "fire, cold, light, arcane"
		elseif eff.kind == "charged" then
			eff.sid = self:addTemporaryValue("flat_damage_armor", {
				[DamageType.LIGHTNING] = eff.power, 
				[DamageType.BLIGHT] = eff.power,
				[DamageType.MIND] = eff.power,
				[DamageType.DARKNESS] = eff.power,
				})
			eff.what = "lightning, blight, mind, darkness"
		end
	end,
	deactivate = function(self, eff)
		if eff.sid then
			self:removeTemporaryValue("flat_damage_armor", eff.sid)
		end
	end,
}

newEffect{
	name = "CLEAR_MIND", image = "talents/mental_shielding.png",
	desc = "Clear Mind",
	long_desc = function(self, eff) return ("Nullifies the next %d detrimental mental effects."):format(self.mental_negative_status_effect_immune) end,
	type = "mental",
	subtype = { psionic=true, },
	status = "beneficial",
	parameters = { power=2 },
	activate = function(self, eff)
		self.mental_negative_status_effect_immune = eff.power
		eff.particles = self:addParticles(engine.Particles.new("generic_power", 1, {rm=0, rM=0, gm=100, gM=180, bm=180, bM=255, am=200, aM=255}))
	end,
	deactivate = function(self, eff)
		self.mental_negative_status_effect_immune = nil
		self:removeParticles(eff.particles)
	end,
}

newEffect{
	name = "RESONANCE_FIELD", image = "talents/resonance_field.png",
	desc = "Resonance Field",
	long_desc = function(self, eff) return ("The target is surrounded by a psychic field, absorbing 50%% of all damage (up to %d/%d)."):format(self.resonance_field_absorb, eff.power) end,
	type = "mental",
	subtype = { psionic=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A psychic field forms around #target#.", "+Resonance Shield" end,
	on_lose = function(self, err) return "The psychic field around #target# crumbles.", "-Resonance Shield" end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		self.resonance_field_absorb = eff.power
		eff.sid = self:addTemporaryValue("resonance_field", eff.power)
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={1, 1, 0}}))
		--	eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, color={1, 1, 0}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=1, b=0, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self.resonance_field_absorb = nil
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("resonance_field", eff.sid)
	end,
}

newEffect{
	name = "MIND_LINK_TARGET", image = "talents/mind_link.png",
	desc = "Mind Link",
	long_desc = function(self, eff) return ("The target's mind has been invaded, increasing all mind damage it receives from %s by %d%%."):format(eff.src.name:capitalize(), eff.power) end,
	type = "mental",
	subtype = { psionic=true },
	status = "detrimental",
	parameters = {power = 1, range = 5},
	remove_on_clone = true, decrease = 0,
	on_gain = function(self, err) return "#Target#'s mind has been invaded!", "+Mind Link" end,
	on_lose = function(self, err) return "#Target# is free from the mental invasion.", "-Mind Link" end,
	on_timeout = function(self, eff)
		-- Remove the mind link when appropriate
		local p = eff.src:isTalentActive(eff.src.T_MIND_LINK)
		if not p or p.target ~= self or eff.src.dead or not game.level:hasEntity(eff.src) or core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) > eff.range then
			self:removeEffect(self.EFF_MIND_LINK_TARGET)
		end
	end,
}

newEffect{
	name = "FEEDBACK_LOOP", image = "talents/feedback_loop.png",
	desc = "Feedback Loop",
	long_desc = function(self, eff) return "The target is gaining feedback." end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target# is gaining feedback.", "+Feedback Loop" end,
	on_lose = function(self, err) return "#Target# is no longer gaining feedback.", "-Feedback Loop" end,
	activate = function(self, eff)
		eff.particle = self:addParticles(Particles.new("ultrashield", 1, {rm=255, rM=255, gm=180, gM=255, bm=0, bM=0, am=35, aM=90, radius=0.2, density=15, life=28, instop=40}))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "FOCUSED_WRATH", image = "talents/focused_wrath.png",
	desc = "Focused Wrath",
	long_desc = function(self, eff) return ("The target's subconscious has focused its attention on %s."):format(eff.target.name:capitalize()) end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power = 1 },
	on_gain = function(self, err) return "#Target#'s subconscious has been focused.", "+Focused Wrath" end,
	on_lose = function(self, err) return "#Target#'s subconscious has returned to normal.", "-Focused Wrath" end,
	on_timeout = function(self, eff)
		if not eff.target or eff.target.dead or not game.level:hasEntity(eff.target) then
			self:removeEffect(self.EFF_FOCUSED_WRATH)
		end
	end,
}

newEffect{
	name = "SLEEP", image = "talents/sleep.png",
	desc = "Sleep",
	long_desc = function(self, eff) return ("The target is asleep and unable to act.  Every %d damage it takes will reduce the duration of the effect by one turn."):format(eff.power) end,
	type = "mental",
	subtype = { sleep=true },
	status = "detrimental",
	parameters = { power=1, insomnia=1, waking=0, contagious=0 },
	on_gain = function(self, err) return "#Target# has been put to sleep.", "+Sleep" end,
	on_lose = function(self, err) return "#Target# is no longer sleeping.", "-Sleep" end,
	on_timeout = function(self, eff)
		local dream_prison = false
		if eff.src and eff.src.isTalentActive and eff.src:isTalentActive(eff.src.T_DREAM_PRISON) then
			local t = eff.src:getTalentFromId(eff.src.T_DREAM_PRISON)
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.src:getTalentRange(t) then
				dream_prison = true
			end
		end
		if dream_prison then
			eff.dur = eff.dur + 1
			if not eff.particle then
				if core.shader.active(4) then
					eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, aadjust=5, color={0, 1, 1}}))
				else
					eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
				end
			end
		elseif eff.contagious > 0 and eff.dur > 1 then
			local t = eff.src:getTalentFromId(eff.src.T_SLEEP)
			t.doContagiousSleep(eff.src, self, eff, t)
		end
		if eff.particle and not dream_prison then
			self:removeParticles(eff.particle)
		end
		-- Incriment Insomnia Duration
		if not self:attr("lucid_dreamer") then
			self:setEffect(self.EFF_INSOMNIA, 1, {power=eff.insomnia})
		end
	end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("sleep", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep", eff.sid)
		if not self:attr("sleep") and not self.dead and game.level:hasEntity(self) and eff.waking > 0 then
			local t = eff.src:getTalentFromId(self.T_RESTLESS_NIGHT)
			t.doRestlessNight(eff.src, self, eff.waking)
		end
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "SLUMBER", image = "talents/slumber.png",
	desc = "Slumber",
	long_desc = function(self, eff) return ("The target is in a deep sleep and unable to act.  Every %d damage it takes will reduce the duration of the effect by one turn."):format(eff.power) end,
	type = "mental",
	subtype = { sleep=true },
	status = "detrimental",
	parameters = { power=1, insomnia=1, waking=0 },
	on_gain = function(self, err) return "#Target# is in a deep sleep.", "+Slumber" end,
	on_lose = function(self, err) return "#Target# is no longer sleeping.", "-Slumber" end,
	on_timeout = function(self, eff)
		local dream_prison = false
		if eff.src and eff.src.isTalentActive and eff.src:isTalentActive(eff.src.T_DREAM_PRISON) then
			local t = eff.src:getTalentFromId(eff.src.T_DREAM_PRISON)
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.src:getTalentRange(t) then
				dream_prison = true
			end
		end
		if dream_prison then
			eff.dur = eff.dur + 1
			if not eff.particle then
				if core.shader.active(4) then
					eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", time_factor=6000, aadjust=5, color={0, 1, 1}}))
				else
					eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
				end
			end
		elseif eff.particle and not dream_prison then
			self:removeParticles(eff.particle)
		end
		-- Incriment Insomnia Duration
		if not self:attr("lucid_dreamer") then
			self:setEffect(self.EFF_INSOMNIA, 1, {power=eff.insomnia})
		end
	end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("sleep", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep", eff.sid)
		if not self:attr("sleep") and not self.dead and game.level:hasEntity(self) and eff.waking > 0 then
			local t = eff.src:getTalentFromId(self.T_RESTLESS_NIGHT)
			t.doRestlessNight(eff.src, self, eff.waking)
		end
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "NIGHTMARE", image = "talents/nightmare.png",
	desc = "Nightmare",
	long_desc = function(self, eff) return ("The target is in a nightmarish sleep, suffering %0.2f mind damage each turn and unable to act.  Every %d damage it takes will reduce the duration of the effect by one turn."):format(eff.dam, eff.power) end,
	type = "mental",
	subtype = { nightmare=true, sleep=true },
	status = "detrimental",
	parameters = { power=1, dam=0, insomnia=1, waking=0},
	on_gain = function(self, err) return "#F53CBE##Target# is lost in a nightmare.", "+Nightmare" end,
	on_lose = function(self, err) return "#Target# is free from the nightmare.", "-Nightmare" end,
	on_timeout = function(self, eff)
		local dream_prison = false
		if eff.src and eff.src.isTalentActive and eff.src:isTalentActive(eff.src.T_DREAM_PRISON) then
			local t = eff.src:getTalentFromId(eff.src.T_DREAM_PRISON)
			if core.fov.distance(self.x, self.y, eff.src.x, eff.src.y) <= eff.src:getTalentRange(t) then
				dream_prison = true
			end
		end
		if dream_prison then
			eff.dur = eff.dur + 1
			if not eff.particle then
				if core.shader.active(4) then
					eff.particle = self:addParticles(Particles.new("shader_shield", 1, {img="shield2", size_factor=1.25}, {type="shield", aadjust=5, color={0, 1, 1}}))
				else
					eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=0, g=1, b=1, a=1}))
				end
			end
		else
			-- Store the power for later
			local real_power = eff.temp_power or eff.power
			-- Temporarily spike the temp_power so the nightmare doesn't break it
			eff.temp_power = 10000
			DamageType:get(DamageType.DARKNESS).projector(eff.src or self, self.x, self.y, DamageType.DARKNESS, eff.dam)
			-- Set the power back to its baseline
			eff.temp_power = real_power
		end
		if eff.particle and not dream_prison then
			self:removeParticles(eff.particle)
		end
		-- Incriment Insomnia Duration
		if not self:attr("lucid_dreamer") then
			self:setEffect(self.EFF_INSOMNIA, 1, {power=eff.insomnia})
		end
	end,
	activate = function(self, eff)
		eff.sid = self:addTemporaryValue("sleep", 1)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep", eff.sid)
		if not self:attr("sleep") and not self.dead and game.level:hasEntity(self) and eff.waking > 0 then
			local t = eff.src:getTalentFromId(self.T_RESTLESS_NIGHT)
			t.doRestlessNight(eff.src, self, eff.waking)
		end
		if eff.particle then
			self:removeParticles(eff.particle)
		end
	end,
}

newEffect{
	name = "RESTLESS_NIGHT", image = "talents/restless_night.png",
	desc = "Restless Night",
	long_desc = function(self, eff) return ("Fatigue from poor sleep, dealing %0.2f mind damage per turn."):format(eff.power) end,
	type = "mental",
	subtype = { psionic=true},
	status = "detrimental",
	parameters = { power=1 },
	on_gain = function(self, err) return "#Target# had a restless night.", "+Restless Night" end,
	on_lose = function(self, err) return "#Target# has recovered from poor sleep.", "-Restless Night" end,
	on_merge = function(self, old_eff, new_eff)
		-- Merge the flames!
		local olddam = old_eff.power * old_eff.dur
		local newdam = new_eff.power * new_eff.dur
		local dur = math.ceil((old_eff.dur + new_eff.dur) / 2)
		old_eff.dur = dur
		old_eff.power = (olddam + newdam) / dur
		return old_eff
	end,
	on_timeout = function(self, eff)
		DamageType:get(DamageType.MIND).projector(eff.src or self, self.x, self.y, DamageType.MIND, eff.power)
	end,
}

newEffect{
	name = "INSOMNIA", image = "effects/insomnia.png",
	desc = "Insomnia",
	long_desc = function(self, eff) return ("The target is wide awake and has %d%% resistance to sleep effects."):format(eff.cur_power) end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power=0 },
	on_gain = function(self, err) return "#Target# is suffering from insomnia.", "+Insomnia" end,
	on_lose = function(self, err) return "#Target# is no longer suffering from insomnia.", "-Insomnia" end,
	on_merge = function(self, old_eff, new_eff)
		-- Add the durations on merge
		local dur = old_eff.dur + new_eff.dur
		old_eff.dur = math.min(10, dur)
		old_eff.cur_power = old_eff.power * old_eff.dur
		-- Need to remove and re-add the effect
		self:removeTemporaryValue("sleep_immune", old_eff.sid)
		old_eff.sid = self:addTemporaryValue("sleep_immune", old_eff.cur_power/100)
		return old_eff
	end,
	on_timeout = function(self, eff)
		-- Insomnia only ticks when we're awake
		if self:attr("sleep") and self:attr("sleep") > 0 then
			eff.dur = eff.dur + 1
		else
			-- Deincrement the power
			eff.cur_power = eff.power * eff.dur
			self:removeTemporaryValue("sleep_immune", eff.sid)
			eff.sid = self:addTemporaryValue("sleep_immune", eff.cur_power/100)
		end
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power * eff.dur
		eff.sid = self:addTemporaryValue("sleep_immune", eff.cur_power/100)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("sleep_immune", eff.sid)
	end,
}

newEffect{
	name = "SUNDER_MIND", image = "talents/sunder_mind.png",
	desc = "Sundered Mind",
	long_desc = function(self, eff) return ("The target's mental faculties have been impaired, reducing its mental save by %d."):format(eff.cur_power or eff.power) end,
	type = "mental",
	subtype = { psionic=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#'s mental functions have been impaired.", "+Sundered Mind" end,
	on_lose = function(self, err) return "#Target# regains its senses.", "-Sundered Mind" end,
	parameters = { power=10 },
	on_merge = function(self, old_eff, new_eff)
		self:removeTemporaryValue("combat_mentalresist", old_eff.sunder)
		old_eff.cur_power = old_eff.cur_power + new_eff.power
		old_eff.sunder = self:addTemporaryValue("combat_mentalresist", -old_eff.cur_power)

		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		eff.cur_power = eff.power
		eff.sunder = self:addTemporaryValue("combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("combat_mentalresist", eff.sunder)
	end,
}

newEffect{
	name = "BROKEN_DREAM", image = "effects/broken_dream.png",
	desc = "Broken Dream",
	long_desc = function(self, eff) return ("The target's dreams have been broken by the dreamforge, reducing its mental save by %d and reducing its chance of successfully casting a spell by %d%%."):format(eff.power, eff.fail) end,
	type = "mental",
	subtype = { psionic=true, morale=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target#'s dreams have been broken.", "+Broken Dream" end,
	on_lose = function(self, err) return "#Target# regains hope.", "-Broken Dream" end,
	parameters = { power=10, fail=10 },
	activate = function(self, eff)
		eff.silence = self:addTemporaryValue("spell_failure", eff.fail)
		eff.sunder = self:addTemporaryValue("combat_mentalresist", -eff.power)
	end,
	deactivate = function(self, eff)
		self:removeTemporaryValue("spell_failure", eff.silence)
		self:removeTemporaryValue("combat_mentalresist", eff.sunder)
	end,
}

newEffect{
	name = "FORGE_SHIELD", image = "talents/block.png",
	desc = "Forge Shield",
	long_desc = function(self, eff)
		local e_string = ""
		if eff.number == 1 then
			e_string = DamageType.dam_def[next(eff.d_types)].name
		else
			local list = table.keys(eff.d_types)
			for i = 1, #list do
				list[i] = DamageType.dam_def[list[i]].name
			end
			e_string = table.concat(list, ", ")
		end
		local function tchelper(first, rest)
		  return first:upper()..rest:lower()
		end
		return ("Absorbs %d damage from the next blockable attack.  Currently Blocking: %s."):format(eff.power, e_string:gsub("(%a)([%w_']*)", tchelper))
	end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { power=1 },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
		damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.1}, {type="shield", time_factor=-8000, llpow=1, aadjust=7, color={1, 0.5, 0}}))
		else
			eff.particle = self:addParticles(Particles.new("generic_shield", 1, {r=1, g=0.5, b=0.0, a=1}))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "HIDDEN_RESOURCES", image = "talents/hidden_resources.png",
	desc = "Hidden Resources",
	long_desc = function(self, eff) return "The target does not consume any resources." end,
	type = "mental",
	subtype = { willpower=true },
	status = "beneficial",
	on_gain = function(self, err) return "#Target#'s focuses.", "+Hidden Ressources" end,
	on_lose = function(self, err) return "#Target#'s loses some focus.", "-Hidden Ressources" end,
	parameters = { },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "force_talent_ignore_ressources", 1)
	end,
}

newEffect{
	name = "SPELL_FEEDBACK", image = "talents/spell_feedback.png",
	desc = "Spell Feedback",
	long_desc = function(self, eff) return ("The target suffers %d%% spell failue."):format(eff.power) end,
	type = "mental",
	subtype = { nature=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target# is surrounded by antimagic forces.", "+Spell Feedback" end,
	on_lose = function(self, err) return "#Target#'s antimagic forces vanishes.", "-Spell Feedback" end,
	parameters = { power=40 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "spell_failure", eff.power)
	end,
}

newEffect{
	name = "MIND_PARASITE", image = "talents/mind_parasite.png",
	desc = "Mind Parasite",
	long_desc = function(self, eff) return ("The target is infected with a mind parasite. Each time it uses a talent it has a %d%% chance to have %d random talent(s) put on cooldown for %d turns."):format(eff.chance, eff.nb, eff.turns) end,
	type = "mental",
	subtype = { nature=true, mind=true },
	status = "detrimental",
	on_gain = function(self, err) return "#Target# is infected with a mind parasite.", "+Mind Parasite" end,
	on_lose = function(self, err) return "#Target# is free from the mind parasite.", "-Mind Parasite" end,
	parameters = { chance=40, nb=1, turns=2 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "random_talent_cooldown_on_use", eff.chance)
		self:effectTemporaryValue(eff, "random_talent_cooldown_on_use_nb", eff.nb)
		self:effectTemporaryValue(eff, "random_talent_cooldown_on_use_turns", eff.turns)
	end,
}

newEffect{
	name = "MINDLASH", image = "talents/mindlash.png",
	desc = "Mindlash",
	long_desc = function(self, eff) return ("Repeated mindlash usage is very taxing increasing the psi cost each time (currently %d%%)"):format(eff.power * 100) end,
	type = "mental",
	subtype = { mind=true },
	status = "detrimental",
	parameters = {  },
	on_merge = function(self, old_eff, new_eff)
		new_eff.power = old_eff.power + 1
		return new_eff
	end,
	activate = function(self, eff)
		eff.power = 2
	end,
}

newEffect{
	name = "SHADOW_EMPATHY", image = "talents/shadow_empathy.png",
	desc = "Shadow Empathy",
	long_desc = function(self, eff) return ("%d%% of all damage is redirected to a random shadow."):format(eff.power) end,
	type = "mental",
	subtype = { mind=true, shield=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "shadow_empathy", eff.power)
		eff.particle = self:addParticles(Particles.new("darkness_power", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)		
	end,
}

newEffect{
	name = "SHADOW_DECOY", image = "talents/shadow_decoy.png",
	desc = "Shadow Decoy",
	long_desc = function(self, eff) return ("A random shadow absorbed a fatal blow for you, granting you a negative shield of %d."):format(eff.power) end,
	type = "mental",
	subtype = { mind=true, shield=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "die_at", -eff.power)
		eff.particle = self:addParticles(Particles.new("darkness_power", 1))
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)		
	end,
}

newEffect{
	name = "CRYSTAL_BUFF", image = "talents/stone_touch.png",
	desc = "Crystal Resonance",
	--Might consider adding the gem properties to this tooltip
	long_desc = function(self, eff) return ("The power released by the %s resonates."):format(eff.name) end,
	type = "mental",
	subtype = { psionic=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return "#Target# glints with a crystaline aura", "+Crystal Resonance" end,
	on_lose = function(self, err) return "#Target# is no longer glinting.", "-Crystal Resonance" end,
	gem_types = {
		GEM_DIAMOND = function(self, eff) return {self:effectTemporaryValue(eff, "inc_stats", {[Stats.STAT_STR] = 5, [Stats.STAT_DEX] = 5, [Stats.STAT_MAG] = 5, [Stats.STAT_WIL] = 5, [Stats.STAT_CUN] = 5, [Stats.STAT_CON] = 5 }), } end,
		GEM_PEARL = function(self, eff) return {self:effectTemporaryValue(eff,"resists", { all = 5}), self:effectTemporaryValue(eff,"combat_armour", 5) } end,
		GEM_MOONSTONE = function(self, eff) return {self:effectTemporaryValue(eff,"combat_def", 10), self:effectTemporaryValue(eff,"combat_mentalresist", 10), self:effectTemporaryValue(eff,"combat_spellresist", 10), self:effectTemporaryValue(eff,"combat_physresist", 10), } end,
		GEM_FIRE_OPAL = function(self, eff) return {self:effectTemporaryValue(eff,"inc_damage", { all = 10}), self:effectTemporaryValue(eff,"combat_physcrit", 5), self:effectTemporaryValue(eff,"combat_mindcrit", 5), self:effectTemporaryValue(eff,"combat_spellcrit", 5) } end,
		GEM_BLOODSTONE = function(self, eff) return {self:effectTemporaryValue(eff,"stun_immune", 0.6) } end,
		GEM_RUBY = function(self, eff) return {self:effectTemporaryValue(eff,"inc_stats", {[Stats.STAT_STR] = 4, [Stats.STAT_DEX] = 4, [Stats.STAT_MAG] = 4, [Stats.STAT_WIL] = 4, [Stats.STAT_CUN] = 4, [Stats.STAT_CON] = 4 }) } end,
		GEM_AMBER = function(self, eff) return {self:effectTemporaryValue(eff,"inc_damage", { all = 8}), self:effectTemporaryValue(eff,"combat_physcrit", 4), self:effectTemporaryValue(eff,"combat_mindcrit", 4), self:effectTemporaryValue(eff,"combat_spellcrit", 4) } end,
		GEM_TURQUOISE = function(self, eff) return {self:effectTemporaryValue(eff,"see_stealth", 10), self:effectTemporaryValue(eff,"see_invisible", 10) } end,
		GEM_JADE = function(self, eff) return {self:effectTemporaryValue(eff,"resists", { all = 4}), self:effectTemporaryValue(eff,"combat_armour", 4) } end,
		GEM_SAPPHIRE = function(self, eff) return {self:effectTemporaryValue(eff,"combat_def", 8), self:effectTemporaryValue(eff,"combat_mentalresist", 8), self:effectTemporaryValue(eff,"combat_spellresist", 8), self:effectTemporaryValue(eff,"combat_physresist", 8), } end,
		GEM_QUARTZ = function(self, eff) return {self:effectTemporaryValue(eff,"stun_immune", 0.3) } end,
		GEM_EMERALD = function(self, eff) return {self:effectTemporaryValue(eff,"resists", { all = 3}), self:effectTemporaryValue(eff,"combat_armour", 3) } end,
		GEM_LAPIS_LAZULI = function(self, eff) return {self:effectTemporaryValue(eff,"combat_def", 6), self:effectTemporaryValue(eff,"combat_mentalresist", 6), self:effectTemporaryValue(eff,"combat_spellresist", 6), self:effectTemporaryValue(eff,"combat_physresist", 6), } end,
		GEM_GARNET = function(self, eff) return {self:effectTemporaryValue(eff,"inc_damage", { all = 6}), self:effectTemporaryValue(eff,"combat_physcrit", 3), self:effectTemporaryValue(eff,"combat_mindcrit", 3), self:effectTemporaryValue(eff,"combat_spellcrit", 3) } end,
		GEM_ONYX = function(self, eff) return {self:effectTemporaryValue(eff,"inc_stats", {[Stats.STAT_STR] = 3, [Stats.STAT_DEX] = 3, [Stats.STAT_MAG] = 3, [Stats.STAT_WIL] = 3, [Stats.STAT_CUN] = 3, [Stats.STAT_CON] = 3 }) } end,
		GEM_AMETHYST = function(self, eff) return {self:effectTemporaryValue(eff,"inc_damage", { all = 4}), self:effectTemporaryValue(eff,"combat_physcrit", 2), self:effectTemporaryValue(eff,"combat_mindcrit", 2), self:effectTemporaryValue(eff,"combat_spellcrit", 2) } end,
		GEM_OPAL = function(self, eff) return {self:effectTemporaryValue(eff,"inc_stats", {[Stats.STAT_STR] = 2, [Stats.STAT_DEX] = 2, [Stats.STAT_MAG] = 2, [Stats.STAT_WIL] = 2, [Stats.STAT_CUN] = 2, [Stats.STAT_CON] = 2 }) } end,
		GEM_TOPAZ = function(self, eff) return {self:effectTemporaryValue(eff,"combat_def", 4), self:effectTemporaryValue(eff,"combat_mentalresist", 4), self:effectTemporaryValue(eff,"combat_spellresist", 4), self:effectTemporaryValue(eff,"combat_physresist", 4), } end,
		GEM_AQUAMARINE = function(self, eff) return {self:effectTemporaryValue(eff,"resists", { all = 2}), self:effectTemporaryValue(eff,"combat_armour", 2) } end,
		GEM_AMETRINE = function(self, eff) return {self:effectTemporaryValue(eff,"inc_damage", { all = 2}), self:effectTemporaryValue(eff,"combat_physcrit", 1), self:effectTemporaryValue(eff,"combat_mindcrit", 1), self:effectTemporaryValue(eff,"combat_spellcrit", 1) } end,
		GEM_ZIRCON = function(self, eff) return {self:effectTemporaryValue(eff,"resists", { all = 1}), self:effectTemporaryValue(eff,"combat_armour", 1) } end,
		GEM_SPINEL = function(self, eff) return {self:effectTemporaryValue(eff,"combat_def", 2), self:effectTemporaryValue(eff,"combat_mentalresist", 2), self:effectTemporaryValue(eff,"combat_spellresist", 2), self:effectTemporaryValue(eff,"combat_physresist", 2), } end,
		GEM_CITRINE = function(self, eff) return {self:effectTemporaryValue(eff,"lite", 1), self:effectTemporaryValue(eff,"infravision", 2) } end,
		GEM_AGATE = function(self, eff) return {self:effectTemporaryValue(eff,"inc_stats", {[Stats.STAT_STR] = 1, [Stats.STAT_DEX] = 1, [Stats.STAT_MAG] = 1, [Stats.STAT_WIL] = 1, [Stats.STAT_CUN] = 1, [Stats.STAT_CON] = 1 }) } end,
	},
	activate = function(self, eff)
		local buff = self.tempeffect_def.EFF_CRYSTAL_BUFF.gem_types[eff.gem]
		eff.id1 = buff(self, eff)
	end,
	deactivate = function(self, eff)

	end,
}

newEffect{
	name = "WEAPON_WARDING", image = "talents/warding_weapon.png",
	desc = "Weapon Warding",
	long_desc = function(self, eff) return ("Target is using %s telekinetically wielded weapon defensively and will block the next melee attack and retaliate."):format(string.his_her(self)) end,
	type = "mental",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { nb=1 },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
	do_block = function(self, eff, target, hitted, crit, weapon, damtype, mult, dam)
		local weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
		if type(weapon) == "boolean" then weapon = nil end
		if not weapon or self:attr("disarmed") then return end

		self:removeEffect(self.EFF_WEAPON_WARDING)
		if self:getInven(self.INVEN_PSIONIC_FOCUS) then
			local t = self:getTalentFromId(self.T_WARDING_WEAPON)
			for i, o in ipairs(self:getInven(self.INVEN_PSIONIC_FOCUS)) do
				if o.combat and not o.archery then
					self:logCombat(target, "#CRIMSON##Source# blocks #Target#'s attack and retaliates with %s telekinetically wielded weapon!#LAST#", string.his_her(self))
					self:attackTargetWith(target, o.combat, nil, t.getWeaponDamage(self, t))
				end
			end
			if self:getTalentLevelRaw(t) >= 3 and target:canBe("disarmed") then
				target:setEffect(target.EFF_DISARMED, 3, {apply_power=self:combatMindpower()})
			end
		end
		return true
	end,
	activate = function(self, eff)
	end,
	deactivate = function(self, eff)
	end,
}

newEffect{
	name = "THOUGHTSENSE", image = "talents/thought_sense.png",
	desc = "Thought Sense",
	long_desc = function(self, eff) return ("Detect nearby thoughts, revealing creature locations in a radius of %d and boosting defense by %d."):format(eff.range, eff.def) end,
	type = "mental",
	subtype = { tactic=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "detect_range", eff.range)
		self:effectTemporaryValue(eff, "detect_actor", 1)
		self:effectTemporaryValue(eff, "combat_def", eff.def)
		game.level.map.changed = true
		if core.shader.active() then
			local h1x, h1y = self:attachementSpot("head", true) if h1x then eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, oversize=0.5, a=225, appear=8, speed=0, img="thoughtsense", base_rot=0, radius=0, x=h1x, y=h1y})) end
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
	end,
}

newEffect{
	name = "STATIC_CHARGE", image = "talents/static_net.png",
	desc = "Static Charge",
	long_desc = function(self, eff) return ("You have accumulated an electric charge. Your next melee hit does %d extra lightning damage.."):format(eff.power) end,
	type = "mental",
	subtype = { lightning=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, eff) return nil, nil end,
	on_lose = function(self, eff) return nil, nil end,
	on_merge = function(self, old_eff, new_eff)
		old_eff.power = new_eff.power + old_eff.power
		old_eff.dur = new_eff.dur
		return old_eff
	end,
	activate = function(self, eff)
		if core.shader.active() then
			local h1x, h1y = self:attachementSpot("hand1", true) if h1x then eff.particle1 = self:addParticles(Particles.new("circle", 1, {shader=true, oversize=0.3, a=185, appear=8, speed=0, img="transcend_electro", base_rot=0, radius=0, x=h1x, y=h1y})) end
			local h2x, h2y = self:attachementSpot("hand2", true) if h2x then eff.particle2 = self:addParticles(Particles.new("circle", 1, {shader=true, oversize=0.3, a=185, appear=8, speed=0, img="transcend_electro", base_rot=0, radius=0, x=h2x, y=h2y})) end
		end
	end,
	deactivate = function(self, eff)
		if eff.particle1 then self:removeParticles(eff.particle1) end
		if eff.particle2 then self:removeParticles(eff.particle2) end
	end,
}

newEffect{
	name = "HEART_STARTED", image = "talents/heartstart.png",
	desc = "Heart Started",
	long_desc = function(self, eff) return ("A psionic charge is keeping your heart pumping, allowing you to survive to %+d health."):format(-eff.power) end,
	type = "mental",
	subtype = { lightning=true },
	status = "beneficial",
	parameters = { power=10 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "die_at", -eff.power)
	end,
	deactivate = function(self, eff)	
	end,
}

newEffect{
	name = "TRANSCENDENT_TELEKINESIS", image = "talents/transcendent_telekinesis.png",
	desc = "Transcendent Telekinesis",
	long_desc = function(self, eff) return ("Your telekinesis transcends normal limits. +%d Physical damage and +%d%% Physical damage penetration, and improved kinetic effects."):format(eff.power, eff.penetration) end,
	type = "mental",
	subtype = { physical=true },
	status = "beneficial",
	parameters = { power=10, penetration = 0 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.PHYSICAL]=eff.power})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.PHYSICAL]=eff.penetration})
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, toback=true, oversize=1.7, a=155, appear=8, speed=0, img="transcend_tele", radius=0}))
		self:callTalent(self.T_KINETIC_SHIELD, "adjust_shield_gfx", true)
	end,
	deactivate = function(self, eff)	
		self:removeParticles(eff.particle)
		self:callTalent(self.T_KINETIC_SHIELD, "adjust_shield_gfx", false)
	end,
}

newEffect{
	name = "TRANSCENDENT_PYROKINESIS", image = "talents/transcendent_pyrokinesis.png",
	desc = "Transcendent Pyrokinesis",
	long_desc = function(self, eff) return ("Your pyrokinesis transcends normal limits. +%d%% Fire/Cold damage and +%d%% Fire/Cold damage penetration, and improved thermal effects."):format(eff.power, eff.penetration) end,
	type = "mental",
	subtype = { fire=true, cold=true },
	status = "beneficial",
	parameters = { power=10, penetration = 0, weaken = 0},
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.FIRE]=eff.power, [DamageType.COLD]=eff.power})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.FIRE]=eff.penetration, [DamageType.COLD]=eff.penetration})
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, toback=true, oversize=1.7, a=155, appear=8, speed=0, img="transcend_pyro", radius=0}))
		self:callTalent(self.T_THERMAL_SHIELD, "adjust_shield_gfx", true)
	end,
	deactivate = function(self, eff)	
		self:removeParticles(eff.particle)
		self:callTalent(self.T_THERMAL_SHIELD, "adjust_shield_gfx", false)
	end,
}

newEffect{
	name = "TRANSCENDENT_ELECTROKINESIS", image = "talents/transcendent_electrokinesis.png",
	desc = "Transcendent Electrokinesis",
	long_desc = function(self, eff) return ("Your electrokinesis transcends normal limits. +%d%% Lightning damage and +%d%% Lightning damage penetration, and improved charged effects."):format(eff.power, eff.penetration) end,
	type = "mental",
	subtype = { lightning=true, mind=true },
	status = "beneficial",
	parameters = { power=10, penetration = 0 },
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "inc_damage", {[DamageType.LIGHTNING]=eff.power})
		self:effectTemporaryValue(eff, "resists_pen", {[DamageType.LIGHTNING]=eff.penetration})
		eff.particle = self:addParticles(Particles.new("circle", 1, {shader=true, toback=true, oversize=1.7, a=155, appear=8, speed=0, img="transcend_electro", radius=0}))
		self:callTalent(self.T_CHARGED_SHIELD, "adjust_shield_gfx", true)
	end,
	deactivate = function(self, eff)	
		self:removeParticles(eff.particle)
		self:callTalent(self.T_CHARGED_SHIELD, "adjust_shield_gfx", false)
	end,
}

newEffect{
	name = "PSI_DAMAGE_SHIELD", image = "talents/barrier.png",
	desc = "Psionic Damage Shield",
	long_desc = function(self, eff) return ("The target is surrounded by a psionic shield, absorbing %d/%d damage before it crumbles."):format(self.damage_shield_absorb, eff.power) end,
	type = "mental",
	subtype = { psionic=true, shield=true },
	status = "beneficial",
	parameters = { power=100 },
	on_gain = function(self, err) return "A psionic shield forms around #target#.", "+Shield" end,
	on_lose = function(self, err) return "The psionic shield around #target# crumbles.", "-Shield" end,
	damage_feedback = function(self, eff, src, value)
		if eff.particle and eff.particle._shader and eff.particle._shader.shad and src and src.x and src.y then
			local r = -rng.float(0.2, 0.4)
			local a = math.atan2(src.y - self.y, src.x - self.x)
			eff.particle._shader:setUniform("impact", {math.cos(a) * r, math.sin(a) * r})
			eff.particle._shader:setUniform("impact_tick", core.game.getTime())
		end
	end,
	activate = function(self, eff)
		self:removeEffect(self.EFF_DAMAGE_SHIELD)
		eff.tmpid = self:addTemporaryValue("damage_shield", eff.power)
		if eff.reflect then eff.refid = self:addTemporaryValue("damage_shield_reflect", eff.reflect) end
		--- Warning there can be only one time shield active at once for an actor
		self.damage_shield_absorb = eff.power
		self.damage_shield_absorb_max = eff.power
		if core.shader.active(4) then
			eff.particle = self:addParticles(Particles.new("shader_shield", 1, {size_factor=1.4, img="shield3"}, {type="runicshield", ellipsoidalFactor=1, time_factor=-10000, llpow=1, aadjust=7, bubbleColor=colors.hex1alpha"9fe836a0", auraColor=colors.hex1alpha"36bce8da"}))
		else
			eff.particle = self:addParticles(Particles.new("damage_shield", 1))
		end
	end,
	deactivate = function(self, eff)
		self:removeParticles(eff.particle)
		self:removeTemporaryValue("damage_shield", eff.tmpid)
		if eff.refid then self:removeTemporaryValue("damage_shield_reflect", eff.refid) end
		self.damage_shield_absorb = nil
		self.damage_shield_absorb_max = nil
	end,
}
