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
local Chat = require "engine.Chat"
local Dialog = require "engine.ui.Dialog"

module(..., package.seeall, class.make)

--- Init inscriptions
function _M:init(t)
	self.inscriptions = {}
	self.inscriptions_data = {}
	self.max_inscriptions = 3
end

function _M:setInscription(id, name, data, cooldown, vocal, src)
	-- Find a spot
	if not id then
		for i = 1, self.max_inscriptions do
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
	if oldname then
		self:unlearnTalent(self["T_"..oldname])
		self.inscriptions_data[oldname] = nil
	end

	-- Learn new talent
	name = name.."_"..id
	self.inscriptions_data[name] = data
	self.inscriptions[id] = name
	print("Inscribing on "..self.name..": "..tostring(name))
	self:learnTalent(self["T_"..name], true, 1)
	local t = self:getTalentFromId(self["T_"..name])
	if cooldown then self:startTalentCooldown(t) end
	if vocal then
		game.logPlayer(self, "You are now inscribed with %s.", t.name)
	end
	return true
end

function _M:getInscriptionData(name)
	assert(self.inscriptions_data[name], "unknown inscription "..name)
	local d = table.clone(self.inscriptions_data[name])
	d.inc_stat = 0
	if d.use_stat and d.use_stat_mod then d.inc_stat = self:getStat(d.use_stat) * d.use_stat_mod end
	return d
end
