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

require "engine.class"
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorInventory"
require "engine.interface.ActorTemporaryEffects"
require "engine.interface.ActorLife"
require "engine.interface.ActorProject"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorTalents"
require "engine.interface.ActorResource"
require "engine.interface.ActorQuest"
require "engine.interface.BloodyDeath"
require "engine.interface.ActorFOV"
require "mod.class.interface.Combat"
require "mod.class.interface.Archery"
require "mod.class.interface.ActorInscriptions"
local Faction = require "engine.Faction"
local Map = require "engine.Map"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(
	-- a ToME actor is a complex beast it uses may inetrfaces
	engine.Actor,
	engine.interface.ActorInventory,
	engine.interface.ActorTemporaryEffects,
	engine.interface.ActorLife,
	engine.interface.ActorProject,
	engine.interface.ActorLevel,
	engine.interface.ActorStats,
	engine.interface.ActorTalents,
	engine.interface.ActorResource,
	engine.interface.ActorQuest,
	engine.interface.BloodyDeath,
	engine.interface.ActorFOV,
	mod.class.interface.ActorInscriptions,
	mod.class.interface.Combat,
	mod.class.interface.Archery
))

-- Dont save the can_see_cache
_M._no_save_fields.can_see_cache = true

-- Use distance maps
_M.__do_distance_map = true

function _M:init(t, no_default)
	-- Define some basic combat stats
	self.combat_def = 0
	self.combat_armor = 0
	self.combat_atk = 0
	self.combat_apr = 0
	self.combat_dam = 0
	self.combat_physcrit = 0
	self.combat_physspeed = 0
	self.combat_spellspeed = 0
	self.combat_spellcrit = 0
	self.combat_spellpower = 0
	self.combat_mindpower = 0

	self.combat_physresist = 0
	self.combat_spellresist = 0
	self.combat_mentalresist = 0

	self.fatigue = 0

	self.spell_cooldown_reduction = 0

	self.unused_stats = self.unused_stats or 3
	self.unused_talents =  self.unused_talents or 2
	self.unused_generics =  self.unused_generics or 1
	self.unused_talents_types = self.unused_talents_types or 0

	t.healing_factor = t.healing_factor or 1

	t.sight = t.sight or 20

	t.resource_pool_refs = t.resource_pool_refs or {}

	t.lite = t.lite or 0

	t.size_category = t.size_category or 3
	t.rank = t.rank or 2

	t.life_rating = t.life_rating or 10
	t.mana_rating = t.mana_rating or 4
	t.vim_rating = t.vim_rating or 4
	t.stamina_rating = t.stamina_rating or 3
	t.positive_negative_rating = t.positive_negative_rating or 3

	t.esp = t.esp or {range=10}

	t.talent_cd_reduction = t.talent_cd_reduction or {}

	t.on_melee_hit = t.on_melee_hit or {}
	t.melee_project = t.melee_project or {}
	t.ranged_project = t.ranged_project or {}
	t.can_pass = t.can_pass or {}
	t.move_project = t.move_project or {}
	t.can_breath = t.can_breath or {}

	-- Resistances
	t.resists = t.resists or {}
	t.resists_cap = t.resists_cap or { all = 100 }
	t.resists_pen = t.resists_pen or {}

	-- % Increase damage
	t.inc_damage = t.inc_damage or {}

	-- Default regen
	t.air_regen = t.air_regen or 3
	t.mana_regen = t.mana_regen or 0.5
	t.stamina_regen = t.stamina_regen or 0.3 -- Stamina regens slower than mana
	t.life_regen = t.life_regen or 0.25 -- Life regen real slow
	t.equilibrium_regen = t.equilibrium_regen or 0 -- Equilibrium does not regen
	t.vim_regen = t.vim_regen or 0 -- Vim does not regen
	t.positive_regen = t.positive_regen or -0.2 -- Positive energy slowly decays
	t.negative_regen = t.negative_regen or -0.2 -- Positive energy slowly decays
	t.paradox_regen = t.paradox_regen or 0 -- Paradox does not regen

	t.max_positive = t.max_positive or 50
	t.max_negative = t.max_negative or 50
	t.positive = t.positive or 0
	t.negative = t.negative or 0

	t.hate_rating = t.hate_rating or 0.2
	t.hate_regen = t.hate_regen or 0
	t.max_hate = t.max_hate or 10
	t.absolute_max_hate = t.absolute_max_hate or 14
	t.hate = t.hate or 10
	t.hate_per_kill = t.hate_per_kill or 0.8

	-- Equilibrium has a default very high max, as bad effects happen even before reaching it
	t.max_equilibrium = t.max_equilibrium or 100000
	t.equilibrium = t.equilibrium or 0

	-- Paradox has a default very high max, as bad effects happen even before reaching it
	t.max_paradox = t.max_paradox or 100000
	t.paradox = t.paradox or 300

	t.money = t.money or 0

	-- Default melee barehanded damage
	self.combat = { dam=1, atk=1, apr=0, dammod={str=1} }

	engine.Actor.init(self, t, no_default)
	engine.interface.ActorInventory.init(self, t)
	engine.interface.ActorTemporaryEffects.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorProject.init(self, t)
	engine.interface.ActorTalents.init(self, t)
	engine.interface.ActorResource.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorLevel.init(self, t)
	engine.interface.ActorFOV.init(self, t)
	mod.class.interface.ActorInscriptions.init(self, t)

	self:resetCanSeeCache()
end

function _M:act()
	if not engine.Actor.act(self) then return end

	self.changed = true

	-- If ressources are too low, disable sustains
	if self.mana < 1 or self.stamina < 1 then
		for tid, _ in pairs(self.sustain_talents) do
			local t = self:getTalentFromId(tid)
			if (t.sustain_mana and self.mana < 1) or (t.sustain_stamina and self.stamina < 1) then
				self:forceUseTalent(tid, {ignore_energy=true})
			end
		end
	end

	if self:isTalentActive (self.T_DARKEST_LIGHT) and self.positive > self.negative then
		self:forceUseTalent(self.T_DARKEST_LIGHT, {ignore_energy=true})
		game.logSeen(self, "%s's darkness can no longer hold back the light!", self.name:capitalize())
	end

	-- Cooldown talents
	self:cooldownTalents()
	-- Regen resources
	self:regenLife()
	if self:knowTalent(self.T_UNNATURAL_BODY) then
		local t = self:getTalentFromId(self.T_UNNATURAL_BODY)
		t.do_regenLife(self, t)
	end
	self:regenResources()
	-- Hate decay
	if self:knowTalent(self.T_HATE_POOL) and self.hate > 0 then
		-- hate loss speeds up as hate increases
		local hateChange = -math.max(0.02, 0.07 * math.pow(self.hate / 10, 2))
		self:incHate(hateChange)
	end

	-- Compute timed effects
	self:timedEffects()

	-- Handle thunderstorm, even if the actor is stunned or incampacited it still works
	if self:isTalentActive(self.T_THUNDERSTORM) then
		local t = self:getTalentFromId(self.T_THUNDERSTORM)
		t.do_storm(self, t)
	end
	if self:isTalentActive(self.T_BODY_OF_FIRE) then
		local t = self:getTalentFromId(self.T_BODY_OF_FIRE)
		t.do_fire(self, t)
	end
	if self:isTalentActive(self.T_HYMN_OF_MOONLIGHT) then
		local t = self:getTalentFromId(self.T_HYMN_OF_MOONLIGHT)
		t.do_beams(self, t)
	end
	if self:isTalentActive(self.T_BLOOD_FRENZY) then
		local t = self:getTalentFromId(self.T_BLOOD_FRENZY)
		t.do_turn(self, t)
	end
	-- this handles cursed gloom turn based effects
	if self:isTalentActive(self.T_GLOOM) then
	    local t = self:getTalentFromId(self.T_GLOOM)
		t.do_gloom(self, t)
	end
	-- this handles cursed call shadows turn based effects
	if self:isTalentActive(self.T_CALL_SHADOWS) then
	    local t = self:getTalentFromId(self.T_CALL_SHADOWS)
		t.do_callShadows(self, t)
	end
	-- this handles cursed deflection turn based effects
	if self:isTalentActive(self.T_DEFLECTION) then
	    local t = self:getTalentFromId(self.T_DEFLECTION)
		t.do_act(self, t, self:isTalentActive(self.T_DEFLECTION))
	end
	-- this handles doomed unseen force turn based effects
	if self.unseenForce then
		local t = self:getTalentFromId(self.T_UNSEEN_FORCE)
		t.do_unseenForce(self, t)
	end

	if self:attr("stunned") then
		self.stunned_counter = (self.stunned_counter or 0) + (self:attr("stun_immune") or 0) * 100
		if self.stunned_counter < 100 then
			self.energy.value = 0
		else
			-- We are saved for this turn
			self.stunned_counter = self.stunned_counter - 100
			game.logSeen(self, "%s temporarily fights the stun.", self.name:capitalize())
		end
	end
	if self:attr("encased_in_ice") then self.energy.value = 0 end
	if self:attr("stoned") then self.energy.value = 0 end
	if self:attr("dazed") then self.energy.value = 0 end

	-- Suffocate ?
	local air_level, air_condition = game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "air_level"), game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "air_condition")
	if air_level then
		if not air_condition or not self.can_breath[air_condition] then self:suffocate(-air_level, self) end
	end

	-- Regain natural balance?
	local equilibrium_level = game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "equilibrium_level")
	if equilibrium_level then self:incEquilibrium(equilibrium_level) end

	-- Do stuff to things standing in the fire
	game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "on_stand", self)

	-- Still enough energy to act ?
	if self.energy.value < game.energy_to_act then return false end

	-- Still not dead ?
	if self.dead then return false end

	-- Ok reset the seen cache
	self:resetCanSeeCache()

	if self.on_act then self:on_act() end

	return true
end

function _M:move(x, y, force)
	local moved = false

	if force or self:enoughEnergy() then
		-- Confused ?
		if not force and self:attr("confused") then
			if rng.percent(self:attr("confused")) then
				x, y = self.x + rng.range(-1, 1), self.y + rng.range(-1, 1)
			end
		end

		-- Should we prob travel through walls ?
		if not force and self:attr("prob_travel") and game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			moved = self:probabilityTravel(x, y, self:attr("prob_travel"))
		-- Never move but tries to attack ? ok
		elseif not force and self:attr("never_move") then
			-- A bit weird, but this simple asks the collision code to detect an attack
			if not game.level.map:checkAllEntities(x, y, "block_move", self, true) then
				game.logPlayer(self, "You are unable to move!")
			end
		else
			moved = engine.Actor.move(self, x, y, force)
		end
		if not force and moved and not self.did_energy then self:useEnergy(game.energy_to_act * self:combatMovementSpeed()) end
	end
	self.did_energy = nil

	-- Try to detect traps
	if self:knowTalent(self.T_TRAP_DETECTION) then
		local power = self:getTalentLevel(self.T_TRAP_DETECTION) * self:getCun(25)
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(yy) do
			local trap = game.level.map(x, y, Map.TRAP)
			if trap and not trap:knownBy(self) and self:checkHit(power, trap.detect_power) then
				trap:setKnown(self, true)
				game.level.map:updateMap(x, y)
				game.logPlayer(self, "You have found a trap (%s)!", trap:getName())
			end
		end end
	end

	if moved and self:isTalentActive(self.T_BODY_OF_STONE) then
		self:forceUseTalent(self.T_BODY_OF_STONE, {ignore_energy=true})
	end

	if moved and self:hasEffect(self.EFF_FRICTION) then
		local p = self:hasEffect(self.EFF_FRICTION)
		DamageType:get(DamageType.FIREBURN).projector(p.src, self.x, self.y, DamageType.FIREBURN, p.dam)
	end

	return moved
end

--- Get the "path string" for this actor
-- See Map:addPathString() for more info
function _M:getPathString()
	local ps = self.open_door and "return {open_door=true,can_pass={" or "return {can_pass={"
	for what, check in pairs(self.can_pass) do
		ps = ps .. what.."="..check..","
	end
	ps = ps.."}}"
--	print("[PATH STRING] for", self.name, " :=: ", ps)
	return ps
end

--- Drop no-teleport items
function _M:dropNoTeleportObjects()
	for inven_id, inven in pairs(self.inven) do
		for item = #inven, 1, -1 do
			local o = inven[item]
			if o.no_teleport then
				self:dropFloor(inven, item, false, true)
				game.logPlayer(self, "#LIGHT_RED#Your %s is immunte to the teleportation and drops to the floor!", o:getName{do_color=true})
			end
		end
	end
end

--- Blink through walls
function _M:probabilityTravel(x, y, dist)
	if game.zone.wilderness then return true end

	local dirx, diry = x - self.x, y - self.y
	local tx, ty = x, y
	while game.level.map:isBound(tx, ty) and game.level.map:checkAllEntities(tx, ty, "block_move", self) and dist > 0 do
		if game.level.map.attrs(tx, ty, "no_teleport") then break end
		if game.level.map:checkAllEntities(tx, ty, "no_prob_travel", self) then break end
		tx = tx + dirx
		ty = ty + diry
		dist = dist - 1
	end
	if game.level.map:isBound(tx, ty) and not game.level.map:checkAllEntities(tx, ty, "block_move", self) and not game.level.map.attrs(tx, ty, "no_teleport") then
		self:dropNoTeleportObjects()
		return engine.Actor.move(self, tx, ty, false)
	end
	return true
end

--- Teleports randomly to a passable grid
-- This simply calls the default actor teleportRandom but first checks for space-time stability
-- @param x the coord of the teleporatation
-- @param y the coord of the teleporatation
-- @param dist the radius of the random effect, if set to 0 it is a precise teleport
-- @param min_dist the minimun radius of of the effect, will never teleport closer. Defaults to 0 if not set
-- @return true if the teleport worked
function _M:teleportRandom(x, y, dist, min_dist)
	if game.level.data.no_teleport_south and y + dist > self.y then
		y = self.y - dist
	end
	local ox, oy = self.x, self.y
	local ret = engine.Actor.teleportRandom(self, x, y, dist, min_dist)
	if self.x ~= ox or self.y ~= oy then
		self.x, self.y, ox, oy = ox, oy, self.x, self.y
		self:dropNoTeleportObjects()
		self.x, self.y, ox, oy = ox, oy, self.x, self.y
	end
	return ret
end

--- Quake a zone
-- Moves randomly each grid to an other grid
function _M:doQuake(tg, x, y)
	local w = game.level.map.w
	local locs = {}
	local ms = {}
	self:project(tg, x, y, function(tx, ty)
		if not game.level.map.attrs(tx, ty, "no_teleport") then
			locs[#locs+1] = {x=tx,y=ty}
			ms[#ms+1] = {map=game.level.map.map[tx + ty * w], attrs=game.level.map.attrs[tx + ty * w]}
		end
	end)

	while #locs > 0 do
		local l = rng.tableRemove(locs)
		local m = rng.tableRemove(ms)

		game.level.map.map[l.x + l.y * w] = m.map
		game.level.map.attrs[l.x + l.y * w] = m.attrs
		for z, e in pairs(m.map or {}) do
			if e.move then
				e.x = nil e.y = nil e:move(l.x, l.y, true)
			end
		end
	end
	game.level.map:cleanFOV()
	game.level.map.changed = true
	game.level.map:redisplay()
end

--- Reveals location surrounding the actor
function _M:magicMap(radius, x, y, checker)
	x = x or self.x
	y = y or self.y
	radius = math.floor(radius)

	local ox, oy

	self.x, self.y, ox, oy = x, y, self.x, self.y
	self:computeFOV(radius, "block_sense", function(x, y)
		if not checker or checker(x, y) then
			game.level.map.remembers(x, y, true)
			game.level.map.has_seens(x, y, true)
		end
	end, true, true, true)

	self.x, self.y = ox, oy
end

--- What is our reaction toward the target
-- This can modify faction reaction using specific actor to actor reactions
function _M:reactionToward(target, no_reflection)
	local v = engine.Actor.reactionToward(self, target)

	if self.reaction_actor and self.reaction_actor[target.unique or target.name] then v = v + self.reaction_actor[target.unique or target.name] end

	-- Take the lowest of the two just in case
	if not no_reflection and target.reactionToward then v = math.min(v, target:reactionToward(self, true)) end

	return util.bound(v, -100, 100)
end

function _M:incMoney(v)
	self.money = self.money + v
	if self.money < 0 then self.money = 0 end
	self.changed = true

	if self.player then
		world:gainAchievement("TREASURE_HUNTER", self)
		world:gainAchievement("TREASURE_HOARDER", self)
		world:gainAchievement("DRAGON_GREED", self)
	end
end

function _M:getRankStatAdjust()
	if self.rank == 1 then return -1
	elseif self.rank == 2 then return -0.5
	elseif self.rank == 3 then return 0
	elseif self.rank == 3.5 then return 1
	elseif self.rank == 4 then return 1
	elseif self.rank >= 5 then return 1
	else return 0
	end
end

function _M:getRankLevelAdjust()
	if self.rank == 1 then return -1
	elseif self.rank == 2 then return 0
	elseif self.rank == 3 then return 1
	elseif self.rank == 3.5 then return 2
	elseif self.rank == 4 then return 3
	elseif self.rank >= 5 then return 4
	else return 0
	end
end

function _M:getRankLifeAdjust(value)
	local level_adjust = 1 + self.level / 40
	if self.rank == 1 then return value * (level_adjust - 0.2)
	elseif self.rank == 2 then return value * (level_adjust - 0.1)
	elseif self.rank == 3 then return value * (level_adjust + 0.1)
	elseif self.rank == 3.5 then return value * (level_adjust + 0.3)
	elseif self.rank == 4 then return value * (level_adjust + 0.3)
	elseif self.rank >= 5 then return value * (level_adjust + 0.5)
	else return 0
	end
end

function _M:getRankResistAdjust()
	if self.rank == 1 then return 0.4, 0.9
	elseif self.rank == 2 then return 0.5, 1.5
	elseif self.rank == 3 then return 0.8, 1.5
	elseif self.rank == 3.5 then return 0.9, 1.5
	elseif self.rank == 4 then return 0.9, 1.5
	elseif self.rank >= 5 then return 0.9, 1.5
	else return 0
	end
end

function _M:TextRank()
	local rank, color = "normal", "#ANTIQUE_WHITE#"
	if self.rank == 1 then rank, color = "critter", "#C0C0C0#"
	elseif self.rank == 2 then rank, color = "normal", "#ANTIQUE_WHITE#"
	elseif self.rank == 3 then rank, color = "elite", "#YELLOW#"
	elseif self.rank == 3.5 then rank, color = "unique", "#SANDY_BROWN#"
	elseif self.rank == 4 then rank, color = "boss", "#ORANGE#"
	elseif self.rank >= 5 then rank, color = "elite boss", "#GOLD#"
	end
	return rank, color
end

function _M:TextSizeCategory()
	local sizecat = "medium"
	if self.size_category <= 1 then sizecat = "tiny"
	elseif self.size_category == 2 then sizecat = "small"
	elseif self.size_category == 3 then sizecat = "medium"
	elseif self.size_category == 4 then sizecat = "big"
	elseif self.size_category == 5 then sizecat = "huge"
	elseif self.size_category >= 6 then sizecat = "gargantuan"
	end
	return sizecat
end

function _M:tooltip(x, y, seen_by)
	if seen_by and not seen_by:canSee(self) then return end
	local factcolor, factstate, factlevel = "#ANTIQUE_WHITE#", "neutral", Faction:factionReaction(self.faction, game.player.faction)
	if factlevel < 0 then factcolor, factstate = "#LIGHT_RED#", "hostile"
	elseif factlevel > 0 then factcolor, factstate = "#LIGHT_GREEN#", "friendly"
	end

	local pfactcolor, pfactstate, pfactlevel = "#ANTIQUE_WHITE#", "neutral", self:reactionToward(game.player)
	if pfactlevel < 0 then pfactcolor, pfactstate = "#LIGHT_RED#", "hostile"
	elseif pfactlevel > 0 then pfactcolor, pfactstate = "#LIGHT_GREEN#", "friendly"
	end

	local rank, rank_color = self:TextRank()

	local effs = {}
	for tid, act in pairs(self.sustain_talents) do
		if act then effs[#effs+1] = ("- #LIGHT_GREEN#%s"):format(self:getTalentFromId(tid).name) end
	end
	for eff_id, p in pairs(self.tmp) do
		local e = self.tempeffect_def[eff_id]
		local dur = p.dur + 1
		if e.status == "detrimental" then
			effs[#effs+1] = ("- #LIGHT_RED#%s(%d)"):format(e.desc,dur)
		else
			effs[#effs+1] = ("- #LIGHT_GREEN#%s(%d)"):format(e.desc,dur)
		end
	end

	local resists = {}
	for t, v in pairs(self.resists) do
		resists[#resists+1] = string.format("%d%% %s", v, t == "all" and "all" or DamageType:get(t).name)
	end

	return ([[%s%s%s
%s / %s
Rank: %s%s
#00ffff#Level: %d
Exp: %d/%d
#ff0000#HP: %d (%d%%)
Stats: %d /  %d / %d / %d / %d / %d
Resists: %s
Size: #ANTIQUE_WHITE#%s
%s
Faction: %s%s (%s, %d)
Personal reaction: %s%s, %d
%s]]):format(
	self:getDisplayString(), rank_color, self.name,
	self.type:capitalize(), self.subtype:capitalize(),
	rank_color, rank,
	self.level,
	self.exp,
	self:getExpChart(self.level+1) or "---",
	self.life, self.life * 100 / self.max_life,
	self:getStr(),
	self:getDex(),
	self:getMag(),
	self:getWil(),
	self:getCun(),
	self:getCon(),
	table.concat(resists, ','),
	self:TextSizeCategory(),
	self.desc or "",
	factcolor, Faction.factions[self.faction].name, factstate, factlevel,
	pfactcolor, pfactstate, pfactlevel,
	table.concat(effs, "\n")
	)
end

--- Called before healing
function _M:onHeal(value, src)
	if self:hasEffect(self.EFF_UNSTOPPABLE) then
		return 0
	end
	return value * (self.healing_factor or 1)
end

--- Called before taking a hit, it's the chance to check for shields
function _M:onTakeHit(value, src)
	-- Un-daze
	if self:hasEffect(self.EFF_DAZED) then
		self:removeEffect(self.EFF_DAZED)
	end
	-- Un-meditate
	if self:hasEffect(self.EFF_MEDITATION) then
		self:removeEffect(self.EFF_MEDITATION)
	end
	-- remove stalking if there is an interaction
	if self.stalker and src and self.stalker == src then
		self.stalker:removeEffect(self.EFF_STALKER)
		self:removeEffect(self.EFF_STALKED)
	end

	-- Remove domination hex
	if self:hasEffect(self.EFF_DOMINATION_HEX) and src and src == self:hasEffect(self.EFF_DOMINATION_HEX).src then
		self:removeEffect(self.EFF_DOMINATION_HEX)
	end

	if self:attr("invulnerable") then
		return 0
	end

	if self:attr("retribution") then
	-- Absorb damage into the retribution
		if value / 2 <= self.retribution_absorb then
			self.retribution_absorb = self.retribution_absorb - (value / 2)
			value = value / 2
		else
			self.retribution_absorb = 0
			value = value - self.retribution_absorb
			local dam = self.retribution_strike

			-- Deactivate without loosing energy
			self:forceUseTalent(self.T_RETRIBUTION, {ignore_energy=true})

			-- Explode!
			game.logSeen(self, "%s unleashes the stored damage in retribution!", self.name:capitalize())
			local tg = {type="ball", range=0, radius=self:getTalentRange(self:getTalentFromId(self.T_RETRIBUTION)), friendlyfire=false, talent=t}
			local grids = self:project(tg, self.x, self.y, DamageType.LIGHT, dam)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "sunburst", {radius=tg.radius, grids=grids, tx=self.x, ty=self.y})
		end
	end

	if self:attr("disruption_shield") then
		local mana = self:getMana()
		local mana_val = value * self:attr("disruption_shield")
		-- We have enough to absord the full hit
		if mana_val <= mana then
			self:incMana(-mana_val)
			self.disruption_shield_absorb = self.disruption_shield_absorb + value
			return 0
		-- Or the shield collapses in a deadly arcane explosion
		else
			local dam = self.disruption_shield_absorb

			-- Deactivate without loosing energy
			self:forceUseTalent(self.T_DISRUPTION_SHIELD, {ignore_energy=true})

			-- Explode!
			game.logSeen(self, "%s disruption shield collapses and then explodes in a powerful manastorm!", self.name:capitalize())
			local tg = {type="ball", radius=5}
			self:project(tg, self.x, self.y, DamageType.ARCANE, dam, {type="manathrust"})
		end
	end

	if self:attr("time_shield") then
		-- Absorb damage into the time shield
		if value <= self.time_shield_absorb then
			self.time_shield_absorb = self.time_shield_absorb - value
			value = 0
		else
			self.time_shield_absorb = 0
			value = value - self.time_shield_absorb
		end

		-- If we are at the end of the capacity, release the time shield damage
		if self.time_shield_absorb <= 0 then
			game.logPlayer(self, "Your time shield crumbles under the damage!")
			self:removeEffect(self.EFF_TIME_SHIELD)
		end
	end

	if self:attr("damage_shield") then
		-- Absorb damage into the shield
		if value <= self.damage_shield_absorb then
			self.damage_shield_absorb = self.damage_shield_absorb - value
			value = 0
		else
			self.damage_shield_absorb = 0
			value = value - self.damage_shield_absorb
		end

		-- If we are at the end of the capacity, release the time shield damage
		if self.damage_shield_absorb <= 0 then
			game.logPlayer(self, "Your shield crumbles under the damage!")
			self:removeEffect(self.EFF_DAMAGE_SHIELD)
		end
	end

	if self:attr("displacement_shield") then
		-- Absorb damage into the displacement shield
		if value <= self.displacement_shield and rng.percent(self.displacement_shield_chance) then
			game.logSeen(self, "The displacement shield teleports the damage to %s!", self.displacement_shield_target.name)
			self.displacement_shield = self.displacement_shield - value
			self.displacement_shield_target:takeHit(value, src)
			self:removeEffect(self.EFF_DISPLACEMENT_SHIELD)
			value = 0
		end
	end

	if self:isTalentActive(self.T_BONE_SHIELD) then
		local t = self:getTalentFromId(self.T_BONE_SHIELD)
		t.absorb(self, t, self:isTalentActive(self.T_BONE_SHIELD))
		value = 0
	end

	if self:isTalentActive(self.T_DEFLECTION) then
		local t = self:getTalentFromId(self.T_DEFLECTION)
		value = t.do_onTakeHit(self, t, self:isTalentActive(self.T_DEFLECTION), value)
	end

	-- Mount takes some damage ?
	local mount = self:hasMount()
	if mount and mount.mount.share_damage then
		mount.mount.actor:takeHit(value * mount.mount.share_damage / 100, src)
		value = value * (100 - mount.mount.share_damage) / 100
		-- Remove the dead mount
		if mount.mount.actor.dead and mount.mount.effect then
			self:removeEffect(mount.mount.effect)
		end
	end

	-- Achievements
	if src and src.resolveSource and src:resolveSource().player and value >= 600 then
		world:gainAchievement("SIZE_MATTERS", src:resolveSource())
	end

	-- Stoned ? SHATTER !
	if self:attr("stoned") and value >= self.max_life * 0.3 then
		-- Make the damage high enough to kill it
		value = self.max_life + 1
		game.logSeen(self, "%s shatters into pieces!", self.name:capitalize())
	end

	-- Adds hate
	if self:knowTalent(self.T_HATE_POOL) then
		local hateGain = 0
		local hateMessage

		if value / self.max_life >= 0.15 then
			-- you take a big hit..adds 0.2 + 0.2 for each 5% over 15%
			hateGain = hateGain + 0.2 + (((value / self.max_life) - 0.15) * 10 * 0.5)
			hateMessage = "#F53CBE#You fight through the pain!"
		end

		if value / self.max_life >= 0.05 and (self.life - value) / self.max_life < 0.25 then
			-- you take a hit with low health
			hateGain = hateGain + 0.4
			hateMessage = "#F53CBE#Your rage grows even as your life fades!"
		end

		if hateGain >= 0.1 then
			self.hate = math.min(self.max_hate, self.hate + hateGain)
			if hateMessage then
				game.logPlayer(self, hateMessage.." (+%0.1f hate)", hateGain)
			end
		end
	end
	if src and src.knowTalent and src:knowTalent(src.T_HATE_POOL) then
		local hateGain = 0
		local hateMessage

		if value / src.max_life > 0.33 then
			-- you deliver a big hit
			hateGain = hateGain + 0.4
			hateMessage = "#F53CBE#Your powerful attack feeds your madness!"
		end

		if hateGain >= 0.1 then
			src.hate = math.min(src.max_hate, src.hate + hateGain)
			if hateMessage then
				game.logPlayer(src, hateMessage.." (+%0.1f hate)", hateGain)
			end
		end
	end

	-- Bloodlust!
	if src and src.knowTalent and src:knowTalent(src.T_BLOODLUST) then
		src:setEffect(src.EFF_BLOODLUST, 1, {})
	end

	if self:knowTalent(self.T_RAMPAGE) then
		local t = self:getTalentFromId(self.T_RAMPAGE)
		t:onTakeHit(self, value / self.max_life)
	end

	if self:hasEffect(self.EFF_UNSTOPPABLE) then
		if value > self.life then value = self.life - 1 end
	end

	-- Split ?
	if self.clone_on_hit and value >= self.clone_on_hit.min_dam_pct * self.max_life / 100 and rng.percent(self.clone_on_hit.chance) then
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if x then
			-- Find a place around to clone
			local a = self:clone()
			a.life = math.max(1, a.life - value / 2)
			a.clone_on_hit.chance = math.ceil(a.clone_on_hit.chance / 2)
			a.energy.val = 0
			a.exp_worth = 0.1
			a.inven = {}
			a.x, a.y = nil, nil
			game.zone:addEntity(game.level, a, "actor", x, y)
			game.logSeen(self, "%s is split in two!", self.name:capitalize())
			value = value / 2
		end
	end

	if self.on_takehit then value = self:check("on_takehit", value, src) end

	-- Chronomancy
	if self:knowTalent(self.T_AVOID_FATE) then
		local af = .6 - (self:getTalentLevel(self.T_AVOID_FATE)/20)
		print ("af->", af)
		local av = self.max_life * af
		if value >= self.life and self.life >= av then
			value = self.life - 1
			game.logSeen(self, "%s has avoided a fatal blow!!", self.name:capitalize())
		end
	end

	if self:attr("damage_smearing") and value >= 10 then
		self:setEffect(self.EFF_SMEARED, 5, {src=src, power=value/6})
		value = value / 6
	end

	if value > 0 and self:isTalentActive(self.T_SHIELD_OF_LIGHT) then
		self:heal(self:combatTalentSpellDamage(self.T_SHIELD_OF_LIGHT, 5, 25), self)
		if value <= 2 then
			drain = value
		else
			drain = 2
		end
		self:incPositive(- drain)
		if self:getPositive() <= 0 then
			self:forceUseTalent(self.T_SHIELD_OF_LIGHT, {ignore_energy=true})
		end
	end


	-- Second Life
	if self:isTalentActive(self.T_SECOND_LIFE) and value >= self.life then
		local sl = self.max_life * (0.05 + self:getTalentLevelRaw(self.T_SECOND_LIFE)/25)
		value = 0
		self.life = sl
		game.logSeen(self, "%s has been saved by a blast of positive energy!", self.name:capitalize())
		self:forceUseTalent(self.T_SECOND_LIFE, {ignore_energy=true})
	end

	if self:knowTalent(self.T_LEECH) and src.hasEffect and src:hasEffect(src.EFF_VIMSENSE) then
		self:incVim(3 + self:getTalentLevel(self.T_LEECH) * 0.7)
		self:heal(5 + self:getTalentLevel(self.T_LEECH) * 3)
		game.logPlayer(self, "#AQUAMARINE#You leech a part of %s vim.", src.name:capitalize())
	end

	return value
end

function _M:resolveSource()
	if self.summoner_gain_exp and self.summoner then
		return self.summoner:resolveSource()
	else
		return self
	end
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)

	-- Gives the killer some exp for the kill
	local killer = nil
	if src and src.resolveSource and src:resolveSource().gainExp then
		killer = src:resolveSource()
		killer:gainExp(self:worthExp(killer))
	end

	-- Hack: even if the boss dies from something else, give the player exp
	if (not killer or not killer.player) and self.rank > 3 then
		game.logPlayer(game.player, "You feel a surge of power as a powerful creature falls nearby.")
		killer = game.player:resolveSource()
		killer:gainExp(self:worthExp(killer))
	end

	-- Do we get a blooooooody death ?
	if rng.percent(33) then self:bloodyDeath() end

	-- Drop stuff
	if not self.keep_inven_on_death then
		if not self.no_drops then
			for inven_id, inven in pairs(self.inven) do
				for i, o in ipairs(inven) do
					-- Handle boss wielding artifacts
					if o.__special_boss_drop and rng.percent(o.__special_boss_drop.chance) then
						print("Refusing to drop "..self.name.." artifact "..o.name.." with chance "..o.__special_boss_drop.chance)

						-- Do not drop
						o.no_drop = true

						-- Drop a random artifact instead
						local ro = game.zone:makeEntity(game.level, "object", {unique=true, not_properties={"lore"}}, nil, true)
						if ro then game.zone:addEntity(game.level, ro, "object", self.x, self.y) end
					end

					if not o.no_drop then
						o.droppedBy = self.name
						game.level.map:addObject(self.x, self.y, o)
					else
						o:removed()
					end
				end
			end
		end
		self.inven = {}
	end

	-- Give stamina back
	if src and src.knowTalent and src:knowTalent(src.T_UNENDING_FRENZY) then
		src:incStamina(src:getTalentLevel(src.T_UNENDING_FRENZY) * 2)
	end

	-- Increases blood frenzy
	if src and src.knowTalent and src:knowTalent(src.T_BLOOD_FRENZY) and src:isTalentActive(src.T_BLOOD_FRENZY) then
		src.blood_frenzy = src.blood_frenzy + src:getTalentLevel(src.T_BLOOD_FRENZY) * 2
	end

	-- Adds hate
	if src and src.knowTalent and src:knowTalent(self.T_HATE_POOL) then
		local hateGain = src.hate_per_kill
		local hateMessage

		if self.level - 2 > src.level then
			-- level bonus
			hateGain = hateGain + (self.level - 2 - src.level) * 0.2
			hateMessage = "#F53CBE#You have taken the life of an experienced foe!"
		end

		if self.rank >= 4 then
			-- boss bonus
			hateGain = hateGain * 4
			hateMessage = "#F53CBE#Your hate has conquered a great adversary!"
		elseif self.rank >= 3 then
			-- elite bonus
			hateGain = hateGain * 2
			hateMessage = "#F53CBE#An elite foe has fallen to your hate!"
		end
		hateGain = math.min(hateGain, 10)

		src.hate = math.min(src.max_hate, src.hate + hateGain)
		if hateMessage then
			game.logPlayer(src, hateMessage.." (+%0.1f hate)", hateGain - src.hate_per_kill)
		end
	end

	if src and src.knowTalent and src:knowTalent(src.T_UNNATURAL_BODY) then
		local t = src:getTalentFromId(src.T_UNNATURAL_BODY)
		t.on_kill(src, t, self)
	end

	if src and src.knowTalent and src:knowTalent(src.T_CRUEL_VIGOR) then
		local t = src:getTalentFromId(src.T_CRUEL_VIGOR)
		t.on_kill(src, t)
	end

	if src and src.knowTalent and src:knowTalent(src.T_BLOODRAGE) then
		local t = src:getTalentFromId(src.T_BLOODRAGE)
		t.on_kill(src, t)
	end

	if src and src.isTalentActive and src:isTalentActive(src.T_FORAGE) then
		local t = src:getTalentFromId(src.T_FORAGE)
		t.on_kill(src, t, self)
	end

	if src and src.hasEffect and src:hasEffect(self.EFF_UNSTOPPABLE) then
		local p = src:hasEffect(self.EFF_UNSTOPPABLE)
		p.kills = p.kills + 1
	end

	if self:hasEffect(self.EFF_CORROSIVE_WORM) then
		local p = self:hasEffect(self.EFF_CORROSIVE_WORM)
		p.src:project({type="ball", radius=4, x=self.x, y=self.y}, self.x, self.y, DamageType.ACID, p.explosion, {type="acid"})
	end

	-- Increase vim
	if src and src.attr and src:attr("vim_on_death") and not self:attr("undead") then src:incVim(src:attr("vim_on_death")) end

	if src and src.resolveSource and src:resolveSource().player then
		-- Achievements
		local p = src:resolveSource()
		if math.floor(p.life) <= 1 and not p.dead then world:gainAchievement("THAT_WAS_CLOSE", p) end
		world:gainAchievement("EXTERMINATOR", p, self)
		world:gainAchievement("PEST_CONTROL", p, self)
		world:gainAchievement("REAVER", p, self)

		if self.unique then
			p:registerUniqueKilled(self)
		end

		-- Record kills
		p.all_kills = p.all_kills or {}
		p.all_kills[self.name] = p.all_kills[self.name] or 0
		p.all_kills[self.name] = p.all_kills[self.name] + 1
	end

	return true
end

function _M:learnStats(statorder)
	self.auto_stat_cnt = self.auto_stat_cnt or 1
	local nb = 0
	local max = 60

	-- Allow to go over a natural 60, up to 80 at level 50
	if not self.no_auto_high_stats then max = 60 + (self.level * 20 / 50) end

	while self.unused_stats > 0 do
		if self:getStat(statorder[self.auto_stat_cnt]) < max then
			self:incStat(statorder[self.auto_stat_cnt], 1)
			self.unused_stats = self.unused_stats - 1
		end
		self.auto_stat_cnt = util.boundWrap(self.auto_stat_cnt + 1, 1, #statorder)
		nb = nb + 1
		if nb >= #statorder then break end
	end
end

function _M:resetToFull()
	self.life = self.max_life
	self.mana = self.max_mana
	self.vim = self.max_vim
	self.stamina = self.max_stamina
	self.equilibrium = 0
	self.air = self.max_air
end

function _M:levelup()
	self.unused_stats = self.unused_stats + 3 + self:getRankStatAdjust()
	self.unused_talents = self.unused_talents + 1
	self.unused_generics = self.unused_generics + 1
	if self.level % 5 == 0 then self.unused_talents = self.unused_talents + 1 end
	if self.level % 5 == 0 then self.unused_generics = self.unused_generics - 1 end
	-- At levels 10, 20 and 30 we gain a new talent type
	if self.level == 10 or  self.level == 20 or  self.level == 30 then
		self.unused_talents_types = self.unused_talents_types + 1
	end

	-- Gain some basic resistances
	if not self.no_auto_resists then
		-- Make up a random list of resists the first time
		if not self.auto_resists_list then
			local list = {
				DamageType.PHYSICAL,
				DamageType.FIRE, DamageType.COLD, DamageType.ACID, DamageType.LIGHTNING,
				DamageType.LIGHT, DamageType.DARKNESS,
				DamageType.NATURE, DamageType.BLIGHT,
			}
			self.auto_resists_list = {}
			for i = 1, rng.range(1, self.auto_resists_nb or 2) do
				local t = rng.tableRemove(list)
				-- Double the chance so that resist is more likely to happen
				if rng.percent(30) then self.auto_resists_list[#self.auto_resists_list+1] = t end
				self.auto_resists_list[#self.auto_resists_list+1] = t
			end
		end
		-- Provide one of our resists
		local t = rng.table(self.auto_resists_list)
		if (self.resists[t] or 0) < 50 then
			self.resists[t] = (self.resists[t] or 0) + rng.float(self:getRankResistAdjust())
		end

		-- Bosses have a right to get a general damage reduction
		if self.rank >= 4 then
			self.resists.all = (self.resists.all or 0) + rng.float(self:getRankResistAdjust()) / (self.rank == 4 and 3 or 2.5)
		end
	end

	-- Gain life and resources
	local rating = self.life_rating
	if not self.fixed_rating then
		rating = rng.range(math.floor(self.life_rating * 0.5), math.floor(self.life_rating * 1.5))
	end
	self.max_life = self.max_life + math.max(self:getRankLifeAdjust(rating), 1)

	self:incMaxVim(self.vim_rating)
	self:incMaxMana(self.mana_rating)
	self:incMaxStamina(self.stamina_rating)
	self:incMaxPositive(self.positive_negative_rating)
	self:incMaxNegative(self.positive_negative_rating)
	if self.max_hate < self.absolute_max_hate then
		local amount = math.min(self.hate_rating, self.absolute_max_hate - self.max_hate)
		self:incMaxHate(amount)
	end
	-- Heal up on new level
	self:resetToFull()

	-- Auto levelup ?
	if self.autolevel then
		engine.Autolevel:autoLevel(self)
	end

	-- Force levelup of the golem
	if self.alchemy_golem then self.alchemy_golem:forceLevelup(self.level) end
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		self.max_life = self.max_life + 5 * v
	elseif stat == self.STAT_WIL then
		self:incMaxMana(5 * v)
		self:incMaxStamina(2 * v)
	elseif stat == self.STAT_STR then
		self:checkEncumbrance()
	end
end

--- Called when a temporary value changes (added or deleted)
-- Takes care to call onStatChange when needed
-- @param prop the property changing
-- @param sub the sub element of the property if it is a table, or nil
-- @param v the value of the change
function _M:onTemporaryValueChange(prop, sub, v)
	if prop == "inc_stats" then
		self:onStatChange(sub, v)
	end
end

function _M:attack(target)
	self:bumpInto(target)
end

function _M:getMaxEncumbrance()
	local add = 0
	if self:knowTalent(self.T_BURDEN_MANAGEMENT) then
		add = add + 20 + self:getTalentLevel(self.T_BURDEN_MANAGEMENT) * 15
	end
	return math.floor(40 + self:getStr() * 1.8 + (self.max_encumber or 0) + add)
end

function _M:getEncumbrance()
	local enc = 0

	local fct = function(so) enc = enc + so.encumber end
	if self:knowTalent(self.T_EFFICIENT_PACKING) then
		local reduction = 1 - self:getTalentLevel(self.T_EFFICIENT_PACKING) * 0.1
		fct = function(so)
			if so.encumber <= 1 then
				enc = enc + so.encumber * reduction
			else
				enc = enc + so.encumber
			end
		end
	end

	-- Compute encumbrance
	for inven_id, inven in pairs(self.inven) do
		for item, o in ipairs(inven) do
			o:forAllStack(fct)
		end
	end
--	print("Total encumbrance", enc)
	return math.floor(enc)
end

function _M:checkEncumbrance()
	-- Compute encumbrance
	local enc, max = self:getEncumbrance(), self:getMaxEncumbrance()

	-- We are pinned to the ground if we carry too much
	if not self.encumbered and enc > max then
		game.logPlayer(self, "#FF0000#You carry too much--you are encumbered!")
		game.logPlayer(self, "#FF0000#Drop some of your items.")
		self.encumbered = self:addTemporaryValue("never_move", 1)
	elseif self.encumbered and enc <= max then
		self:removeTemporaryValue("never_move", self.encumbered)
		self.encumbered = nil
		game.logPlayer(self, "#00FF00#You are no longer encumbered.")
	end
end

--- Call when an object is added
function _M:onAddObject(o)
	engine.interface.ActorInventory.onAddObject(self, o)

	self:checkEncumbrance()

	-- Achievement checks
	if self.player then
		if o.unique then
			self:resolveSource():registerArtifactsPicked(o)
		end
		world:gainAchievement("DEUS_EX_MACHINA", self, o)
	end
end

--- Call when an object is removed
function _M:onRemoveObject(o)
	engine.interface.ActorInventory.onRemoveObject(self, o)

	self:checkEncumbrance()
end

--- Returns the possible offslot
function _M:getObjectOffslot(o)
	if o.dual_wieldable and self:attr("allow_any_dual_weapons") then
		return self.INVEN_OFFHAND
	else
		return o.offslot
	end
end

--- Actor learns a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalent(t_id, force, nb)
	if not engine.interface.ActorTalents.learnTalent(self, t_id, force, nb) then return false end

	-- If we learned a spell, get mana, if you learned a technique get stamina, if we learned a wild gift, get power
	local t = _M.talents_def[t_id]

	if t.dont_provide_pool then return true end

	if t.type[1]:find("^spell/") and not self:knowTalent(self.T_MANA_POOL) and t.mana or t.sustain_mana then
		self:learnTalent(self.T_MANA_POOL, true)
		self.resource_pool_refs[self.T_MANA_POOL] = (self.resource_pool_refs[self.T_MANA_POOL] or 0) + 1
	end
	if t.type[1]:find("^wild%-gift/") and not self:knowTalent(self.T_EQUILIBRIUM_POOL) and t.equilibrium or t.sustain_equilibrium then
		self:learnTalent(self.T_EQUILIBRIUM_POOL, true)
		self.resource_pool_refs[self.T_EQUILIBRIUM_POOL] = (self.resource_pool_refs[self.T_EQUILIBRIUM_POOL] or 0) + 1
	end
	if t.type[1]:find("^technique/") and not self:knowTalent(self.T_STAMINA_POOL) and t.stamina or t.sustain_stamina then
		self:learnTalent(self.T_STAMINA_POOL, true)
		self.resource_pool_refs[self.T_STAMINA_POOL] = (self.resource_pool_refs[self.T_STAMINA_POOL] or 0) + 1
	end
	if t.type[1]:find("^corruption/") and not self:knowTalent(self.T_VIM_POOL) and t.vim or t.sustain_vim then
		self:learnTalent(self.T_VIM_POOL, true)
		self.resource_pool_refs[self.T_VIM_POOL] = (self.resource_pool_refs[self.T_VIM_POOL] or 0) + 1
	end
	if t.type[1]:find("^divine/") and (t.positive or t.sustain_positive) and not self:knowTalent(self.T_POSITIVE_POOL) then
		self:learnTalent(self.T_POSITIVE_POOL, true)
		self.resource_pool_refs[self.T_POSITIVE_POOL] = (self.resource_pool_refs[self.T_POSITIVE_POOL] or 0) + 1
	end
	if t.type[1]:find("^divine/") and (t.negative or t.sustain_negative) and not self:knowTalent(self.T_NEGATIVE_POOL) then
		self:learnTalent(self.T_NEGATIVE_POOL, true)
		self.resource_pool_refs[self.T_NEGATIVE_POOL] = (self.resource_pool_refs[self.T_NEGATIVE_POOL] or 0) + 1
	end
	if t.type[1]:find("^cursed/") and not self:knowTalent(self.T_HATE_POOL) then
		self:learnTalent(self.T_HATE_POOL, true)
		self.resource_pool_refs[self.T_HATE_POOL] = (self.resource_pool_refs[self.T_HATE_POOL] or 0) + 1
	end
	if t.type[1]:find("^chronomancy/") and not self:knowTalent(self.T_PARADOX_POOL) then
		self:learnTalent(self.T_PARADOX_POOL, true)
		self.resource_pool_refs[self.T_PARADOX_POOL] = (self.resource_pool_refs[self.T_PARADOX_POOL] or 0) + 1
	end
	-- If we learn an archery talent, also learn to shoot
	if t.type[1]:find("^technique/archery") and not self:knowTalent(self.T_SHOOT) then
		self:learnTalent(self.T_SHOOT, true)
		self.resource_pool_refs[self.T_SHOOT] = (self.resource_pool_refs[self.T_SHOOT] or 0) + 1
	end

	return true
end

--- Actor forgets a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalent(t_id)
	if not engine.interface.ActorTalents.unlearnTalent(self, t_id, force) then return false end
	-- Check the various pools
	for key, num_refs in pairs(self.resource_pool_refs) do
		if num_refs == 0 then
			self:unlearnTalent(key)
		end
	end
	return true
end

--- Equilibrium check
function _M:equilibriumChance(eq)
	eq = (eq or 0) + self:getEquilibrium()
	local wil = self:getWil()
	-- Do not fail if below willpower
	if eq < wil then return true, 100 end
	eq = eq - wil
	local chance = math.sqrt(eq) / 60
	print("[Equilibrium] Use chance: ", 100 - chance * 100, "::", self:getEquilibrium())
	return rng.percent(100 - chance * 100), 100 - chance * 100
end

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent, fake)
	if self:attr("feared") then
		if not silent then game.logSeen(self, "%s is too afraid to use %s.", self.name:capitalize(), ab.name) end
		return false
	end
	if ab.no_silence and self:attr("silence") then
		if not silent then game.logSeen(self, "%s is silenced and cannot use %s.", self.name:capitalize(), ab.name) end
		return false
	end

	if not self:enoughEnergy() and not fake then return false end

	if ab.mode == "sustained" then
		if ab.sustain_mana and self.max_mana < ab.sustain_mana and not self:isTalentActive(ab.id) then
			if not silent then game.logPlayer(self, "You do not have enough mana to activate %s.", ab.name) end
			return false
		end
		if ab.sustain_stamina and self.max_stamina < ab.sustain_stamina and not self:isTalentActive(ab.id) then
			if not silent then game.logPlayer(self, "You do not have enough stamina to activate %s.", ab.name) end
			return false
		end
		if ab.sustain_vim and self.max_vim < ab.sustain_vim and not self:isTalentActive(ab.id) then
			if not silent then game.logPlayer(self, "You do not have enough vim to activate %s.", ab.name) end
			return false
		end
		if ab.sustain_positive and self.max_positive < ab.sustain_positive and not self:isTalentActive(ab.id) then
			if not silent then game.logPlayer(self, "You do not have enough positive energy to activate %s.", ab.name) end
			return false
		end
		if ab.sustain_negative and self.max_negative < ab.sustain_negative and not self:isTalentActive(ab.id) then
			if not silent then game.logPlayer(self, "You do not have enough negative energy to activate %s.", ab.name) end
			return false
		end
		if ab.sustain_hate and self.max_hate < ab.sustain_hate and not self:isTalentActive(ab.id) then
			if not silent then game.logPlayer(self, "You do not have enough hate to activate %s.", ab.name) end
			return false
		end
	else
		if ab.mana and self:getMana() < ab.mana * (100 + 2 * self:combatFatigue()) / 100 then
			if not silent then game.logPlayer(self, "You do not have enough mana to cast %s.", ab.name) end
			return false
		end
		if ab.stamina and self:getStamina() < ab.stamina * (100 + self:combatFatigue()) / 100 then
			if not silent then game.logPlayer(self, "You do not have enough stamina to use %s.", ab.name) end
			return false
		end
		if ab.vim and self:getVim() < ab.vim then
			if not silent then game.logPlayer(self, "You do not have enough vim to use %s.", ab.name) end
			return false
		end
		if ab.positive and self:getPositive() < ab.positive * (100 + self:combatFatigue()) / 100 then
			if not silent then game.logPlayer(self, "You do not have enough positive energy to use %s.", ab.name) end
			return false
		end
		if ab.negative and self:getNegative() < ab.negative * (100 + self:combatFatigue()) / 100 then
			if not silent then game.logPlayer(self, "You do not have enough negative energy to use %s.", ab.name) end
			return false
		end
		if ab.hate and self:getHate() < ab.hate * (100 + self:combatFatigue()) / 100 then
			if not silent then game.logPlayer(self, "You do not have enough hate to use %s.", ab.name) end
			return false
		end
	end

	-- Equilibrium is special, it has no max, but the higher it is the higher the chance of failure (and loss of the turn)
	-- But it is not affected by fatigue
	if (ab.equilibrium or ab.sustain_equilibrium) and not fake then
		-- Fail ? lose energy and 1/10 more equilibrium
		if not self:attr("no_equilibrium_fail") and not self:equilibriumChance(ab.equilibrium or ab.sustain_equilibrium) then
			if not silent then game.logPlayer(self, "You fail to use %s due to your equilibrium!", ab.name) end
			self:incEquilibrium((ab.equilibrium or ab.sustain_equilibrium) / 10)
			self:useEnergy()
			return false
		end
	end

	-- Paradox is special, it has no max, but the higher it is the higher the chance of something bad happening
	-- But it is not affected by fatigue
	if (ab.paradox or ab.sustain_paradox) and not fake then
		local pa = ab.paradox or ab.sustain_paradox
		local chance = math.pow (((self:getParadox() - self:getWil()) /200), 2)
		-- Fail ? lose energy and 1/10 more paradox
		print("[Paradox] Fail chance: ", chance, "::", self:getParadox())
		if rng.percent(chance) then
			game.logPlayer(self, "You fail to use %s due to your paradox!", ab.name)
			self:incParadox(pa / 2)
			self:useEnergy()
			return false
		end
	end

	-- Confused ? lose a turn!
	if self:attr("confused") and not fake then
		if rng.percent(self:attr("confused")) then
			if not silent then game.logSeen(self, "%s is confused and fails to use %s.", self.name:capitalize(), ab.name) end
			self:useEnergy()
			return false
		end
	end

	if not silent then
		-- Allow for silent talents
		if ab.message ~= nil then
			if ab.message then
				game.logSeen(self, "%s", self:useTalentMessage(ab))
			end
		elseif ab.mode == "sustained" and not self:isTalentActive(ab.id) then
			game.logSeen(self, "%s activates %s.", self.name:capitalize(), ab.name)
		elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
			game.logSeen(self, "%s deactivates %s.", self.name:capitalize(), ab.name)
		elseif ab.is_spell then
			game.logSeen(self, "%s casts %s.", self.name:capitalize(), ab.name)
		else
			game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
		end
	end
	return true
end

--- Called before a talent is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	if not ret then return end

	-- Count talents that count as spells
	if ab.is_spell then
		if self:hasQuest("antimagic") and not self:hasQuest("antimagic"):isEnded() then self:setQuestStatus("antimagic", engine.Quest.FAILED) end -- Fail antimagic quest
		self:antimagicBackslash(4 + self:getTalentLevelRaw(ab))
	end

	if not ab.no_energy then
		if ab.is_spell then
			self:useEnergy(game.energy_to_act * self:combatSpellSpeed())
		elseif ab.type[1]:find("^technique/") then
			self:useEnergy(game.energy_to_act * self:combatSpeed())
		else
			self:useEnergy()
		end
	end

	local trigger = false
	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_mana then
				trigger = true; self.max_mana = self.max_mana - ab.sustain_mana
			end
			if ab.sustain_stamina then
				trigger = true; self.max_stamina = self.max_stamina - ab.sustain_stamina
			end
			if ab.sustain_vim then
				trigger = true; self.max_vim = self.max_vim - ab.sustain_vim
			end
			if ab.sustain_equilibrium then
				self:incEquilibrium(ab.sustain_equilibrium)
			end
			if ab.sustain_positive then
				trigger = true; self.max_positive = self.max_positive - ab.sustain_positive
			end
			if ab.sustain_negative then
				trigger = true; self.max_negative = self.max_negative - ab.sustain_negative
			end
			if ab.sustain_hate then
				trigger = true; self.max_hate = self.max_hate - ab.sustain_hate
			end
			if ab.sustain_paradox then
				self:incParadox(ab.sustain_paradox)
			end
		else
			if ab.sustain_mana then
				trigger = true; self.max_mana = self.max_mana + ab.sustain_mana
			end
			if ab.sustain_stamina then
				trigger = true; self.max_stamina = self.max_stamina + ab.sustain_stamina
			end
			if ab.sustain_vim then
				trigger = true; self.max_vim = self.max_vim + ab.sustain_vim
			end
			if ab.sustain_equilibrium then
				self:incEquilibrium(-ab.sustain_equilibrium)
			end
			if ab.sustain_positive then
				trigger = true; self.max_positive = self.max_positive + ab.sustain_positive
			end
			if ab.sustain_negative then
				trigger = true; self.max_negative = self.max_negative + ab.sustain_negative
			end
			if ab.sustain_hate then
				trigger = true; self.max_hate = self.max_hate + ab.sustain_hate
			end
			if ab.sustain_paradox then
				self:incParadox(-ab.sustain_paradox)
			end
		end
	else
		if ab.mana then
			trigger = true; self:incMana(-ab.mana * (100 + 2 * self:combatFatigue()) / 100)
		end
		if ab.stamina then
			trigger = true; self:incStamina(-ab.stamina * (100 + self:combatFatigue()) / 100)
		end
		-- Vim is not affected by fatigue
		if ab.vim then
			trigger = true; self:incVim(-ab.vim)
		end
		if ab.positive then
			trigger = true; self:incPositive(-ab.positive * (100 + self:combatFatigue()) / 100)
		end
		if ab.negative then
			trigger = true; self:incNegative(-ab.negative * (100 + self:combatFatigue()) / 100)
		end
		if ab.hate then
			trigger = true; self:incHate(-ab.hate * (100 + self:combatFatigue()) / 100)
		end
		-- Equilibrium is not affected by fatigue
		if ab.equilibrium then
			self:incEquilibrium(ab.equilibrium)
		end
		-- Paradox is not affected by fatigue but it's cost does increase exponentially
		if ab.paradox then
			trigger = true; self:incParadox(ab.paradox * (1 + (self.paradox / 100)))
		end
	end
	if trigger and self:hasEffect(self.EFF_BURNING_HEX) then
		local p = self:hasEffect(self.EFF_BURNING_HEX)
		DamageType:get(DamageType.FIRE).projector(p.src, self.x, self.y, DamageType.FIRE, p.dam)
	end

	-- Cancel stealth!
	if ab.id ~= self.T_STEALTH and ab.id ~= self.T_HIDE_IN_PLAIN_SIGHT and not ab.no_break_stealth then self:breakStealth() end
	if ab.id ~= self.T_LIGHTNING_SPEED then self:breakLightningSpeed() end
	return true
end

--- Force a talent to activate without using energy or such
function _M:forceUseTalent(t, def)
	local oldpause = game.paused
	local oldenergy = self.energy.value
	if def.ignore_energy then self.energy.value = 10000 end

	if def.no_equilibrium_fail then self:attr("no_equilibrium_fail", 1) end
	self:useTalent(t, nil, def.force_level, def.ignore_cd, def.force_target)
	if def.no_equilibrium_fail then self:attr("no_equilibrium_fail", -1) end

	if def.ignore_energy then
		game.paused = oldpause
		self.energy.value = oldenergy
	end
end

--- Breaks stealth if active
function _M:breakStealth()
	if self:isTalentActive(self.T_STEALTH) then
		local chance = 0
		if self:knowTalent(self.T_UNSEEN_ACTIONS) then
			chance = 10 + self:getTalentLevel(self.T_UNSEEN_ACTIONS) * 9 + (self:getLck() - 50) * 0.2
		end

		-- Do not break stealth
		if rng.percent(chance) then return end

		self:forceUseTalent(self.T_STEALTH, {ignore_energy=true})
		self.changed = true
	end
end

--- Breaks lightning speed if active
function _M:breakLightningSpeed()
	if self:hasEffect(self.EFF_LIGHTNING_SPEED) then
		self:removeEffect(self.EFF_LIGHTNING_SPEED)
	end
end

--- Break antimagic for a while after using spells & magic devices
function _M:antimagicBackslash(turns)
	local done = false
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if t.type[1] == "wild-gift/antimagic" and t.mode ~= "passive" then
			if t.mode == "activated" then
				self.talents_cd[tid] = (self.talents_cd[tid] or 0) + turns
			elseif t.mode == "sustained" then
				if self:isTalentActive(tid) then self:forceUseTalent(tid, {ignore_energy=true}) end
				self.talents_cd[tid] = (self.talents_cd[tid] or 0) + turns
			end
			done = true
		end
	end
	if done then game.logPlayer(self, "#LIGHT_RED#Your antimagic abilities are disrupted!") end
end

--- Pack Rat chance
function _M:doesPackRat()
	if self:knowTalent(self.T_PACK_RAT) then
		local chance = 10 + self:getTalentLevel(self.T_PACK_RAT) * 7
		if rng.percent(chance) then return true end
	end
	return false
end

--- Return the full description of a talent
-- You may overload it to add more data (like power usage, ...)
function _M:getTalentFullDescription(t, addlevel)
	local old = self.talents[t.id]
	self.talents[t.id] = (self.talents[t.id] or 0) + (addlevel or 0)

	local d = tstring{}

	d:add({"color",0x6f,0xff,0x83}, "Effective talent level: ", {"color",0x00,0xFF,0x00}, ("%.1f"):format(self:getTalentLevel(t)), true)
	if t.mode == "passive" then d:add({"color",0x6f,0xff,0x83}, "Use mode: ", {"color",0x00,0xFF,0x00}, "Passive", true)
	elseif t.mode == "sustained" then d:add({"color",0x6f,0xff,0x83}, "Use mode: ", {"color",0x00,0xFF,0x00}, "Sustained", true)
	else d:add({"color",0x6f,0xff,0x83}, "Use mode: ", {"color",0x00,0xFF,0x00}, "Activated", true)
	end

	if t.mana or t.sustain_mana then d:add({"color",0x6f,0xff,0x83}, "Mana cost: ", {"color",0x7f,0xff,0xd4}, ""..(t.sustain_mana or t.mana * (100 + 2 * self:combatFatigue()) / 100), true) end
	if t.stamina or t.sustain_stamina then d:add({"color",0x6f,0xff,0x83}, "Stamina cost: ", {"color",0xff,0xcc,0x80}, ""..(t.sustain_stamina or t.stamina * (100 + self:combatFatigue()) / 100), true) end
	if t.equilibrium or t.sustain_equilibrium then d:add({"color",0x6f,0xff,0x83}, "Equilibrium cost: ", {"color",0x00,0xff,0x74}, ""..(t.equilibrium or t.sustain_equilibrium), true) end
	if t.vim or t.sustain_vim then d:add({"color",0x6f,0xff,0x83}, "Vim cost: ", {"color",0x88,0x88,0x88}, ""..(t.sustain_vim or t.vim), true) end
	if t.positive or t.sustain_positive then d:add({"color",0x6f,0xff,0x83}, "Positive energy cost: ", {"color",255, 215, 0}, ""..(t.sustain_positive or t.positive * (100 + self:combatFatigue()) / 100), true) end
	if t.negative or t.sustain_negative then d:add({"color",0x6f,0xff,0x83}, "Negative energy cost: ", {"color", 127, 127, 127}, ""..(t.sustain_negative or t.negative * (100 + self:combatFatigue()) / 100), true) end
	if t.hate or t.sustain_hate then d:add({"color",0x6f,0xff,0x83}, "Hate cost:  ", {"color", 127, 127, 127}, ""..(t.hate or t.sustain_hate), true) end
	if t.paradox or t.sustain_paradox then d:add({"color",0x6f,0xff,0x83}, "Paradox cost: ", {"color",  176, 196, 222}, ("%0.2f"):format(t.sustain_paradox or t.paradox * (1 + (self.paradox / 100))), true) end
	if self:getTalentRange(t) > 1 then d:add({"color",0x6f,0xff,0x83}, "Range: ", {"color",0xFF,0xFF,0xFF}, ("%0.2f"):format(self:getTalentRange(t)), true)
	else d:add({"color",0x6f,0xff,0x83}, "Range: ", {"color",0xFF,0xFF,0xFF}, "melee/personal", true)
	end
	if self:getTalentCooldown(t) then d:add({"color",0x6f,0xff,0x83}, "Cooldown: ", {"color",0xFF,0xFF,0xFF}, ""..self:getTalentCooldown(t), true) end
	local speed = self:getTalentProjectileSpeed(t)
	if speed then d:add({"color",0x6f,0xff,0x83}, "Travel Speed: ", {"color",0xFF,0xFF,0xFF}, ""..(speed * 100).."% of base", true)
	else d:add({"color",0x6f,0xff,0x83}, "Travel Speed: ", {"color",0xFF,0xFF,0xFF}, "instantaneous", true)
	end
	local uspeed = "1 turn"
	if t.no_energy and type(t.no_energy) == "boolean" and t.no_energy == true then uspeed = "instant" end
	d:add({"color",0x6f,0xff,0x83}, "Usage Speed: ", {"color",0xFF,0xFF,0xFF}, uspeed, true)

	d:add({"color",0x6f,0xff,0x83}, "Description: ", {"color",0xFF,0xFF,0xFF}, t.info(self, t), true)

	self.talents[t.id] = old

	return d
end

function _M:getTalentCooldown(t)
	if not t.cooldown then return end
	local cd = t.cooldown
	if type(cd) == "function" then cd = cd(self, t) end
	if not cd then return end
	if self.talent_cd_reduction[t.id] then cd = cd - self.talent_cd_reduction[t.id] end
	if self.talent_cd_reduction.all then cd = cd - self.talent_cd_reduction.all end
	if t.is_spell then
		return math.ceil(cd * (1 - self.spell_cooldown_reduction or 0))
	else
		return cd
	end
end

--- Starts a talent cooldown; overloaded from the default to handle talent cooldown reduction
-- @param t the talent to cooldown
function _M:startTalentCooldown(t)
	if not t.cooldown then return end
	self.talents_cd[t.id] = self:getTalentCooldown(t)
	self.changed = true
end

--- How much experience is this actor worth
-- @param target to whom is the exp rewarded
-- @return the experience rewarded
function _M:worthExp(target)
	if not target.level or self.level < target.level - 7 then return 0 end

	-- HHHHAACKKK ! Use a normal scheme for the game except in the infinite dungeon
	if not game.zone.infinite_dungeon then
		local mult = 0.6
		if self.rank == 1 then mult = 0.6
		elseif self.rank == 2 then mult = 0.8
		elseif self.rank == 3 then mult = 3
		elseif self.rank == 3.5 then mult = 15
		elseif self.rank == 4 then mult = 60
		elseif self.rank >= 5 then mult = 120
		end

		return self.level * mult * self.exp_worth * (target.exp_kill_multiplier or 1)
	else
		local mult = 2 + (self.exp_kill_multiplier or 0)
		if self.rank == 1 then mult = 2
		elseif self.rank == 2 then mult = 2
		elseif self.rank == 3 then mult = 3.5
		elseif self.rank == 3.5 then mult = 5
		elseif self.rank == 4 then mult = 6
		elseif self.rank >= 5 then mult = 6.5
		end

		return self.level * mult * self.exp_worth * (target.exp_kill_multiplier or 1)
	end
end

--- Suffocate a bit, lose air
function _M:suffocate(value, src)
	if self:attr("no_breath") then return false, false end
	if self:attr("invulnerable") then return false, false end
	self.air = self.air - value
	local ae = game.level.map(self.x, self.y, Map.ACTOR)
	if self.air <= 0 then
		game.logSeen(self, "%s suffocates to death!", self.name:capitalize())
		return self:die(src), true
	end
	return false, true
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- Check for telepathy, invisibility, stealth, ...
function _M:canSeeNoCache(actor, def, def_pct)
	if not actor then return false, 0 end

	-- ESP, see all, or only types/subtypes
	if self:attr("esp") then
		local esp = self:attr("esp")
		-- Full ESP
		if esp.all and esp.all > 0 then
			if game.level then
				game.level.map.seens(actor.x, actor.y, 1)
			end
			return true, 100
		end

		-- Type based ESP
		if esp[actor.type] and esp[actor.type] > 0 then
			return true, 100
		end
		if esp[actor.type.."/"..actor.subtype] and esp[actor.type.."/"..actor.subtype] > 0 then
			return true, 100
		end
	end

	-- Blindness means can't see anything
	if self:attr("blind") then
		return false, 0
	end

	-- Check for stealth. Checks against the target cunning and level
	if actor:attr("stealth") and actor ~= self then
		local def = self.level / 2 + self:getCun(25) + (self:attr("see_stealth") or 0)
		local hit, chance = self:checkHit(def, actor:attr("stealth") + (actor:attr("inc_stealth") or 0), 0, 100)
		if not hit then
			return false, chance
		end
	end

	-- check if the actor is stalking you
	if self.stalker then
		if self.stalker == actor then
			return false, 0
		end
	end

	-- Check for invisibility. This is a "simple" checkHit between invisible and see_invisible attrs
	if actor:attr("invisible") then
		-- Special case, 0 see invisible, can NEVER see invisible things
		if not self:attr("see_invisible") then return false, 0 end
		local hit, chance = self:checkHit(self:attr("see_invisible"), actor:attr("invisible"), 0, 100)
		if not hit then
			return false, chance
		end
	end

	-- check cursed pity talent
	if actor:knowTalent(self.T_PITY) then
		local t = actor:getTalentFromId(self.T_PITY)
		if math.floor(core.fov.distance(self.x, self.y, actor.x, actor.y)) >= actor:getTalentRange(t) then
			return false, 50 - actor:getTalentLevel(self.T_PITY) * 5
		end
	end

	if def ~= nil then
		return def, def_pct
	else
		return true, 100
	end
end

function _M:canSee(actor, def, def_pct)
	if not actor then return false, 0 end

	self.can_see_cache = self.can_see_cache or {}
	local s = tostring(def).."/"..tostring(def_pct)

	if self.can_see_cache[actor] and self.can_see_cache[actor][s] then return self.can_see_cache[actor][s][1], self.can_see_cache[actor][s][2] end
	self.can_see_cache[actor] = self.can_see_cache[actor] or {}
	self.can_see_cache[actor][s] = self.can_see_cache[actor][s] or {}

	local res, chance = self:canSeeNoCache(actor, def, def_pct)
	self.can_see_cache[actor][s] = {res,chance}

	-- Make sure the display updates
	if self.player and type(def) == "nil" and actor._mo then actor._mo:onSeen(res) end

	return res, chance
end

function _M:resetCanSeeCache()
	self.can_see_cache = {}
	setmetatable(self.can_see_cache, {__mode="k"})
end

--- Can the target be applied some effects
-- @param what a string describing what is being tried
function _M:canBe(what)
	if what == "poison" and rng.percent(100 * (self:attr("poison_immune") or 0)) then return false end
	if what == "disease" and rng.percent(100 * (self:attr("disease_immune") or 0)) then return false end
	if what == "cut" and rng.percent(100 * (self:attr("cut_immune") or 0)) then return false end
	if what == "confusion" and rng.percent(100 * (self:attr("confusion_immune") or 0)) then return false end
	if what == "blind" and rng.percent(100 * (self:attr("blind_immune") or 0)) then return false end
	if what == "silence" and rng.percent(100 * (self:attr("silence_immune") or 0)) then return false end
	if what == "disarm" and rng.percent(100 * (self:attr("disarm_immune") or 0)) then return false end
	if what == "pin" and rng.percent(100 * (self:attr("pin_immune") or 0)) then return false end
	if what == "stun" and rng.percent(100 * (self:attr("stun_immune") or 0)) then return false end
	if what == "fear" and rng.percent(100 * (self:attr("fear_immune") or 0)) then return false end
	if what == "knockback" and rng.percent(100 * (self:attr("knockback_immune") or 0)) then return false end
	if what == "stone" and rng.percent(100 * (self:attr("stone_immune") or 0)) then return false end
	if what == "instakill" and rng.percent(100 * (self:attr("instakill_immune") or 0)) then return false end
	if what == "teleport" and rng.percent(100 * (self:attr("teleport_immune") or 0)) then return false end
	if what == "worldport" and game.zone.no_worldport then return false end
	if what == "summon" and self:attr("suppress_summon") then return false end
	return true
end

--- Adjusts timed effect durations based on rank and other things
function _M:updateEffectDuration(dur, what)
	-- Rank reduction: below elite = none; elite = 1, boss = 2, elite boss = 3
	local rankmod = 0
	if self.rank == 3 then rankmod = 25
	elseif self.rank == 3.5 then rankmod = 40
	elseif self.rank == 4 then rankmod = 45
	elseif self.rank == 5 then rankmod = 75
	end
	if rankmod <= 0 then return dur end

	print("Effect duration reduction <", dur)
	if what == "stun" then
		local p = self:combatPhysicalResist(), rankmod * (util.bound(self:combatPhysicalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "pin" then
		local p = self:combatPhysicalResist(), rankmod * (util.bound(self:combatPhysicalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "disarm" then
		local p = self:combatPhysicalResist(), rankmod * (util.bound(self:combatPhysicalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "frozen" then
		local p = self:combatSpellResist(), rankmod * (util.bound(self:combatSpellResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "blind" then
		local p = self:combatMentalResist(), rankmod * (util.bound(self:combatMentalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "silence" then
		local p = self:combatMentalResist(), rankmod * (util.bound(self:combatMentalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "slow" then
		local p = self:combatPhysicalResist(), rankmod * (util.bound(self:combatPhysicalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	elseif what == "confusion" then
		local p = self:combatMentalResist(), rankmod * (util.bound(self:combatMentalResist() * 3, 40, 115) / 100)
		dur = dur - math.ceil(dur * (p) / 100)
	end
	print("Effect duration reduction >", dur)
	return dur
end

--- Called when we are projected upon
-- This is used to do spell reflection, antimagic, ...
function _M:on_project(tx, ty, who, t, x, y, damtype, dam, particles)
	-- Spell reflect
	if self:attr("spell_reflect") and ((t.talent and t.talent.reflectable) or t.reflectable) and rng.percent(self:attr("spell_reflect")) then
		game.logSeen(self, "%s reflects the spell!", self.name:capitalize())
		-- Setup the bypass so it does not eternally reflect between two actors
		t.bypass = true
		who:project(t, x, y, damtype, dam, particles)
		return true
	end

	-- Spell absorb
	if self:attr("spell_absorb") and (t.talent and t.talent.is_spell) and rng.percent(self:attr("spell_absorb")) then
		game.logSeen(self, "%s ignores the spell!", self.name:capitalize())
		return true
	end
	return false
end

--- Called when we have been projected upon and the DamageType is about to be called
function _M:projected(tx, ty, who, t, x, y, damtype, dam, particles)
	return false
end

--- Called when we are targetted by a projectile
function _M:on_projectile_target(x, y, p)
	if self:attr("slow_projectiles") then
		print("Projectile slowing down from", p.energy.mod)
		p.energy.mod = p.energy.mod * (100 - self.slow_projectiles) / 100
		print("Projectile slowing down to", p.energy.mod)
	end
end

--- Call when added to a level
-- Used to make escorts and such
function _M:addedToLevel(level, x, y)
	if self.make_escort then
		for _, filter in ipairs(self.make_escort) do
			for i = 1, filter.number do
				if not filter.chance or rng.percent(filter.chance) then
					-- Find space
					local x, y = util.findFreeGrid(self.x, self.y, 10, true, {[Map.ACTOR]=true})
					if not x then break end

					-- Find an actor with that filter
					local m = game.zone:makeEntity(game.level, "actor", filter, nil, true)
					if m and m:canMove(x, y) then
						if filter.no_subescort then m.make_escort = nil end
						game.zone:addEntity(game.level, m, "actor", x, y)
					elseif m then m:removed() end
				end
			end
		end
		self.make_escort = nil
	end
	self:check("on_added_to_level", level, x, y)
end
