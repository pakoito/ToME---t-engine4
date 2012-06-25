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

local list = {}

local function check(x, y)
	if not game.state:canEventGrid(level, x, y) then return false end
	if not game.state:canEventGrid(level, x-1, y) or level.map(x-1, y, level.map.ACTOR) then return false end
	return true
end

for i = 1, 7 do
	local x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
	local tries = 0
	while not check(x, y) and tries < 100 do
		x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
		tries = tries + 1
	end
	if tries >= 100 then return false end
	list[#list+1] = {x=x, y=y}
end

local Talents = require("engine.interface.ActorTalents")

for i, p in ipairs(list) do
	local g = game.level.map(p.x, p.y, engine.Map.TERRAIN):cloneFull()
	g.name = "monolith"
	g.display='&' g.color_r=0 g.color_g=255 g.color_b=255 g.notice = true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/moonstone_0"..rng.range(1,8)..".png", display_y=-1, display_h=2, z=18}
	g.nice_tiler = nil
	game.zone:addEntity(game.level, g, "terrain", p.x, p.y)

	local m = mod.class.NPC.new{
		type = "humanoid", subtype = "shalore", image = "npc/humanoid_shalore_elven_corruptor.png",
		name = "Cultist",
		desc = [[An elven cultist, he doesnt seem to mind you.]],
		display = "p", color=colors.ORCHID,
		faction = "unaligned",
		combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },
		body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
		infravision = 10,
		lite = 1,
		life_rating = 11,
		rank = 3,
		size_category = 3,
		open_door = true,
		silence_immune = 0.5,
		resolvers.racial(),
		autolevel = "caster",
		ai = "tactical", ai_state = { ai_move="move_dmap", talent_in=1, },
		ai_tactic = resolvers.tactic"ranged",
		stats = { str=10, dex=8, mag=20, con=16 },
		level_range = {5, nil}, exp_worth = 1,
		max_life = resolvers.rngavg(100, 110),
		resolvers.equip{
			{type="weapon", subtype="staff", forbid_power_source={antimagic=true}, autoreq=true},
			{type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true},
		},
		resolvers.talents{
			[Talents.T_BONE_SHIELD]={base=2, every=10, max=5},
			[Talents.T_BLOOD_SPRAY]={base=5, every=10, max=7},
			[Talents.T_DRAIN]={base=5, every=10, max=7},
			[Talents.T_SOUL_ROT]={base=5, every=10, max=7},
			[Talents.T_BLOOD_GRASP]={base=4, every=10, max=6},
			[Talents.T_BONE_SPEAR]={base=5, every=10, max=7},
		},
		resolvers.sustains_at_birth(),
		resolvers.inscriptions(1, "rune"),
	}
	m:resolve() m:resolve(nil, true)
	game.zone:addEntity(game.level, m, "actor", p.x-1, p.y)
end

return true
