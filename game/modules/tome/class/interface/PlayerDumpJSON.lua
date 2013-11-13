-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Base = require "engine.interface.PlayerDumpJSON"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(class.make{}, Base))

function _M:dumpToJSON(js, bypass, nosub)
	if not Base.dumpToJSON(self, js) and not bypass then return end

	js:version("tome-json-char-1")

	local nb_inscriptions = 0
	for i = 1, self.max_inscriptions do if self.inscriptions[i] then nb_inscriptions = nb_inscriptions + 1 end end

	local cur_exp, max_exp = self.exp, self:getExpChart(self.level+1)
	local title = ("%s the level %d %s %s"):format(self.name, self.level, self.descriptor and self.descriptor.subrace or rawget(self, "type") or "???", self.descriptor and self.descriptor.subclass or self.subtype or "???")

	-------------------------------------------------------------------
	-- Character
	-------------------------------------------------------------------
	local deaths = "no deaths recorded"
	if self.died_times and #self.died_times > 0 then
		deaths = {}
		for i, reason in ipairs(self.died_times) do
			deaths[#deaths+1] = string.format("Killed by %s at level %d on the %s", reason.name or "unknown", reason.level, game.calendar:getTimeDate(reason.turn, "%s %s %s year of Ascendancy at %02d:%02d"))
		end
		deaths = table.concat(deaths, "\n")
	end

	local addons = {}
	for name, add in pairs(game.__mod_info.addons) do
		addons[add.short_name] = ("%s %d.%d.%d"):format(add.long_name, add.version[1], add.version[2], add.version[3])
	end

	js:newSection("character", {
		game = string.format("%s %d.%d.%d", game.__mod_info.long_name, game.__mod_info.version[1], game.__mod_info.version[2], game.__mod_info.version[3]),
		addons = addons,
		name = self.name,
		sex = self.descriptor and self.descriptor.sex or (self.female and "Female" or "Male"),
		race = ((self.descriptor and self.descriptor.subrace) or self.type:capitalize()),
		class = ((self.descriptor and self.descriptor.subclass) or self.subtype:capitalize()),
		size = self:TextSizeCategory(),
		campaign = self.descriptor and self.descriptor.world or "---",
		difficulty = self.descriptor and self.descriptor.difficulty or "---",
		permadeath = self.descriptor and self.descriptor.permadeath or "---",
		level = self.level,
		exp = string.format("%d%%", 100 * cur_exp / max_exp),
		gold = string.format("%d", self.money),
		lifes = self.easy_mode_lifes,
		died = self.died_times and { times=#self.died_times, now=self.dead and "dead" or "alive", desc=deaths },
		antimagic = self:attr("forbid_arcane") and true or false,
	})

	-------------------------------------------------------------------
	-- Stats
	-------------------------------------------------------------------
	js:newSection("primary stats", {
		strength = {value=self:getStr(), base=self:getStat(self.STAT_STR, nil, nil, true)},
		dexterity = {value=self:getDex(), base=self:getStat(self.STAT_DEX, nil, nil, true)},
		magic = {value=self:getMag(), base=self:getStat(self.STAT_MAG, nil, nil, true)},
		willpower = {value=self:getWil(), base=self:getStat(self.STAT_WIL, nil, nil, true)},
		cunning = {value=self:getCun(), base=self:getStat(self.STAT_CUN, nil, nil, true)},
		constitution = {value=self:getCon(), base=self:getStat(self.STAT_CON, nil, nil, true)},
	})

	-------------------------------------------------------------------
	-- Resources
	-------------------------------------------------------------------
	local r = js:newSection("resources")
	r.life = string.format("%d/%d", self.life, self.max_life)
	if self:knowTalent(self.T_STAMINA_POOL) then r.stamina=string.format("%d/%d", self.stamina, self.max_stamina) end
	if self:knowTalent(self.T_MANA_POOL) then r.mana=string.format("%d/%d", self.mana, self.max_mana) end
	if self:knowTalent(self.T_SOUL_POOL) then r.souls=string.format("%d/%d", self.soul, self.max_soul) end
	if self:knowTalent(self.T_POSITIVE_POOL) then r.positive=string.format("%d/%d", self.positive, self.max_positive) end
	if self:knowTalent(self.T_NEGATIVE_POOL) then r.negative=string.format("%d/%d", self.negative, self.max_negative) end
	if self:knowTalent(self.T_VIM_POOL) then r.vim=string.format("%d/%d", self.vim, self.max_vim) end
	if self:knowTalent(self.T_PSI_POOL) then r.psi=string.format("%d/%d", self.psi, self.max_psi) end
	if self.psionic_feedback_max then r.psi_feedback=string.format("%d/%d", self:getFeedback(), self:getMaxFeedback()) end
	if self:knowTalent(self.T_EQUILIBRIUM_POOL) then r.equilibrium=string.format("%d", self.equilibrium) end
	if self:knowTalent(self.T_PARADOX_POOL) then r.paradox=string.format("%d", self.paradox) end
	if self:knowTalent(self.T_HATE_POOL) then r.hate=string.format("%d/%d", self.hate, self.max_hate) end

	-------------------------------------------------------------------
	-- Inscriptions
	-------------------------------------------------------------------
	local ins = js:newSection("inscriptions", {used=("%d/%d"):format(nb_inscriptions, self.max_inscriptions)})
	ins.all = {}
	ins = ins.all
	for i = 1, self.max_inscriptions do if self.inscriptions[i] then
		local t = self:getTalentFromId("T_"..self.inscriptions[i])
		local desc = tostring(self:getTalentFullDescription(t))
		ins[#ins+1] = {name=t.name, kind=t.type[1], desc=desc}
	end end

	-------------------------------------------------------------------
	-- Winner
	-------------------------------------------------------------------
	if self.winner then
		local win = js:newSection("winner")
		local text = {}
		for i, line in ipairs(self.winner_text) do
			win[#win+1] = line:removeColorCodes()
		end
		win.text = table.concat(text, "\n")
	end

	-------------------------------------------------------------------
	-- Healing
	-------------------------------------------------------------------
	js:newSection("healing", {
		factor = util.bound((self.healing_factor or 1), 0, 2.5),
		regen = self.life_regen,
		regen_full = self.life_regen * util.bound((self.healing_factor or 1), 0, 2.5),
	})

	-------------------------------------------------------------------
	-- Vision
	-------------------------------------------------------------------
	local esp = table.keys(self.esp)
	local esp = {}
	for k, e in pairs(self.esp) do if type(e) == "number" and e > 0 then esp[#esp+1] = k end end
	js:newSection("vision", {
		lite = self.lite,
		range = self.sight,
		infravision = (self:attr("infravision") or self:attr("heightened_senses")) and math.max((self.heightened_senses or 0), (self.infravision or 0)) or 0,
		stealth = self.stealth,
		see_stealth = self.see_stealth,
		invisibility = self.invisible,
		see_invisible = self.see_invisible,
		esp_range = self.esp_range,
		esp = esp,
		full_esp = self:attr("esp_all"),
	})

	-------------------------------------------------------------------
	-- Speeds
	-------------------------------------------------------------------
	local speeds = js:newSection("speeds")
	speeds.global = self.global_speed * 100
	speeds.movement = 100 * (1/self:combatMovementSpeed()-1)
	speeds.spell = 100 * (self.combat_spellspeed - 1)
	speeds.mental = 100 * (self.combat_physspeed - 1)
	speeds.attack = 100 * (self.combat_mindspeed - 1)

	-------------------------------------------------------------------
	-- Offense
	-------------------------------------------------------------------
	local c = js:newSection("offense")
	if self:getInven(self.INVEN_MAINHAND) then
		c.mainhand = {}
		for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
			local mean, dam = self:getObjectCombat(o, "mainhand"), self:getObjectCombat(o, "mainhand")
			if o.archery and mean then
				dam = (self:getInven("QUIVER")[1] and self:getInven("QUIVER")[1].combat)
			end
			local d = {}
			c.mainhand[#c.mainhand+1] = d
			if mean and dam then
				d.accuracy = string.format("%d", self:combatAttack(mean))
				d.damage = string.format("%d", self:combatDamage(dam))
				d.APR = string.format("%d", self:combatAPR(dam))
				d.crit = string.format("%d%%", self:combatCrit(dam))
				d.speed = string.format("%0.2f", self:combatSpeed(mean))
			end
			if mean and mean.range then d.range = mean.range end
		end
	end
	--Unarmed?
	if self:isUnarmed() then
		local mean, dam = self:getObjectCombat(nil, "barehand"), self:getObjectCombat(nil, "barehand")
		local d = {}
		c.barehand = {}
		c.barehand[#c.barehand+1] = d
		if mean and dam then
			d.accuracy = string.format("%d", self:combatAttack(mean))
			d.damage = string.format("%d", self:combatDamage(dam))
			d.APR = string.format("%d", self:combatAPR(dam))
			d.crit = string.format("%d%%", self:combatCrit(dam))
			d.speed = string.format("%0.2f", self:combatSpeed(mean))
		end
		if mean and mean.range then d.range = mean.range end
	end
	if self:getInven(self.INVEN_OFFHAND) then
		c.offhand = {}
		for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
			local offmult = self:getOffHandMult(o.combat)
			local mean, dam = self:getObjectCombat(o, "offhand"), self:getObjectCombat(o, "offhand")
			if o.archery and mean then
				dam = (self:getInven("QUIVER")[1] and self:getInven("QUIVER")[1].combat)
			end
			local d = {}
			c.offhand[#c.offhand+1] = d
			if mean and dam then
				d.penaly = offmult
				d.accuracy = string.format("%d", self:combatAttack(mean))
				d.damage = string.format("%d", self:combatDamage(dam) * offmult)
				d.APR = string.format("%d", self:combatAPR(dam))
				d.crit = string.format("%d%%", self:combatCrit(dam))
				d.speed = string.format("%0.2f", self:combatSpeed(mean))
			end
			if mean and mean.range then d.range = mean.range end
		end
	end

	c.spell = {
		spellpower = self:combatSpellpower(),
		crit = string.format("%d%%", self:combatSpellCrit()),
		speed = self:combatSpellSpeed(),
		cooldown = (self.spell_cooldown_reduction or 0) * 100,
	}

	c.mind = {
		mindpower = self:combatMindpower(),
		crit = string.format("%d%%", self:combatMindCrit()),
		speed = self:combatMindSpeed(),
	}

	c.damage = {}

	if self.inc_damage.all then c.damage.all = string.format("%d%%", self.inc_damage.all) end
	for i, t in ipairs(DamageType.dam_def) do
		if self:combatHasDamageIncrease(DamageType[t.type]) then
			c.damage[t.name] = string.format("%d%%", self:combatGetDamageIncrease(DamageType[t.type]))
		end
	end

	c.damage_pen = {}

	if self.resists_pen.all then c.damage_pen.all = string.format("%d%%", self.resists_pen.all) end
	for i, t in ipairs(DamageType.dam_def) do
		if self.resists_pen[DamageType[t.type]] and self.resists_pen[DamageType[t.type]] ~= 0 then
			c.damage_pen[t.name] = string.format("%d%%", self.resists_pen[DamageType[t.type]] + (self.resists_pen.all or 0))
		end
	end

	-------------------------------------------------------------------
	-- Defense
	-------------------------------------------------------------------
	local d = js:newSection("defense")
	d.defense = {}
	d.defense.fatigue = self:combatFatigue()
	d.defense.armour = self:combatArmor()
	d.defense.armour_hardiness = self:combatArmorHardiness()
	d.defense.defense = self:combatDefense(true)
	d.defense.ranged_defense = self:combatDefenseRanged(true)
	d.defense.physical_save = self:combatPhysicalResist(true)
	d.defense.spell_save = self:combatSpellResist(true)
	d.defense.mental_save = self:combatMentalResist(true)

	d.resistances = {}
	if self.resists.all then d.resistances.all = string.format("%3d%%(%3d%%)", self.resists.all, self.resists_cap.all or 0) end
	for i, t in ipairs(DamageType.dam_def) do
		if self.resists[DamageType[t.type]] and self.resists[DamageType[t.type]] ~= 0 then
			d.resistances[t.name] =  string.format("%3d%%(%3d%%)", self:combatGetResist(DamageType[t.type]), (self.resists_cap[DamageType[t.type]] or 0) + (self.resists_cap.all or 0))
		end
	end

	d.immunities = {}
	immune_type = "poison_immune" immune_name = "Poison Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "cut_immune" immune_name = "Bleed Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "confusion_immune" immune_name = "Confusion Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "blind_immune" immune_name = "Blind Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "silence_immune" immune_name = "Silence Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "disarm_immune" immune_name = "Disarm Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "pin_immune" immune_name = "Pinning Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "stun_immune" immune_name = "Stun Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "fear_immune" immune_name = "Fear Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "knockback_immune" immune_name = "Knockback Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "stone_immune" immune_name = "Stoning Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "instakill_immune" immune_name = "Instadeath Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end
	immune_type = "teleport_immune" immune_name = "Teleport Resistance" if self:attr(immune_type) then d.immunities[immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) end

	-------------------------------------------------------------------
	-- Talents
	-------------------------------------------------------------------
	local tdef = js:newSection("talents")
	for i, tt in ipairs(self.talents_types_def) do
		local ttknown = self:knowTalentType(tt.type)
		if not (self.talents_types[tt.type] == nil) and ttknown then
			local cat = tt.type:gsub("/.*", "")
			local catname = ("%s / %s"):format(cat:capitalize(), tt.name:capitalize())
			local td = { list={}, mastery = ("%.02f"):format(self:getTalentTypeMastery(tt.type)), kind=tt.generic and "generic" or "class" }
			tdef[catname] = td

			-- Find all talents of this school
			if (ttknown) then
				for j, t in ipairs(tt.talents) do
					if not t.hide then
						local skillname = t.name
						local desc = self:getTalentFullDescription(t):toString()
						td.list[#td.list+1] = { name=skillname, val=("%d/%d"):format(self:getTalentLevelRaw(t.id), t.points), desc=desc}
					end
				end
			end
		end
	end

	-------------------------------------------------------------------
	-- Effects
	-------------------------------------------------------------------
	local ee = js:newSection("effects")
	for tid, act in pairs(self.sustain_talents) do
		if act then
			local t = self:getTalentFromId(tid)
			ee[#ee+1] = { name = t.name, kind="talent", desc="" }
		end
	end
	for eff_id, p in pairs(self.tmp) do
		local e = self.tempeffect_def[eff_id]
		local name = e.desc
		if e.display_desc then name = e.display_desc(self, p) end
		local desc = e.long_desc(self, p)
		if e.status == "detrimental" then
			ee[#ee+1] = { kind="detrimental effect", name = name, desc=desc }
		else
			ee[#ee+1] = { kind="beneficial effect", name = name, desc=desc }
		end
	end

	-------------------------------------------------------------------
	-- Quests
	-------------------------------------------------------------------
	local quests = js:newSection("quests")
	for id, q in pairs(self.quests or {}) do
		quests[#quests+1] = { name=q.name, status=q.status_text[q.status], desc=q:desc(self)}
	end
	table.sort(quests, function(a, b) return a.name < b.name end)

	-------------------------------------------------------------------
	-- Achievements
	-------------------------------------------------------------------
	local achs = js:newSection("achievements")
	for id, data in pairs(self.achievements or {}) do
		local a = world:getAchievementFromId(id)
		if a then
			achs[#achs+1] = { name=a.name, when=game.calendar:getTimeDate(data.turn, "%s %s %s year of Ascendancy at %02d:%02d"), desc=a.desc.."\nBy "..(data.who or "???")}
		end
	end
	table.sort(achs, function(a, b) return a.name < b.name end)

	-------------------------------------------------------------------
	-- Equip
	-------------------------------------------------------------------
	local equip = js:newSection("equipment")
	for inven_id =  1, #self.inven_def do
		if self.inven[inven_id] and self.inven_def[inven_id].is_worn then
			for item, o in ipairs(self.inven[inven_id]) do
				local desc = tostring(o:getDesc())
				equip[self.inven_def[inven_id].name] = equip[self.inven_def[inven_id].name] or {}
				local ie = equip[self.inven_def[inven_id].name]
				ie[#ie+1] = { name=o:getName{do_color=true, no_image=true}, desc=desc }
			end
		end
	end

	-------------------------------------------------------------------
	-- Inventory
	-------------------------------------------------------------------
	local inven = js:newSection("inventory")
	for item, o in ipairs(self.inven[self.INVEN_INVEN]) do
		local desc = tostring(o:getDesc())
		inven[#inven+1] = { name=o:getName{do_color=true, no_image=true}, desc=desc }
	end

	-------------------------------------------------------------------
	-- Log
	-------------------------------------------------------------------
	local log = js:newSection("last_messages")
	log.text = table.concat(game.uiset.logdisplay:getLines(30), "#LAST#\n")

	-------------------------------------------------------------------
	-- Metatags
	-------------------------------------------------------------------
	local tags = {
		game = game.__mod_info.version_name,
		level = self.level,
		name = self.name,
		difficulty = self.descriptor and self.descriptor.difficulty or "---",
		permadeath = self.descriptor and self.descriptor.permadeath,
		campaign = self.descriptor and self.descriptor.world or "---",
		race = self.descriptor and self.descriptor.subrace or rawget(self, "type") or "---",
		class = self.descriptor and self.descriptor.subclass or self.subtype or "---",
		dead = self.dead and "dead" or nil,
		winner = self.winner and "winner" or nil,
	}

	-------------------------------------------------------------------
	-- Other party members
	-------------------------------------------------------------------
	if not nosub then for act, def in pairs(game.party.members) do
		if act ~= self and def.important then
			local sub = js:subsheet(def.title)
			self.dumpToJSON(act, sub, true, true)
		end
	end end

	local addons = {}
	for name, add in pairs(game.__mod_info.addons) do
		addons[#addons+1] = add.short_name
	end
	if #addons > 0 then
		tags.addon = addons
	end

	if self.has_custom_tile then
		tags.tile = self.has_custom_tile
		js:hiddenData("tile", self.has_custom_tile)
	end

	self:triggerHook{"ToME:PlayerDumpJSON", title=title, js=js, tags=tags}

	return title, tags
end
