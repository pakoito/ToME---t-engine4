-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
require "engine.Entity"
local Dialog = require "engine.ui.Dialog"
local Map = require "engine.Map"
local Particles = require "engine.Particles"
require "mod.class.Player"

module(..., package.seeall, class.inherit(mod.class.Player))

function _M:init(t, no_default)
	mod.class.Player.init(self, t, no_default)

	self.name = "Yiilkgur, the Sher'Tul Fortress"
	self.is_fortress = true
	self.no_worldmap_encounter = true
	self.allow_talents_worldmap = true
	self.faction = game:getPlayer(true).faction
	self.no_inventory_access = true
	self.no_breath = true
	self.no_party_class = true
	self.no_leave_control = true
	self.no_levelup_access = true
--	self.can_change_level = true
--	self.can_change_zone = true
	self.display = ' '
	self.moddable_tile = nil
	self.can_pass = {pass_water=500, pass_wall=500, pass_tree=500}
	self.image="terrain/shertul_flying_castle.png"
	self.display_h = 2
	self.display_y = -1
	self.z = 18

	self.max_life = 10000
	self.life = 10000
	self.energy.mod = 2

	self.shader = "moving_transparency"

	self:learnTalent(self.T_SHERTUL_FORTRESS_GETOUT, true)
	self:learnTalent(self.T_SHERTUL_FORTRESS_BEAM, true)

	self:addParticles(Particles.new("shertul_fortress_orbiters", 1, {}))
end

function _M:tooltip(x, y, seen_by)
	return tstring{{"color", "GOLD"}, self.name, {"color", "WHITE"}}
end

function _M:die(src, death_note)
	return self:onPartyDeath(src, death_note)
end

--- Attach or remove a display callback
-- Defines particles to display
function _M:defineDisplayCallback()
	if not self._mo then return end

	local ps = self:getParticlesList()

	local f_self = nil
	local f_danger = nil
	local f_powerful = nil
	local f_friend = nil
	local f_enemy = nil
	local f_neutral = nil

	self._mo:displayCallback(function(x, y, w, h, zoom, on_map)
		local e
		for i = 1, #ps do
			e = ps[i]
			e:checkDisplay()
			if e.ps:isAlive() then e.ps:toScreen(x + w / 2, y + h / 2, true, w / (game.level and game.level.map.tile_w or w))
			else self:removeParticles(e)
			end
		end

		return true
	end)
end

function _M:move(x, y, force)
	local ox, oy = self.x, self.y
	local moved = self:moveModActor(x, y, force)
	if moved then
		game.level.map:moveViewSurround(self.x, self.y, 8, 8)
		game.level.map.attrs(self.x, self.y, "walked", true)

		if self.describeFloor then self:describeFloor(self.x, self.y) end
	end

	-- Update wilderness coords
	if game.zone.wilderness and not force then
		-- Cheat with time
		game.turn = game.turn + 1000
		local p = game:getPlayer(true)
		p.wild_x, p.wild_y = self.x, self.y
		if self.x ~= ox or self.y ~= oy then
			game.state:worldDirectorAI()
		end
	end

	-- Update zone name
	if game.zone.variable_zone_name then game:updateZoneName() end

	return moved
end

function _M:moveModActor(x, y, force)
	local moved = false
	local ox, oy = self.x, self.y

	if force or self:enoughEnergy() then

		-- Confused ?
		if not force and self:attr("confused") then
			if rng.percent(self:attr("confused")) then
				x, y = self.x + rng.range(-1, 1), self.y + rng.range(-1, 1)
			end
		end

		-- Encased in ice, attack the ice
		if not force and self:attr("encased_in_ice") then
			self:attackTarget(self)
			moved = true
		-- Should we prob travel through walls ?
		elseif not force and self:attr("prob_travel") and game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			moved = self:probabilityTravel(x, y, self:attr("prob_travel"))
		-- Never move but tries to attack ? ok
		elseif not force and self:attr("never_move") then
			-- A bit weird, but this simple asks the collision code to detect an attack
			if not game.level.map:checkAllEntities(x, y, "block_move", self, true) then
				game.logPlayer(self, "You are unable to move!")
			end
		else
			moved = self:moveEngineMove(x, y, force)
		end
		if not force and moved and (self.x ~= ox or self.y ~= oy) and not self.did_energy then
			self:useEnergy(game.energy_to_act * self:combatMovementSpeed())
		end
	end
	self.did_energy = nil

	-- Try to detect traps
	if self:knowTalent(self.T_HEIGHTENED_SENSES) then
		local power = self:getTalentLevel(self.T_HEIGHTENED_SENSES) * self:getCun(25, true)
		local grids = core.fov.circle_grids(self.x, self.y, 1, true)
		for x, yy in pairs(grids) do for y, _ in pairs(yy) do
			local trap = game.level.map(x, y, Map.TRAP)
			if trap and not trap:knownBy(self) and self:checkHit(power, trap.detect_power) then
				trap:setKnown(self, true)
				game.level.map:updateMap(x, y)
				game.logPlayer(self, "You have found a trap (%s)!", trap:getName())
			end
		end end
	end

	if moved and self:isTalentActive(self.T_BODY_OF_STONE) then
		self:forceUseTalent(self.T_BODY_OF_STONE, {ignore_energy=true})
	end

	if moved and not force and ox and oy and (ox ~= self.x or oy ~= self.y) and config.settings.tome.smooth_move > 0 then
		local blur = 0
		self:setMoveAnim(ox, oy, config.settings.tome.smooth_move, blur)
	end

	return moved
end

--- Moves an actor on the map
-- *WARNING*: changing x and y properties manually is *WRONG* and will blow up in your face. Use this method. Always.
-- @param map the map to move onto
-- @param x coord of the destination
-- @param y coord of the destination
-- @param force if true do not check for the presence of an other entity. *Use wisely*
-- @return true if a move was *ATTEMPTED*. This means the actor will probably want to use energy
function _M:moveEngineMove(x, y, force)
	if self.dead then return true end
	local map = game.level.map

	x = math.floor(x)
	y = math.floor(y)

	if x < 0 then x = 0 end
	if x >= map.w then x = map.w - 1 end
	if y < 0 then y = 0 end
	if y >= map.h then y = map.h - 1 end

	if not force and map:checkAllEntities(x, y, "block_fortress", self, true) then return true end
	if not force and map.attrs(x, y, "block_fortress") then return true end

	if self.x and self.y then
		map:remove(self.x, self.y, Map.PROJECTILE)
	else
--		print("[MOVE] actor moved without a starting position", self.name, x, y)
	end
	self.old_x, self.old_y = self.x or x, self.y or y
	self.x, self.y = x, y
	map(x, y, Map.PROJECTILE, self)

	-- Move emote
	if self.__emote then
		if self.__emote.dead then self.__emote = nil
		else
			self.__emote.x = x
			self.__emote.y = y
			map.emotes[self.__emote] = true
		end
	end

	map:checkAllEntities(x, y, "on_move", self, force)

	return true
end

function _M:takeControl(from)
	game:onTickEnd(function()
		game.party:addMember(self, {temporary_level=1, control="full"})
		game.party:setPlayer(self, true)
		game.level.map:remove(from.x, from.y, engine.Map.ACTOR)
		from:attr("dont_act", 1)
	end)
end

--- Checks if something bumps in us
-- If it happens the method attack is called on the target with the attacker as parameter.
-- Do not touch!
function _M:block_move(x, y, e, act)
	if act and e == game.player then
		Dialog:yesnoPopup(self.name, "Do you wish to teleport to the fortress?", function(ret) if ret then
			if not game.zone.wilderness then
				Dialog:simplePopup(self.name, "The teleport fizzles!")
				return
			end
			self:takeControl(e)
		end end)
	end
	return false
end

function _M:deleteFromMap(map)
	if self.x and self.y and map then
		map:remove(self.x, self.y, engine.Map.PROJECTILE)
		self:closeParticles()
	end
end
