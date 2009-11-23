require "engine.class"
require "engine.GameTurnBased"
require "engine.KeyCommand"
require "engine.LogDisplay"
local Tooltip = require "engine.Tooltip"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Grid = require "engine.Grid"
local Actor = require "mod.class.Actor"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

module(..., package.seeall, class.inherit(engine.GameTurnBased))

function _M:init()
	engine.GameTurnBased.init(self, engine.Key.current, 1000, 100)
end

function _M:run()
	self:setupCommands()

	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="engine.Entity"}
	Map:setViewPort(self.w, math.floor(self.h * 0.80), 16, 16)

	self.zone = Zone.new("ancient_ruins")

	self.tooltip = engine.Tooltip.new(nil, nil, {255,255,255}, {30,30,30})

	self.log = engine.LogDisplay.new(self.w * 0.5, self.h * 0.20, nil, nil, nil, {255,255,255}, {30,30,30})
	self.log("Welcome to #00FF00#Tales of Middle Earth!")

	self.zone:getLevel(self, 1)

	self.player = Player.new{name="player", image='player.png', display='@', color_r=230, color_g=230, color_b=230}
	self.player:move(self.level.start.x, self.level.start.y, true)
	self.level:addEntity(self.player)

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()
end

function _M:tick()
	engine.GameTurnBased.tick(self)
end

function _M:display()
	self.log:display():toScreen(0, self.h * 0.80)

	if self.level and self.level.map then
		self.level.map.seens(self.player.x, self.player.y, true)
		self.level.map.lites(self.player.x, self.player.y, true)
		self.level.map.remembers(self.player.x, self.player.y, true)
		self.level.map.fov(self.player.x, self.player.y, 20)
		self.level.map.fov_lite(self.player.x, self.player.y, 4)
		local s = self.level.map:display()
		if s then
			s:toScreen(0, 0)
		end

		local mx, my = core.mouse.get()
		local tt = self.level.map:checkAllEntities(math.floor(mx / self.level.map.tile_w), math.floor(my / self.level.map.tile_h), "tooltip")
		if tt then
			self.tooltip:set(tt)
			local t = self.tooltip:display()
			if t then t:toScreen(mx, my) end
		end
	end
end

function _M:setupCommands()
	self.key:addCommands
	{
		_LEFT = function()
			if self.player:move(self.player.x - 1, self.player.y) then
				self.paused = false
			end
		end,
		_RIGHT = function()
			if self.player:move(self.player.x + 1, self.player.y) then
				self.paused = false
			end
		end,
		_UP = function()
			if self.player:move(self.player.x, self.player.y - 1) then
				self.paused = false
			end
		end,
		_DOWN = function()
			if self.player:move(self.player.x, self.player.y + 1) then
				self.paused = false
			end
		end,
		_KP1 = function()
			if self.player:move(self.player.x - 1, self.player.y + 1) then
				self.paused = false
			end
		end,
		_KP2 = function()
			if self.player:move(self.player.x, self.player.y + 1) then
				self.paused = false
			end
		end,
		_KP3 = function()
			if self.player:move(self.player.x + 1, self.player.y + 1) then
				self.paused = false
			end
		end,
		_KP4 = function()
			if self.player:move(self.player.x - 1, self.player.y) then
				self.paused = false
			end
		end,
		_KP5 = function()
			if self.player:move(self.player.x, self.player.y) then
				self.paused = false
			end
		end,
		_KP6 = function()
			if self.player:move(self.player.x + 1, self.player.y) then
				self.paused = false
			end
		end,
		_KP7 = function()
			if self.player:move(self.player.x - 1, self.player.y - 1) then
				self.paused = false
			end
		end,
		_KP8 = function()
			if self.player:move(self.player.x, self.player.y - 1) then
				self.paused = false
			end
		end,
		_KP9 = function()
			if self.player:move(self.player.x + 1, self.player.y - 1) then
				self.paused = false
			end
		end,
	}
	self.key:setCurrent()
end
