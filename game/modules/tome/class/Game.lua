require "engine.class"
require "engine.Game"
require "engine.KeyCommand"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Entity = require "engine.Entity"
local Actor = require "tome.class.Actor"

module(..., package.seeall, class.inherit(engine.Game))

function _M:init()
	engine.Game.init(self, engine.KeyCommand.new())
	self:setupCommands()

	local map = Map.new(40, 40)
	local floor = Entity.new{display='#', color_r=100, color_g=100, color_b=100}
	local e1 = Entity.new{display='#', color_r=255, block_sight=true}
	local e2 = Entity.new{display='#', color_g=255, block_sight=true}
	local e3 = Entity.new{display='#', color_b=255, block_sight=true, block_move=true}
	local e4 = e3:clone{color_r=255}

	for i = 0, 39 do for j = 0, 39 do
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
	level:activate()
	self:setLevel(level)

	self.player = Actor.new(self, {name="player!", display='.', color_r=125, color_g=125, color_b=0})
	self.player:move(2, 3)
end

function _M:tick()
end

function _M:setupCommands()
	self.key:addCommand("_LEFT", function()
		self.player:move(self.player.x - 1, self.player.y)
	end)
	self.key:addCommand("_RIGHT", function()
		self.player:move(self.player.x + 1, self.player.y)
	end)
	self.key:addCommand("_UP", function()
		self.player:move(self.player.x, self.player.y - 1)
	end)
	self.key:addCommand("_DOWN", function()
		self.player:move(self.player.x, self.player.y + 1)
	end)
	self.key:setCurrent()
end
