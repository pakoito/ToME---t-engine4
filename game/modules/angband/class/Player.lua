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
require "engine.interface.PlayerMouse"
require "engine.interface.PlayerHotkeys"
require "engine.interface.ActorInventory"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"
local DeathDialog = require "mod.dialogs.DeathDialog"
local Astar = require"engine.Astar"
local DirectPath = require"engine.DirectPath"
require "mod.class.interface.Combat"

--- Defines the player
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.Actor,
	engine.interface.PlayerRest,
	engine.interface.PlayerRun,
	engine.interface.PlayerMouse,
	engine.interface.PlayerHotkeys,
	engine.interface.ActorInventory,
	mod.class.interface.Combat
))

function _M:init(t, no_default)
	t.display=t.display or '@'
	t.color_r=t.color_r or 230
	t.color_g=t.color_g or 230
	t.color_b=t.color_b or 230

	t.player = true
	t.type = t.type or "humanoid"
	t.subtype = t.subtype or "player"
	t.faction = t.faction or "players"

	t.lite = t.lite or 0

	t.body = { INVEN=23, WEAPON=1, SHOOTER=1, FINGER=2, NECK=1, LITE=1, BODY=1, CLOAK=1, HEAD=1, SHIELD=1, HANDS=1, FEET=1, QUIVER=1 }

	mod.class.Actor.init(self, t, no_default)
	engine.interface.ActorInventory.init(self, t)
	engine.interface.PlayerHotkeys.init(self, t)

	self.descriptor = {}
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)
	end
	return moved
end

function _M:act()
	if not mod.class.Actor.act(self) then return end

	-- Clean log flasher
	game.flash:empty()

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() and self.player then
		game.paused = true
	end
end

-- Precompute FOV form, for speed
local fovdist = {}
for i = 0, 30 * 30 do
	fovdist[i] = math.max((20 - math.sqrt(i)) / 14, 0.6)
end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()

	if not self:attr("blind") then
		-- Compute both the normal and the lite FOV, using cache
		self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
			game.level.map:apply(x, y, fovdist[sqdist])
		end, true, false, true)
		if self.lite <= 0 then game.level.map:applyLite(self.x, self.y)
		else self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true) end
	end

	-- Compute ESP FOV, using cache
	self:computeFOV(self.esp.range or 10, "block_esp", function(x, y) game.level.map:applyESP(x, y) end, true, true, true)

	-- Compute both the normal and the lite FOV, using cache
	self:computeFOV(self.sight or 20, "block_sight", function(x, y, dx, dy, sqdist)
		game.level.map:apply(x, y, fovdist[sqdist])
	end, true, false, true)
	if self.lite <= 0 then game.level.map:applyLite(self.x, self.y)
	else self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true) end
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
end

--- Call when an object is removed
function _M:onRemoveObject(o)
	engine.interface.ActorInventory.onRemoveObject(self, o)

	self:checkEncumbrance()
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
					if self:hasQuest("antimagic") and not self:hasQuest("antimagic"):isEnded() then self:setQuestStatus("antimagic", engine.Quest.FAILED) end -- Fail antimagic quest
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
				self:breakStealth()
				self:breakLightningSpeed()
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


function _M:levelup()
	mod.class.Actor.levelup(self)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 80, 0.5, -2, "LEVEL UP!", {0,255,255})
	game.log("#00ffff#Welcome to level %d.", self.level)
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
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) and game.level.map.seens(x, y) then seen = true end
	end, nil)
	return seen
end

--- Can we continue resting ?
-- We can rest if no hostiles are in sight, and if we need life/mana/stamina (and their regen rates allows them to fully regen)
function _M:restCheck()
	if spotHostiles(self) then return false, "hostile spotted" end

	-- Check ressources, make sure they CAN go up, otherwise we will never stop
	if self:getPower() < self:getMaxPower() and self.power_regen > 0 then return true end
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
	end)
	if noticed then return false, noticed end

	self:playerFOV()

	return engine.interface.PlayerRun.runCheck(self)
end

--- Move with the mouse
-- We just feed our spotHostile to the interface mouseMove
function _M:mouseMove(tmx, tmy)
	return engine.interface.PlayerMouse.mouseMove(self, tmx, tmy, spotHostiles)
end
