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
local ActorAI = require "engine.interface.ActorAI"
local Faction = require "engine.Faction"
local Emote = require("engine.Emote")
local Map = require("engine.Map")
require "mod.class.Actor"

module(..., package.seeall, class.inherit(mod.class.Actor, engine.interface.ActorAI))

function _M:init(t, no_default)
	if type(t.cant_be_moved) == "nil" then t.cant_be_moved = true end
	mod.class.Actor.init(self, t, no_default)
	ActorAI.init(self, t)

	-- Grab default image name if none is set
	if not self.image and self.name ~= "unknown actor" then self.image = "npc/"..tostring(self.type or "unknown").."_"..tostring(self.subtype or "unknown"):lower():gsub("[^a-z0-9]", "_").."_"..(self.name or "unknown"):lower():gsub("[^a-z0-9]", "_")..".png" end

	self.unit_power = self.unit_power or 0
	self.max_unit_power = self.max_unit_power or self.unit_power
end

--- Checks what to do with the target
-- Talk ? attack ? displace ?
function _M:bumpInto(target, x, y)
	local reaction = self:reactionToward(target)
	if reaction < 0 then
		return self:encounterAttack(target, x, y)
	elseif reaction >= 0 then
		-- Talk ?
		if target.player and self.can_talk then
			local chat = Chat.new(self.can_talk, self, target)
			chat:invoke()
			if self.can_talk_only_once then self.can_talk = nil end
		elseif target.cant_be_moved and self.cant_be_moved and target.x and target.y and self.x and self.y then
			-- Displace
			local tx, ty, sx, sy = target.x, target.y, self.x, self.y
			target.x = nil target.y = nil
			self.x = nil self.y = nil
			target:move(sx, sy, true)
			self:move(tx, ty, true)
		end
	end
end

function _M:takeHit()
	return nil, 0
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
		-- Tactical info
		if game.level and game.always_target then
			-- Tactical life info
			if on_map then
				local dh = h * 0.1
				local lp = self.unit_power / self.max_unit_power + 0.0001
				if lp > .75 then -- green
					core.display.drawQuad(x + 3, y + h - dh, w - 6, dh, 129, 180, 57, 128)
					core.display.drawQuad(x + 3, y + h - dh, (w - 6) * lp, dh, 50, 220, 77, 255)
				elseif lp > .5 then -- yellow
					core.display.drawQuad(x + 3, y + h - dh, w - 6, dh, 175, 175, 10, 128)
					core.display.drawQuad(x + 3, y + h - dh, (w - 6) * lp, dh, 240, 252, 35, 255)
				elseif lp > .25 then -- orange
					core.display.drawQuad(x + 3, y + h - dh, w - 6, dh, 185, 88, 0, 128)
					core.display.drawQuad(x + 3, y + h - dh, (w - 6) * lp, dh, 255, 156, 21, 255)
				else -- red
					core.display.drawQuad(x + 3, y + h - dh, w - 6, dh, 167, 55, 39, 128)
					core.display.drawQuad(x + 3, y + h - dh, (w - 6) * lp, dh, 235, 0, 0, 255)
				end
			end
		end

		-- Tactical info
		if game.level and game.level.map.view_faction then
			local map = game.level.map
			if on_map then
				if not f_self then
					f_self = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_self)
					f_powerful = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_powerful)
					f_danger = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_danger)
					f_friend = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_friend)
					f_enemy = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_enemy)
					f_neutral = game.level.map.tilesTactic:get(nil, 0,0,0, 0,0,0, map.faction_neutral)
				end

				if self.faction then
					local friend
					if not map.actor_player then friend = Faction:factionReaction(map.view_faction, self.faction)
					else friend = map.actor_player:reactionToward(self) end

					if self == map.actor_player then
						f_self:toScreen(x, y, w, h)
					elseif map:faction_danger_check(self) then
						if friend >= 0 then f_powerful:toScreen(x, y, w, h)
						else f_danger:toScreen(x, y, w, h) end
					elseif friend > 0 then
						f_friend:toScreen(x, y, w, h)
					elseif friend < 0 then
						f_enemy:toScreen(x, y, w, h)
					else
						f_neutral:toScreen(x, y, w, h)
					end
				end
			end
		end

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

function _M:encounterAttack(target, x, y)
	if target.player then target:onWorldEncounter(self, self.x, self.y) return end

	self.unit_power = self.unit_power or 0
	target.unit_power = target.unit_power or 0

	if self.unit_power > target.unit_power then
		self.unit_power = self.unit_power - target.unit_power
		target.unit_power = 0
	elseif self.unit_power < target.unit_power then
		target.unit_power = target.unit_power - self.unit_power
		self.unit_power = 0
	else
		self.unit_power, target.unit_power = self.unit_power - target.unit_power, target.unit_power - self.unit_power
	end

	if self.unit_power <= 0 then
		game.logSeen(self, "%s kills %s.", target.name:capitalize(), self.name)
		self:die(target)
	end
	if target.unit_power <= 0 then
		game.logSeen(target, "%s kills %s.", self.name:capitalize(), target.name)
		target:die(src)
	end
end

function _M:act()
	while self:enoughEnergy() and not self.dead do
		-- Do basic actor stuff
		if not mod.class.Actor.act(self) then return end

		-- Compute FOV, if needed
		self:doFOV()

		-- Let the AI think .... beware of Shub !
		-- If AI did nothing, use energy anyway
		self:doAI()

		if not self.energy.used then self:useEnergy() end
	end
end

function _M:doFOV()
	self:computeFOV(self.sight or 4, "block_sight", nil, nil, nil, true)
end

function _M:tooltip(x, y, seen_by)
	if seen_by and not seen_by:canSee(self) then return end
	local factcolor, factstate, factlevel = "#ANTIQUE_WHITE#", "neutral", self:reactionToward(game.player)
	if factlevel < 0 then factcolor, factstate = "#LIGHT_RED#", "hostile"
	elseif factlevel > 0 then factcolor, factstate = "#LIGHT_GREEN#", "friendly"
	end

	local rank, rank_color = self:TextRank()

	local ts = tstring{}
	ts:add({"uid",self.uid}) ts:merge(rank_color:toTString()) ts:add(self.name, {"color", "WHITE"}, true)
	ts:add(self.type:capitalize(), " / ", self.subtype:capitalize(), true)
	ts:add("Rank: ") ts:merge(rank_color:toTString()) ts:add(rank, {"color", "WHITE"}, true)
	ts:add(self.desc, true)
	ts:add("Faction: ") ts:merge(factcolor:toTString()) ts:add(("%s (%s, %d)"):format(Faction.factions[self.faction].name, factstate, factlevel), {"color", "WHITE"}, true)
	ts:add(
		("Killed by you: "):format(killed), true,
		"Target: ", self.ai_target.actor and self.ai_target.actor.name or "none", true,
		"UID: "..self.uid
	)

	return ts
end

function _M:die(src)
	engine.interface.ActorLife.die(self, src)
end
