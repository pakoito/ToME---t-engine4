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
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerHotkeys"
require "engine.interface.PlayerSlide"
require "engine.interface.PlayerMouse"
require "mod.class.interface.PlayerStats"
require "mod.class.interface.PlayerLore"
require "mod.class.interface.PlayerDumpJSON"
require "mod.class.interface.PlayerExplore"
require "mod.class.interface.PartyDeath"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"

--- Defines the player for ToME
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.Actor,
	engine.interface.PlayerRest,
	engine.interface.PlayerRun,
	engine.interface.PlayerHotkeys,
	engine.interface.PlayerMouse,
	engine.interface.PlayerSlide,
	mod.class.interface.PlayerStats,
	mod.class.interface.PlayerLore,
	mod.class.interface.PlayerDumpJSON,
	mod.class.interface.PlayerExplore,
	mod.class.interface.PartyDeath
))

-- Allow character registration even after birth
allow_late_uuid = true

function _M:init(t, no_default)
	t.display=t.display or '@'
	t.color_r=t.color_r or 230
	t.color_g=t.color_g or 230
	t.color_b=t.color_b or 230

	t.unique = t.unique or "player"
	t.player = true
	if type(t.open_door) == "nil" then t.open_door = true end
	t.type = t.type or "humanoid"
	t.subtype = t.subtype or "player"
	t.faction = t.faction or "players"

	t.ai = t.ai or "tactical"
	t.ai_state = t.ai_state or {talent_in=1, ai_move="move_astar"}

	if t.fixed_rating == nil then t.fixed_rating = true end

	-- Dont give free resists & higher stat max to players
	t.resists_cap = t.resists_cap or {}

	t.lite = t.lite or 0

	t.rank = t.rank or 3
	t.old_life = 0
	t.old_air = 0
	t.old_psi = 0

	t.money_value_multiplier = t.money_value_multiplier or 1 -- changes amounts in gold piles and such

	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)
	mod.class.interface.PlayerLore.init(self, t)

	self.descriptor = self.descriptor or {}
	self.died_times = self.died_times or {}
	self.last_learnt_talents = self.last_learnt_talents or { class={}, generic={} }
	self.puuid = self.puuid or util.uuid()
end

function _M:onBirth(birther)
	-- Make a list of random escort levels
	local race_def = birther.birth_descriptor_def.race[self.descriptor.race]
	local subrace_def = birther.birth_descriptor_def.subrace[self.descriptor.subrace]
	local def = subrace_def.random_escort_possibilities or race_def.random_escort_possibilities
	if def then
		local zones = {}
		for i, zd in ipairs(def) do for j = zd[2], zd[3] do zones[#zones+1] = {zd[1], j} end end
		self.random_escort_levels = {}
		for i = 1, 9 do
			local z = rng.tableRemove(zones)
			print("Random escort on", z[1], z[2])
			self.random_escort_levels[z[1]] = self.random_escort_levels[z[1]] or {}
			self.random_escort_levels[z[1]][z[2]] = true
		end
	end
end

function _M:onEnterLevel(zone, level)
	-- Save where we entered
	self.entered_level = {x=self.x, y=self.y}

	-- mark entrance (if applicable) as noticed
	game.level.map.attrs(self.x, self.y, "noticed", true)

	-- Fire random escort quest
	if self.random_escort_levels and self.random_escort_levels[zone.short_name] and self.random_escort_levels[zone.short_name][level.level] then
		self:grantQuest("escort-duty")
	end

	-- Cancel effects
	local effs = {}
	for eff_id, p in pairs(self.tmp) do
		if self.tempeffect_def[eff_id].cancel_on_level_change then
			effs[#effs+1] = eff_id
			if type(self.tempeffect_def[eff_id].cancel_on_level_change) == "function" then self.tempeffect_def[eff_id].cancel_on_level_change(self, p) end
		end
	end
	for i, eff_id in ipairs(effs) do self:removeEffect(eff_id) end
end

function _M:onEnterLevelEnd(zone, level)

end

function _M:onLeaveLevel(zone, level)
	if self:hasEffect(self.EFF_FEED) then
		self:removeEffect(self.EFF_FEED, true)
	end

	-- Fail past escort quests
	local eid = "escort-duty-"..zone.short_name.."-"..level.level
	if self:hasQuest(eid) and not self:hasQuest(eid):isEnded() then
		local q = self:hasQuest(eid)
		q.abandoned = true
		self:setQuestStatus(eid, q.FAILED)
	end
end

-- Wilderness encounter
function _M:onWorldEncounter(target, x, y)
	if target.on_encounter then
		if x and y and game.level.map(x, y, Map.ACTOR) == target then
			game.level.map:remove(x, y, Map.ACTOR)
		end
		game.state:handleWorldEncounter(target)
	end
end

function _M:describeFloor(x, y)
	if self.old_x == x and self.old_y == y then return end

	-- Autopickup money
	if self:getInven(self.INVEN_INVEN) and not self.no_inventory_access then
		local i, nb = 1, 0
		local obj = game.level.map:getObject(x, y, i)
		while obj do
			local desc = true
			if obj.auto_pickup and self:pickupFloor(i, true) then desc = false end
			if desc and self:attr("has_transmo") and obj.__transmo == nil then
				obj.__transmo_pre = true
				if self:pickupFloor(i, true) then
					desc = false
					if not obj.quest and not obj.plot then obj.__transmo = true end
				end
				obj.__transmo_pre = nil
			end
			if desc then
				if self:attr("auto_id") and obj:getPowerRank() <= self.auto_id then obj:identify(true) end
				nb = nb + 1
				i = i + 1
				game.logSeen(self, "There is an item here: %s", obj:getName{do_color=true})
			end
			obj = game.level.map:getObject(x, y, i)
		end
	end

	local g = game.level.map(x, y, game.level.map.TERRAIN)
	if g and g.change_level then
		game.logPlayer(self, "#YELLOW_GREEN#There is "..g.name:a_an().." here (press '<', '>' or right click to use).")
		local sx, sy = game.level.map:getTileToScreen(x, y)
		game.flyers:add(sx, sy, 60, 0, -1.5, ("Level change (%s)!"):format(g.name), colors.simple(colors.YELLOW_GREEN), true)
	end
end

function _M:move(x, y, force)
	local ox, oy = self.x, self.y
	local moved = mod.class.Actor.move(self, x, y, force)

	if not force and ox == self.x and oy == self.y and self.doPlayerSlide then
		self.doPlayerSlide = nil
		tx, ty = self:tryPlayerSlide(x, y, false)
		if tx then moved = self:move(tx, ty, false) end
	end
	self.doPlayerSlide = nil

	if moved then
		game.level.map:moveViewSurround(self.x, self.y, config.settings.tome.scroll_dist, config.settings.tome.scroll_dist)
		game.level.map.attrs(self.x, self.y, "walked", true)

		if self.describeFloor then self:describeFloor(self.x, self.y) end
	end

--	if not force and ox == self.x and oy == self.y and self.tryPlayerSlide then
--		x, y = self:tryPlayerSlide(x, y, false)
--		self.tryPlayerSlide = false
--		moved = self:move(x, y, false)
--		self.tryPlayerSlide = nil
--	end

	-- Update wilderness coords
	if game.zone.wilderness and not force then
		-- Cheat with time
		game.turn = game.turn + 1000
		self.wild_x, self.wild_y = self.x, self.y
		if self.x ~= ox or self.y ~= oy then
			game.state:worldDirectorAI()
		end
	end

	-- Update zone name
	if game.zone.variable_zone_name then game:updateZoneName() end

	self.old_x, self.old_y = self.x, self.y

	return moved
end

function _M:act()
	if not mod.class.Actor.act(self) then return end

	-- Run out of time ?
	if self.summon_time then
		self.summon_time = self.summon_time - 1
		if self.summon_time <= 0 then
			game.logPlayer(self, "#PINK#Your summoned %s disappears.", self.name)
			self:die()
			return true
		end
	end

	-- Funky shader things !
	self:updateMainShader()

	self.old_life = self.life
	self.old_air = self.air
	self.old_psi = self.psi

	-- Clean log flasher
--	game.flash:empty()

	-- update feed/beckoned immediately before the player moves for best visual consistency (this is not perfect but looks much better than updating mid-move)
	if self:hasEffect(self.EFF_FEED) then
		self.tempeffect_def[self.EFF_FEED].updateFeed(self, self:hasEffect(self.EFF_FEED))
	elseif self:hasEffect(self.EFF_FED_UPON) then
		local fed_upon_eff = self:hasEffect(self.EFF_FED_UPON)

		fed_upon_eff.src.tempeffect_def[fed_upon_eff.src.EFF_FEED].updateFeed(fed_upon_eff.src, fed_upon_eff.src:hasEffect(self.EFF_FEED))
	end

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() and self.player and self:enoughEnergy() then
		game.paused = true
	elseif not self.player then
		self:useEnergy()
	end
end

function _M:tooltip(x, y, seen_by)
	local str = mod.class.Actor.tooltip(self, x, y, seen_by)
	if not str then return end
	if config.settings.cheat then str:add(true, "UID: "..self.uid, true, self.image) end

	return str
end

--- Funky shader stuff
function _M:updateMainShader()
	if game.fbo_shader then
		-- Set shader HP warning
		if self.life ~= self.old_life then
			if self.life < self.max_life / 2 then game.fbo_shader:setUniform("hp_warning", 1 - (self.life / self.max_life))
			else game.fbo_shader:setUniform("hp_warning", 0) end
		end
		-- Set shader air warning
		if self.air ~= self.old_air then
			if self.air < self.max_air / 2 then game.fbo_shader:setUniform("air_warning", 1 - (self.air / self.max_air))
			else game.fbo_shader:setUniform("air_warning", 0) end
		end
		if self:attr("solipsism_threshold") and self.psi ~= self.old_psi then
			local solipsism_power = self:attr("solipsism_threshold") - self:getPsi()/self:getMaxPsi()
			if solipsism_power > 0 then game.fbo_shader:setUniform("solipsism_warning", solipsism_power)
			else game.fbo_shader:setUniform("solipsism_warning", 0) end
		end

		-- Colorize shader
		if self:attr("stealth") and self:attr("stealth") > 0 then game.fbo_shader:setUniform("colorize", {0.9,0.9,0.9,0.6})
		elseif self:attr("invisible") and self:attr("invisible") > 0 then game.fbo_shader:setUniform("colorize", {0.3,0.4,0.9,0.8})
		elseif self:attr("unstoppable") then game.fbo_shader:setUniform("colorize", {1,0.2,0,1})
		elseif self:attr("lightning_speed") then game.fbo_shader:setUniform("colorize", {0.2,0.3,1,1})
		elseif game.level and game.level.data.is_eidolon_plane then game.fbo_shader:setUniform("colorize", {1,1,1,1})
--		elseif game:hasDialogUp() then game.fbo_shader:setUniform("colorize", {0.9,0.9,0.9})
		else game.fbo_shader:setUniform("colorize", {0,0,0,0}) -- Disable
		end

		-- Blur shader
		if self:attr("confused") and self.confused >= 1 then game.fbo_shader:setUniform("blur", 2)
--		elseif game:hasDialogUp() then game.fbo_shader:setUniform("blur", 3)
		else game.fbo_shader:setUniform("blur", 0) -- Disable
		end

		-- Moving Blur shader
		if self:attr("invisible") then game.fbo_shader:setUniform("motionblur", 3)
		elseif self:attr("lightning_speed") then game.fbo_shader:setUniform("motionblur", 2)
		elseif game.level and game.level.data and game.level.data.motionblur then game.fbo_shader:setUniform("motionblur", game.level.data.motionblur)
		else game.fbo_shader:setUniform("motionblur", 0) -- Disable
		end
	end
end

-- Precompute FOV form, for speed
local fovdist = {}
for i = 0, 30 * 30 do
	fovdist[i] = math.max((20 - math.sqrt(i)) / 17, 0.6)
end
local wild_fovdist = {}
for i = 0, 10 * 10 do
	wild_fovdist[i] = math.max((5 - math.sqrt(i)) / 1.4, 0.6)
end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()

	-- Do wilderness stuff, nothing else
	if game.zone.wilderness then
		self:computeFOV(game.zone.wilderness_see_radius, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y, wild_fovdist[sqdist]) end, true, true, true)
		return
	end

	-- Compute ESP FOV, using cache
	if (self.esp_all and self.esp_all > 0) or next(self.esp) then
		self:computeFOV(self.esp_range or 10, "block_esp", function(x, y) game.level.map:applyESP(x, y, 0.6) end, true, true, true)
	end

	-- Handle Sense spell, a simple FOV, using cache. Note that this means some terrain features can be made to block sensing
	if self:attr("detect_range") then
		self:computeFOV(self:attr("detect_range"), "block_sense", function(x, y)
			local ok = false
			if self:attr("detect_actor") and game.level.map(x, y, game.level.map.ACTOR) then ok = true end
			if self:attr("detect_object") and game.level.map(x, y, game.level.map.OBJECT) then ok = true end
			if self:attr("detect_trap") and game.level.map(x, y, game.level.map.TRAP) then
				game.level.map(x, y, game.level.map.TRAP):setKnown(self, true)
				game.level.map:updateMap(x, y)
				ok = true
			end

			if ok then
				if self.detect_function then self.detect_function(self, x, y) end
				game.level.map.seens(x, y, 0.6)
			end
		end, true, true, true)
	end

	-- Handle arcane eye
	if self:hasEffect(self.EFF_ARCANE_EYE) then
		local eff = self:hasEffect(self.EFF_ARCANE_EYE)
		local map = game.level.map

		core.fov.calc_circle(
			eff.x, eff.y, game.level.map.w, game.level.map.h, eff.radius, function(_, x, y) if map:checkAllEntities(x, y, "block_sight", self) then return true end end,
			function(_, x, y)
				local t = map(x, y, map.ACTOR)
				if t and (eff.true_seeing or self:canSee(t)) then
					map.seens(x, y, 1)
					if self.can_see_cache[t] then self.can_see_cache[t]["nil/nil"] = {true, 100} end
					if t ~= self then t:setEffect(t.EFF_ARCANE_EYE_SEEN, 1, {src=self, true_seeing=eff.true_seeing}) end
				end
			end,
			cache and map._fovcache["block_sight"]
		)
	end

	-- Handle Preternatural Senses talent, a simple FOV, using cache.
	if self:knowTalent(self.T_PRETERNATURAL_SENSES) then
		local t = self:getTalentFromId(self.T_PRETERNATURAL_SENSES)
		local range = self:getTalentRange(t)
		self:computeFOV(range, "block_sense", function(x, y)
			if game.level.map(x, y, game.level.map.ACTOR) then
				game.level.map.seens(x, y, 0.6)
			end
		end, true, true, true)

		local effStalker = self:hasEffect(self.EFF_STALKER)
		if effStalker then
			if core.fov.distance(self.x, self.y, effStalker.target.x, effStalker.target.y) <= 10 then
				game.level.map.seens(effStalker.target.x, effStalker.target.y, 0.6)
			end
		end
	end

	if not self:attr("blind") then
		-- Handle dark vision; same as infravision, but also sees past creeping dark
		-- this is treated as a sense, but is filtered by custom LOS code
		if self:knowTalent(self.T_DARK_VISION) then
			local t = self:getTalentFromId(self.T_DARK_VISION)
			local range = self:getTalentRange(t)
			self:computeFOV(range, "block_sense", function(x, y)
				local actor = game.level.map(x, y, game.level.map.ACTOR)
				if actor and self:hasLOS(x, y) then
					game.level.map.seens(x, y, 0.6)
				end
			end, true, true, true)
		end

		-- Overseer of Nations bonus
		local bonus = 0
		if self:knowTalent(self.T_OVERSEER_OF_NATIONS) then
			bonus = math.ceil(self:getTalentLevelRaw(self.T_OVERSEER_OF_NATIONS)/2)
		end

		-- Handle infravision/heightened_senses which allow to see outside of lite radius but with LOS
		if self:attr("infravision") or self:attr("heightened_senses") then
			local radius = math.max((self.heightened_senses or 0), (self.infravision or 0))
			radius = math.min(radius + bonus, self.sight)
			local rad2 = math.max(1, math.floor(radius / 4))
			self:computeFOV(radius, "block_sight", function(x, y, dx, dy, sqdist) if game.level.map(x, y, game.level.map.ACTOR) then game.level.map.seens(x, y, fovdist[sqdist]) end end, true, true, true)
			self:computeFOV(rad2, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y, fovdist[sqdist]) end, true, true, true)
		end

		-- Compute both the normal and the lite FOV, using cache
		-- Do it last so it overrides others
		self:computeFOV(self.sight or 10, "block_sight", function(x, y, dx, dy, sqdist)
			game.level.map:apply(x, y, fovdist[sqdist])
		end, true, false, true)
		if self.lite <= 0 then game.level.map:applyLite(self.x, self.y)
		else self:computeFOV(self.lite + bonus, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true) end

		-- For each entity, generate lite
		local uid, e = next(game.level.entities)
		while uid do
			if e ~= self and e.lite and e.lite > 0 and e.computeFOV then
				e:computeFOV(e.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyExtraLite(x, y, fovdist[sqdist]) end, true, true)
			end
			uid, e = next(game.level.entities, uid)
		end
	-- Inner Sight; works even while blinded
	elseif self:attr("blind_sight") then
		self:computeFOV(self:attr("blind_sight"), "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y, 0.6) end, true, true, true)
	end
end

function _M:doFOV()
	self:playerFOV()
end

--- Create a line to target based on field of vision
function _M:lineFOV(tx, ty, extra_block, block, sx, sy)
	sx = sx or self.x
	sy = sy or self.y
	local act = game.level.map(x, y, Map.ACTOR)
	local sees_target = game.level.map.seens(tx, ty)

	local darkVisionRange
	if self:knowTalent(self.T_DARK_VISION) then
		local t = self:getTalentFromId(self.T_DARK_VISION)
		darkVisionRange = self:getTalentRange(t)
	end
	local inCreepingDark = false

	extra_block = type(extra_block) == "function" and extra_block
		or type(extra_block) == "string" and function(_, x, y) return game.level.map:checkAllEntities(x, y, extra_block) end

	block = block or function(_, x, y)
		if darkVisionRange then
			if game.level.map:checkAllEntities(x, y, "creepingDark") then
				inCreepingDark = true
			end
			if inCreepingDark and core.fov.distance(sx, sy, x, y) > darkVisionRange then
				return true
			end
		end

		if sees_target then
			return game.level.map:checkAllEntities(x, y, "block_sight") or
				game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
				extra_block and extra_block(self, x, y)
		elseif core.fov.distance(sx, sy, x, y) <= self.sight and (game.level.map.remembers(x, y) or game.level.map.seens(x, y)) then
			return game.level.map:checkEntity(x, y, Map.TERRAIN, "block_sight") or
				game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, engine.Map.TERRAIN, "pass_projectile") or
				extra_block and extra_block(self, x, y)
		else
			return true
		end
	end

	return core.fov.line(sx, sy, tx, ty, block)
end

--- Called before taking a hit, overload mod.class.Actor:onTakeHit() to stop resting and running
function _M:onTakeHit(value, src)
	self:runStop("taken damage")
	self:restStop("taken damage")
	local ret = mod.class.Actor.onTakeHit(self, value, src)
	if self.life < self.max_life * 0.3 then
		local sx, sy = game.level.map:getTileToScreen(self.x, self.y)
		game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, 2, "LOW HEALTH!", {255,0,0}, true)
	end

	-- Hit direction warning
	if src.x and src.y and (self.x ~= src.x or self.y ~= src.y) then
		local range = core.fov.distance(src.x, src.y, self.x, self.y)
		if range > 1 then
			local angle = math.atan2(src.y - self.y, src.x - self.x)
			game.level.map:particleEmitter(self.x, self.y, 1, "hit_warning", {angle=math.deg(angle)})
		end
	end

	return ret
end

function _M:on_set_temporary_effect(eff_id, e, p)
	mod.class.Actor.on_set_temporary_effect(self, eff_id, e, p)

	if e.status == "detrimental" and not e.no_stop_resting then
		self:runStop("detrimental status effect")
		self:restStop("detrimental status effect")
	end
end

function _M:heal(value, src)
	-- Difficulty settings
	if game.difficulty == game.DIFFICULTY_EASY then
		value = value * 1.3
	end

	mod.class.Actor.heal(self, value, src)
end

function _M:die(src, death_note)
	self:runStop("died")
	self:restStop("died")

	return self:onPartyDeath(src, death_note)
end

--- Suffocate a bit, lose air
function _M:suffocate(value, src, death_msg)
	local dead, affected = mod.class.Actor.suffocate(self, value, src, death_msg)
	if affected and value > 0 and self.runStop then
		self:runStop("suffocating")
		self:restStop("suffocating")
	end
	return dead, affected
end

function _M:onChat()
	self:runStop("chat started")
	self:restStop("chat started")
end

function _M:setName(name)
	self.name = name
	game.save_name = name
end

--- Notify the player of available cooldowns
function _M:onTalentCooledDown(tid)
	if not self:knowTalent(tid) then return end
	local t = self:getTalentFromId(tid)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 30, -0.3, -3.5, ("%s available"):format(t.name:capitalize()), {0,255,00})
	game.log("#00ff00#%sTalent %s is ready to use.", (t.display_entity and t.display_entity:getDisplayString() or ""), t.name)
end

--- Tries to get a target from the user
function _M:getTarget(typ)
	if self:attr("encased_in_ice") then
		if type(typ) ~= "table" then
			return self.x, self.y, self
		end
		local orig_range = typ.range
		typ.range = 0
		local x, y, act = game:targetGetForPlayer(typ)
		typ.range = orig_range
		if x then
			return self.x, self.y, self
		else
			return
		end
	else
		return game:targetGetForPlayer(typ)
	end
end

--- Sets the current target
function _M:setTarget(target)
	return game:targetSetForPlayer(target)
end

local function spotHostiles(self)
	local seen = {}
	if not self.x then return seen end

	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, self.sight or 10, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then
			seen[#seen + 1] = {x=x,y=y,actor=actor}
		end
	end, nil)
	return seen
end

--- We started resting
function _M:onRestStart()
	if self.resting and self:attr("equilibrium_regen_on_rest") and not self.resting.equilibrium_regen then
		self:attr("equilibrium_regen", self:attr("equilibrium_regen_on_rest"))
		self.resting.equilibrium_regen = self:attr("equilibrium_regen_on_rest")
	end
end

--- We stopped resting
function _M:onRestStop()
	if self.resting and self.resting.equilibrium_regen then
		self:attr("equilibrium_regen", -self.resting.equilibrium_regen)
		self.resting.equilibrium_regen = nil
	end
end

--- Can we continue resting ?
-- We can rest if no hostiles are in sight, and if we need life/mana/stamina/psi (and their regen rates allows them to fully regen)
function _M:restCheck()
	local spotted = spotHostiles(self)
	if #spotted > 0 then
		for _, node in ipairs(spotted) do
			node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
		end
		return false, ("hostile spotted (%s%s)"):format(spotted[1].actor.name, game.level.map:isOnScreen(spotted[1].x, spotted[1].y) and "" or " - offscreen")
	end

	-- Resting improves regen
	for act, def in pairs(game.party.members) do if game.level:hasEntity(act) and not act.dead then
		local perc = math.min(self.resting.cnt / 10, 8)
		local old_shield = act.arcane_shield
		act.arcane_shield = nil
		act:heal(act.life_regen * perc)
		act.arcane_shield = old_shield
		act:incStamina(act.stamina_regen * perc)
		act:incMana(act.mana_regen * perc)
		act:incPsi(act.psi_regen * perc)
	end end

	-- Reload
	local ammo = self:hasAmmo()
	if self.resting.cnt == 0 and ammo and ammo.combat.shots_left < ammo.combat.capacity and not self:hasEffect(self.EFF_RELOADING) and self:knowTalent(self.T_RELOAD) then
		self:forceUseTalent(self.T_RELOAD, {ignore_energy=true})
	end

	-- Check resources, make sure they CAN go up, otherwise we will never stop
	if not self.resting.rest_turns then
		if self.air_regen < 0 then return false, "losing breath!" end
		if self.life_regen <= 0 then return false, "losing health!" end
		if self:getMana() < self:getMaxMana() and self.mana_regen > 0 then return true end
		if self:getStamina() < self:getMaxStamina() and self.stamina_regen > 0 then return true end
		if self:getPsi() < self:getMaxPsi() and self.psi_regen > 0 then return true end
		if self:getEquilibrium() > self:getMinEquilibrium() and self.equilibrium_regen < 0 then return true end
		if self:getParadox() > 0 and self:getParadox() > self.min_paradox and self:isTalentActive(self.T_SPACETIME_TUNING) then return true end
		if self.life < self.max_life and self.life_regen> 0 then return true end
		for act, def in pairs(game.party.members) do if game.level:hasEntity(act) and not act.dead then
			if act.life < act.max_life and act.life_regen> 0 then return true end
		end end

		if ammo and ammo.combat.shots_left < ammo.combat.capacity and ((self:hasEffect(self.EFF_RELOADING)) or (ammo.combat.ammo_every and ammo.combat.ammo_every > 0)) then return true end
	else
		return true
	end

	-- Enter cooldown waiting rest if we are at max already
	if self.resting.cnt == 0 then
		self.resting.wait_cooldowns = true
	end

	if self.resting.wait_cooldowns then
		for tid, cd in pairs(self.talents_cd) do
			if self:isTalentActive(self.T_CONDUIT) and (tid == self.T_KINETIC_AURA or tid == self.T_CHARGED_AURA or tid == self.T_THERMAL_AURA) then
				-- nothing
			elseif self.talents_auto[tid] then
				-- nothing
			else
				if cd > 0 then return true end
			end
		end
	end

	self.resting.wait_cooldowns = nil

	-- Enter recall waiting rest if we are at max already
	if self.resting.cnt == 0 and self:hasEffect(self.EFF_RECALL) then
		self.resting.wait_recall = true
	end

	if self.resting.wait_recall then
		if self:hasEffect(self.EFF_RECALL) then
			return true
		end
	end

	self.resting.wait_recall = nil

	return false, "all resources and life at maximum"
end

--- Can we continue running?
-- We can run if no hostiles are in sight, and if no interesting terrain or characters are next to us.
-- Known traps aren't interesting.  We let the engine run around traps, or stop if it can't.
-- 'ignore_memory' is only used when checking for paths around traps.  This ensures we don't remember items "obj_seen" that we aren't supposed to
function _M:runCheck(ignore_memory)
	local spotted = spotHostiles(self)
	if #spotted > 0 then return false, ("hostile spotted (%s%s)"):format(spotted[1].actor.name, game.level.map:isOnScreen(spotted[1].x, spotted[1].y) and "" or " - offscreen") end

	if self.air_regen < 0 then return false, "losing breath!" end

	-- Notice any noticeable terrain
	local noticed = false
	self:runScan(function(x, y, what)
		-- Objects are always interesting, only on curent spot
		if what == "self" and not game.level.map.attrs(x, y, "obj_seen") then
			local obj = game.level.map:getObject(x, y, 1)
			if obj then
				noticed = "object seen"
				if not ignore_memory then game.level.map.attrs(x, y, "obj_seen", true) end
				return
			end
		end

		-- Only notice interesting terrains, but allow auto-explore and A* to take us to the exit.  Auto-explore can also take us through "safe" doors
		local grid = game.level.map(x, y, Map.TERRAIN)
		if grid and grid.notice and not (self.running and self.running.path and (game.level.map.attrs(x, y, "noticed")
				or (what ~= self and (self.running.explore and grid.door_opened                     -- safe door
				or #self.running.path == self.running.cnt and (self.running.explore == "exit"       -- auto-explore onto exit
				or not self.running.explore and grid.change_level))                                 -- A* onto exit
				or #self.running.path - self.running.cnt < 2 and (self.running.explore == "portal"  -- auto-explore onto portal
				or not self.running.explore and grid.orb_portal)                                    -- A* onto portal
				or self.running.cnt < 3 and grid.orb_portal and                                     -- path from portal
				game.level.map:checkEntity(self.running.path[1].x, self.running.path[1].y, Map.TERRAIN, "orb_portal"))))
		then
			if self.running and self.running.explore and self.running.path and self.running.explore ~= "unseen" and self.running.cnt == #self.running.path + 1 then
				noticed = "at " .. self.running.explore
			else
				noticed = "interesting terrain"
			end
			-- let's only remember and ignore standard interesting terrain
			if not ignore_memory and (grid.change_level or grid.orb_portal) then game.level.map.attrs(x, y, "noticed", true) end
			return
		end
		if grid and grid.type and grid.type == "store" then noticed = "store entrance spotted"; return end

		-- Only notice interesting characters
		local actor = game.level.map(x, y, Map.ACTOR)
		if actor and actor.can_talk then noticed = "interesting character"; return end

		-- We let the engine take care of traps, but we should still notice "trap" stores.
		if game.level.map:checkAllEntities(x, y, "store") then noticed = "store entrance spotted"; return end
	end)
	if noticed then return false, noticed end

	return engine.interface.PlayerRun.runCheck(self)
end

--- Move with the mouse
-- We just feed our spotHostile to the interface mouseMove
function _M:mouseMove(tmx, tmy, force_move)
	local astar_check = function(x, y)
		-- Dont do traps
		local trap = game.level.map(x, y, Map.TRAP)
		if trap and trap:knownBy(self) and trap:canTrigger(x, y, self, true) then return false end

		-- Dont go where you cant breath
		if not self:attr("no_breath") then
			local air_level, air_condition = game.level.map:checkEntity(x, y, Map.TERRAIN, "air_level"), game.level.map:checkEntity(x, y, Map.TERRAIN, "air_condition")
			if air_level then
				if not air_condition or not self.can_breath[air_condition] or self.can_breath[air_condition] <= 0 then
					return false
				end
			end
		end
		return true
	end
	return engine.interface.PlayerMouse.mouseMove(self, tmx, tmy, function() local spotted = spotHostiles(self) ; return #spotted > 0 end, {recheck=true, astar_check=astar_check}, force_move)
end

--- Called after running a step
function _M:runMoved()
	self:playerFOV()
	if self.running and self.running.explore then
		game.level.map:particleEmitter(self.x, self.y, 1, "dust_trail")
	end
	-- Autoreload on Auto-explore
	local ammo = self:hasAmmo()
	if self.running and self.running.explore and ammo and ammo.combat.shots_left < ammo.combat.capacity and not self:hasEffect(self.EFF_RELOADING) and self:knowTalent(self.T_RELOAD) then
		self:forceUseTalent(self.T_RELOAD, {ignore_energy=true})
	end
end

--- Called after stopping running
function _M:runStopped()
	game.level.map.clean_fov = true
	self:playerFOV()
	local spotted = spotHostiles(self)
	if #spotted > 0 then
		for _, node in ipairs(spotted) do
			node.actor:addParticles(engine.Particles.new("notice_enemy", 1))
		end
	end

	-- if you stop at an object (such as on a trap), then mark it as seen
	local obj = game.level.map:getObject(x, y, 1)
	if obj then game.level.map.attrs(x, y, "obj_seen", true) end
end

--- Activates a hotkey with a type "inventory"
function _M:hotkeyInventory(name)
	local find = function(name)
		local os = {}
		-- Sort invens, use worn first
		local invens = {}
		for inven_id, inven in pairs(self.inven) do
			invens[#invens+1] = {inven_id, inven}
		end
		table.sort(invens, function(a,b) return (a[2].worn and 1 or 0) > (b[2].worn and 1 or 0) end)
		for i = 1, #invens do
			local inven_id, inven = unpack(invens[i])
			local o, item = self:findInInventory(inven, name, {no_count=true, force_id=true, no_add_name=true})
			if o and item then os[#os+1] = {o, item, inven_id, inven} end
		end
		if #os == 0 then return end
		table.sort(os, function(a, b) return (a[4].use_speed or 1) < (b[4].use_speed or 1) end)
		return os[1][1], os[1][2], os[1][3]
	end

	local o, item, inven = find(name)
	if not o then
		Dialog:simplePopup("Item not found", "You do not have any "..name..".")
	else
		-- Wear it ??
		if o:wornInven() and not o.wielded and inven == self.INVEN_INVEN then
			if not o.use_no_wear then
				self:doWear(inven, item, o)
				return
			end
		end
		self:playerUseItem(o, item, inven)
	end
end

function _M:doDrop(inven, item, on_done)
	if game.zone.wilderness then
		Dialog:yesnoLongPopup("Warning", "You cannot drop items on the world map.\nIf you drop it, it will be lost forever.", 300, function(ret)
			-- The test is reversed because the buttons are reversed, to prevent mistakes
			if not ret then
				local o = self:removeObject(inven, item, true)
				game.logPlayer(self, "You destroy %s.", o:getName{do_colour=true, do_count=true})
				self:sortInven()
				self:useEnergy()
				if on_done then on_done() end
			end
		end, "Cancel", "Destroy")
		return
	end
	self:dropFloor(inven, item, true, true)
	self:sortInven(inven)
	self:useEnergy()
	self.changed = true
	game:playSound("actions/drop")
	if on_done then on_done() end
end

function _M:doWear(inven, item, o)
	self:removeObject(inven, item, true)
	local ro = self:wearObject(o, true, true)
	if ro then
		self:useEnergy()
		if type(ro) == "table" then self:addObject(inven, ro) end
	elseif not ro then
		self:addObject(inven, o)
	end
	self:sortInven()
	self:playerCheckSustains()
	self.changed = true
end

function _M:doTakeoff(inven, item, o, simple)
	if self:takeoffObject(inven, item) then
		self:addObject(self.INVEN_INVEN, o)
	end
	if not simple then
		self:sortInven()
		self:useEnergy()
	end
	self:playerCheckSustains()
	self.changed = true
end

function _M:getEncumberTitleUpdator(title)
	return function()
		local enc, max = self:getEncumbrance(), self:getMaxEncumbrance()
		local color = "#00ff00#"
		if enc > max then color = "#ff0000#"
		elseif enc > max * 0.9 then color = "#ff8a00#"
		elseif enc > max * 0.75 then color = "#fcff00#"
		end
		return ("%s - %sEncumberance %d/%d"):format(title, color, enc, max)
	end
end

function _M:playerPickup()
	-- If 2 or more objects, display a pickup dialog, otherwise just picks up
	if game.level.map:getObject(self.x, self.y, 2) then
		local titleupdator = self:getEncumberTitleUpdator("Pickup")
		local d d = self:showPickupFloor(titleupdator(), nil, function(o, item)
			local o = self:pickupFloor(item, true)
			if o and type(o) == "table" then o.__new_pickup = true end
			self.changed = true
			d:updateTitle(titleupdator())
			d:used()
		end)
	else
		local o = self:pickupFloor(1, true)
		self:sortInven()
		if o and type(o) == "table" then
			self:useEnergy()
			o.__new_pickup = true
		end
		self.changed = true
	end
end

function _M:playerDrop()
	local inven = self:getInven(self.INVEN_INVEN)
	local titleupdator = self:getEncumberTitleUpdator("Drop object")
	local d d = self:showInventory(titleupdator(), inven, nil, function(o, item)
		self:doDrop(inven, item)
		d:updateTitle(titleupdator())
		return true
	end)
end

function _M:playerWear()
	local inven = self:getInven(self.INVEN_INVEN)
	local titleupdator = self:getEncumberTitleUpdator("Wield/wear object")
	local d d = self:showInventory(titleupdator(), inven, function(o)
		return o:wornInven() and self:getInven(o:wornInven()) and true or false
	end, function(o, item)
		self:doWear(inven, item, o)
		d:updateTitle(titleupdator())
		return true
	end)
end

function _M:playerTakeoff()
	local titleupdator = self:getEncumberTitleUpdator("Take off object")
	local d d = self:showEquipment(titleupdator(), nil, function(o, inven, item)
		self:doTakeoff(inven, item, o)
		d:updateTitle(titleupdator())
		return true
	end)
end

function _M:playerUseItem(object, item, inven)
	if game.zone.wilderness then game.logPlayer(self, "You cannot use items on the world map.") return end

	local use_fct = function(o, inven, item)
		if not o then return end
		local co = coroutine.create(function()
			self.changed = true

			-- Count magic devices
			if (o.power_source and o.power_source.arcane) and self:attr("forbid_arcane") then
				game.logPlayer(self, "Your antimagic disrupts %s.", o:getName{no_count=true, do_color=true})
				return true
			end

			local ret = o:use(self, nil, inven, item) or {}
			if not ret.used then return end
			if ret.id then
				o:identify(true)
			end
			if ret.destroy then
				if o.multicharge and o.multicharge > 1 then
					o.multicharge = o.multicharge - 1
				else
					local _, del = self:removeObject(self:getInven(inven), item)
					if del then
						game.log("You have no more %s.", o:getName{no_count=true, do_color=true})
					else
						game.log("You have %s.", o:getName{do_color=true})
					end
					self:sortInven(self:getInven(inven))
				end
				self:breakStepUp()
				self:breakStealth()
				self:breakLightningSpeed()
				self:breakPsionicChannel()
				return true
			end

			self:breakStepUp()
			self:breakStealth()
			self:breakLightningSpeed()
			self:breakReloading()
			self:breakPsionicChannel()
			self.changed = true
		end)
		local ok, ret = coroutine.resume(co)
		if not ok and ret then print(debug.traceback(co)) error(ret) end
		return true
	end

	if object and item then return use_fct(object, inven, item) end

	local titleupdator = self:getEncumberTitleUpdator("Use object")
	self:showEquipInven(titleupdator(),
		function(o)
			return o:canUseObject()
		end,
		use_fct
	)
end

function _M:quickSwitchWeapons()
	local mh1, mh2 = self.inven[self.INVEN_MAINHAND], self.inven[self.INVEN_QS_MAINHAND]
	local oh1, oh2 = self.inven[self.INVEN_OFFHAND], self.inven[self.INVEN_QS_OFFHAND]
	local pf1, pf2 = self.inven[self.INVEN_PSIONIC_FOCUS], self.inven[self.INVEN_QS_PSIONIC_FOCUS]
	local qv1, qv2 = self.inven[self.INVEN_QUIVER], self.inven[self.INVEN_QS_QUIVER]

	if not mh1 or not mh2 or not oh1 or not oh2 then return end

	-- Do not reset power of switched items
	self.no_power_reset_on_wear = true

	-- Check for free weapon swaps
	local free_swap = false
	if self:knowTalent(self.T_CELERITY) or self:attr("quick_weapon_swap") then free_swap = true end

	local mhset1, mhset2 = {}, {}
	local ohset1, ohset2 = {}, {}
	local pfset1, pfset2 = {}, {}
	local qvset1, qvset2 = {}, {}
	-- Remove them all
	for i = #mh1, 1, -1 do mhset1[#mhset1+1] = self:removeObject(mh1, i, true) end
	for i = #mh2, 1, -1 do mhset2[#mhset2+1] = self:removeObject(mh2, i, true) end
	for i = #oh1, 1, -1 do ohset1[#ohset1+1] = self:removeObject(oh1, i, true) end
	for i = #oh2, 1, -1 do ohset2[#ohset2+1] = self:removeObject(oh2, i, true) end
	if pf1 and pf2 then
		for i = #pf1, 1, -1 do pfset1[#pfset1+1] = self:removeObject(pf1, i, true) end
		for i = #pf2, 1, -1 do pfset2[#pfset2+1] = self:removeObject(pf2, i, true) end
	end
	if qv1 and qv2 then
		for i = #qv1, 1, -1 do qvset1[#qvset1+1] = self:removeObject(qv1, i, true) end
		for i = #qv2, 1, -1 do qvset2[#qvset2+1] = self:removeObject(qv2, i, true) end
	end
	-- Put them all back
	for i = 1, #mhset1 do self:addObject(mh2, mhset1[i]) end
	for i = 1, #mhset2 do self:addObject(mh1, mhset2[i]) end
	for i = 1, #ohset1 do self:addObject(oh2, ohset1[i]) end
	for i = 1, #ohset2 do self:addObject(oh1, ohset2[i]) end
	if pf1 and pf2 then
		for i = 1, #pfset1 do self:addObject(pf2, pfset1[i]) end
		for i = 1, #pfset2 do self:addObject(pf1, pfset2[i]) end
	end
	if qv1 and qv2 then
		for i = 1, #qvset1 do self:addObject(qv2, qvset1[i]) end
		for i = 1, #qvset2 do self:addObject(qv1, qvset2[i]) end
	end
	if free_swap == false then self:useEnergy() end
	local names = ""
	if pf1 and pf2 then
		if not pf1[1] then
			if mh1[1] and oh1[1] then names = mh1[1]:getName{do_color=true}.." and "..oh1[1]:getName{do_color=true}
			elseif mh1[1] and not oh1[1] then names = mh1[1]:getName{do_color=true}
			elseif not mh1[1] and oh1[1] then names = oh1[1]:getName{do_color=true}
			end
		else
			if mh1[1] and oh1[1] then names = mh1[1]:getName{do_color=true}.." and "..oh1[1]:getName{do_color=true}.." and "..pf1[1]:getName{do_color=true}
			elseif mh1[1] and not oh1[1] then names = mh1[1]:getName{do_color=true}.." and "..pf1[1]:getName{do_color=true}
			elseif not mh1[1] and oh1[1] then names = oh1[1]:getName{do_color=true}.." and "..pf1[1]:getName{do_color=true}
			end
		end
	else
		if mh1[1] and oh1[1] then names = mh1[1]:getName{do_color=true}.." and "..oh1[1]:getName{do_color=true}
		elseif mh1[1] and not oh1[1] then names = mh1[1]:getName{do_color=true}
		elseif not mh1[1] and oh1[1] then names = oh1[1]:getName{do_color=true}
		end
	end

	self.no_power_reset_on_wear = nil

	self:playerCheckSustains()

	game.logPlayer(self, "You switch your weapons to: %s.", names)
	self.off_weapon_slots = not self.off_weapon_slots
	self.changed = true
end

--- Call when an object is worn
-- This doesnt call the base interface onWear, it copies the code because we need some tricky stuff
function _M:onWear(o, bypass_set)
	mod.class.Actor.onWear(self, o, bypass_set)

	if not self.no_power_reset_on_wear then
		o:forAllStack(function(so)
			if so.power and so:attr("power_regen") then so.power = 0 end
			if so.talent_cooldown then self.talents_cd[so.talent_cooldown] = math.max(self.talents_cd[so.talent_cooldown] or 0, math.min(4, math.floor((so.use_power or so.use_talent or {power=10}).power / 5))) end
		end)
	end
end

-- Go through all sustained talents and turn them off if pre_use fails
function _M:playerCheckSustains()
	for tid, _ in pairs(self.talents) do
		local t = self:getTalentFromId(tid)
		if t.mode == "sustained" and self:isTalentActive(t.id) then
			-- handles unarmed
			if t.is_unarmed and (self:hasMassiveArmor() or not self:isUnarmed()) then
				self:forceUseTalent(tid, {ignore_energy=true})
			end
			-- handles pre_use checks
			if t.on_pre_use and not t.on_pre_use(self, t, silent, fake) then
				self:forceUseTalent(tid, {ignore_energy=true})
			end
		end
	end
end

function _M:playerLevelup(on_finish, on_birth)
	local LevelupDialog = require "mod.dialogs.LevelupDialog"
	local ds = LevelupDialog.new(self, on_finish, on_birth)
	game:registerDialog(ds)
end

--- Use a portal with the orb of many ways
function _M:useOrbPortal(portal)
	if portal.special then portal:special(self) return end

	local spotted = spotHostiles(self)
	if #spotted > 0 then game.logPlayer(self, "You can not use the Orb with foes in sight.") return end

	if portal.on_preuse then portal:on_preuse(self) end

	if portal.nothing then -- nothing
	elseif portal.teleport_level then
		local x, y = util.findFreeGrid(portal.teleport_level.x, portal.teleport_level.y, 2, true, {[Map.ACTOR]=true})
		if x and y then self:move(x, y, true) end
	else
		if portal.change_wilderness then
			if portal.change_wilderness.spot then
				game:onLevelLoad(portal.change_wilderness.level_name or (portal.change_zone.."-"..portal.change_level), function(zone, level, spot)
					local spot = level:pickSpot(spot)
					game.player.wild_x = spot and spot.x or 0
					game.player.wild_y = spot and spot.y or 0
				end, portal.change_wilderness.spot)
			else
				self.wild_x = portal.change_wilderness.x or 0
				self.wild_y = portal.change_wilderness.y or 0
			end
		end
		game:changeLevel(portal.change_level, portal.change_zone)

		if portal.after_zone_teleport then
			self:move(portal.after_zone_teleport.x, portal.after_zone_teleport.y, true)
			for e, _ in pairs(game.party.members) do if e ~= self then
				local x, y = util.findFreeGrid(portal.after_zone_teleport.x, portal.after_zone_teleport.y, 10, true, {[Map.ACTOR]=true})
				if x then e:move(x, y, true) end
			end end
		end
	end

	if portal.message then game.logPlayer(self, portal.message) end
	if portal.on_use then portal:on_use(self) end
	self.energy.value = self.energy.value + game.energy_to_act
end

--- Use the orbs of command
function _M:useCommandOrb(o)
	local g = game.level.map(self.x, self.y, Map.TERRAIN)
	if not g then return end
	if not g.define_as or not o.define_as or o.define_as ~= g.define_as then
		game.logPlayer(self, "This does not seem to have any effect.")
		return
	end

	if g.orb_command then
		g.orb_command:special(self)
		return
	end

	game.logPlayer(self, "You use the %s on the pedestal. There is a distant 'clonk' sound.", o:getName{do_colour=true})
	self:grantQuest("orb-command")
	self:setQuestStatus("orb-command", engine.Quest.COMPLETED, o.define_as)
end

--- Notify of object pickup
function _M:on_pickup_object(o)
	if self:attr("auto_id") and o:getPowerRank() <= self.auto_id then
		o:identify(true)
	end
	if o.pickup_sound then game:playSound(o.pickup_sound) end
end

--- Tell us when we are targeted
function _M:on_targeted(act)
	if self:attr("invisible") or self:attr("stealth") then
		if self:canSee(act) and game.level.map.seens(act.x, act.y) then
			game.logPlayer(self, "#LIGHT_RED#%s has seen you!", act.name:capitalize())
		else
			game.logPlayer(self, "#LIGHT_RED#Something has seen you!")
		end
	end
end

------ Quest Events
function _M:on_quest_grant(quest)
	game.logPlayer(game.player, "#LIGHT_GREEN#Accepted quest '%s'! #WHITE#(Press 'j' to see the quest log)", quest.name)
	game.bignews:say(60, "#LIGHT_GREEN#Accepted quest '%s'!", quest.name)
end

function _M:on_quest_status(quest, status, sub)
	if sub then
		game.logPlayer(game.player, "#LIGHT_GREEN#Quest '%s' status updated! #WHITE#(Press 'j' to see the quest log)", quest.name)
		game.bignews:say(60, "#LIGHT_GREEN#Quest '%s' updated!", quest.name)
	elseif status == engine.Quest.COMPLETED then
		game.logPlayer(game.player, "#LIGHT_GREEN#Quest '%s' completed! #WHITE#(Press 'j' to see the quest log)", quest.name)
		game.bignews:say(60, "#LIGHT_GREEN#Quest '%s' completed!", quest.name)
	elseif status == engine.Quest.DONE then
		game.logPlayer(game.player, "#LIGHT_GREEN#Quest '%s' is done! #WHITE#(Press 'j' to see the quest log)", quest.name)
		game.bignews:say(60, "#LIGHT_GREEN#Quest '%s' done!", quest.name)
	elseif status == engine.Quest.FAILED then
		game.logPlayer(game.player, "#LIGHT_RED#Quest '%s' is failed! #WHITE#(Press 'j' to see the quest log)", quest.name)
		game.bignews:say(60, "#LIGHT_RED#Quest '%s' failed!", quest.name)
	end
end

function _M:attackOrMoveDir(dir)
	local game_or_player = not config.settings.tome.actor_based_movement_mode and game or self
	local tmp = game_or_player.bump_attack_disabled

	game_or_player.bump_attack_disabled = false
	self:moveDir(dir)
	game_or_player.bump_attack_disabled = tmp
end
