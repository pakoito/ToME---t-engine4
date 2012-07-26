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

require "engine.class"
local ActorAI = require "engine.interface.ActorAI"
local Faction = require "engine.Faction"
local Emote = require("engine.Emote")
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI))

function _M:init(t, no_default)
	mod.class.Actor.init(self, t, no_default)
	ActorAI.init(self, t)

	-- Grab default image name if none is set
	if not self.image and self.name ~= "unknown actor" then self.image = "npc/"..tostring(self.type or "unknown").."_"..tostring(self.subtype or "unknown"):lower():gsub("[^a-z0-9]", "_").."_"..(self.name or "unknown"):lower():gsub("[^a-z0-9]", "_")..".png" end
end

function _M:act()
	while self:enoughEnergy() and not self.dead do
		-- Do basic actor stuff
		if not mod.class.Actor.act(self) then return end
		local old_energy = self.energy.value

		-- Compute FOV, if needed
		self:doFOV()

		-- Let the AI think .... beware of Shub !
		-- If AI did nothing, use energy anyway
		self:doAI()

		if self.emote_random and self.x and self.y and game.level.map.seens(self.x, self.y) and rng.range(0, 999) < self.emote_random.chance * 10 then
			local e = util.getval(rng.table(self.emote_random))
			if e then
				local dur = util.bound(#e, 30, 90)
				self:doEmote(e, dur)
			end
		end

		if not self.energy.used then self:useEnergy() end
		if old_energy == self.energy.value then break end -- Prevent infinite loops
	end
end

function _M:doFOV()
	-- If the actor has no special vision we can use the default cache
	if not self.special_vision then
		self:computeFOV(self.sight or 10, "block_sight", nil, nil, nil, true)
	else
		self:computeFOV(self.sight or 10, "block_sight")
	end
end

--- Create a line to target based on field of vision
function _M:lineFOV(tx, ty, extra_block, block, sx, sy)
	sx = sx or self.x
	sy = sy or self.y
	local act = game.level.map(tx, ty, engine.Map.ACTOR)
	local sees_target = core.fov.distance(sx, sy, tx, ty) <= self.sight and game.level.map.lites(tx, ty) or
		act and self:canSee(act) and core.fov.distance(sx, sy, tx, ty) <= math.max(self.sight, (self.heightened_senses or 0) + (self.infravision or 0))

	local darkVisionRange
	if self:knowTalent(self.T_DARK_VISION) then
		local t = self:getTalentFromId(self.T_DARK_VISION)
		darkVisionRange = self:getTalentRange(t)
	end
	local inCreepingDark = false

	extra_block = type(extra_block) == "function" and extra_block
		or type(extra_block) == "string" and function(_, x, y) return game.level.map:checkAllEntities(x, y, extra_block) end

	-- This block function can be called *a lot*, so every conditional statement we move outside the function helps
	block = block or sees_target and (darkVisionRange and
			-- target is seen and source actor has dark vision
			function(_, x, y)
				if game.level.map:checkAllEntities(x, y, "creepingDark") then
					inCreepingDark = true
				end
				if inCreepingDark and core.fov.distance(sx, sy, x, y) > darkVisionRange then
					return true
				end
				return game.level.map:checkAllEntities(x, y, "block_sight") or
					game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
					extra_block and extra_block(self, x, y)
			end
			-- target is seen and source actor does NOT have dark vision
			or function(_, x, y)
				return game.level.map:checkAllEntities(x, y, "block_sight") or
					game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
					extra_block and extra_block(self, x, y)
			end)
		or darkVisionRange and
			-- target is NOT seen and source actor has dark vision (do we even need to check for creepingDark in this case?)
			function(_, x, y)
				if game.level.map:checkAllEntities(x, y, "creepingDark") then
					inCreepingDark = true
				end
				if inCreepingDark and core.fov.distance(sx, sy, x, y) > darkVisionRange then
					return true
				end
				if core.fov.distance(sx, sy, x, y) <= self.sight and game.level.map.lites(x, y) then
					return game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_sight") or
						game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
						extra_block and extra_block(self, x, y)
				else
					return true
				end
			end
		or
			-- target is NOT seen and the source actor does NOT have dark vision
			function(_, x, y)
				if core.fov.distance(sx, sy, x, y) <= self.sight and game.level.map.lites(x, y) then
					return game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_sight") or
						game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
						extra_block and extra_block(self, x, y)
				else
					return true
				end
			end

	return core.fov.line(sx, sy, tx, ty, block)
end

--- Give target to others
function _M:seen_by(who)
	if self.ai_target.actor then return end
	if self.dont_pass_target then return end
	if not who.ai_target then return end
	if not who.ai_target.actor then return end
	if self:reactionToward(who) <= 0 then return end
	if not who:canSee(who.ai_target.actor) then return end
	if not who.x or not self:hasLOS(who.x, who.y) then return end
	self:setTarget(who.ai_target.actor)
	print("[TARGET] Passing target", self.name, "from", who.name, "to", who.ai_target.actor.name)
end

--- Check if we are angered
-- @param src the angerer
-- @param set true if value is the finite value, false if it is an increment
-- @param value the value to add/subtract
function _M:checkAngered(src, set, value)
	if not src.resolveSource then return end
	if not src.faction then return end
	if self.never_anger then return end
	if game.party:hasMember(self) then return end
	if self.summoner and self.summoner == src then return end

	-- Cant anger at our own faction unless it's the silly player
	if self.faction == src.faction and not src.player then return end

	local rsrc = src:resolveSource()
	local rid = rsrc.unique or rsrc.name
	if not self.reaction_actor then self.reaction_actor = {} end

	local was_hostile = self:reactionToward(src) < 0

	if not set then
		self.reaction_actor[rid] = util.bound((self.reaction_actor[rid] or 0) + value, -200, 200)
	else
		self.reaction_actor[rid] = util.bound(value, -200, 200)
	end

	if not was_hostile and self:reactionToward(src) < 0 then
		if self.anger_emote then
			self:doEmote(self.anger_emote:gsub("@himher@", src.female and "her" or "him"), 30)
		end
	end
end

--- Called by ActorLife interface
-- We use it to pass aggression values to the AIs
function _M:onTakeHit(value, src)
	value = mod.class.Actor.onTakeHit(self, value, src)

	if not self.ai_target.actor and src and src.targetable and value > 0 then
		self.ai_target.actor = src
	end

	-- Get angry if attacked by a friend
	if src and src ~= self and src.resolveSource and src.faction and self:reactionToward(src) >= 0 and value > 0 then
		self:checkAngered(src, false, -50)

		-- Call for help if we become hostile
		for i = 1, #self.fov.actors_dist do
			local act = self.fov.actors_dist[i]
			if act and act ~= self and self:reactionToward(act) > 0 and not act.dead and act.checkAngered then
				act:checkAngered(src, false, -50)
			end
		end
	end

	return value
end

function _M:die(src, death_note)
	if self.dead then self:disappear(src) self:deleteFromMap(game.level.map) return true end

	if src and Faction:get(self.faction) and Faction:get(self.faction).hostile_on_attack then
		Faction:setFactionReaction(self.faction, src.faction, Faction:factionReaction(self.faction, src.faction) - self.rank, true)
	end

	-- Get angry if attacked by a friend
	if src and src ~= self and src.resolveSource and src.faction then
		local rsrc = src:resolveSource()
		local rid = rsrc.unique or rsrc.name

		-- Call for help if we become hostile
		for i = 1, #self.fov.actors_dist do
			local act = self.fov.actors_dist[i]
			if act and act ~= self and act:reactionToward(rsrc) >= 0 and self:reactionToward(act) > 0 and not act.dead and act.checkAngered then
				act:checkAngered(src, false, -101)
			end
		end
	end

	-- Self resurrect, mouhaha!
	if self:attr("self_resurrect") then
		self:attr("self_resurrect", -1)
		game.logSeen(self, "#LIGHT_RED#%s rises from the dead!", self.name:capitalize()) -- src, not self as the source, to make sure the player knows his doom ;>
		local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
		game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "RESURRECT!", {255,120,0})

		local effs = {}

		-- Go through all spell effects
		for eff_id, p in pairs(self.tmp) do
			local e = self.tempeffect_def[eff_id]
			effs[#effs+1] = {"effect", eff_id}
		end

		-- Go through all sustained spells
		for tid, act in pairs(self.sustain_talents) do
			if act then
				effs[#effs+1] = {"talent", tid}
			end
		end

		while #effs > 0 do
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				self:removeEffect(eff[2])
			else
				self:forceUseTalent(eff[2], {ignore_energy=true})
			end
		end
		self.life = self.max_life
		self.mana = self.max_mana
		self.stamina = self.max_stamina
		self.equilibrium = 0
		self.air = self.max_air

		self.dead = false
		self.died = (self.died or 0) + 1
		self:move(self.x, self.y, true)

		self:check("on_resurrect", "basic_resurrect")

		return
	end

	if self.rank >= 4 and game.state:allowRodRecall() then
		local rod = game.zone:makeEntityByName(game.level, "object", "ROD_OF_RECALL")
		if rod then
			game.zone:addEntity(game.level, rod, "object", self.x, self.y)
			game.state:allowRodRecall(false)
			if self.define_as == "THE_MASTER" then world:gainAchievement("FIRST_BOSS_MASTER", src)
			elseif self.define_as == "GRAND_CORRUPTOR" then world:gainAchievement("FIRST_BOSS_GRAND_CORRUPTOR", src)
			elseif self.define_as == "PROTECTOR_MYSSIL" then world:gainAchievement("FIRST_BOSS_MYSSIL", src)
			elseif self.define_as == "URKIS" then world:gainAchievement("FIRST_BOSS_URKIS", src)
			end
		end
	end
	-- Ok the player managed to kill a boss dont bother him with tutorial anymore
	if self.rank >= 3.5 and not profile.mod.allow_build.tutorial_done then game:setAllowedBuild("tutorial_done") end

	return mod.class.Actor.die(self, src, death_note)
end

function _M:tooltip(x, y, seen_by)
	local str = mod.class.Actor.tooltip(self, x, y, seen_by)
	if not str then return end
	local killed = game.player.all_kills and (game.player.all_kills[self.name] or 0) or 0

	str:add(
		true,
		("Killed by you: "):format(killed), true,
		"Target: ", self.ai_target.actor and self.ai_target.actor.name or "none"
	)
	if config.settings.cheat then str:add(true, "UID: "..self.uid, true, self.image) end

	return str
end

function _M:getTarget(typ)
	-- Free ourselves
	if self:attr("encased_in_ice") then
		return self.x, self.y, self
	-- Heal/buff/... ourselves
	elseif type(typ) == "table" and typ.first_target == "friend" and typ.default_target == self then
		return self.x, self.y, self
	-- Hit our foes
	else
		return ActorAI.getTarget(self, typ)
	end
end

--- Make emotes appear in the log too
function _M:setEmote(e)
	game.logSeen(self, "%s says: '%s'", self.name:capitalize(), e.text)
	mod.class.Actor.setEmote(self, e)
end

--- Simple emote
function _M:doEmote(text, dur, color)
	self:setEmote(Emote.new(text, dur, color))
end

--- Call when added to a level
-- Used to make escorts and such
function _M:addedToLevel(level, x, y)
	if game.difficulty == game.DIFFICULTY_INSANE and not game.party:hasMember(self) then
		-- Increase talent level
		for tid, lev in pairs(self.talents) do
			self:learnTalent(tid, true, lev)
		end
	end

	return mod.class.Actor.addedToLevel(self, level, x, y)
end

