-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
require "mod.class.NPC"
local Map = require "engine.Map"
local ActorTalents = require "engine.interface.ActorTalents"

--- Defines the player
-- It is a normal actor, with some redefined methods to handle user interaction.<br/>
-- It is also able to run and rest and use hotkeys
module(..., package.seeall, class.inherit(
	mod.class.NPC
))

function _M:init(t, no_default)
	t.display=''
	t.color_r=230
	t.color_g=230
	t.color_b=230

	t.player = true
	t.type = t.type or "humanoid"
	t.subtype = t.subtype or "player"
	t.faction = t.faction or "players"

	t.lite = t.lite or 0

	t.ai = "player_demo"
	t.ai_state = { talent_in=2, },

	mod.class.NPC.init(self, t, no_default)

	self:learnTalent(self.T_MANATHRUST, true, 2)
	self:learnTalent(self.T_FLAME, true, 2)
	self:learnTalent(self.T_FIREFLASH, true, 2)
	self:learnTalent(self.T_LIGHTNING, true, 2)
	self:learnTalent(self.T_SUNSHIELD, true, 2)
	self:learnTalent(self.T_FLAMESHOCK, true, 2)

	local tile = rng.range(1, 4)
	if tile == 1 then
		self.image = "player/humanoid_dwarf_dwarven_summoner.png"
	elseif tile == 2 then
		self.image = "player/humanoid_human_riala_shalarak.png"
	elseif tile == 3 then
		self.image = "player/humanoid_elf_high_chronomancer_zemekkys.png"
	elseif tile == 4 then
		self.image = "player/humanoid_halfling_protector_myssil.png"
	end
	self:removeAllMOs()
end

function _M:move(x, y, force)
	local moved = mod.class.NPC.move(self, x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)
	end
	return moved
end

function _M:act()
	if not mod.class.NPC.act(self) then return end
end

-- Precompute FOV form, for speed
local fovdist = {}
for i = 0, 30 * 30 do
	fovdist[i] = math.max((20 - math.sqrt(i)) / 17, 0.6)
end

function _M:playerFOV()
	-- Clean FOV before computing it
	game.level.map:cleanFOV()
	-- Compute both the normal and the lite FOV, using cache
	-- Do it last so it overrides others
	self:computeFOV(self.sight or 10, "block_sight", function(x, y, dx, dy, sqdist)
		game.level.map:apply(x, y, fovdist[sqdist])
	end, true, false, true)
	self:computeFOV(self.lite, "block_sight", function(x, y, dx, dy, sqdist) game.level.map:applyLite(x, y) end, true, true, true)
end

function _M:onTakeHit(value, src)
	return 0
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
	mod.class.NPC.levelup(self)

	local x, y = game.level.map:getTileToScreen(self.x, self.y)
	game.flyers:add(x, y, 80, 0.5, -2, "LEVEL UP!", {0,255,255})
end
