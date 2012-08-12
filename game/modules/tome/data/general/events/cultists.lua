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

-- Unique
if game.state:doneEvent(event_id) then return end

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

game.level.event_cultists = {sacrifice = 0, kill = 0}

for i, p in ipairs(list) do
	local g = game.level.map(p.x, p.y, engine.Map.TERRAIN):cloneFull()
	g.name = "monolith"
	g.display='&' g.color_r=0 g.color_g=255 g.color_b=255 g.notice = true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/moonstone_0"..rng.range(1,8)..".png", display_y=-1, display_h=2, z=18}
	g.nice_tiler = nil
	g.is_monolith = true
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
			[Talents.T_BLOOD_SPRAY]={base=2, every=10, max=7},
			[Talents.T_DRAIN]={base=2, every=10, max=7},
			[Talents.T_SOUL_ROT]={base=2, every=10, max=7},
			[Talents.T_BLOOD_GRASP]={base=2, every=10, max=6},
			[Talents.T_BONE_SPEAR]={base=2, every=10, max=7},
		},
		resolvers.sustains_at_birth(),
		resolvers.inscriptions(1, "rune"),
		is_cultist_event = true,
		monolith_x = p.x,
		monolith_y = p.y,
		on_die = function(self)
			local g = game.level.map(self.monolith_x, self.monolith_y, engine.Map.TERRAIN)
			if not g or not g.is_monolith then return end
			if self.self_sacrifice then
				self:doEmote(rng.table{"My soul for her!", "The Dark Queen shall reign!", "Take me! Take me!", "From death comes life!"}, 60)
				g.add_displays[#g.add_displays].image = g.add_displays[#g.add_displays].image:gsub("/moonstone_0", "/darkgreen_moonstone_0")
				g.name = "corrupted monolith"
				game.level.event_cultists.sacrifice = game.level.event_cultists.sacrifice + 1
			else
				self:doEmote(rng.table{"This is too soon!", "No the ritual will weaken!"}, 60)
				g.add_displays[#g.add_displays].image = g.add_displays[#g.add_displays].image:gsub("/moonstone_0", "/bluish_moonstone_0")
				g.name = "disrupted monolith"
				game.level.event_cultists.kill = game.level.event_cultists.kill + 1
			end
			g:removeAllMOs()
			game.level.map:updateMap(self.monolith_x, self.monolith_y)
			if not game.level.turn_counter then
				game.level.event_cultists.queen_x = self.monolith_x
				game.level.event_cultists.queen_y = self.monolith_y
				game.level.turn_counter = 10 * 210
				game.level.max_turn_counter = 10 * 210
				game.level.turn_counter_desc = "Something the cultists are doing is coming. Beware."
				require("engine.ui.Dialog"):simplePopup("Cultist", "The cultist soul seems to be absorbed by the strange stone he was guarding. You feel like something is about to happen...")
			end
		end,
	}
	m:resolve() m:resolve(nil, true)
	game.zone:addEntity(game.level, m, "actor", p.x-1, p.y)
end

game.zone.cultist_event_levels = game.zone.cultist_event_levels or {}
game.zone.cultist_event_levels[level.level] = true

if not game.zone.cultist_event_on_turn then game.zone.cultist_event_on_turn = game.zone.on_turn or function() end end
game.zone.on_turn = function()
	if game.zone.cultist_event_on_turn then game.zone.cultist_event_on_turn() end
	if not game.zone.cultist_event_levels[game.level.level] then return end

	if game.level.turn_counter then
		game.level.turn_counter = game.level.turn_counter - 1
		game.player.changed = true
		if game.level.turn_counter < 0 then
			game.level.turn_counter = nil

			local scale = (7 - game.level.event_cultists.kill) / 6

			local Talents = require("engine.interface.ActorTalents")
			local m = mod.class.NPC.new{
				type = "demon", subtype = "major",
				display = 'U',
				name = "Shasshhiy'Kaish", color=colors.VIOLET, unique = true,
				resolvers.nice_tile{image="invis.png", add_mos = {{image="npc/demon_major_shasshhiy_kaish.png", display_h=2, display_y=-1}}},
				desc = [[This demon would be very attractive if not for the hovering crown of flames, the three tails and sharp claws. As you watch her you can almost feel pain digging in your flesh. She wants you to suffer.]],
				killer_message = "and used for her perverted desires",
				level_range = {25, nil}, exp_worth = 2,
				female = 1,
				faction = "fearscape",
				rank = 4,
				size_category = 4,
				max_life = 250, life_rating = 27, fixed_rating = true,
				infravision = 10,
				stats = { str=25, dex=25, cun=32, mag=26, con=14 },
				move_others=true,

				instakill_immune = 1,
				stun_immune = 0.5,
				blind_immune = 0.5,
				combat_armor = 0, combat_def = 0,

				open_door = true,

				autolevel = "warriormage",
				ai = "tactical", ai_state = { talent_in=2, ai_move="move_astar", },
				ai_tactic = resolvers.tactic"melee",
				resolvers.inscriptions(3, "rune"),

				body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },

				combat = { dam=resolvers.levelup(resolvers.mbonus(86, 20), 1, 1.4), atk=50, apr=30, dammod={str=1.1} },

				resolvers.drops{chance=100, nb=math.ceil(5 * scale), {tome_drops="boss"} },

				resolvers.talents{
					[Talents.T_METEOR_RAIN]={base=4, every=5, max=7},
					[Talents.T_INNER_DEMONS]={base=4, every=5, max=7},
					[Talents.T_FLAME_OF_URH_ROK]={base=5, every=5, max=8},
					[Talents.T_PACIFICATION_HEX]={base=5, every=5, max=8},
					[Talents.T_BURNING_HEX]={base=5, every=5, max=8},
					[Talents.T_BLOOD_LOCK]={base=5, every=5, max=8},
					[Talents.T_SPELLCRAFT]=5,
				},
				resolvers.sustains_at_birth(),

				inc_damage = {all=90},
			}
			if game.level.event_cultists.kill == 1 then
				m.on_die = function(self) world:gainAchievement("EVENT_CULTISTS", game:getPlayer(true)) end
			end
			m:resolve() m:resolve(nil, true)

			local o = mod.class.Object.new{
				define_as = "METEORIC_CROWN",
				slot = "HEAD",
				type = "armor", subtype="head",
				name = "Crown of Burning Pain", image = "object/artifact/crown_of_burning_pain.png",
				unided_name = "burning crown",
				desc = [[This crown of pure flames possess a myriad of small molten rocks floating wildly above it. Each can be removed to throw as a true meteor.]],
				add_name = " (#ARMOR#)",
				power_source = {arcane=true},
				display = "]", color=colors.SLATE,
				moddable_tile = resolvers.moddable_tile("helm"),
				require = { talent = { m.T_ARMOUR_TRAINING }, },
				encumber = 4,
				metallic = true,
				unique = true,
				require = { stat = { cun=25 } },
				level_range = {20, 35},
				cost = 300,
				material_level = 3,
				wielder = {
					inc_stats = { [m.STAT_CUN] = math.floor(scale * 6), [m.STAT_WIL] = math.floor(scale * 6), },
					combat_def = math.floor(3 + scale * 10),
					combat_armor = 0,
					fatigue = 4,
					resists = { [engine.DamageType.FIRE] = 5 + math.floor(scale * 30)},
					inc_damage = { [engine.DamageType.FIRE] = 5 + math.floor(scale * 30)},
				},
				max_power = 50, power_regen = 1,
				use_talent = { id = m.T_METEOR_RAIN, level = 2, power = 50 - math.floor(scale * 25) },
			}
			o:resolve() o:resolve(nil, true)

			local x, y = util.findFreeGrid(game.level.event_cultists.queen_x-1, game.level.event_cultists.queen_y, 10, true, {[engine.Map.ACTOR]=true})
			if x then
				m.inc_damage.all = m.inc_damage.all - 10 * (game.level.event_cultists.kill)
				m.max_life = m.max_life * (14 - game.level.event_cultists.kill) / 14
				game.zone:addEntity(game.level, o, "object")
				m:addObject(m:getInven("INVEN"), o)

				game.zone:addEntity(game.level, m, "actor", x, y)
				require("engine.ui.Dialog"):simpleLongPopup("Cultist", "A terrible shout thunders across the level: 'Come my darling, come, I will be ssssooo *nice* to you!'\nYou should flee from this level!", 400)
			end
		elseif  game.level.turn_counter == 10 * 180 or
			game.level.turn_counter == 10 * 150 or
			game.level.turn_counter == 10 * 120 or
			game.level.turn_counter == 10 * 90 or
			game.level.turn_counter == 10 * 60 or
			game.level.turn_counter == 10 * 30 then
			local cultists = {}
			for uid, e in pairs(game.level.entities) do if e.is_cultist_event then cultists[#cultists+1] = e end end
			if #cultists > 0 then
				local c = rng.table(cultists)
				game.logSeen(c, "%s pulls a dagger and opens his own chest, piercing his beating heart. The stone glows with malevolent colors.", c.name:capitalize())
				c.self_sacrifice = true
				c:die()
			end
		end
	end
end

return true
