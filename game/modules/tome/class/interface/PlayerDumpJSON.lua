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
local Base = require "engine.interface.PlayerDumpJSON"
local DamageType = require "engine.DamageType"

module(..., package.seeall, class.inherit(class.make{}, Base))

function _M:dumpToJSON(js)
	if not Base.dumpToJSON(self, js) then return end

	local nb_inscriptions = 0
	for i = 1, self.max_inscriptions do if self.inscriptions[i] then nb_inscriptions = nb_inscriptions + 1 end end

	local cur_exp, max_exp = self.exp, self:getExpChart(self.level+1)
	local title = ("%s the level %d %s %s"):format(self.name, self.level, self.descriptor.subrace or "???", self.descriptor.subclass or "???")

	-------------------------------------------------------------------
	-- Character
	-------------------------------------------------------------------
	local deaths = "no deaths recorded"
	if #self.died_times > 0 then
		deaths = "<ul>"
		for i, reason in ipairs(self.died_times) do
			deaths = deaths..string.format("<li>Killed by %s at level %d on the %s</li>", reason.name or "unknown", reason.level, game.calendar:getTimeDate(reason.turn, "%s %s %s year of Ascendancy at %02d:%02d"))
		end
		deaths = deaths.."</ul>"
	end

	local addons = {}
	for name, add in pairs(game.__mod_info.addons) do
		addons[#addons+1] = (" - %s %d.%d.%d"):format(add.long_name, add.version[1], add.version[2], add.version[3])
	end
	if #addons > 0 then addons = "<br/>"..table.concat(addons, "<br/>")
	else addons = "" end

	js:newSection("character", "char", "pairs", "add", {
		{ game = string.format("%s %d.%d.%d%s", game.__mod_info.long_name, game.__mod_info.version[1], game.__mod_info.version[2], game.__mod_info.version[3], addons) },
		{ name = self.name },
		{ sex = self.descriptor.sex },
		{ type = self.descriptor.subrace .. " " .. self.descriptor.subclass },
		{ campaign = self.descriptor.world },
		{ difficulty = self.descriptor.difficulty },
		{ permadeath = self.descriptor.permadeath },
		{ level = self.level },
		{ exp = string.format("%d%%", 100 * cur_exp / max_exp) },
		{ gold = string.format("%d", self.money) },
		{ died = { val=string.format("%d times (now %s)", #self.died_times or 0, self.dead and "dead" or "alive"), tooltip=deaths } },
	})

	-------------------------------------------------------------------
	-- Stats
	-------------------------------------------------------------------
	js:newSection("primary stats", "stats", "pairs", "break", {
		{ strength = self:getStr() },
		{ dexterity = self:getDex() },
		{ magic = self:getMag() },
		{ willpower = self:getWil() },
		{ cunning = self:getCun() },
		{ constitution = self:getCon() },
	})

	-------------------------------------------------------------------
	-- Resources
	-------------------------------------------------------------------
	local r = js:newSection("resources", "resources", "pairs", "add")
	r[#r+1] = {life=string.format("%d/%d", self.life, self.max_life)}
	if self:knowTalent(self.T_STAMINA_POOL) then r[#r+1] = {stamina=string.format("%d/%d", self.stamina, self.max_stamina)} end
	if self:knowTalent(self.T_MANA_POOL) then r[#r+1] = {mana=string.format("%d/%d", self.mana, self.max_mana)} end
	if self:knowTalent(self.T_POSITIVE_POOL) then r[#r+1] = {positive=string.format("%d/%d", self.positive, self.max_positive)} end
	if self:knowTalent(self.T_NEGATIVE_POOL) then r[#r+1] = {negative=string.format("%d/%d", self.negative, self.max_negative)} end
	if self:knowTalent(self.T_VIM_POOL) then r[#r+1] = {vim=string.format("%d/%d", self.vim, self.max_vim)} end
	if self:knowTalent(self.T_PSI_POOL) then r[#r+1] = {psi=string.format("%d/%d", self.psi, self.max_psi)} end
	if self:knowTalent(self.T_EQUILIBRIUM_POOL) then r[#r+1] = {equilibrium=string.format("%d", self.equilibrium)} end
	if self:knowTalent(self.T_PARADOX_POOL) then r[#r+1] = {paradox=string.format("%d", self.paradox)} end
	if self:knowTalent(self.T_HATE_POOL) then r[#r+1] = {hate=string.format("%d/%d", self.hate, self.max_hate)} end

	-------------------------------------------------------------------
	-- Inscriptions
	-------------------------------------------------------------------
	local ins = js:newSection(("inscriptions (%d/%d)"):format(nb_inscriptions, self.max_inscriptions), "inscriptions", "pairs", "break")
	for i = 1, self.max_inscriptions do if self.inscriptions[i] then
		local t = self:getTalentFromId("T_"..self.inscriptions[i])
		local desc = tostring(self:getTalentFullDescription(t))
		local p = t.name:split(": ")
		ins[#ins+1] = {[p[1]] = {val=p[2], tooltip=desc}}
	end end

	-------------------------------------------------------------------
	-- Winner
	-------------------------------------------------------------------
	if self.winner then
		local win = js:newSection("winner", "win", "text", nil)
		for i, line in ipairs(self.winner_text) do
			win[#win+1] = { val=line:removeColorCodes(), bg="000000"}
		end
	end

	-------------------------------------------------------------------
	-- Offense
	-------------------------------------------------------------------
	local c = js:newSection("offense", "offense", "pairs", "add")
	if self:getInven(self.INVEN_MAINHAND) then
		for i, o in ipairs(self:getInven(self.INVEN_MAINHAND)) do
			local mean, dam = o.combat, o.combat
			if o.archery and mean then
				dam = (self:getInven("QUIVER")[1] and self:getInven("QUIVER")[1].combat)
			end
			if mean and dam then
				c[#c+1] = { ["accuracy (main hand)"] = string.format("%d", self:combatAttack(mean)) }
				c[#c+1] = { ["damage (main hand)"] = string.format("%d", self:combatDamage(dam)) }
				c[#c+1] = { ["APR (main hand)"] = string.format("%d", self:combatAPR(dam)) }
				c[#c+1] = { ["crit (main hand)"] = string.format("%d%%", self:combatCrit(dam)) }
				c[#c+1] = { ["speed (main hand)"] = string.format("%0.2f", self:combatSpeed(mean)) }
			end
			if mean and mean.range then c[#c+1] = { ["range (main hand)"] = mean.range } end
		end
	end
	--Unarmed?
	if self:isUnarmed() then
		local mean, dam = self.combat, self.combat
		if mean and dam then
			c[#c+1] = { ["accuracy (unarmed)"] = string.format("%d", self:combatAttack(mean)) }
			c[#c+1] = { ["damage (unarmed)"] = string.format("%d", self:combatDamage(dam)) }
			c[#c+1] = { ["APR (unarmed)"] = string.format("%d", self:combatAPR(dam)) }
			c[#c+1] = { ["crit (unarmed)"] = string.format("%d%%", self:combatCrit(dam)) }
			c[#c+1] = { ["speed (unarmed)"] = string.format("%0.2f", self:combatSpeed(mean)) }
		end
		if mean and mean.range then c[#c+1] = { ["range (unarmed)"] = mean.range } end
	end
	if self:getInven(self.INVEN_OFFHAND) then
		for i, o in ipairs(self:getInven(self.INVEN_OFFHAND)) do
			local offmult = self:getOffHandMult(o.combat)
			local mean, dam = o.combat, o.combat
			if o.archery and mean then
				dam = (self:getInven("QUIVER")[1] and self:getInven("QUIVER")[1].combat)
			end
			if mean and dam then
				c[#c+1] = { ["accuracy (off hand)"] = string.format("%d", self:combatAttack(mean)) }
				c[#c+1] = { ["damage (off hand)"] = string.format("%d", self:combatDamage(dam) * offmult) }
				c[#c+1] = { ["APR (off hand)"] = string.format("%d", self:combatAPR(dam)) }
				c[#c+1] = { ["crit(off hand)"] = string.format("%d%%", self:combatCrit(dam)) }
				c[#c+1] = { ["speed(off hand)"] = string.format("%0.2f", self:combatSpeed(mean)) }
			end
			if mean and mean.range then c[#c+1] = { ["range (main hand)"] = mean.range } end
		end
	end
	c[#c+1] = { spellpower = self:combatSpellpower() }
	c[#c+1] = { ["spell crit"] = self:combatSpellCrit() }
	c[#c+1] = { ["spell speed"] = self:combatSpellSpeed() }

	if self.inc_damage.all then c[#c+1] = { ["all damage"] = string.format("%d%%", self.inc_damage.all) } end
	for i, t in ipairs(DamageType.dam_def) do
		if self.inc_damage[DamageType[t.type]] and self.inc_damage[DamageType[t.type]] ~= 0 then
			c[#c+1] = { [t.name.." damage"] = string.format("%d%%", self.inc_damage[DamageType[t.type]] + (self.inc_damage.all or 0)) }
		end
	end

	-------------------------------------------------------------------
	-- Defense
	-------------------------------------------------------------------
	local d = js:newSection("defense", "defense", "pairs", "break")
	d[#d+1] = { ["fatigue"] = self:combatFatigue() }
	d[#d+1] = { ["armour"] = self:combatArmor() }
	d[#d+1] = { ["armour hardiness"] = self:combatArmorHardiness() }
	d[#d+1] = { ["defense"] = self:combatDefense(true) }
	d[#d+1] = { ["ranged defense"] = self:combatDefenseRanged(true) }
	d[#d+1] = { ["physical save"] = self:combatPhysicalResist(true) }
	d[#d+1] = { ["spell save"] = self:combatSpellResist(true) }
	d[#d+1] = { ["mental save"] = self:combatMentalResist(true) }
	if self.resists.all then d[#d+1] = { ["all resists(cap)"] = string.format("%3d%%(%3d%%)", self.resists.all, self.resists_cap.all or 0) } end
	for i, t in ipairs(DamageType.dam_def) do
		if self.resists[DamageType[t.type]] and self.resists[DamageType[t.type]] ~= 0 then
			d[#d+1] = { [t.name.." resist(cap)"] =  string.format("%3d%%(%3d%%)", self:combatGetResist(DamageType[t.type]), (self.resists_cap[DamageType[t.type]] or 0) + (self.resists_cap.all or 0)) }
		end
	end
	immune_type = "poison_immune" immune_name = "Poison Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "cut_immune" immune_name = "Bleed Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "confusion_immune" immune_name = "Confusion Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "blind_immune" immune_name = "Blind Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "silence_immune" immune_name = "Silence Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "disarm_immune" immune_name = "Disarm Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "pin_immune" immune_name = "Pinning Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "stun_immune" immune_name = "Stun Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "fear_immune" immune_name = "Fear Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "knockback_immune" immune_name = "Knockback Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "stone_immune" immune_name = "Stoning Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "instakill_immune" immune_name = "Instadeath Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end
	immune_type = "teleport_immune" immune_name = "Teleport Resistance" if self:attr(immune_type) then d[#d+1] = { [immune_name] = string.format("%d%%", util.bound(self:attr(immune_type) * 100, 0, 100)) } end

	-------------------------------------------------------------------
	-- Talents
	-------------------------------------------------------------------
	local tdef = js:newSection("talents", "talents", "pairs", "add")
	for i, tt in ipairs(self.talents_types_def) do
		local ttknown = self:knowTalentType(tt.type)
		if not (self.talents_types[tt.type] == nil) and ttknown then
			local cat = tt.type:gsub("/.*", "")
			local catname = ("%s / %s"):format(cat:capitalize(), tt.name:capitalize())
			tdef[#tdef+1] = { [catname] = ("(mastery %.02f)"):format(self:getTalentTypeMastery(tt.type)) }

			-- Find all talents of this school
			if (ttknown) then
				for j, t in ipairs(tt.talents) do
					if not t.hide then
						local typename = "class"
						if t.generic then typename = "generic" end
						local skillname = ("<ul><li>%s (%s)</li></ul>"):format(t.name, typename)
						local desc = self:getTalentFullDescription(t):toString()
						tdef[#tdef+1] = { [skillname] = {val=("%d/%d"):format(self:getTalentLevelRaw(t.id), t.points), tooltip=desc} }
					end
				end
			end
		end
	end

	-------------------------------------------------------------------
	-- Effects
	-------------------------------------------------------------------
	local e = js:newSection("current effects", "effects", "pairs", "add")
	for tid, act in pairs(self.sustain_talents) do
		if act then
			local t = self:getTalentFromId(tid)
			e[#e+1] = { Talent = t.name }
		end
	end
	for eff_id, p in pairs(self.tmp) do
		local e = self.tempeffect_def[eff_id]
		local desc = e.long_desc(self, p)
		if e.status == "detrimental" then
			e[#e+1] = { ["detrimental effect"] = e.desc }
		else
			e[#e+1] = { ["beneficial effect"] = e.desc }
		end
	end

	-------------------------------------------------------------------
	-- Quests
	-------------------------------------------------------------------
	local quests = js:newSection("quests", "quests", "pairs", "add")
	for id, q in pairs(game.party.quests or {}) do
		quests[#quests+1] = { [q.status_text[q.status]] = {val=q.name, tooltip=q:desc(self)} }
	end
	table.sort(quests, function(a, b) local _, aname = next(a) local _, bname = next(b) return aname.val < bname.val end)

	-------------------------------------------------------------------
	-- Achievements
	-------------------------------------------------------------------
	local achs = js:newSection("achievements", "achievements", "pairs", "break")
	for id, data in pairs(self.achievements or {}) do
		local a = world:getAchievementFromId(id)
		achs[#achs+1] = { [a.name] = {val=game.calendar:getTimeDate(data.turn, "%s %s %s year of Ascendancy at %02d:%02d"), tooltip=a.desc.."\nBy "..(data.who or "???")} }
	end
	table.sort(achs, function(a, b) local aname = next(a) local bname = next(b) return aname < bname end)

	-------------------------------------------------------------------
	-- Equip
	-------------------------------------------------------------------
	local equip = js:newSection("equipment", "equip", "pairs", "add")
	for inven_id =  1, #self.inven_def do
		if self.inven[inven_id] and self.inven_def[inven_id].is_worn then
			for item, o in ipairs(self.inven[inven_id]) do
				local desc = tostring(o:getDesc())
				equip[#equip+1] = { [self.inven_def[inven_id].name] = { val=o:getName{do_color=true, no_image=true}, tooltip=desc, bg="000000" } }
			end
		end
	end

	-------------------------------------------------------------------
	-- Inventory
	-------------------------------------------------------------------
	local inven = js:newSection("inventory", "inven", "list", "break")
	for item, o in ipairs(self.inven[self.INVEN_INVEN]) do
		local desc = tostring(o:getDesc())
		inven[#inven+1] = { val=o:getName{do_color=true, no_image=true}, tooltip=desc, bg="000000" }
	end

	-------------------------------------------------------------------
	-- Log
	-------------------------------------------------------------------
	local log = js:newSection("last messages", "log", "text", nil)
	log[#log+1] = { val=table.concat(game.uiset.logdisplay:getLines(30), "#LAST#\n"), bg="000000" }

	-- Cleanup numbers
	for _, sec in ipairs(js.sections) do
		if sec.type == "pairs" then
			for __, line in ipairs(js[sec.table]) do
				local k, e = next(line)
				if type(e) == "number" then line[k] = math.floor(e) end
			end
		end
	end

	local tags = {
		game = game.__mod_info.version_name,
		level = self.level,
		name = self.name,
		difficulty = self.descriptor.difficulty,
		permadeath = self.descriptor.permadeath,
		campaign = self.descriptor.world,
		race = self.descriptor.subrace,
		class = self.descriptor.subclass,
		dead = self.dead and "dead" or nil,
		winner = self.winner and "winner" or nil,
	}

	local addons = {}
	for name, add in pairs(game.__mod_info.addons) do
		addons[#addons+1] = add.short_name
	end
	if #addons > 0 then
		tags.addons = table.concat(addons, ',')
	end

	if self.has_custom_tile then
		tags.tile = self.has_custom_tile
		js:hiddenData("tile", self.has_custom_tile)
	end

	return title, tags
end
