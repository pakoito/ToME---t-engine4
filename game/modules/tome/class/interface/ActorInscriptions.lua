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
local Chat = require "engine.Chat"
local Dialog = require "engine.ui.Dialog"

module(..., package.seeall, class.make)

--- Init inscriptions
function _M:init(t)
	self.inscriptions = self.inscriptions or {}
	self.inscriptions_data = self.inscriptions_data or {}
	self.max_inscriptions = self.max_inscriptions or 3
	self.inscriptions_slots_added = self.inscriptions_slots_added or 0
end

function _M:setInscription(id, name, data, cooldown, vocal, src, bypass_max_same, bypass_max)
	-- Check allowance
	local t = self:getTalentFromId(self["T_"..name.."_1"])
	if self.inscription_restrictions and not self.inscription_restrictions[t.type[1]] then
		if vocal then game.logPlayer(self, "You are unable to use this kind of inscription.") end
		return
	end

	-- Count occurrences
	local nb_same = 0
	for i = 1, self.max_inscriptions do
		if self.inscriptions[i] and self.inscriptions[i] == name.."_"..i then nb_same = nb_same + 1 end
	end
	if nb_same >= 2 and not bypass_max_same then
		if vocal then game.logPlayer(self, "You already have too many of this inscription.") end
		-- Replace chat
		if self.player and src then
			local t = self:getTalentFromId(self["T_"..name.."_1"])
			src.player = self
			src.iname = name
			src.idata = data
			src.replace_same = name
			local chat = Chat.new("player-inscription", {name=t.name}, self, src)
			chat:invoke()
		end
		return
	end

	-- Find a spot
	if not id then
		for i = 1, (bypass_max and 6 or self.max_inscriptions) do
			if not self.inscriptions[i] then id = i break end
		end
	end
	if not id then
		if vocal then
			game.logPlayer(self, "You are have no more inscription slots.")
		end
		-- Replace chat
		if self.player and src then
			local t = self:getTalentFromId(self["T_"..name.."_1"])
			src.player = self
			src.iname = name
			src.idata = data
			local chat = Chat.new("player-inscription", {name=t.name}, self, src)
			chat:invoke()
		end
		return
	end

	-- Unlearn old talent
	local oldname = self.inscriptions[id]
	local oldpos = nil
	if oldname then
		for i = 1, 12 * self.nb_hotkey_pages do
			if self.hotkey[i] and self.hotkey[i][1] == "talent" and self.hotkey[i][2] == "T_"..oldname then oldpos = i break end
		end
		self:unlearnTalent(self["T_"..oldname])
		self.inscriptions_data[oldname] = nil
	end


	-- Learn new talent
	name = name.."_"..id
	data.__id = id
	if src and src.obj then data.item_name = src.obj:getName{do_color=true, no_count=true}:toTString() end
	self.inscriptions_data[name] = data
	self.inscriptions[id] = name
	print("Inscribing on "..self.name..": "..tostring(name))
	self:learnTalent(self["T_"..name], true, 1, {no_unlearn=true})
	local t = self:getTalentFromId(self["T_"..name])
	if cooldown then self:startTalentCooldown(t) end
	if vocal then
		game.logPlayer(self, "You are now inscribed with %s.", t.name)
	end

	-- Hotkey
	if oldpos then
		for i = 1, 12 * self.nb_hotkey_pages do
			if self.hotkey[i] and self.hotkey[i][1] == "talent" and self.hotkey[i][2] == "T_"..name then self.hotkey[i] = nil end
		end
		self.hotkey[oldpos] = {"talent", "T_"..name}
	end

	return true
end

function _M:getInscriptionData(name)
	local fake = self.__inscription_data_fake
	assert(fake or self.inscriptions_data[name], "unknown inscription "..name)
	local d = table.clone(fake or self.inscriptions_data[name])
	d.inc_stat = 0
	if d.use_any_stat and d.use_stat_mod then
		local max = math.max(
			self:getStr(),
			self:getDex(),
			self:getCon(),
			self:getMag(),
			self:getWil(),
			self:getCun()
		) * d.use_any_stat
		d.inc_stat = max * d.use_stat_mod
	elseif d.use_stat and d.use_stat_mod then d.inc_stat = self:getStat(d.use_stat) * d.use_stat_mod end
	return d
end

function _M:usedInscription(name)
	assert(self.inscriptions_data[name], "unknown inscription "..name)
	local d = self.inscriptions_data[name]
	if not d.nb_uses then return end
	d.nb_uses = d.nb_uses - 1
	if d.nb_uses <= 0 then
		local t = self:getTalentFromId(self["T_"..name])
		game.logPlayer(self, "Your %s is depleted!", t.name)
		game:onTickEnd(function()
			self:unlearnTalent(self["T_"..name])
			self.inscriptions[d.__id] = nil
			self.inscriptions_data[name] = nil
		end)
	end
end
