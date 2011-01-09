-- ToME - Tales of Maj'Eyal
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
require "engine.Entity"
local Map = require "engine.Map"
local PartyOrder = require "mod.dialogs.PartyOrder"

module(..., package.seeall, class.inherit(
	engine.Entity
))

function _M:init(t, no_default)
	engine.Entity.init(self, t, no_default)

	self.members = {}
	self.m_list = {}
	self.energy = {value = 0, mod=100000} -- "Act" every tick
end

function _M:addMember(actor, def)
	if self.members[actor] then
		print("[PARTY] error trying to add existing actor: ", actor.uid, actor.name)
		return false
	end
	if type(def.control) == "nil" then def.control = "no" end
	def.title = def.title or "Party member"
	self.members[actor] = def
	self.m_list[#self.m_list+1] = actor
	def.index = #self.m_list

	actor.addEntityOrder = function(self, level)
		print("[PARTY] New member, add after", self.name, game.party.m_list[1].name)
		return game.party.m_list[1] -- Make the sure party is always consecutive in the level entities list
	end
end

function _M:removeMember(actor, silent)
	if not self.members[actor] then
		if not silent then
			print("[PARTY] error trying to remove non-existing actor: ", actor.uid, actor.name)
		end
		return false
	end
	table.remove(self.m_list, self.members[actor].index)
	self.members[actor] = nil

	actor.addEntityOrder = nil

	-- Update indexes
	for i = 1, #self.m_list do
		self.members[self.m_list[i]].index = i
	end
end

function _M:hasMember(actor)
	return self.members[actor]
end

function _M:findMember(filter)
	for i, actor in ipairs(self.m_list) do
		local ok = true
		local def = self.members[actor]

		if filter.main and not def.main then ok = false end
		if filter.type and def.type ~= filter.type then ok = false end

		if ok then return actor end
	end
end

function _M:canControl(actor, vocal)
	if not actor then return false end
	if actor == game.player then return false end

	if not self.members[actor] then
--		print("[PARTY] error trying to set player, not a member of party: ", actor.uid, actor.name)
		return false
	end
	if self.members[actor].control ~= "full" then
--		print("[PARTY] error trying to set player, not controlable: ", actor.uid, actor.name)
		return false
	end
	if actor.dead or (game.level and not game.level:hasEntity(actor)) then
		if vocal then game.logPlayer(game.player, "Can not switch control to this creature.") end
		return false
	end
	if actor.on_can_control and not actor:on_can_control(vocal) then return false end
	return true
end

function _M:setPlayer(actor)
	if type(actor) == "number" then actor = self.m_list[actor] end

	local ok, err = self:canControl(actor, true)
	if not ok then return nil, err end

	local def = self.members[actor]
	local oldp = self.player
	self.player = actor

	-- Convert the class to always be a player
	if actor.__CLASSNAME ~= "mod.class.Player" then
		actor.__PREVIOUS_CLASSNAME = actor.__CLASSNAME
		actor:replaceWith(mod.class.Player.new(actor))
		actor.changed = true
	end

	-- Setup as the curent player
	actor.player = true
	game.paused = actor:enoughEnergy()
	game.player = actor
	game.hotkeys_display.actor = actor
	Map:setViewerActor(actor)
	if game.target then game.target.source_actor = actor end
	if game.level then game.level.map:moveViewSurround(actor.x, actor.y, 8, 8) end
	actor._move_others = actor.move_others
	actor.move_others = true

	-- Change back the old actor to a normal actor
	if oldp then
		if self.members[oldp].on_uncontrol then self.members[oldp].on_uncontrol(oldp) end

		if oldp.__PREVIOUS_CLASSNAME then
			oldp:replaceWith(require(oldp.__PREVIOUS_CLASSNAME).new(oldp))
		end

		actor.move_others = actor._move_others
		oldp.changed = true
		oldp.player = nil
		if game.level and oldp.x and oldp.y then oldp:move(oldp.x, oldp.y, true) end
	end

	if def.on_control then def.on_control(actor) end

	if game.level and actor.x and actor.y then actor:move(actor.x, actor.y, true) end

	game.logPlayer(actor, "#MOCCASIN#Character control switched to %s.", actor.name)

	return true
end

function _M:findSuitablePlayer(type)
	for i, actor in ipairs(self.m_list) do
		local def = self.members[actor]
		if def.control == "full" and (not type or def.type == type) and not actor.dead then
			self:setPlayer(actor)
			return true
		end
	end
	return false
end

function _M:canOrder(actor, order, vocal)
	if not actor then return false end
	if actor == game.player then return false end

	if not self.members[actor] then
--		print("[PARTY] error trying to order, not a member of party: ", actor.uid, actor.name)
		return false
	end
	if self.members[actor].control ~= "full" or self.members[actor].control ~= "order" or not self.members[actor].orders then
--		print("[PARTY] error trying to order, not controlable: ", actor.uid, actor.name)
		return false
	end
	if actor.dead or (game.level and not game.level:hasEntity(actor)) then
		if vocal then game.logPlayer(game.player, "Can not give orders to this creature.") end
		return false
	end
	if actor.on_can_order and not actor:on_can_order(vocal) then return false end
	if order and not self.members[actor].orders[order] then
--		print("[PARTY] error trying to order, unknown order: ", actor.uid, actor.name)
		return false
	end
	return true
end

function _M:giveOrders(actor)
	if type(actor) == "number" then actor = self.m_list[actor] end

	local ok, err = self:canOrder(actor, nil, true)
	if not ok then return nil, err end

	local def = self.members[actor]

	game:registerDialog(PartyOrder.new(actor, def))

	return true
end

function _M:giveOrder(actor, order)
	if type(actor) == "number" then actor = self.m_list[actor] end

	local ok, err = self:canOrder(actor, order, true)
	if not ok then return nil, err end

	local def = self.members[actor]

	if order == "leash" then
	elseif order == "behavior" then
--		game:registerDialog(require
	end

	return true
end

function _M:select(actor)
	if not actor then return false end
	if type(actor) == "number" then actor = self.m_list[actor] end
	if actor == game.player then return false end

	if self:canControl(actor) then return self:setPlayer(actor)
	elseif self:canOrder(actor) then return self:giveOrders(actor)
	end
	return false
end
