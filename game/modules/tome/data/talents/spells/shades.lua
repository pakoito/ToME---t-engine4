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

newTalent{
	name = "Shadow Tunnel",
	type = {"spell/shades",1},
	require = spells_req_high1,
	points = 5,
	random_ego = "attack",
	mana = 25,
	cooldown = 20,
	range = 10,
	tactical = { DEFEND = 2 },
	requires_target = true,
	getChance = function(self, t) return 20 + self:combatTalentSpellDamage(t, 15, 60) end,
	action = function(self, t)
		local list = {}
		if game.party and game.party:hasMember(self) then
			for act, def in pairs(game.party.members) do
				if act.summoner and act.summoner == self and act.necrotic_minion then list[#list+1] = act end
			end
		else
			for uid, act in pairs(game.level.entities) do
				if act.summoner and act.summoner == self and act.necrotic_minion then list[#list+1] = act end
			end
		end

		for i, m in ipairs(list) do
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if x and y then
				m:move(x, y, true)
				game.level.map:particleEmitter(x, y, 1, "summon")
			end
			m:setEffect(m.EFF_EVASION, 5, {chance=t.getChance(self, t)})
		end

		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[Surround your minions in a veil of darkness. The darkness will teleport them to you and grant them %d%% evasion for 5 turns.
		The evasion chance will increase with your Spellpower.]]):
		format(chance)
	end,
}

newTalent{
	name = "Curse of the Meek",
	type = {"spell/shades",2},
	require = spells_req_high2,
	points = 5,
	mana = 50,
	cooldown = 30,
	range = 10,
	tactical = { DEFEND = 3 },
	action = function(self, t)
		local nb = math.ceil(self:getTalentLevel(t))
		for i = 1, nb do
			local x, y = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if x and y then
				local NPC = require "mod.class.NPC"
				local m = NPC.new{
					type = "humanoid", display = "p",
					color=colors.WHITE,

					combat = { dam=resolvers.rngavg(1,2), atk=2, apr=0, dammod={str=0.4} },

					body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
					lite = 3,

					life_rating = 10,
					rank = 2,
					size_category = 3,

					autolevel = "warrior",
					stats = { str=12, dex=8, mag=6, con=10 },
					ai = "summoned", ai_real = "dumb_talented_simple", ai_state = { talent_in=2, },
					level_range = {1, 3},

					max_life = resolvers.rngavg(30,40),
					combat_armor = 2, combat_def = 0,

					summoner = self,
					summoner_gain_exp=false,
					summon_time = 8,
				}

				m.level = 1
				local race = 5 -- rng.range(1, 5)
				if race == 1 then
					m.name = "human farmer"
					m.subtype = "human"
					m.image = "npc/humanoid_human_human_farmer.png"
					m.desc = [[A weather-worn human farmer, looking at a loss as to what's going on.]]
				elseif race == 2 then
					m.name = "halfling gardener"
					m.subtype = "halfling"
					m.desc = [[A rugged halfling gardener, looking quite confused as to what he's doing here.]]
					m.image = "npc/humanoid_halfling_halfling_gardener.png"
				elseif race == 3 then
					m.name = "shalore scribe"
					m.subtype = "shalore"
					m.desc = [[A scrawny elven scribe, looking bewildered at his surroundings.]]
					m.image = "npc/humanoid_shalore_shalore_rune_master.png"
				elseif race == 4 then
					m.name = "dwarven lumberjack"
					m.subtype = "dwarf"
					m.desc = [[A brawny dwarven lumberjack, looking a bit upset at his current situation.]]
					m.image = "npc/humanoid_dwarf_lumberjack.png"
				elseif race == 5 then
					m.name = "cute bunny"
					m.type = "vermin" m.subtype = "rodent"
					m.desc = [[It is so cute!]]
					m.image = "npc/vermin_rodent_cute_little_bunny.png"
				end
				m.faction = self.faction
				m.no_necrotic_soul = true

				m:resolve() m:resolve(nil, true)
				m:forceLevelup(self.level)
				game.zone:addEntity(game.level, m, "actor", x, y)
				game.level.map:particleEmitter(x, y, 1, "summon")
				m:setEffect(m.EFF_CURSE_HATE, 100, {src=self})
				m.on_die = function(self, src)
					local p = self.summoner:isTalentActive(self.summoner.T_NECROTIC_AURA)
					if p and src and src.reactionToward and src:reactionToward(self) < 0 and rng.percent(70) then
						p.souls = math.min(p.souls + 1, p.souls_max)
						self.summoner.changed = true
					end
				end
			end
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		return ([[Reaches through the shadows into quiter places, summoning %d harmless creatures.
		Those creatures are then cursed with a Curse of Hate, making all hostile foes try to kill them.
		If killed by hostile foes you have 70%% chance to gain a soul.]]):
		format(math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Forgery of Haze",
	type = {"spell/shades",3},
	require = spells_req_high3,
	points = 5,
	mana = 70,
	cooldown = 30,
	range = 10,
	tactical = { ATTACK = 2, },
	requires_target = true,
	getDuration = function(self, t) return math.floor(3 + self:getTalentLevel(t)) end,
	getHealth = function(self, t) return 0.2 + self:combatTalentSpellDamage(t, 20, 500) / 1000 end,
	getDam = function(self, t) return 0.4 + self:combatTalentSpellDamage(t, 10, 500) / 1000 end,
	action = function(self, t)
		-- Find space
		local x, y = util.findFreeGrid(self.x, self.y, 1, true, {[Map.ACTOR]=true})
		if not x then
			game.logPlayer(self, "Not enough space to summon!")
			return
		end

		local m = require("mod.class.NPC").new(self:clone{
			shader = "shadow_simulacrum",
			no_drops = true,
			faction = self.faction,
			summoner = self, summoner_gain_exp=true,
			summon_time = t.getDuration(self, t),
			ai_target = {actor=nil},
			ai = "summoned", ai_real = "tactical",
			name = "Forgery of Haze ("..self.name..")",
			desc = [[A dark shadowy shape whose form resembles you.]],
		})
		m:removeAllMOs()
		m.make_escort = nil
		m.on_added_to_level = nil

		m.energy.value = 0
		m.player = nil
		m.max_life = m.max_life * t.getHealth(self, t)
		m.life = util.bound(m.life, 0, m.max_life)
		m.forceLevelup = function() end
		m.die = nil
		m.on_die = nil
		m.on_acquire_target = nil
		m.seen_by = nil
		m.can_talk = nil
		m.puuid = nil
		m.on_takehit = nil
		m.exp_worth = 0
		m.no_inventory_access = true
		m.clone_on_hit = nil
		m.talents.T_CREATE_MINIONS = nil
		m.talents.T_FORGERY_OF_HAZE = nil
		m.remove_from_party_on_death = true
		m.inc_damage.all = ((100 + (m.inc_damage.all or 0)) * t.getDam(self, t)) - 100

		game.zone:addEntity(game.level, m, "actor", x, y)
		game.level.map:particleEmitter(x, y, 1, "shadow")

		if game.party:hasMember(self) then
			game.party:addMember(m, {
				control="no",
				type="minion",
				title="Forgery of Haze",
				orders = {target=true},
			})
		end

		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		return ([[Through the shadows you forge a temporary copy of yourself, existing for %d turns.
		The copy possesses your exact talents and stats, has %d%% life and deals %d%% damage.]]):
		format(t.getDuration(self, t), t.getHealth(self, t) * 100, t.getDam(self, t) * 100)
	end,
}

newTalent{
	name = "Frostdusk",
	type = {"spell/shades",4},
	require = spells_req_high4,
	points = 5,
	mode = "sustained",
	sustain_mana = 50,
	cooldown = 30,
	tactical = { BUFF = 2 },
	getDarknessDamageIncrease = function(self, t) return self:getTalentLevelRaw(t) * 2 end,
	getResistPenalty = function(self, t) return self:getTalentLevelRaw(t) * 10 end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		return {
			dam = self:addTemporaryValue("inc_damage", {[DamageType.DARKNESS] = t.getDarknessDamageIncrease(self, t), [DamageType.COLD] = t.getDarknessDamageIncrease(self, t)}),
			resist = self:addTemporaryValue("resists_pen", {[DamageType.DARKNESS] = t.getResistPenalty(self, t)}),
			particle = self:addParticles(Particles.new("ultrashield", 1, {rm=0, rM=0, gm=0, gM=0, bm=10, bM=100, am=70, aM=180, radius=0.4, density=60, life=14, instop=20})),
		}
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeTemporaryValue("inc_damage", p.dam)
		self:removeTemporaryValue("resists_pen", p.resist)
		return true
	end,
	info = function(self, t)
		local damageinc = t.getDarknessDamageIncrease(self, t)
		local ressistpen = t.getResistPenalty(self, t)
		return ([[Surround yourself with Frostdusk, increasing all your darkness and cold damage by %d%% and ignoring %d%% of the darkness resistance of your targets.]])
		:format(damageinc, ressistpen)
	end,
}
