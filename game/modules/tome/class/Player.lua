require "engine.class"
require "mod.class.Actor"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"

module(..., package.seeall, class.inherit(mod.class.Actor))

function _M:init(t)
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
	mod.class.Actor.init(self, t)
	self.player = true
	self.faction = "players"

	-- Default regen
	self.mana_regen = self.mana_regen or 1
	self.stamina_regen = self.stamina_regen or 1
	self.life_regen = self.life_regen or 0.5

	self.descriptor = {}
	self.hotkey = {}
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 4, 4)

		local obj = game.level.map(self.x, self.y, Map.OBJECT)
		if obj then
			game.logSeen(self, "There is an item here: "..obj:getName())
		end
	end
	return moved
end

function _M:act()
	mod.class.Actor.act(self)

	game.paused = true
end

function _M:die()
	-- a tad brutal
	os.exit()
end

function _M:setName(name)
	self.name = name
	game.save_name = name
end

--- Notify the player of available cooldowns
function _M:onTalentCooledDown(tid)
	local t = self:getTalentFromId(tid)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 80, -0.3, -1.5, ("%s available"):format(t.name:capitalize()), {0,255,00})
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
		elseif type(typ) == "table" then msg = typ.msg end
		game:targetMode("exclusive", msg, coroutine.running(), typ)
		return coroutine.yield()
	end
	return game.target.target.x, game.target.target.y
end

--- Quick way to check if the player can see the target
function _M:canSee(entity)
	if entity.x and entity.y and game.level.map.seens(entity.x, entity.y) then return true end
end

--- Uses an hotkeyed talent
function _M:activateHotkey(id)
	if self.hotkey[id] then
		self:useTalent(self.hotkey[id])
	else
		Dialog:simplePopup("Hotkey not defined", "You may define a hotkey by pressing 'm' and following the inscructions there.")
	end
end
