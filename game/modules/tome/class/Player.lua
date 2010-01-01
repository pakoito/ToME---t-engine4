require "engine.class"
require "mod.class.Actor"
local Map = require "engine.Map"
local Dialog = require "engine.Dialog"
local ActorTalents = require "engine.interface.ActorTalents"

module(..., package.seeall, class.inherit(mod.class.Actor))

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
	self.player = true
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
	-- FIX
	self.unused_talents = 6
	self.move_others=true

	self.lite = 4

	self.descriptor = {}
	self.hotkey = {}
end

function _M:move(x, y, force)
	local moved = mod.class.Actor.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)

		local obj = game.level.map(self.x, self.y, Map.OBJECT)
		if obj then
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
		elseif type(typ) == "table" then
			if typ.default_target then self.target.target.entity = typ.default_target end
			msg = typ.msg
		end
		game:targetMode("exclusive", msg, coroutine.running(), typ)
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

--- Uses an hotkeyed talent
function _M:activateHotkey(id)
	if self.hotkey[id] then
		self:useTalent(self.hotkey[id])
	else
		Dialog:simplePopup("Hotkey not defined", "You may define a hotkey by pressing 'm' and following the inscructions there.")
	end
end
