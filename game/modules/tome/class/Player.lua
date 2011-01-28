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
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerHotkeys"
require "engine.interface.PlayerSlide"
require "engine.interface.PlayerMouse"
require "mod.class.interface.PlayerStats"
require "mod.class.interface.PlayerLore"
require "mod.class.interface.PlayerDumpJSON"
require "mod.class.interface.PartyDeath"
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"
local LevelupStatsDialog = require "mod.dialogs.LevelupStatsDialog"
local LevelupTalentsDialog = require "mod.dialogs.LevelupTalentsDialog"

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
	mod.class.interface.PartyDeath
))

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
	t.ai_state = t.ai_state or {talent_in=1, ai_move="move_astar", tactic_follow_leader=true}

	if t.fixed_rating == nil then t.fixed_rating = true end

	-- Dont give free resists & higher stat max to players
	t.resists_cap = t.resists_cap or {}

	t.lite = t.lite or 0

	t.rank = t.rank or 3
	t.old_life = 0

	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)
	mod.class.interface.PlayerLore.init(self, t)

	self.descriptor = self.descriptor or {}
	self.died_times = self.died_times or {}
end

function _M:onBirth(birther)
	-- Make a list of random escort levels
	local race_def = birther.birth_descriptor_def.race[self.descriptor.race]
	if race_def.random_escort_possibilities then
		local zones = {}
		for i, zd in ipairs(race_def.random_escort_possibilities) do for j = zd[2], zd[3] do zones[#zones+1] = {zd[1], j} end end
		self.random_escort_levels = {}
		for i = 1, 9 do
			local z = rng.tableRemove(zones)
			print("Random escort on", z[1], z[2])
			self.random_escort_levels[z[1]] = self.random_escort_levels[z[1]] or {}
			self.random_escort_levels[z[1]][z[2]] = true
		end
	end

	if self.descriptor.world == "Tutorial" then
		local d = require("engine.dialogs.ShowText").new("Tutorial: Movement", "tutorial/move")
		game:registerDialog(d)
	end
end

function _M:onEnterLevel(zone, level)
	-- Save where we entered
	self.entered_level = {x=self.x, y=self.y}

	-- Fire random escort quest
	if self.random_escort_levels and self.random_escort_levels[zone.short_name] and self.random_escort_levels[zone.short_name][level.level] then
		self:grantQuest("escort-duty")
	end

	-- Cancel effects
	local effs = {}
	for eff_id, p in pairs(self.tmp) do
		if self.tempeffect_def[eff_id].cancel_on_level_change then effs[#effs+1] = eff_id end
	end
	for i, eff_id in ipairs(effs) do self:removeEffect(eff_id) end
end

function _M:onEnterLevelEnd(zone, level)
	-- Clone level when they are made, for chronomancy
	if self:attr("game_cloning") then
		game:chronoClone("on_level")
	end
end

function _M:onLeaveLevel(zone, level)
	-- clean up things that need to be removed before re-entering the level
	if self:isTalentActive(self.T_CALL_SHADOWS) then
		local t = self:getTalentFromId(self.T_CALL_SHADOWS)
		t.removeAllShadows(self, t)
	end

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
function _M:onWorldEncounter(target)
	if target.on_encounter then
		game.state:handleWorldEncounter(target)
	end
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)

		-- Autopickup money
		if self:getInven(self.INVEN_INVEN) then
			local i, nb = 1, 0
			local obj = game.level.map:getObject(self.x, self.y, i)
			while obj do
				if obj.auto_pickup then
					self:pickupFloor(i, true)
				else
					if self:attr("auto_id") and obj:getPowerRank() <= self.auto_id then obj:identify(true) end
					nb = nb + 1
					i = i + 1
				end
				obj = game.level.map:getObject(self.x, self.y, i)
			end
			if nb >= 2 then
				game.logSeen(self, "There is more than one object lying here.")
			elseif nb == 1 then
				game.logSeen(self, "There is an item here: %s", game.level.map:getObject(self.x, self.y, 1):getName{do_color=true})
			end
		end

		local g = game.level.map(self.x, self.y, game.level.map.TERRAIN)
		if g and g.change_level then game.logPlayer(self, "#YELLOW_GREEN#There is "..g.name:a_an().." here (press '<', '>' or right click to use).") end
	end

	-- Update wilderness coords
	if game.zone.wilderness then
		-- Cheat with time
		game.turn = game.turn + 1000
		self.wild_x, self.wild_y = self.x, self.y
		game.state:worldDirectorAI()
	end

	-- Update zone name
	if game.zone.variable_zone_name then game:updateZoneName() end

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

	-- Clean log flasher
	game.flash:empty()

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() and self.player then
		game.paused = true
	elseif not self.player then
		self:useEnergy()
	end
end

--- Funky shader stuff
function _M:updateMainShader()
	if game.fbo_shader then
		-- Set shader HP warning
		if self.life ~= self.old_life then
			if self.life < self.max_life / 2 then game.fbo_shader:setUniform("hp_warning", 1 - (self.life / self.max_life))
			else game.fbo_shader:setUniform("hp_warning", 0) end
		end

		-- Colorize shader
		if self:attr("stealth") then game.fbo_shader:setUniform("colorize", {0.9,0.9,0.9})
		elseif self:attr("invisible") then game.fbo_shader:setUniform("colorize", {0.4,0.5,0.7})
		elseif self:attr("unstoppable") then game.fbo_shader:setUniform("colorize", {1,0.2,0})
		elseif self:attr("lightning_speed") then game.fbo_shader:setUniform("colorize", {0.2,0.3,1})
--		elseif game:hasDialogUp() then game.fbo_shader:setUniform("colorize", {0.9,0.9,0.9})
		else game.fbo_shader:setUniform("colorize", {0,0,0}) -- Disable
		end

		-- Blur shader
		if self:attr("confused") then game.fbo_shader:setUniform("blur", 2)
--		elseif game:hasDialogUp() then game.fbo_shader:setUniform("blur", 3)
		else game.fbo_shader:setUniform("blur", 0) -- Disable
		end

		-- Moving Blur shader
		if self:attr("invisible") then game.fbo_shader:setUniform("motionblur", 3)
		elseif self:attr("lightning_speed") then game.fbo_shader:setUniform("motionblur", 2)
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
local arcane_eye_true_seeing = function() return true, 100 end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()
	-- Compute ESP FOV, using cache
	if not game.zone.wilderness then self:computeFOV(self.esp.range or 10, "block_esp", function(x, y) game.level.map:applyESP(x, y, 0.6) end, true, true, true) end

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
				if t and (eff.true_seeing or self:canSee(t)) then map.seens(x, y, 1) end
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
	end

	-- For each entity, generate lite
	local uid, e = next(game.level.entities)
	while uid do
		if e ~= self and e.lite and e.lite > 0 and e.computeFOV then
			e:computeFOV(e.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyExtraLite(x, y, fovdist[sqdist]) end, true, true)
		end
		uid, e = next(game.level.entities, uid)
	end

	if not self:attr("blind") then
		-- Handle dark vision; same as infravision, but also sees past creeping dark
		-- this is treated as a sense, but is filtered by custom LOS code
		if self:knowTalent(self.T_DARK_VISION) then
			local t = self:getTalentFromId(self.T_DARK_VISION)
			local range = self:getTalentRange(t)
			self:computeFOV(range, "block_sense", function(x, y)
				local actor = game.level.map(x, y, game.level.map.ACTOR)
				if actor then
					-- modified actor:hasLOS()
					local l = line.new(self.x, self.y, x, y)
					local lx, ly = l()
					while lx and ly do
						if game.level.map:checkAllEntities(lx, ly, "block_sight") then
							if not game.level.map:checkAllEntities(lx, ly, "creepingDark") then break end
							print("see creepingDark")
						end

						lx, ly = l()
					end
					-- Ok if we are at the end reset lx and ly for the next code
					if not lx and not ly then lx, ly = x, y end

					if lx == x and ly == y then
						game.level.map.seens(x, y, 0.6)
					end
				end
			end, true, true, true)
		end

		-- Handle infravision/heightened_senses which allow to see outside of lite radius but with LOS
		if self:attr("infravision") or self:attr("heightened_senses") then
			local rad = (self.heightened_senses or 0) + (self.infravision or 0)
			local rad2 = math.max(1, math.floor(rad / 4))
			self:computeFOV(rad, "block_sight", function(x, y, dx, dy, sqdist) if game.level.map(x, y, game.level.map.ACTOR) then game.level.map.seens(x, y, fovdist[sqdist]) end end, true, true, true)
			self:computeFOV(rad2, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y, fovdist[sqdist]) end, true, true, true)
		end

		-- Compute both the normal and the lite FOV, using cache
		-- Do it last so it overrides others
		if game.zone.wilderness_see_radius then
			self:computeFOV(game.zone.wilderness_see_radius, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y, wild_fovdist[sqdist]) end, true, true, true)
		else
			self:computeFOV(self.sight or 10, "block_sight", function(x, y, dx, dy, sqdist)
				game.level.map:apply(x, y, fovdist[sqdist])
			end, true, false, true)
			if self.lite <= 0 then game.level.map:applyLite(self.x, self.y)
			else self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true) end
		end
	end
end

function _M:doFOV()
	self:playerFOV()
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
		local range = math.floor(core.fov.distance(src.x, src.y, self.x,  self.y))
		if range > 1 then
			local angle = math.atan2(src.y - self.y, src.x - self.x)
			game.level.map:particleEmitter(self.x, self.y, 1, "hit_warning", {angle=math.deg(angle)})
		end
	end

	return ret
end

function _M:heal(value, src)
	-- Difficulty settings
	if game.difficulty == game.DIFFICULTY_EASY then
		value = value * 1.3
	end

	mod.class.Actor.heal(self, value, src)
end

function _M:die(src)
	self:runStop("died")
	self:restStop("died")

	return self:onPartyDeath(self, src)
end

--- Suffocate a bit, lose air
function _M:suffocate(value, src)
	local dead, affected = mod.class.Actor.suffocate(self, value, src)
	if affected and value < 0 then
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
	local t = self:getTalentFromId(tid)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 30, -0.3, -3.5, ("%s available"):format(t.name:capitalize()), {0,255,00})
	game.log("#00ff00#Talent %s is ready to use.", t.name)
end

--- Tries to get a target from the user
function _M:getTarget(typ)
	return game:targetGetForPlayer(typ)
end

--- Sets the current target
function _M:setTarget(target)
	return game:targetSetForPlayer(target)
end

local function spotHostiles(self)
	local seen = false
	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, game.level.map.w, game.level.map.h, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then
			seen = {x=x,y=y,actor=actor}
		end
	end, nil)
	return seen
end

--- Can we continue resting ?
-- We can rest if no hostiles are in sight, and if we need life/mana/stamina (and their regen rates allows them to fully regen)
function _M:restCheck()
	local spotted = spotHostiles(self)
	if spotted then return false, ("hostile spotted (%s%s)"):format(spotted.actor.name, game.level.map:isOnScreen(spotted.x, spotted.y) and "" or " - offscreen") end

	-- Resting improves regen
	local perc = math.min(self.resting.cnt / 10, 4)
	self:heal(self.life_regen * perc)
	self:incStamina(self.stamina_regen * perc)
	self:incMana(self.mana_regen * perc)

	-- Check resources, make sure they CAN go up, otherwise we will never stop
	if not self.resting.rest_turns then
		if self.air_regen < 0 then return false, "loosing breath!" end
		if self:getMana() < self:getMaxMana() and self.mana_regen > 0 then return true end
		if self:getStamina() < self:getMaxStamina() and self.stamina_regen > 0 then return true end
		if self.life < self.max_life and self.life_regen> 0 then return true end
		if self.alchemy_golem and game.level:hasEntity(self.alchemy_golem) and self.alchemy_golem.life_regen > 0 and not self.alchemy_golem.dead and self.alchemy_golem.life < self.alchemy_golem.max_life then return true end
	else
		return true
	end

	return false, "all resources and life at maximum"
end

--- Can we continue running?
-- We can run if no hostiles are in sight, and if we no interesting terrains are next to us
function _M:runCheck()
	local spotted = spotHostiles(self)
	if spotted then return false, ("hostile spotted (%s%s)"):format(spotted.actor.name, game.level.map:isOnScreen(spotted.x, spotted.y) and "" or " - offscreen") end

	if self.air_regen < 0 then return false, "losing breath!" end

	-- Notice any noticeable terrain
	local noticed = false
	self:runScan(function(x, y)
		-- Only notice interesting terrains
		local grid = game.level.map(x, y, Map.TERRAIN)
		if grid and grid.notice then noticed = "interesting terrain" end

		-- Objects are always interesting
		local obj = game.level.map:getObject(x, y, 1)
		if obj then noticed = "object seen" end

		-- Traps are always interesting if known
		local trap = game.level.map(x, y, Map.TRAP)
		if trap and trap:knownBy(self) then noticed = "trap spotted" end
	end)
	if noticed then return false, noticed end

	return engine.interface.PlayerRun.runCheck(self)
end

--- Move with the mouse
-- We just feed our spotHostile to the interface mouseMove
function _M:mouseMove(tmx, tmy)
	return engine.interface.PlayerMouse.mouseMove(self, tmx, tmy, spotHostiles)
end

--- Called after running a step
function _M:runMoved()
	self:playerFOV()
end

--- Activates a hotkey with a type "inventory"
function _M:hotkeyInventory(name)
	local find = function(name)
		local os = {}
		for inven_id, inven in pairs(self.inven) do
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
		self:playerUseItem(o, item, inven)
	end
end

--- Show combined equipment/inventory dialog
-- Overload to make it use the tooltip
function _M:showEquipInven(title, filter, action)
	local last = nil
	return mod.class.Actor.showEquipInven(self, title, filter, action, function(item)
		if item.last_display_x then
			game.tooltip_x, game.tooltip_y = {}, 1
			game.tooltip:displayAtMap(nil, nil, item.last_display_x, item.last_display_y, item.desc)

			if item == last or not item.object or item.object.wielded then game.tooltip2_x = nil return end
			last = item

			local winven = item.object:wornInven()
			winven = winven and self:getInven(winven)
			if not winven then game.tooltip2_x = nil return end

			local str = tstring{{"font", "bold"}, {"color", "GREY"}, "Currently equiped:", {"font", "normal"}, {"color", "LAST"}, true}
			local ok = false
			for i = 1, #winven do
				str:merge(winven[i]:getDesc())
				if i < #winven then str:add{true, "---", true} end
				ok = true
			end
			if ok then
				game.tooltip2_x, game.tooltip2_y = {}, 1
				game.tooltip2:displayAtMap(nil, nil, 1, item.last_display_y, str)
				game.tooltip2.last_display_x = game.tooltip.last_display_x - game.tooltip2.w
			else
				game.tooltip2_x = nil
			end
		end
	end)
end

function _M:doDrop(inven, item)
	if game.zone.wilderness then
		Dialog:yesnoLongPopup("Warning", "You cannot drop items on the world map.\nIf you drop it, it will be lost forever.", 300, function(ret)
			-- The test is reversed because the buttons are reversed, to prevent mistakes
			if not ret then
				local o = self:removeObject(inven, item, true)
				game.logPlayer(self, "You destroy %s.", o:getName{do_colour=true, do_count=true})
				self:sortInven()
				self:useEnergy()
			end
		end, "Cancel", "Destroy")
		return
	end
	self:dropFloor(inven, item, true, true)
	self:sortInven(inven)
	self:useEnergy()
	self.changed = true
end

function _M:doWear(inven, item, o)
	self:removeObject(inven, item, true)
	local ro = self:wearObject(o, true, true)
	if ro then
		if type(ro) == "table" then self:addObject(inven, ro) end
	elseif not ro then
		self:addObject(inven, o)
	end
	self:sortInven()
	self:useEnergy()
	self.changed = true
end

function _M:doTakeoff(inven, item, o)
	if self:takeoffObject(inven, item) then
		self:addObject(self.INVEN_INVEN, o)
	end
	self:sortInven()
	self:useEnergy()
	self.changed = true
end

function _M:getEncumberTitleUpdator(title)
	return function()
		local enc, max = self:getEncumbrance(), self:getMaxEncumbrance()
		return ("%s - Encumbered %d/%d"):format(title, enc, max)
	end
end

function _M:playerPickup()
	-- If 2 or more objects, display a pickup dialog, otherwise just picks up
	if game.level.map:getObject(self.x, self.y, 2) then
		local titleupdator = self:getEncumberTitleUpdator("Pickup")
		local d d = self:showPickupFloor(titleupdator(), nil, function(o, item)
			self:pickupFloor(item, true)
			self.changed = true
			d.title = titleupdator()
			d:used()
		end)
	else
		self:pickupFloor(1, true)
		self:sortInven()
		self:useEnergy()
	self.changed = true
	end
end

function _M:playerDrop()
	local inven = self:getInven(self.INVEN_INVEN)
	local titleupdator = self:getEncumberTitleUpdator("Drop object")
	self:showInventory(titleupdator(), inven, nil, function(o, item)
		self:doDrop(inven, item)
	end)
end

function _M:playerWear()
	local inven = self:getInven(self.INVEN_INVEN)
	local titleupdator = self:getEncumberTitleUpdator("Wield/wear object")
	self:showInventory(titleupdator(), inven, function(o)
		return o:wornInven() and self:getInven(o:wornInven())  and true or false
	end, function(o, item)
		self:doWear(inven, item, o)
	end)
end

function _M:playerTakeoff()
	local titleupdator = self:getEncumberTitleUpdator("Take off object")
	self:showEquipment(titleupdator(), nil, function(o, inven, item)
		self:doTakeoff(inven, item, o)
	end)
end

function _M:playerUseItem(object, item, inven)
	if game.zone.wilderness then game.logPlayer(self, "You cannot use items on the world map.") return end

	local use_fct = function(o, inven, item)
		local co = coroutine.create(function()
			self.changed = true

			-- Count magic devices
			if (o.is_magic_device or (o.power_source and o.power_source.arcane)) and self:attr("forbid_arcane") then
				game.logPlayer(self, "Your antimagic disrupts %s.", o:getName{no_count=true, do_color=true})
				return true
			end

			local ret, id = o:use(self, nil, inven, item)
			if id then
				o:identify(true)
			end
			if ret and ret == "destroy" then
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
				self:breakStealth()
				self:breakLightningSpeed()
				self:breakGatherTheThreads()
				return true
			end

			self:breakStealth()
			self:breakLightningSpeed()
			self:breakGatherTheThreads()
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
		use_fct,
		true
	)
end

function _M:quickSwitchWeapons()
	local mh1, mh2 = self.inven[self.INVEN_MAINHAND], self.inven[self.INVEN_QS_MAINHAND]
	local oh1, oh2 = self.inven[self.INVEN_OFFHAND], self.inven[self.INVEN_QS_OFFHAND]

	local mhset1, mhset2 = {}, {}
	local ohset1, ohset2 = {}, {}
	-- Remove them all
	for i = #mh1, 1, -1 do mhset1[#mhset1+1] = self:removeObject(mh1, i, true) end
	for i = #mh2, 1, -1 do mhset2[#mhset2+1] = self:removeObject(mh2, i, true) end
	for i = #oh1, 1, -1 do ohset1[#ohset1+1] = self:removeObject(oh1, i, true) end
	for i = #oh2, 1, -1 do ohset2[#ohset2+1] = self:removeObject(oh2, i, true) end

	-- Put them all back
	for i = 1, #mhset1 do self:addObject(mh2, mhset1[i]) end
	for i = 1, #mhset2 do self:addObject(mh1, mhset2[i]) end
	for i = 1, #ohset1 do self:addObject(oh2, ohset1[i]) end
	for i = 1, #ohset2 do self:addObject(oh1, ohset2[i]) end

	if not self:hasEffect(self.EFF_CELERITY) then self:useEnergy() end
	local names = ""
	if mh1[1] and oh1[1] then names = mh1[1]:getName{do_color=true}.." and "..oh1[1]:getName{do_color=true}
	elseif mh1[1] and not oh1[1] then names = mh1[1]:getName{do_color=true}
	elseif not mh1[1] and oh1[1] then names = oh1[1]:getName{do_color=true}
	end
	game.logPlayer(self, "You switch your weapons to: %s.", names)
end

function _M:playerLevelup(on_finish)
	if self.unused_stats > 0 then
		local ds = LevelupStatsDialog.new(self, on_finish)
		game:registerDialog(ds)
	else
		local dt = LevelupTalentsDialog.new(self, on_finish)
		game:registerDialog(dt)
	end
end

--- Use a portal with the orb of many ways
function _M:useOrbPortal(portal)
	if portal.special then portal:special(self) return end

	if spotHostiles(self) then game.logPlayer(self, "You can not use the Orb with foes in sight.") return end

	if portal.on_preuse then portal:on_preuse(self) end

	if portal.teleport_level then
		local x, y = util.findFreeGrid(portal.teleport_level.x, portal.teleport_level.y, 2, true, {[Map.ACTOR]=true})
		if x and y then self:move(x, y, true) end
	else
		if portal.change_wilderness then
			if portal.change_wilderness.spot then
				local spot = game.memory_levels[portal.change_wilderness.level_name or (portal.change_zone.."-"..portal.change_level)]:pickSpot(portal.change_wilderness.spot)
				self.wild_x = spot and spot.x or 0
				self.wild_y = spot and spot.y or 0
			else
				self.wild_x = portal.change_wilderness.x or 0
				self.wild_y = portal.change_wilderness.y or 0
			end
		end
		game:changeLevel(portal.change_level, portal.change_zone)

		if portal.after_zone_teleport then self:move(portal.after_zone_teleport.x, portal.after_zone_teleport.y, true) end
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

	game.logPlayer(self, "You use the %s on the pedestal. There is a distant 'clonk' sound.", o:getName{do_colour=true})
	self:grantQuest("orb-command")
	self:setQuestStatus("orb-command", engine.Quest.COMPLETED, o.define_as)
end

--- Notify of object pickup
function _M:on_pickup_object(o)
	-- Grant the artifact quest
	if o.unique and not o.lore and not o:isIdentified() and not game.zone.infinite_dungeon then self:grantQuest("first-artifact") end

	if self:attr("auto_id") and o:getPowerRank() <= self.auto_id then
		o:identify(true)
	end
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
	game.logPlayer(game.player, "#LIGHT_GREEN#Accepted quest '%s'! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
end

function _M:on_quest_status(quest, status, sub)
	if sub then
		game.logPlayer(game.player, "#LIGHT_GREEN#Quest '%s' status updated! #WHITE#(Press 'j' to see the quest log)", quest.name)
	elseif status == engine.Quest.COMPLETED then
		game.logPlayer(game.player, "#LIGHT_GREEN#Quest '%s' completed! #WHITE#(Press 'j' to see the quest log)", quest.name)
	elseif status == engine.Quest.DONE then
		game.logPlayer(game.player, "#LIGHT_GREEN#Quest '%s' is done! #WHITE#(Press 'j' to see the quest log)", quest.name)
	elseif status == engine.Quest.FAILED then
		game.logPlayer(game.player, "#LIGHT_RED#Quest '%s' is failed! #WHITE#(Press 'j' to see the quest log)", quest.name)
	end
end
