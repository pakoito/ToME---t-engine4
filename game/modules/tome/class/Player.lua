require "engine.class"
require "mod.class.Actor"
require "engine.interface.PlayerRest"
require "engine.interface.PlayerRun"
require "engine.interface.PlayerHotkeys"
local Savefile = require "engine.Savefile"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"

--- Defines the player for ToME
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.Actor,
	engine.interface.PlayerRest,
	engine.interface.PlayerRun,
	engine.interface.PlayerHotkeys
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
	mod.class.Actor.init(self, t, no_default)
	engine.interface.PlayerHotkeys.init(self, t)
	self.player = true
	self.type = "humanoid"
	self.subtype = "player"
	self.faction = "players"

	self.display='@'
	self.color_r=230
	self.color_g=230
	self.color_b=230
--	self.image="player.png"

	self.fixed_rating = true

	self.max_life=150
	self.max_mana=85
	self.max_stamina=85
	self.unused_stats = 6
	self.unused_talents = 2
	self.move_others=true

	self.lite = 0

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
			game.logSeen(self, "There is an item here: "..obj:getName())
		end
	end

	-- Update wilderness coords
	if game.zone.short_name == "wilderness" then
		self.wild_x, self.wild_y = self.x, self.y
	end

	return moved
end

function _M:act()
	if not mod.class.Actor.act(self) then return end

	-- Clean log flasher
	game.flash:empty()

	-- Resting ? Running ? Otherwise pause
	if not self:restStep() and not self:runStep() then
		game.paused = true
	end
end

function _M:die()
	local save = Savefile.new(game.save_name)
	save:delete()
	save:close()
	util.showMainMenu()
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
end

--- Tries to get a target from the user
-- *WARNING* If used inside a coroutine it will yield and resume it later when a target is found.
-- This is usualy just what you want so dont think too much about it :)
function _M:getTarget(typ)
	if coroutine.running() then
		local msg
		if type(typ) == "string" then msg, typ = typ, nil
		elseif type(typ) == "table" then
			if typ.default_target then self.target.target.entity = typ.default_target end
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
	core.fov.calc_circle(self.x, self.y, 20, game.level.map.opaque, function(map, x, y)
		local actor = map(x, y, map.ACTOR)
		if actor and self:reactionToward(actor) < 0 and self:canSee(actor) then seen = true end
	end, game.level.map)
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
		if grid and grid.notice then noticed = "interresting terrain" end

		-- Objects are always interresting
		local obj = game.level.map:getObject(x, y, 1)
		if obj then noticed = "object seen" end
	end)
	if noticed then return false, noticed end

	return engine.interface.PlayerRun.runCheck(self)
end

function _M:playerPickup()
	-- If 2 or more objects, display a pickup dialog, otehrwise just picks up
	if game.level.map:getObject(self.x, self.y, 2) then
		self:showPickupFloor(nil, nil, function(o, item)
			self:pickupFloor(item, true)
			self:sortInven()
		end)
	else
		self:pickupFloor(1, true)
		self:sortInven()
		self:useEnergy()
	end
end

function _M:playerDrop()
	local inven = self:getInven(self.INVEN_INVEN)
	self:showInventory("Drop object", inven, nil, function(o, item)
		self:dropFloor(inven, item)
		self:sortInven()
		self:useEnergy()
	end)
end

function _M:playerWear()
	local inven = self:getInven(self.INVEN_INVEN)
	self:showInventory("Wield/wear object", inven, function(o)
		return o:wornInven() and true or false
	end, function(o, item)
		local ro = self:wearObject(o, true, true)
		if ro then
			if type(ro) == "table" then self:addObject(self.INVEN_INVEN, ro) end
			self:removeObject(self.INVEN_INVEN, item)
		end
		self:sortInven()
		self:useEnergy()
	end)
end

function _M:playerTakeoff()
	self:showEquipment("Take off object", nil, function(o, inven, item)
		if self:takeoffObject(inven, item) then
			self:addObject(self.INVEN_INVEN, o)
		end
		self:sortInven()
		self:useEnergy()
	end)
end

function _M:playerUseItem(object, item)
	local use_fct = function(o, item)
		self.changed = true
		local ret, no_id = o:use(self)
		if not no_id then
			o:identify(true)
		end
		if ret and ret == "destroy" then
			if o.multicharge and o.multicharge > 1 then
				o.multicharge = o.multicharge - 1
			else
				self:removeObject(self:getInven(self.INVEN_INVEN), item)
				game.log("You have no more "..o:getName())
				self:sortInven()
				self:useEnergy()
			end
		end
		self:breakStealth()
	end

	if object and item then return use_fct(object, item) end

	self:showInventory(nil, self:getInven(self.INVEN_INVEN),
		function(o)
			return o:canUseObject()
		end,
		use_fct,
		true
	)
end
