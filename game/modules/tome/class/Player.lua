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
local Map = require "engine.Map"
local Dialog = require "engine.ui.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"
local LevelupStatsDialog = require "mod.dialogs.LevelupStatsDialog"
local LevelupTalentsDialog = require "mod.dialogs.LevelupTalentsDialog"
local DeathDialog = require "mod.dialogs.DeathDialog"

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
	mod.class.interface.PlayerLore
))

function _M:init(t, no_default)
	t.display=t.display or '@'
	t.color_r=t.color_r or 230
	t.color_g=t.color_g or 230
	t.color_b=t.color_b or 230

	t.player = true
	t.open_door = true
	t.type = t.type or "humanoid"
	t.subtype = t.subtype or "player"
	t.faction = t.faction or "players"

	if t.fixed_rating == nil then t.fixed_rating = true end

	t.move_others = true

	-- Dont give free resists & higher stat max to players
	t.no_auto_resists = true
	t.no_auto_high_stats = true

	t.lite = t.lite or 0

	t.rank = t.rank or 3
	t.old_life = 0

	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)
	mod.class.interface.PlayerLore.init(self, t)

	self.descriptor = {}
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
	-- Save where we enterred
	self.entered_level = {x=self.x, y=self.y}

	-- Fire random escort quest
	if self.random_escort_levels and self.random_escort_levels[zone.short_name] and self.random_escort_levels[zone.short_name][level.level] then
		self:grantQuest("escort-duty")
	end
end

function _M:onLeaveLevel(zone, level)
	-- Fail past escort quests
	local eid = "escort-duty-"..zone.short_name.."-"..level.level
	if self.quests and self.quests[eid] and not self:hasQuest(eid):isEnded() then
		local q = self.quests[eid]
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
		local i, nb = 1, 0
		local obj = game.level.map:getObject(self.x, self.y, i)
		while obj do
			if obj.auto_pickup then
				self:pickupFloor(i, true)
			else
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

	-- Update wilderness coords
	if game.zone.wilderness then
		-- Cheat with time
		game.turn = game.turn + 1000

		self.wild_x, self.wild_y = self.x, self.y
		local g = game.level.map(self.x, self.y, Map.TERRAIN)

		if g and g.can_encounter and game.level.data.encounters then
			local type = game.level.data.encounters.chance(self)
			if type then
				game.level.level = self.level
				game.level:setEntitiesList("encounters_rng", game.zone:computeRarities("encounters_rng", game.level:getEntitiesList("encounters"), game.level, nil))
				local e = game.zone:makeEntity(game.level, "encounters_rng", {type=type, mapx=self.x, mapy=self.y, nb_tries=10})
				if e then
					if e:check("on_encounter", self) then
						e:added()
					end
				end
			end
		end

		game.state:worldDirectorAI()
	end

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
		if self:attr("stealth") then game.fbo_shader:setUniform("colorize", {0.7,0.7,0.7})
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
	fovdist[i] = math.max((20 - math.sqrt(i)) / 14, 0.6)
end
local wild_fovdist = {}
for i = 0, 10 * 10 do
	wild_fovdist[i] = math.max((5 - math.sqrt(i)) / 1.4, 0.6)
end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()
	-- Compute ESP FOV, using cache
	if not game.zone.wilderness then self:computeFOV(self.esp.range or 10, "block_esp", function(x, y) game.level.map:applyESP(x, y) end, true, true, true) end

	if not self:attr("blind") then
		-- Compute both the normal and the lite FOV, using cache
		if game.zone.wilderness_see_radius then
			self:computeFOV(game.zone.wilderness_see_radius, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y, wild_fovdist[sqdist]) end, true, true, true)
		else
			self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
				game.level.map:apply(x, y, fovdist[sqdist])
			end, true, false, true)
			if self.lite <= 0 then game.level.map:applyLite(self.x, self.y)
			else self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true) end
		end

		-- Handle infravision/heightened_senses which allow to see outside of lite radius but with LOS
		if self:attr("infravision") or self:attr("heightened_senses") then
			local rad = (self.heightened_senses or 0) + (self.infravision or 0)
			self:computeFOV(rad, "block_sight", function(x, y) if game.level.map(x, y, game.level.map.ACTOR) then game.level.map.seens(x, y, 1) end end, true, true, true)
		end
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
				game.level.map.seens(x, y, 1)
			end
		end, true, true, true)
	end


	-- Handle Preternatural Senses talent, a simple FOV, using cache.
	if self:knowTalent(self.T_PRETERNATURAL_SENSES) then
		local t = self:getTalentFromId(self.T_PRETERNATURAL_SENSES)
		local range = self:getTalentRange(t)
		self:computeFOV(range, "block_sense", function(x, y)
			if game.level.map(x, y, game.level.map.ACTOR) then
				game.level.map.seens(x, y, 1)
			end
		end, true, true, true)
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
		value = value * 1.1
	elseif game.difficulty == game.DIFFICULTY_NIGHTMARE then
		value = value * 0.8
	elseif game.difficulty == game.DIFFICULTY_INSANE then
		value = value * 0.6
	end

	mod.class.Actor.heal(self, value, src)
end

function _M:die(src)
	if self.game_ender then
		engine.interface.ActorLife.die(self, src)
		game.paused = true
		self.energy.value = game.energy_to_act
		self.killedBy = src
		self.died_times = (self.died_times or 0) + 1
		self:registerDeath(self.killedBy)
		game:registerDialog(DeathDialog.new(self))
	else
		mod.class.Actor.die(self, src)
	end
end

--- Suffocate a bit, lose air
function _M:suffocate(value, src)
	local dead, affected = mod.class.Actor.suffocate(self, value, src)
	if affected then
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

function _M:levelup()
	mod.class.Actor.levelup(self)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 80, 0.5, -2, "LEVEL UP!", {0,255,255})
	game.log("#00ffff#Welcome to level %d.", self.level)
	if self.unused_stats > 0 then game.log("You have %d stat point(s) to spend. Press G to use them.", self.unused_stats) end
	if self.unused_talents > 0 then game.log("You have %d class talent point(s) to spend. Press G to use them.", self.unused_talents) end
	if self.unused_generics > 0 then game.log("You have %d generic talent point(s) to spend. Press G to use them.", self.unused_generics) end
	if self.unused_talents_types > 0 then game.log("You have %d category point(s) to spend. Press G to use them.", self.unused_talents_types) end

	if self.level == 10 then world:gainAchievement("LEVEL_10", self) end
	if self.level == 20 then world:gainAchievement("LEVEL_20", self) end
	if self.level == 30 then world:gainAchievement("LEVEL_30", self) end
	if self.level == 40 then world:gainAchievement("LEVEL_40", self) end
	if self.level == 50 then world:gainAchievement("LEVEL_50", self) end

	if game.difficulty == game.DIFFICULTY_EASY and (
		self.level == 2 or
		self.level == 3 or
		self.level == 5 or
		self.level == 7 or
		self.level == 10 or
		self.level == 14 or
		self.level == 18 or
		self.level == 24 or
		self.level == 30 or
		self.level == 40
		) then
		self.easy_mode_lifes = (self.easy_mode_lifes or 0) + 1
	end
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
	core.fov.calc_circle(self.x, self.y, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
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

	-- Check ressources, make sure they CAN go up, otherwise we will never stop
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
-- We can run if no hostiles are in sight, and if we no interresting terrains are next to us
function _M:runCheck()
	local spotted = spotHostiles(self)
	if spotted then return false, ("hostile spotted (%s%s)"):format(spotted.actor.name, game.level.map:isOnScreen(spotted.x, spotted.y) and "" or " - offscreen") end

	if self.air_regen < 0 then return false, "losing breath!" end

	-- Notice any noticable terrain
	local noticed = false
	self:runScan(function(x, y)
		-- Only notice interresting terrains
		local grid = game.level.map(x, y, Map.TERRAIN)
		if grid and grid.notice then noticed = "interesting terrain" end

		-- Objects are always interresting
		local obj = game.level.map:getObject(x, y, 1)
		if obj then noticed = "object seen" end

		-- Traps are always interresting if known
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
	self:sortInven()
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
	-- If 2 or more objects, display a pickup dialog, otehrwise just picks up
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
			local ret, id = o:use(self, nil, inven, item)
			if id then
				o:identify(true)
			end
			if ret and ret == "destroy" then
				-- Count magic devices
				if o.is_magic_device then
					self:attr("used_magic_devices", 1)
					self:antimagicBackslash(4 + (o.material_level or 1))
				end

				if not o.unique and self:doesPackRat() then
					game.logPlayer(self, "Pack Rat!")
				else
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
				end
				return true
			end

			self:breakStealth()
			self:breakLightningSpeed()
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

	self:useEnergy()
	game.logPlayer(self, "You switch your weapons.")
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
			self.current_wilderness = portal.change_wilderness.name
			self.wild_x = portal.change_wilderness.x or 0
			self.wild_y = portal.change_wilderness.y or 0
		end
		game:changeLevel(portal.change_level, portal.change_zone)
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

	game.logPlayer(self, "You use the %s on the pedestral. There is a distant 'clonk' sound.", o:getName{do_colour=true})
	self:grantQuest("orb-command")
	self:setQuestStatus("orb-command", engine.Quest.COMPLETED, o.define_as)
end

--- Tell us when we are targetted
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
	game.logPlayer(self, "#LIGHT_GREEN#Accepted quest '%s'! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
end

function _M:on_quest_status(quest, status, sub)
	if sub then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' status updated! #WHITE#(Press 'j' to see the quest log)", quest.name)
	elseif status == engine.Quest.COMPLETED then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' completed! #WHITE#(Press 'j' to see the quest log)", quest.name)
	elseif status == engine.Quest.DONE then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' is done! #WHITE#(Press 'j' to see the quest log)", quest.name)
	elseif status == engine.Quest.FAILED then
		game.logPlayer(self, "#LIGHT_RED#Quest '%s' is failed! #WHITE#(Press 'j' to see the quest log)", quest.name)
	end
end
