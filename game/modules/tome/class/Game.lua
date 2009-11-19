require "engine.class"
require "engine.GameTurnBased"
require "engine.KeyCommand"
require "engine.LogDisplay"
local Tooltip = require "engine.Tooltip"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Entity = require "engine.Entity"
local Player = require "tome.class.Player"
local NPC = require "tome.class.NPC"

module(..., package.seeall, class.inherit(engine.GameTurnBased))

function _M:init()
	engine.GameTurnBased.init(self, engine.Key.current, 1000, 100)
	self:setupCommands()

	self.tooltip = engine.Tooltip.new(nil, nil, {255,255,255}, {30,30,30})

	self.log = engine.LogDisplay.new(400, 150, nil, nil, nil, {255,255,255}, {30,30,30})
	self.log("Welcome to #00FF00#Tales of Middle Earth!")

	local map = Map.new(40, 20)
--	map:liteAll(0, 0, map.w, map.h)

	local floor = Entity.new{display='.', color_r=100, color_g=200, color_b=100, color_br=0, color_bg=50, color_bb=0}
	local e1 = Entity.new{display='#', color_r=255, block_sight=true, block_move=true}
	local e2 = Entity.new{display='#', color_g=255, block_sight=true, block_move=true}
	local e3 = Entity.new{display='#', color_b=255, block_sight=true, block_move=true}
	local e4 = e3:clone{color_r=255}

	for i = 0, 39 do for j = 0, 19 do
		map(i, j, 1, floor)
	end end

	map(8, 6, Map.TERRAIN, e4)
	map(8, 7, Map.TERRAIN, e2)
	map(8, 8, Map.TERRAIN, e3)
	map(9, 6, Map.TERRAIN, e1)
	map(9, 7, Map.TERRAIN, e2)
	map(9, 8, Map.TERRAIN, e3)
	map(10, 6, Map.TERRAIN, e1)
	map(10, 7, Map.TERRAIN, e2)
	map(10, 8, Map.TERRAIN, e3)

	local level = Level.new(map)
	self:setLevel(level)

	self.player = Player.new(self, {name="player", display='@', color_r=230, color_g=230, color_b=230})
	self.player:move(4, 3, true)
	level:addEntity(self.player)

	local m = NPC.new(self, {name="monster", display='D', color_r=125, color_g=125, color_b=255})
	m.energy.mod = 0.38
	m:move(1, 3, true)
	level:addEntity(m)

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()
end

function _M:tick()
	engine.GameTurnBased.tick(self)
end

function _M:display()
	self.log:display():toScreen(0, 16 * 20 + 5)

	if self.level and self.level.map then
		local s = self.level.map:display()
		if s then s:toScreen(0, 0) end

		local mx, my = core.mouse.get()
		local tt = self.level.map:checkAllEntity(math.floor(mx / 16), math.floor(my / 16), "tooltip")
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
