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


module(..., package.seeall, class.make)

function _M:playerStatGetCharacterIdentifier(p)
	return p.descriptor.world..","..p.descriptor.subrace..","..p.descriptor.subclass..","..p.descriptor.difficulty..","..p.descriptor.permadeath
end

function _M:registerDeath(src)
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})
	local name = src.name
	profile:saveModuleProfile("deaths", {source=name, cid=pid, nb={"inc",1}})
end

function _M:registerUniqueKilled(who)
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})

	profile:saveModuleProfile("uniques", {victim=who.name, cid=pid, nb={"inc",1}})
end

function _M:registerArtifactsPicked(what)
	if what.stat_picked_up then return end
	what.stat_picked_up = true
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})
	local name = what:getName{do_color=false, do_count=false, force_id=true, no_add_name=true}

	profile:saveModuleProfile("artifacts", {name=name, cid=pid, nb={"inc",1}})
end

function _M:registerCharacterPlayed()
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})

	profile:saveModuleProfile("characters", {cid=pid, nb={"inc",1}})
end

function _M:registerLoreFound(lore)
	profile:saveModuleProfile("lore", {name=lore, nb={"inc",1}})
end

function _M:registerEscorts(status)
	profile:saveModuleProfile("escorts", {fate=status, nb={"inc",1}})
end
