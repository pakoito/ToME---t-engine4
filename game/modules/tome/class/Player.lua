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
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerHotkeys"
require "engine.interface.PlayerSlide"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"
local LevelupStatsDialog = require "mod.dialogs.LevelupStatsDialog"
local LevelupTalentsDialog = require "mod.dialogs.LevelupTalentsDialog"
local DeathDialog = require "mod.dialogs.DeathDialog"
local Astar = require"engine.Astar"
local DirectPath = require"engine.DirectPath"

--- Defines the player for ToME
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.Actor,
	engine.interface.PlayerRest,
	engine.interface.PlayerRun,
	engine.interface.PlayerHotkeys,
	engine.interface.PlayerSlide
))

function _M:init(t, no_default)
	t.body = {
		INVEN = 1000,
		MAINHAND = 1,
		OFFHAND = 1,
		FINGER = 2,
		NECK = 1,
		LITE = 1,
		BODY = 1,
		HEAD = 1,
		HANDS = 1,
		FEET = 1,
		TOOL = 1,
	}
	t.display=t.display or '@'
	t.color_r=t.color_r or 230
	t.color_g=t.color_g or 230
	t.color_b=t.color_b or 230

	t.player = true
	t.type = t.type or "humanoid"
	t.subtype = t.subtype or "player"
	t.faction = t.faction or "players"

	if t.fixed_rating == nil then t.fixed_rating = true end

	t.unused_stats = 6
	t.unused_talents = 2
	t.move_others=true

	t.lite = t.lite or 0

	t.rank = t.rank or 3

	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)

	self.descriptor = {}
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)

		local obj = game.level.map:getObject(self.x, self.y, 1)
		if obj and game.level.map:getObject(self.x, self.y, 2) then
			game.logSeen(self, "There is more than one objects lying here.")
		elseif obj then
			game.logSeen(self, "There is an item here: %s", obj:getName{do_color=true})
		end
	end

	-- Update wilderness coords
	if game.zone.wilderness then
		-- Cheat with time
		game.turn = game.turn + 1000

		self.wild_x, self.wild_y = self.x, self.y
		local g = game.level.map(self.x, self.y, Map.TERRAIN)
		if g and g.can_encounter and game.level.data.encounters then
			print(g,g.can_encounter, game.level.data.encounters)
			local type = game.level.data.encounters.chance(self)
			if type then
				local e = game.zone:makeEntity(game.level, "encounters", {type=type, mapx=self.x, mapy=self.y, nb_tries=10})
				if e then
					print("Made encounter:", e.name)
					if e:check("on_encounter", self) then
						e:added()
					end
				end
			end
		end
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

	-- Clean log flasher
	game.flash:empty()

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() and self.player then
		game.paused = true
	end
end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()
	-- Compute ESP FOV, using cache
	if not game.zone.wilderness then self:computeFOV(self.esp.range or 10, "block_esp", function(x, y) game.level.map:applyESP(x, y) end, true, true) end
	-- Compute both the normal and the lite FOV, using cache
	if game.zone.wilderness_see_radius then
		self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
			game.level.map:apply(x, y, math.max((20 - math.sqrt(sqdist)) / 14, 0.6))
		end, true, false, true)
		self:computeFOV(game.zone.wilderness_see_radius, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true)
	else
		self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
			game.level.map:apply(x, y, math.max((20 - math.sqrt(sqdist)) / 14, 0.6))
		end, true, false, true)
		self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true)
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
	return ret
end

function _M:die(src)
	if self.game_ender then
		engine.interface.ActorLife.die(self, src)
		game.paused = true
		self.energy.value = game.energy_to_act
		game:registerDialog(DeathDialog.new(self))
	else
		mod.class.Actor.die(self, src)
	end

	if src and src.type == "undead" and src.subtype == "skeleton" and rng.percent(src.rank + math.ceil(math.max(src.level / 2, 1))) then
		game:setAllowedBuild("undead")
		game:setAllowedBuild("undead_skeleton", true)
	elseif src and src.type == "undead" and src.subtype == "ghoul" and rng.percent(src.rank + math.ceil(math.max(src.level / 2, 1))) then
		game:setAllowedBuild("undead")
		game:setAllowedBuild("undead_ghoul", true)
	end
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
	if self.unused_talents > 0 then game.log("You have %d talent point(s) to spend. Press G to use them.", self.unused_talents) end
	if self.unused_talents_types > 0 then game.log("You have %d talent category point(s) to spend. Press G to use them.", self.unused_talents_types) end

	if self.level == 10 then world:gainAchievement("LEVEL_10", self) end
	if self.level == 20 then world:gainAchievement("LEVEL_20", self) end
	if self.level == 30 then world:gainAchievement("LEVEL_30", self) end
	if self.level == 40 then world:gainAchievement("LEVEL_40", self) end
	if self.level == 50 then world:gainAchievement("LEVEL_50", self) end
end

--- Tries to get a target from the user
-- *WARNING* If used inside a coroutine it will yield and resume it later when a target is found.
-- This is usualy just what you want so dont think too much about it :)
function _M:getTarget(typ)
	if coroutine.running() then
		local msg
		if type(typ) == "string" then msg, typ = typ, nil
		elseif type(typ) == "table" then
			if typ.default_target then game.target.target.entity = typ.default_target end
			msg = typ.msg
		end
		game:targetMode("exclusive", msg, coroutine.running(), typ)
		if typ.nolock then
			game.target_style = "free"
		end
		return coroutine.yield()
	end
	return game.target.target.x, game.target.target.y, game.target.target.entity
end

--- Sets the current target
function _M:setTarget(target)
	game.target.target.entity = target
	game.target.target.x = target.x
	game.target.target.y = target.y
end

local function spotHostiles(self)
	local seen = false
	-- Check for visible monsters, only see LOS actors, so telepathy wont prevent resting
	core.fov.calc_circle(self.x, self.y, 20, function(_, x, y) return game.level.map:opaque(x, y) end, function(_, x, y)
		local actor = game.level.map(x, y, game.level.map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then seen = true end
	end, nil)
	return seen
end

--- Can we continue resting ?
-- We can rest if no hostiles are in sight, and if we need life/mana/stamina (and their regen rates allows them to fully regen)
function _M:restCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

	-- Check ressources, make sure they CAN go up, otherwise we will never stop
	if self:getMana() < self:getMaxMana() and self.mana_regen > 0 then return true end
	if self:getStamina() < self:getMaxStamina() and self.stamina_regen > 0 then return true end
	if self.life < self.max_life and self.life_regen> 0 then return true end

	return false, "all resources and life at maximun"
end

--- Can we continue running?
-- We can run if no hostiles are in sight, and if we no interresting terrains are next to us
function _M:runCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

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

	self:playerFOV()

	return engine.interface.PlayerRun.runCheck(self)
end

function _M:doDrop(inven, item)
	if game.zone.wilderness then game.logPlayer(self, "You can not drop on the world map.") return end
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
			self:sortInven()
			self.changed = true
			d.title = titleupdator()
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
		return o:wornInven() and true or false
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
	if game.zone.wilderness then game.logPlayer(self, "You can not use items on the world map.") return end

	local use_fct = function(o, inven, item)
		self.changed = true
		local ret, no_id = o:use(self)
		if not no_id then
			o:identify(true)
		end
		if ret and ret == "destroy" then
			if o.multicharge and o.multicharge > 1 then
				o.multicharge = o.multicharge - 1
			else
				self:removeObject(self:getInven(inven), item)
				game.log("You have no more %s", o:getName{no_count=true, do_color=true})
				self:sortInven(self:getInven(inven))
			end
			return true
		end
		self:breakStealth()
		self.changed = true
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

function _M:playerLevelup(on_finish)
	if self.unused_stats > 0 then
		local ds = LevelupStatsDialog.new(self, on_finish)
		game:registerDialog(ds)
	else
		local dt = LevelupTalentsDialog.new(self, on_finish)
		game:registerDialog(dt)
	end
end

--- Runs to the clicked mouse spot
-- if no monsters in sight it will try to make an A* path, if it fails it will do a direct path
-- if there are monsters in sight it will move one stop in the direct path direction
function _M:mouseMove(tmx, tmy)
	if config.settings.tome.cheat and game.key.status[game.key._LSHIFT] and game.key.status[game.key._LCTRL] then
		game.log("[CHEAT] teleport to %dx%d", tmx, tmy)
		self:move(tmx, tmy, true)
	else
		-- If hostiles, attack!
		if spotHostiles(self) or math.floor(core.fov.distance(self.x, self.y, tmx, tmy)) == 1 then
			local l = line.new(self.x, self.y, tmx, tmy)
			local nx, ny = l()
			self:move(nx or self.x, ny or self.y)
			return
		end

		local a = Astar.new(game.level.map, self)
		local path = a:calc(self.x, self.y, tmx, tmy, true)
		-- No Astar path ? jsut be dumb and try direct line
		if not path then
			local d = DirectPath.new(game.level.map, self)
			path = d:calc(self.x, self.y, tmx, tmy, true)
		end

		if path then
			-- Should we just try to move in the direction, aka: attack!
			if path[1] and game.level.map:checkAllEntities(path[1].x, path[1].y, "block_move", self) then self:move(path[1].x, path[1].y) return end

			 -- Insert the player coords, running needs to find the player
			table.insert(path, 1, {x=self.x, y=self.y})

			-- Move along the projected A* path
			self:runFollow(path)
		end
	end
end

--- Use a portal with the orb of many ways
function _M:useOrbPortal(portal)
	if portal.change_wilderness then
		self.current_wilderness = portal.change_wilderness.name
		self.wild_x = portal.change_wilderness.x or 0
		self.wild_y = portal.change_wilderness.y or 0
	end
	game:changeLevel(portal.change_level, portal.change_zone)
	if portal.message then game.logPlayer(self, portal.message) end
end

------ Quest Events
function _M:on_quest_grant(quest)
	game.logPlayer(self, "#LIGHT_GREEN#Accepted quest '%s'! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
end

function _M:on_quest_status(quest, status, sub)
	if sub then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' status updated! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	elseif status == engine.Quest.COMPLETED then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' completed! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	elseif status == engine.Quest.DONE then
		game.logPlayer(self, "#LIGHT_GREEN#Quest '%s' is done! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	elseif status == engine.Quest.FAILED then
		game.logPlayer(self, "#LIGHT_RED#Quest '%s' is failed! #WHITE#(Press CTRL+Q to see the quest log)", quest.name)
	end
end
