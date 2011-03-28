-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	return p.descriptor.world..","..p.descriptor.subrace..","..p.descriptor.subclass..","..p.descriptor.difficulty
end

function _M:registerDeath(src)
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})
	local name = src.name

	profile.mod.deaths = profile.mod.deaths or {}
	profile.mod.deaths.count = (profile.mod.deaths.count or 0) + 1

	profile.mod.deaths.sources = profile.mod.deaths.sources or {}
	profile.mod.deaths.sources[pid] = profile.mod.deaths.sources[pid] or {}
	profile.mod.deaths.sources[pid][name] = (profile.mod.deaths.sources[pid][name] or 0) + 1
	profile:saveModuleProfile("deaths", profile.mod.deaths)
end

function _M:registerUniqueKilled(who)
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})

	profile.mod.uniques = profile.mod.uniques or { uniques={} }
	profile.mod.uniques.uniques[who.name] = profile.mod.uniques.uniques[who.name] or {}
	profile.mod.uniques.uniques[who.name][pid] = (profile.mod.uniques.uniques[who.name][pid] or 0) + 1
	profile:saveModuleProfile("uniques", profile.mod.uniques)
end

function _M:registerArtifactsPicked(what)
	if what.stat_picked_up then return end
	what.stat_picked_up = true
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})
	local name = what:getName{do_color=false, do_count=false, force_id=true}

	profile.mod.artifacts = profile.mod.artifacts or { artifacts={} }
	profile.mod.artifacts.artifacts[name] = profile.mod.artifacts.artifacts[name] or {}
	profile.mod.artifacts.artifacts[name][pid] = (profile.mod.artifacts.artifacts[name][pid] or 0) + 1
	profile:saveModuleProfile("artifacts", profile.mod.artifacts)
end

function _M:registerCharacterPlayed()
	local pid = self:playerStatGetCharacterIdentifier(game.party:findMember{main=true})

	profile.mod.characters = profile.mod.characters or { characters={} }
	profile.mod.characters.characters[pid] = (profile.mod.characters.characters[pid] or 0) + 1
	profile:saveModuleProfile("characters", profile.mod.characters)
end
