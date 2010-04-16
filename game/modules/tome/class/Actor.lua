-- ToME - Tales of Middle-Earth
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
local Map = require "engine.Map"

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
	mod.class.interface.Combat
))

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

	self.combat_physresist = 0
	self.combat_spellresist = 0
	self.combat_mentalresist = 0

	self.fatigue = 0

	self.spell_cooldown_reduction = 0

	self.unused_stats = self.unused_stats or 0
	self.unused_talents =  self.unused_talents or 0
	self.unused_talents_types = self.unused_talents_types or 0

	t.life_rating = t.life_rating or 10
	t.mana_rating = t.mana_rating or 10
	t.stamina_rating = t.stamina_rating or 4

	t.esp = t.esp or {range=10}

	t.on_melee_hit = t.on_melee_hit or {}
	t.melee_project = t.melee_project or {}
	t.can_pass = t.can_pass or {}
	t.move_project = t.move_project or {}

	-- Resistances
	t.resists = t.resists or {}

	-- % Increase damage
	t.inc_damage = t.inc_damage or {}

	-- Default regen
	t.air_regen = t.air_regen or 3
	t.mana_regen = t.mana_regen or 0.5
	t.stamina_regen = t.stamina_regen or 0.3 -- Stamina regens slower than mana
	t.life_regen = t.life_regen or 0.25 -- Life regen real slow
	t.equilibrium_regen = t.equilibrium_regen or -0.01 -- Equilibrium resets real slow

	-- Equilibrium has a default very high max, as bad effects happen even before reaching it
	t.max_equilibrium = t.max_equilibrium or 100000
	t.equilibrium = t.equilibrium or 0

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
end

function _M:act()
	if not engine.Actor.act(self) then return end

	-- Cooldown talents
	self:cooldownTalents()
	-- Regen resources
	self:regenLife()
	self:regenResources()
	-- Compute timed effects
	self:timedEffects()

	-- Handle thunderstorm, even if the actor is stunned or incampacited it still works
	if self:isTalentActive(self.T_THUNDERSTORM) then
		local t = self:getTalentFromId(self.T_THUNDERSTORM)
		t.do_storm(self, t)
	end

	if self:attr("stunned") then self.energy.value = 0 end

	-- Suffocate ?
	local air_level = game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "air_level")
	if air_level then self:suffocate(-air_level, self) end

	-- Regain natural balance?
	local equilibrium_level = game.level.map:checkEntity(self.x, self.y, Map.TERRAIN, "equilibrium_level")
	if equilibrium_level then self:incEquilibrium(equilibrium_level) end

	-- Still enough energy to act ?
	if self.energy.value < game.energy_to_act then return false end

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
			game.level.map:checkAllEntities(x, y, "block_move", self, true)
		else
			moved = engine.Actor.move(self, x, y, force)
		end
		if not force and moved and not self.did_energy then self:useEnergy() end
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

	return moved
end

--- Blink through walls
function _M:probabilityTravel(x, y, dist)
	local dirx, diry = x - self.x, y - self.y
	local tx, ty = x, y
	while game.level.map:isBound(tx, ty) and game.level.map:checkAllEntities(tx, ty, "block_move", self) and dist > 0 do
		tx = tx + dirx
		ty = ty + diry
		dist = dist - 1
	end
	if game.level.map:isBound(tx, ty) and not game.level.map:checkAllEntities(tx, ty, "block_move", self) then
		return engine.Actor.move(self, tx, ty, false)
	end
	return true
end

--- Quake a zone
-- Moves randomly each grid to an other grid
function _M:doQuake(tg, x, y)
	local locs = {}
	local ms = {}
	self:project(tg, x, y, function(tx, ty)
		locs[#locs+1] = {x=tx,y=ty}
		ms[#ms+1] = game.level.map.map[tx + ty * game.level.map.w]
	end)

	while #locs > 0 do
		local l = rng.tableRemove(locs)
		local m = rng.tableRemove(ms)
		game.level.map.map[l.x + l.y * game.level.map.w] = m
		for k, e in pairs(m) do
			if e.x and e.y and e.move then e:move(l.x, l.y, true)
			elseif e.x and e.y then e.x, e.ly = l.x, l.y end
		end
	end
	game.level.map:cleanFOV()
	game.level.map.changed = true
	game.level.map:redisplay()
end

--- Reveals location surrounding the actor
function _M:magicMap(radius, x, y)
	x = x or self.x
	y = y or self.y
	radius = math.floor(radius)
	for i = x - radius, x + radius do for j = y - radius, y + radius do
		if game.level.map:isBound(i, j) and core.fov.distance(x, y, i, j) < radius then
			game.level.map.remembers(i, j, true)
		end
	end end
end

function _M:tooltip()
	return ([[%s
#00ffff#Level: %d
Exp: %d/%d
#ff0000#HP: %d (%d%%)
Stats: %d /  %d / %d / %d / %d / %d
%s]]):format(
	self.name,
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
	self.desc or ""
	)
end

--- Called before taking a hit, it's the chance to check for shields
function _M:onTakeHit(value, src)
	if self:attr("invulnerable") then
		return 0
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
			local old = self.energy.value
			self.energy.value = 10000
			self:useTalent(self.T_DISRUPTION_SHIELD)
			self.energy.value = old

			-- Explode!
			game.logSeen(self, "%s disruption shield collapses and then explodes in a powerfull manastorm!", self.name:capitalize())
			local tg = {type="ball", radius=5}
			self:project(tg, self.x, self.y, engine.DamageType.ARCANE, dam, {type="manathrust"})
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

	if self:attr("displacement_shield") then
		-- Absorb damage into the displacement shield
		if value <= self.displacement_shield and rng.percent(self.displacement_shield_chance) then
			game.logSeen("The displacement shield teleports the damage to %s!", self.displacement_shield_target.name)
			self.displacement_shield = self.displacement_shield - value
			self.displacement_shield_target:takeHit(value, src)
			value = 0
		end
	end

	-- Achievements
	if src and src:resolveSource().player and value >= 600 then
		world:gainAchievement("SIZE_MATTERS", src:resolveSource())
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
	if src then
		src:resolveSource():gainExp(self:worthExp(src:resolveSource()))
	end
	-- Do we get a blooooooody death ?
	if rng.percent(33) then self:bloodyDeath() end

	-- Drop stuff
	for inven_id, inven in pairs(self.inven) do
		for i, o in ipairs(inven) do
			if not o.no_drop then
				game.level.map:addObject(self.x, self.y, o)
			end
		end
	end
	self.inven = {}

	-- Give stamina back
	if src and src:knowTalent(src.T_UNENDING_FRENZY) then
		src:incStamina(src:getTalentLevel(src.T_UNENDING_FRENZY) * 2)
	end

	-- Achievements
	if src and src:resolveSource().player then
		if src:resolveSource().life == 1 then world:gainAchievement("THAT_WAS_CLOSE", src:resolveSource()) end
		world:gainAchievement("EXTERMINATOR", src:resolveSource(), self)
		world:gainAchievement("PEST_CONTROL", src:resolveSource(), self)
	end

	-- Record kills
	if src and src:resolveSource().player then
		local p = src:resolveSource()
		p.all_kills = p.all_kills or {}
		p.all_kills[self.name] = p.all_kills[self.name] or 0
		p.all_kills[self.name] = p.all_kills[self.name] + 1
	end

	return true
end

function _M:levelup()
	self.unused_stats = self.unused_stats + 3
	self.unused_talents = self.unused_talents + 2
	-- At levels 10, 20 and 30 we gain a new talent type
	if self.level == 10 or  self.level == 20 or  self.level == 30 then
		self.unused_talents_types = self.unused_talents_types + 1
	end

	-- Gain life and resources
	local rating = self.life_rating
	if not self.fixed_rating then
		rating = rng.range(math.floor(self.life_rating * 0.5), math.floor(self.life_rating * 1.5))
	end
	self.max_life = self.max_life + rating + 1 -- + 5
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_I) and 1 or 0)
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_II) and 1 or 0)
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_III) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_I) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_II) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_III) and 1 or 0)

	self:incMaxMana(self.mana_rating)
	self:incMaxStamina(self.stamina_rating)
	-- Healp up on new level
	self.life = self.max_life
	self.mana = self.max_mana
	self.stamina = self.max_stamina
	self.equilibrium = 0

	-- Auto levelup ?
	if self.autolevel then
		engine.Autolevel:autoLevel(self)
	end
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		self.max_life = self.max_life + 5 * v
	elseif stat == self.STAT_WIL then
		self:incMaxMana(5 * v)
		self:incMaxStamina(2 * v)
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
	return math.floor(40 + self:getStr() * 1.8) + (self.max_encumber or 0)
end

function _M:getEncumbrance()
	-- Compute encumbrance
	local enc = 0
	for inven_id, inven in pairs(self.inven) do
		for item, o in ipairs(inven) do
			o:forAllStack(function(so) enc = enc + so.encumber end)
		end
	end
	print("Total encumbrance", enc)
	return enc
end

function _M:checkEncumbrance()
	-- Compute encumbrance
	local enc, max = self:getEncumbrance(), self:getMaxEncumbrance()

	-- We are pinned to the ground if we carry too much
	if not self.encumbered and enc > max then
		game.logPlayer(self, "#FF0000#You carry too much, you are encumbered!")
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
		world:gainAchievement("DEUX_EX_MACHINA", self, o)
	end
end

--- Call when an object is removed
function _M:onRemoveObject(o)
	engine.interface.ActorInventory.onRemoveObject(self, o)

	self:checkEncumbrance()
end

--- Actor learns a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was learnt, nil and an error message otherwise
function _M:learnTalent(t_id, force, nb)
	if not engine.interface.ActorTalents.learnTalent(self, t_id, force, nb) then return false end

	-- If we learned a spell, get mana, if you learned a technique get stamina, if we learned a wild gift, get power
	local t = _M.talents_def[t_id]
	if t.type[1]:find("^spell/") and not self:knowTalent(self.T_MANA_POOL) then self:learnTalent(self.T_MANA_POOL, true) end
	if t.type[1]:find("^wild%-gift/") and not self:knowTalent(self.T_EQUILIBRIUM_POOL) then self:learnTalent(self.T_EQUILIBRIUM_POOL, true) end
	if t.type[1]:find("^technique/") and not self:knowTalent(self.T_STAMINA_POOL) then self:learnTalent(self.T_STAMINA_POOL, true) end
	if t.type[1]:find("^corruption/") and not self:knowTalent(self.T_VIM_POOL) then self:learnTalent(self.T_VIM_POOL, true) end

	-- If we learn an archery talent, also learn to shoot
	if t.type[1]:find("^technique/archery") and not self:knowTalent(self.T_SHOOT) then self:learnTalent(self.T_SHOOT, true) end
	return true
end

--- Actor forgets a talent
-- @param t_id the id of the talent to learn
-- @return true if the talent was unlearnt, nil and an error message otherwise
function _M:unlearnTalent(t_id)
	if not engine.interface.ActorTalents.unlearnTalent(self, t_id, force) then return false end
	return true
end

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent)
	if self:attr("feared") then
		game.logSeen(self, "%s is too afraid to use %s.", self.name:capitalize(), ab.name)
		return false
	end

	if not self:enoughEnergy() then print("fail energy") return false end

	if ab.mode == "sustained" then
		if ab.sustain_mana and self.max_mana < ab.sustain_mana and not self:isTalentActive(ab.id) then
			game.logPlayer(self, "You do not have enough mana to activate %s.", ab.name)
			return false
		end
		if ab.sustain_stamina and self.max_stamina < ab.sustain_stamina and not self:isTalentActive(ab.id) then
			game.logPlayer(self, "You do not have enough stamina to activate %s.", ab.name)
			return false
		end
	else
		if ab.mana and self:getMana() < ab.mana * (100 + self.fatigue) / 100 then
			game.logPlayer(self, "You do not have enough mana to cast %s.", ab.name)
			return false
		end
		if ab.stamina and self:getStamina() < ab.stamina * (100 + self.fatigue) / 100 then
			game.logPlayer(self, "You do not have enough stamina to use %s.", ab.name)
			return false
		end
	end

	-- Equilibrium is special, it has no max, but the higher it is the higher the chance of failure (and loss of the turn)
	-- But it is not affected by fatigue
	if ab.equilibrium or ab.sustain_equilibrium then
		local eq = ab.equilibrium or ab.sustain_equilibrium
		local chance = math.sqrt(eq + self:getEquilibrium()) / 60
		-- Fail ? lose energy and 1/10 more equilibrium
		print("[Equilibrium] Use chance: ", 100 - chance * 100)
		if not rng.percent(100 - chance * 100) then
			game.logPlayer(self, "You fail to use %s due to your equilibrium!", ab.name)
			self:incEquilibrium(eq / 10)
			self:useEnergy()
			return false
		end
	end

	-- Confused ? lose a turn!
	if self:attr("confused") then
		if rng.percent(self:attr("confused")) then
			game.logSeen(self, "%s is confused and fails to use %s.", self.name:capitalize(), ab.name)
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
		elseif ab.type[1]:find("^spell/") then
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
	if ret == nil then return end

	if not ab.no_energy then
		if ab.type[1]:find("^spell/") then
			self:useEnergy(game.energy_to_act * self:combatSpellSpeed())
		elseif ab.type[1]:find("^physical/") then
			self:useEnergy(game.energy_to_act * self:combatSpeed())
		else
			self:useEnergy()
		end
	end

	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_mana then
				self.max_mana = self.max_mana - ab.sustain_mana
			end
			if ab.sustain_stamina then
				self.max_stamina = self.max_stamina - ab.sustain_stamina
			end
			if ab.sustain_equilibrium then
				self:incEquilibrium(ab.sustain_equilibrium)
			end
		else
			if ab.sustain_mana then
				self.max_mana = self.max_mana + ab.sustain_mana
			end
			if ab.sustain_stamina then
				self.max_stamina = self.max_stamina + ab.sustain_stamina
			end
			if ab.sustain_equilibrium then
				self:incEquilibrium(-ab.sustain_equilibrium)
			end
		end
	else
		if ab.mana then
			self:incMana(-ab.mana * (100 + self.fatigue) / 100)
		end
		if ab.stamina then
			self:incStamina(-ab.stamina * (100 + self.fatigue) / 100)
		end
		-- Equilibrium is not affected by fatigue
		if ab.equilibrium then
			self:incEquilibrium(ab.equilibrium)
		end
	end


	-- Cancel stealth!
	if ab.id ~= self.T_STEALTH and ab.id ~= self.T_HIDE_IN_PLAIN_SIGHT then self:breakStealth() end

	return true
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

		local old = self.energy.value
		self.energy.value = 100000
		self:useTalent(self.T_STEALTH)
		self.energy.value = old
		self.changed = true
	end
end

--- Return the full description of a talent
-- You may overload it to add more data (like power usage, ...)
function _M:getTalentFullDescription(t)
	local d = {}

	if t.mode == "passive" then d[#d+1] = "#6fff83#Use mode: #00FF00#Passive"
	elseif t.mode == "sustained" then d[#d+1] = "#6fff83#Use mode: #00FF00#Sustained"
	else d[#d+1] = "#6fff83#Use mode: #00FF00#Activable"
	end

	if t.mana or t.sustain_mana then d[#d+1] = "#6fff83#Mana cost: #7fffd4#"..(t.mana or t.sustain_mana) end
	if t.stamina or t.sustain_stamina then d[#d+1] = "#6fff83#Stamina cost: #ffcc80#"..(t.stamina or t.sustain_stamina) end
	if t.equilibrium or t.sustain_equilibrium then d[#d+1] = "#6fff83#Equilibrium cost: #00ff74#"..(t.equilibrium or t.sustain_equilibrium) end
	if t.vim or t.sustain_vim then d[#d+1] = "#6fff83#Vim cost: #888888#"..(t.vim or t.sustain_vim) end
	if self:getTalentRange(t) > 1 then d[#d+1] = "#6fff83#Range: #FFFFFF#"..self:getTalentRange(t)
	else d[#d+1] = "#6fff83#Range: #FFFFFF#melee/personal"
	end
	if t.cooldown then d[#d+1] = "#6fff83#Cooldown: #FFFFFF#"..t.cooldown end


	return table.concat(d, "\n").."\n#6fff83#Description: #FFFFFF#"..t.info(self, t)
end

--- Starts a talent cooldown; overloaded from the default to handle talent cooldown reduction
-- @param t the talent to cooldown
function _M:startTalentCooldown(t)
	if not t.cooldown then return end
	if t.type[1]:find("^spell/") then
		self.talents_cd[t.id] = math.ceil(t.cooldown * (1 - self.spell_cooldown_reduction or 0))
	else
		self.talents_cd[t.id] = t.cooldown
	end
	self.changed = true
end

--- How much experience is this actor worth
-- @param target to whom is the exp rewarded
-- @return the experience rewarded
function _M:worthExp(target)
	if not target.level or self.level < target.level - 3 then return 0 end

	local mult = 2
	if self.unique then mult = 6
	elseif self.egoed then mult = 3 end
	return self.level * mult * self.exp_worth
end

--- Suffocate a bit, lose air
function _M:suffocate(value, src)
	self.air = self.air - value
	if self.air <= 0 and not self:attr("no_breath") then
		game.logSeen(self, "%s suffocates to death!", self.name:capitalize())
		return self:die(src)
	end
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- Check for telepathy, invisibility, stealth, ...
function _M:canSee(actor, def, def_pct)
	-- ESP, see all, or only types/subtypes
	if self:attr("esp") then
		local esp = self:attr("esp")
		-- Full ESP
		if esp.all and esp.all > 0 then
			if game.level then
				game.level.map.seens(actor.x, actor.y, true)
			end
			return true, 100
		end

		-- Type based ESP
		if esp[actor.type] and esp[actor.type] > 0 then return true, 100 end
		if esp[actor.type.."/"..actor.subtype] and esp[actor.type.."/"..actor.subtype] > 0 then return true, 100 end
	end

	-- Blindness means can't see anything
	if self:attr("blind") then return false, 0 end

	-- Check for stealth. Checks against the target cunning and level
	if actor:attr("stealth") and actor ~= self then
		local def = self.level / 2 + self:getCun(25)
		local hit, chance = self:checkHit(def, actor:attr("stealth") + (actor:attr("inc_stealth") or 0), 0, 100)
		if not hit then
			return false, chance
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
	if def ~= nil then
		return def, def_pct
	else
		return true, 100
	end
end

--- Can the target be applied some effects
-- @param what a string describing what is being tried
function _M:canBe(what)
	if what == "poison" and rng.percent(100 * (self:attr("poison_immune") or 0)) then return false end
	if what == "cut" and rng.percent(100 * (self:attr("cut_immune") or 0)) then return false end
	if what == "confusion" and rng.percent(100 * (self:attr("confusion_immune") or 0)) then return false end
	if what == "blind" and rng.percent(100 * (self:attr("blind_immune") or 0)) then return false end
	if what == "stun" and rng.percent(100 * (self:attr("stun_immune") or 0)) then return false end
	if what == "fear" and rng.percent(100 * (self:attr("fear_immune") or 0)) then return false end
	if what == "knockback" and rng.percent(100 * (self:attr("knockback_immune") or 0)) then return false end
	if what == "instakill" and rng.percent(100 * (self:attr("instakill_immune") or 0)) then return false end
	return true
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
	if self:attr("spell_absorb") and (t.talent and t.talent.type[1]:find("^spell/")) and rng.percent(self:attr("spell_absorb")) then
		game.logSeen(self, "%s ignores the spell!", self.name:capitalize())
		return true
	end
	return false
end

--- Called when we have been projected upon and the DamageType is about to be called
function _M:projected(tx, ty, who, t, x, y, damtype, dam, particles)
	return false
end
