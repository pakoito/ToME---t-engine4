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

-- EDGE TODO: Talents, Icons, Particles, Timed Effect Particles

-- Ode to Angband/Tome 2 and all the characters I lost to Time Hounds
summonTemporalHound = function(self, t)  
	if game.zone.wilderness then return false end
	
	local x, y = util.findFreeGrid(self.x, self.y, 8, true, {[Map.ACTOR]=true})
	if not x then
		return false
	end
	
	local m = require("mod.class.NPC").new{
		type = "animal", subtype = "hounds",
		display = "C", image = "npc/summoner_wardog.png",
		color=colors.LIGHT_DARK, shader = "shadow_simulacrum",
		shader_args = { color = {0.6, 0.6, 0.2}, base = 0.8, time_factor = 1500 },
		name = "temporal hound", faction = self.faction,
		desc = [[A trained hound that appears to be all at once a little puppy and a toothless old dog.]],
		sound_moam = {"creatures/wolves/wolf_hurt_%d", 1, 2}, sound_die = {"creatures/wolves/wolf_hurt_%d", 1, 1},
		
		autolevel = "none",
		ai = "summoned", ai_real = "tactical", ai_state = { ai_move="move_complex", talent_in=5, }, -- Temporal Hounds are smart but have no talents of their own
		stats = {str=0, dex=0, con=0, cun=0, wil=0, mag=0},
		inc_stats = t.incStats(self, t),
		level_range = {self.level, self.level}, exp_worth = 0,
		global_speed_base = 1.2,
		
		no_auto_resists = true,

		max_life = 50,
		life_rating = 12,
		infravision = 10,

		combat_armor = 2, combat_def = 4,
		combat = { dam=self:getTalentLevel(t) * 10 + rng.avg(12,25), atk=10, apr=10, dammod={str=0.8}, damtype=DamageType.MATTER, sound="creatures/wolves/wolf_attack_1" },
		
		summoner = self, summoner_gain_exp=true,
	}
	
	m:resolve()
	m:resolve(nil, true)
	
	-- Gain damage, resistances, and immunities
	m.inc_damage = table.clone(self.inc_damage, true)
	m.resists = { [DamageType.PHYSICAL] = t.getResists(self, t)/2, [DamageType.TEMPORAL] = math.min(100, t.getResists(self, t)*2) }
	if self:knowTalent(self.T_COMMAND_BLINK) then
		m:attr("defense_on_teleport", self:callTalent(self.T_COMMAND_BLINK, "getDefense"))
		m:attr("resist_all_on_teleport", self:callTalent(self.T_COMMAND_BLINK, "getDefense")/2)
	end
	if self:knowTalent(self.T_TEMPORAL_VIGOUR) then
		m:attr("stun_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
		m:attr("blind_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
		m:attr("pin_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
		m:attr("confusion_immune", self:callTalent(self.T_TEMPORAL_VIGOUR, "getImmunities"))
	end
	if self:knowTalent(self.T_COMMAND_BREATH) then
		m.damage_affinity = { [DamageType.TEMPORAL] = self:callTalent(self.T_COMMAND_BREATH, "getResists") }
	end
	
	-- Quality of life stuff
	m.life_regen = 1
	m.lite = 1
	m.no_breath = 1
	m.move_others = true
	
	-- Make sure to update sustain counter when we die
	m.on_die = function(self)
		local p = self.summoner:isTalentActive(self.summoner.T_TEMPORAL_HOUNDS)
		local tid = self.summoner:getTalentFromId(self.summoner.T_TEMPORAL_HOUNDS)
		if p then
			p.hounds = p.hounds - 1
			if p.rest_count == 0 then p.rest_count = self.summoner:getTalentCooldown(tid) end
		end
	end
	-- Make sure hounds stay close
	m.on_act = function(self)
		if game.level:hasEntity(self.summoner) and core.fov.distance(self.x, self.y, self.summoner.x, self.summoner.y) > 10 then
			local Map = require "engine.Map"
			local x, y = util.findFreeGrid(self.summoner.x, self.summoner.y, 5, true, {[engine.Map.ACTOR]=true})
			if not x then
				return
			end
			-- Clear it's targeting on teleport
			if self:teleportRandom(x, y, 0) then
				game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
				self:setTarget(nil)
			end
		end
	end
	
	-- Make it look and sound nice :)
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "temporal_teleport")
	game:playSoundNear(self, "creatures/wolves/wolf_howl_3")
	
	-- And add them to the party
	if game.party:hasMember(self) then
		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control="no",
			type="hound",
			title="temporal-hound",
			orders = {target=true, leash=true, anchor=true, talents=true},
		})
	end
	
end

newTalent{
	name = "Temporal Hounds",
	type = {"chronomancy/temporal-hounds", 1},
	require = chrono_req_high1,
	mode = "sustained",
	points = 5,
	sustain_paradox = 48,
	no_sustain_autoreset = true,
	cooldown = function(self, t) return math.ceil(self:combatTalentLimit(t, 15, 45, 25)) end, -- Limit >15
	tactical = { BUFF = 2 },
	callbackOnActBase = function(self, t)
		local p = self:isTalentActive(t.id)
		if p.rest_count > 0 then p.rest_count = p.rest_count - 1 end
		if p.rest_count == 0 and p.hounds < p.max_hounds then
			summonTemporalHound(self, t)
			p.rest_count = self:getTalentCooldown(t)
			p.hounds = p.hounds + 1
		end
	end,
	iconOverlay = function(self, t, p)
		local val = p.rest_count or 0
		if val <= 0 then return "" end
		local fnt = "buff_font"
		return tostring(math.ceil(val)), fnt
	end,
	incStats = function(self, t,fake)
		local mp = self:combatTalentSpellDamage(t, 0, 100) -- Just use base spellpower so we don't get Paradox or Crit cheese
		return{ 
			str=10 + (fake and mp or mp),
			dex=10 + (fake and mp or mp),
			con=10 + (fake and mp or mp),
			mag=10 + (fake and mp or mp),
			wil=10 + (fake and mp or mp),
			cun=10 + (fake and mp or mp),
		}
	end,
	getResists = function(self, t)
		return self:combatTalentLimit(t, 100, 15, 50) -- Limit <100%
	end,
	activate = function(self, t)
		-- Let loose the hounds of war!
		summonTemporalHound(self, t)
		
		return {
				-- Turn off friendly fire if we have this sustain; thanks dekar for the idea :)
				proj = self:addTemporaryValue("archery_pass_friendly", 1),
				rest_count = self:getTalentCooldown(t), 
				hounds = 1, max_hounds = 3
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("archery_pass_friendly", p.proj)
		
		-- unsummon the hounds :(
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "hounds" then
				e.summon_time = 0
			end
		end
		return true
	end,
	info = function(self, t)
		local incStats = t.incStats(self, t, true)
		local cooldown = self:getTalentCooldown(t)
		local resists = t.getResists(self, t)
		return ([[Upon activation summon a Temporal Hound.  Every %d turns another hound will be summoned up to a maximum of three hounds. If a hound dies you'll summon a new hound in %d turns.  
		Your hounds inherit your increased damage percent and have %d%% physical resistance and %d%% temporal resistance.
		Hounds will get %d Strength, %d Dexterity, %d Constitution, %d Magic, %d Willpower, and %d Cunning based on your Spellpower.
		While Temporal Hounds is active your arrows will shoot through friendly targets.]])
		:format(cooldown, cooldown, resists/2, math.min(100, resists*2), incStats.str + 1, incStats.dex + 1, incStats.con + 1, incStats.mag + 1, incStats.wil +1, incStats.cun + 1)
	end
}

newTalent{
	name = "Command Hounds: Blink", short_name="COMMAND_BLINK",
	type = {"chronomancy/temporal-hounds", 2},
	require = chrono_req_high2,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ATTACK=2 },
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 10, 0.5, 0, 1)) end,
	requires_target = true,
	on_pre_use = function(self, t, silent)
		local p = self:isTalentActive(self.T_TEMPORAL_HOUNDS)
		if not p or p and p.hounds == 0 then
			if not silent then
				game.logPlayer(self, "You must have temporal hounds to use this talent.")
			end
			return false
		end
		return true
	end,
	target = function(self, t)
		return {type="hit", range=self:getTalentRange(t), nolock=true, nowarning=true}
	end,
	direct_hit = true,
	getDefense = function(self, t)
		return self:combatTalentSpellDamage(t, 10, 40, getParadoxSpellpower(self))
	end,
	action = function(self, t)
		-- Find our hounds
		local hnds = {}
		for _, e in pairs(game.level.entities) do
			if e.summoner and e.summoner == self and e.subtype == "hounds" then
				hnds[#hnds+1] = e
			end
		end
		
		-- Pick our target
		local tg = self:getTalentTarget(t)
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if not self:hasLOS(x, y) or game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			game.logPlayer(self, "You do not have line of sight.")
			return nil
		end
		local __, x, y = self:canProject(tg, x, y)

		-- Blink our hounds
		for i = 1, #hnds do
			if #hnds <= 0 then return nil end
			local a, id = rng.table(hnds)
			table.remove(hnds, id)
			-- Since it's a precise teleport find a free grid first
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
				if a:teleportRandom(tx, ty, 0) then
					game.level.map:particleEmitter(a.x, a.y, 1, "temporal_teleport")
				end
				-- Set the target so we feel like a wolf pack
				if target and self:reactionToward(target) < 0 then
					a:setTarget(target)
				end
			end
		end
		game:playSoundNear(self, "talents/teleport")
		
		return true
	end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		return ([[Command your Temporal Hounds to teleport too the location.  If you target a creature with this effect you're hounds will set that creature as their target.
		Additionally your hounds now gain %d defense and %d%% resist all after any teleport from any source.
		The teleportation bonuses scale with your Spellpower.]]):format(defense, defense/2)
	end,
}

newTalent{
	name = "Temporal Vigour",
	type = {"chronomancy/temporal-hounds", 3},
	require = chrono_req_high3,
	points = 5,
	mode = "passive",
	getImmunities = function(self, t)
		return self:combatTalentLimit(t, 1, 0.15, 0.50) -- Limit <100%
	end,
	getRegen = function(self, t) return self:combatTalentSpellDamage(t, 10, 50, getParadoxSpellpower(self)) end,
	getHaste = function(self, t) return self:combatScale(self:combatTalentSpellDamage(t, 20, 80, getParadoxSpellpower(self)), 0, 0, 0.57, 57, 0.75) end,
	doAnomaly = function(self, hound, t)  -- Triggered when the hounds is hit
		hound:setEffect(hound.EFF_REGENERATION, 5, {power=t.getRegen(self, t)}) 
		hound:setEffect(hound.EFF_SPEED, 5, {power=t.getHaste(self, t)})
	end,
	info = function(self, t)
		local regen = t.getRegen(self, t)
		local haste = t.getHaste(self, t) * 100
		local immunities = t.getImmunities(self, t) * 100
		return ([[When hit by most anomalies your Temporal Hounds gain %d%% global speed and heal for %d life, per turn, for five turns.
		Additionally your hounds gain %d%% stun, blind, confusion, and pin immunity.
		These regeneration and haste effects scale with your Spellpower.]]):format(regen, haste, immunities)
	end
}

newTalent{
	name = "Command Hounds: Breath", short_name= "COMMAND_BREATH",  -- Turn Back the Clock multi-breath attack
	type = {"chronomancy/temporal-hounds", 4},
	require = chrono_req_high4,
	points = 5,
	paradox = function (self, t) return getParadoxCost(self, t, 10) end,
	cooldown = 10,
	tactical = { ATTACKAREA = {TEMPORAL = 2}, DEBUFF = 2 },
	range = 10,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 4.5, 6.5)) end,
	requires_target = true,
	direct_hit = true,
	on_pre_use = function(self, t, silent)
		local p = self:isTalentActive(self.T_TEMPORAL_HOUNDS)
		if not p or p and p.hounds == 0 then
			if not silent then
				game.logPlayer(self, "You must have temporal hounds to use this talent.")
			end
			return false
		end
		return true
	end,
	getResists = function(self, t)
		return self:combatTalentLimit(t, 100, 15, 50) -- Limit <100%
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 15, 150, getParadoxSpellpower(self)) end,
	getDamageStat = function(self, t) return 2 + math.ceil(t.getDamage(self, t) / 15) end,
	target = function(self, t)
		return {type="cone", range=0, radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	action = function(self, t)
		-- Grab our hounds and build our multi-targeting display; thanks grayswandir for making this possible
		local tg = {multiple=true}
		local hounds = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and a.summoner == self and a.subtype == "hounds" then
				hounds[#hounds+1] = a
				tg[#tg+1] = {type="cone", range=0, radius=self:getTalentRadius(t), start_x=a.x, start_y=a.y, selffire=false, talent=t}
			end
		end end
		
		-- Pick a target
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		-- Switch our targeting type back
		local tg = self:getTalentTarget(t)
		
		-- Now...  we breath time >:)
		for i = 1, #hounds do
			if #hounds <= 0 then break end
			local a, id = rng.table(hounds)
			table.remove(hounds, id)
			
			tg.start_x, tg.start_y = a.x, a.y
			local dam = a:spellCrit(t.getDamage(self, t)) -- hound crit but our spellpower, mostly so it looks right
			
			a:project(tg, x, y, function(px, py)
				DamageType:get(DamageType.TEMPORAL).projector(a, px, py, DamageType.TEMPORAL, dam)
				-- Don't turn back the clock other hounds
				local target = game.level.map(px, py, Map.ACTOR)
				if target and target.subtype ~= "hounds" then
					target:setEffect(target.EFF_TURN_BACK_THE_CLOCK, 3, {power=t.getDamageStat(self, t), apply_power=a:combatSpellpower(), min_dur=1})
				end	
			end)
			
			game.level.map:particleEmitter(a.x, a.y, tg.radius, "breath_time", {radius=tg.radius, tx=x-a.x, ty=y-a.y})
		end
		
		game:playSoundNear(self, "talents/breath")
		
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = self:getTalentRadius(t)
		local stat_damage = t.getDamageStat(self, t)
		local affinity = t.getResists(self, t)
		return ([[Command your Temporal Hounds to breath time, dealing %0.2f temporal damage and reducing the stats of all targets in a radius %d cone.
		Affected targets will have their stats reduced by %d for 3 turns.  You are not immune to the breath of your own hounds but your hounds are immune to stat damage from other hounds.
		Additionally your hounds gain %d%% temporal damage affinity.]]):format(damDesc(self, DamageType.TEMPORAL, damage), radius, stat_damage, affinity)
	end,
}
