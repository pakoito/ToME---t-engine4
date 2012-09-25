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

-- Wild Gifts
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/call", name = "call of the wild", generic = true, description = "Be at one with nature." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/harmony", name = "harmony", generic = true, description = "Nature heals and cleans you." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/antimagic", name = "antimagic", generic = true, description = "The way to combat magic, or even nullify it." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/summon-melee", name = "summoning (melee)", description = "The art of calling creatures to your aid." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/summon-distance", name = "summoning (distance)", description = "The art of calling creatures to your aid." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/summon-utility", name = "summoning (utility)", description = "The art of calling creatures to your aid." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/summon-augmentation", name = "summoning (augmentation)", description = "The art of calling creatures to your aid." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/summon-advanced", name = "summoning (advanced)", min_lev = 10, description = "The art of calling creatures to your aid." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/slime", name = "slime aspect", description = "Through dedicated consumption of slime mold juice, you have gained an affinity with slime molds." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/fungus", name = "fungus", generic = true, description = "By covering yourself in fungus you better your healing." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/sand-drake", name = "sand drake aspect", description = "Take on the defining aspects of a Sand Drake." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/fire-drake", name = "fire drake aspect", description = "Take on the defining aspects of a Fire Drake." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/cold-drake", name = "cold drake aspect", description = "Take on the defining aspects of a Cold Drake." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/storm-drake", name = "storm drake aspect", description = "Take on the defining aspects of a Storm Drake." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/venom-drake", name = "venom drake aspect", description = "Take on the defining aspects of a Venom Drake." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/higher-draconic", name = "higher draconic abilities", description = "Take on the aspects of aged and powerful dragons." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/mindstar-mastery", name = "mindstar mastery", generic = true, description = "Learn to channel your mental power through mindstars, forming powerful psionic blades." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/mucus", name = "mucus", description = "Cover the floor with natural mucus." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/ooze", name = "ooze", description = "Your body and internal organs are becoming more ooze-like in nature, allowing you to spawn more of you." }
newTalentType{ allow_random=true, is_nature=true, type="wild-gift/malleable-body", name = "malleable body", description = "Your body's anatomy is starting to blur." }

-- Generic requires for gifts based on talent level
gifts_req1 = {
	stat = { wil=function(level) return 12 + (level-1) * 2 end },
	level = function(level) return 0 + (level-1)  end,
}
gifts_req2 = {
	stat = { wil=function(level) return 20 + (level-1) * 2 end },
	level = function(level) return 4 + (level-1)  end,
}
gifts_req3 = {
	stat = { wil=function(level) return 28 + (level-1) * 2 end },
	level = function(level) return 8 + (level-1)  end,
}
gifts_req4 = {
	stat = { wil=function(level) return 36 + (level-1) * 2 end },
	level = function(level) return 12 + (level-1)  end,
}
gifts_req5 = {
	stat = { wil=function(level) return 44 + (level-1) * 2 end },
	level = function(level) return 16 + (level-1)  end,
}
gifts_req_high1 = {
	stat = { wil=function(level) return 22 + (level-1) * 2 end },
	level = function(level) return 10 + (level-1)  end,
}
gifts_req_high2 = {
	stat = { wil=function(level) return 30 + (level-1) * 2 end },
	level = function(level) return 14 + (level-1)  end,
}
gifts_req_high3 = {
	stat = { wil=function(level) return 38 + (level-1) * 2 end },
	level = function(level) return 18 + (level-1)  end,
}
gifts_req_high4 = {
	stat = { wil=function(level) return 46 + (level-1) * 2 end },
	level = function(level) return 22 + (level-1)  end,
}
gifts_req_high5 = {
	stat = { wil=function(level) return 54 + (level-1) * 2 end },
	level = function(level) return 26 + (level-1)  end,
}

function checkMaxSummon(self, silent)
	local nb = 0

	-- Count party members
	if game.party:hasMember(self) then
		for act, def in pairs(game.party.members) do
			if act.summoner and act.summoner == self and act.wild_gift_summon then nb = nb + 1 end
		end
	else
		for _, act in pairs(game.level.entities) do
			if act.summoner and act.summoner == self and act.wild_gift_summon then nb = nb + 1 end
		end
	end

	local max = math.max(1, math.floor(self:getCun() / 10))
	if self:attr("nature_summon_max") then
		max = max + self:attr("nature_summon_max")
	end
	if nb >= max then
		if not silent then
			game.logPlayer(self, "#PINK#You can not summon any more; you have too many summons already (%d). You can increase the limit with higher Cunning(+1 for every 10).", nb)
		end
		return true
	else
		return false
	end
end

function setupSummon(self, m, x, y, no_control)
	m.unused_stats = 0
	m.unused_talents = 0
	m.unused_generics = 0
	m.unused_talents_types = 0
	m.no_inventory_access = true
	m.no_points_on_levelup = true
	m.save_hotkeys = true
	m.ai_state = m.ai_state or {}
	m.ai_state.tactic_leash = 100
	-- Try to use stored AI talents to preserve tweaking over multiple summons
	m.ai_talents = self.stored_ai_talents and self.stored_ai_talents[m.name] or {}
	local main_weapon = self:getInven("MAINHAND") and self:getInven("MAINHAND")[1]
	m.life_regen = m.life_regen + (self:attr("nature_summon_regen") or 0)
	m:attr("combat_apr", self:combatAPR(main_weapon))
	m.inc_damage = table.clone(self.inc_damage, true)
	m.resists_pen = table.clone(self.resists_pen, true)
	m:attr("stun_immune", self:attr("stun_immune"))
	m:attr("blind_immune", self:attr("blind_immune"))
	m:attr("pin_immune", self:attr("pin_immune"))
	m:attr("confusion_immune", self:attr("confusion_immune"))
	m:attr("numbed", self:attr("numbed"))
	if game.party:hasMember(self) then
		local can_control = not no_control and self:knowTalent(self.T_SUMMON_CONTROL)

		m.remove_from_party_on_death = true
		game.party:addMember(m, {
			control=can_control and "full" or "no",
			type="summon",
			title="Summon",
			orders = {target=true, leash=true, anchor=true, talents=true},
			on_control = function(self)
				local summoner = self.summoner
				self:setEffect(self.EFF_SUMMON_CONTROL, 1000, {incdur=2 + summoner:getTalentLevel(self.T_SUMMON_CONTROL) * 3, res=summoner:getCun(7, true) * summoner:getTalentLevelRaw(self.T_SUMMON_CONTROL)})
				self:hotkeyAutoTalents()
			end,
			on_uncontrol = function(self)
				self:removeEffect(self.EFF_SUMMON_CONTROL)
			end,
		})
	end
	m:resolve() m:resolve(nil, true)
	m:forceLevelup(self.level)
	game.zone:addEntity(game.level, m, "actor", x, y)
	game.level.map:particleEmitter(x, y, 1, "summon")

	-- Summons never flee
	m.ai_tactic = m.ai_tactic or {}
	m.ai_tactic.escape = 0

	local p = self:hasEffect(self.EFF_FRANTIC_SUMMONING)
	if p then
		p.dur = p.dur - 1
		if p.dur <= 0 then self:removeEffect(self.EFF_FRANTIC_SUMMONING) end
	end

	if m.wild_gift_detonate and self:isTalentActive(self.T_MASTER_SUMMONER) and self:knowTalent(self.T_GRAND_ARRIVAL) then
		local dt = self:getTalentFromId(m.wild_gift_detonate)
		if dt.on_arrival then
			dt.on_arrival(self, self:getTalentFromId(self.T_GRAND_ARRIVAL), m)
		end
	end

	if m.wild_gift_detonate and self:isTalentActive(self.T_MASTER_SUMMONER) and self:knowTalent(self.T_NATURE_CYCLE) then
		local t = self:getTalentFromId(self.T_NATURE_CYCLE)
		for _, tid in ipairs{self.T_RAGE, self.T_DETONATE, self.T_WILD_SUMMON} do
			if self.talents_cd[tid] and rng.percent(t.getChance(self, t)) then
				self.talents_cd[tid] = self.talents_cd[tid] - t.getReduction(self, t)
				if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
				self.changed = true
			end
		end
	end

	if self:knowTalent(self.T_BLIGHTED_SUMMONING) then m:incIncStat("mag", self:getMag()) end

	self:attr("summoned_times", 1)
end

load("/data/talents/gifts/call.lua")
load("/data/talents/gifts/harmony.lua")

load("/data/talents/gifts/antimagic.lua")

load("/data/talents/gifts/slime.lua")
load("/data/talents/gifts/fungus.lua")
load("/data/talents/gifts/mucus.lua")
load("/data/talents/gifts/ooze.lua")
load("/data/talents/gifts/malleable-body.lua")

load("/data/talents/gifts/sand-drake.lua")
load("/data/talents/gifts/fire-drake.lua")
load("/data/talents/gifts/cold-drake.lua")
load("/data/talents/gifts/storm-drake.lua")
load("/data/talents/gifts/venom-drake.lua")
load("/data/talents/gifts/higher-draconic.lua")

load("/data/talents/gifts/summon-melee.lua")
load("/data/talents/gifts/summon-distance.lua")
load("/data/talents/gifts/summon-utility.lua")
load("/data/talents/gifts/summon-augmentation.lua")
load("/data/talents/gifts/summon-advanced.lua")

load("/data/talents/gifts/mindstar-mastery.lua")
