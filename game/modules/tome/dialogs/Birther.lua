-- TE4 - T-Engine 4
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
local Dialog = require "engine.ui.Dialog"
local Birther = require "engine.Birther"
local List = require "engine.ui.List"
local TreeList = require "engine.ui.TreeList"
local Button = require "engine.ui.Button"
local Dropdown = require "engine.ui.Dropdown"
local Textbox = require "engine.ui.Textbox"
local Checkbox = require "engine.ui.Checkbox"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local NameGenerator = require "engine.NameGenerator"
local Module = require "engine.Module"

module(..., package.seeall, class.inherit(Birther))

--- Instanciates a birther for the given actor
function _M:init(title, actor, order, at_end, quickbirth, w, h)
	self.quickbirth = quickbirth
	self.actor = actor
	self.order = order
	self.at_end = at_end

	Dialog.init(self, title and title or "Character Creation", w or 600, h or 400)

	self.descriptors = {}
	self.descriptors_by_type = {}

	self.c_ok = Button.new{text="  Play!  ", fct=function() self:atEnd("created") end}
	self.c_random = Button.new{text="Random!", fct=function() self:randomBirth() end}
	self.c_premade = Button.new{text="Load premade", fct=function() self:loadPremadeUI() end}
	self.c_cancel = Button.new{text="Cancel", fct=function() self:atEnd("quit") end}

	self.c_name = Textbox.new{title="Name: ", text=game.player_name, chars=30, max_len=50, fct=function() end, on_change=function() self:setDescriptor() end}

	self.c_female = Checkbox.new{title="Female", default=true,
		fct=function() end,
		on_change=function(s) self.c_male.checked = not s self:setDescriptor("sex", s and "Female" or "Male") end
	}
	self.c_male = Checkbox.new{title="Male", default=false,
		fct=function() end,
		on_change=function(s) self.c_female.checked = not s self:setDescriptor("sex", s and "Male" or "Female") end
	}

	self:generateCampaigns()
	self.c_campaign_text = Textzone.new{auto_width=true, auto_height=true, text="Campaign: "}
	self.c_campaign = Dropdown.new{width=300, fct=function(item) self:campaignUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_campaigns, nb_items=#self.all_campaigns}

	self:generateDifficulties()
	self.c_difficulty_text = Textzone.new{auto_width=true, auto_height=true, text="Difficulty: "}
	self.c_difficulty = Dropdown.new{width=300, fct=function(item) self:difficultyUse(item) end, on_select=function(item) self:updateDesc(item) end, list=self.all_difficulties, nb_items=#self.all_difficulties}

	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 3 - 10), height=self.ih - self.c_female.h - self.c_ok.h - self.c_campaign.h - 10, scrollbar=true, no_color_bleed=true}

	self:setDescriptor("base", "base")
	self:setDescriptor("world", self.default_campaign)
	self:setDescriptor("difficulty", self.default_difficulty)
	self:setDescriptor("sex", "Female")

	self:generateRaces()
	self.c_race = TreeList.new{width=math.floor(self.iw / 3 - 10), height=self.ih - self.c_female.h - self.c_ok.h - self.c_campaign.h - 10, scrollbar=true, columns={
		{width=100, display_prop="name"},
	}, tree=self.all_races,
		fct=function(item, sel, v) self:raceUse(item, sel, v) end,
		select=function(item, sel) self:updateDesc(item) end,
		on_expand=function(item) end,
		on_drawitem=function(item) end,
	}

	self:generateClasses()
	self.c_class = TreeList.new{width=math.floor(self.iw / 3 - 10), height=self.ih - self.c_female.h - self.c_ok.h - self.c_campaign.h - 10, scrollbar=true, columns={
		{width=100, display_prop="name"},
	}, tree=self.all_classes,
		fct=function(item, sel, v) self:classUse(item, sel, v) end,
		select=function(item, sel) self:updateDesc(item) end,
		on_expand=function(item) end,
		on_drawitem=function(item) end,
	}

	self.cur_order = 1
	self.sel = 1

	self:loadUI{
		-- First line
		{left=0, top=0, ui=self.c_name},
		{left=self.c_name, top=0, ui=self.c_female},
		{left=self.c_female, top=0, ui=self.c_male},

		-- Second line
		{left=0, top=self.c_name, ui=self.c_campaign_text},
		{left=self.c_campaign_text, top=self.c_name, ui=self.c_campaign},
		{left=self.c_campaign, top=self.c_name, ui=self.c_difficulty_text},
		{left=self.c_difficulty_text, top=self.c_name, ui=self.c_difficulty},

		-- Lists
		{left=0, top=self.c_campaign, ui=self.c_race},
		{left=self.c_race, top=self.c_campaign, ui=self.c_class},
		{right=0, top=self.c_campaign, ui=self.c_desc},

		-- Buttons
		{left=0, bottom=0, ui=self.c_ok, hidden=true},
		{left=self.c_ok, bottom=0, ui=self.c_random},
		{left=self.c_random, bottom=0, ui=self.c_premade},
		{right=0, bottom=0, ui=self.c_cancel},
	}
	self:setupUI()

	if self.descriptors_by_type.difficulty == "Tutorial" then
		self:raceUse(self.all_races[1], 1)
		self:raceUse(self.all_races[1].nodes[1], 2)
		self:classUse(self.all_classes[1], 1)
		self:classUse(self.all_classes[1].nodes[1], 2)
	end
	for i, item in ipairs(self.c_campaign.c_list.list) do if self.default_campaign == item.id then self.c_campaign.c_list.sel = i break end end
	for i, item in ipairs(self.c_difficulty.c_list.list) do if self.default_difficulty == item.id then self.c_difficulty.c_list.sel = i break end end
	self:setFocus(self.c_campaign)
	self:setFocus(self.c_name)
end

function _M:atEnd(v)
	if v == "created" then
		game:unregisterDialog(self)
		self:apply()
		game:setPlayerName(self.c_name.text)
		self.at_end(false)
	elseif v == "loaded" then
		game:unregisterDialog(self)
		self.at_end(true)
	else
		util.showMainMenu()
	end
end

function _M:randomBirth()
	-- Random sex
	local sex = rng.percent(50)
	self.c_male.checked = sex
	self.c_female.checked = not sex
	self:setDescriptor("sex", sex and "Male" or "Female")

	-- Random name
	local namegen = NameGenerator.new(sex and {
		phonemesVocals = "a, e, i, o, u, y",
		phonemesConsonants = "b, c, ch, ck, cz, d, dh, f, g, gh, h, j, k, kh, l, m, n, p, ph, q, r, rh, s, sh, t, th, ts, tz, v, w, x, z, zh",
		syllablesStart = "Aer, Al, Am, An, Ar, Arm, Arth, B, Bal, Bar, Be, Bel, Ber, Bok, Bor, Bran, Breg, Bren, Brod, Cam, Chal, Cham, Ch, Cuth, Dag, Daim, Dair, Del, Dr, Dur, Duv, Ear, Elen, Er, Erel, Erem, Fal, Ful, Gal, G, Get, Gil, Gor, Grin, Gun, H, Hal, Han, Har, Hath, Hett, Hur, Iss, Khel, K, Kor, Lel, Lor, M, Mal, Man, Mard, N, Ol, Radh, Rag, Relg, Rh, Run, Sam, Tarr, T, Tor, Tul, Tur, Ul, Ulf, Unr, Ur, Urth, Yar, Z, Zan, Zer",
		syllablesMiddle = "de, do, dra, du, duna, ga, go, hara, kaltho, la, latha, le, ma, nari, ra, re, rego, ro, rodda, romi, rui, sa, to, ya, zila",
		syllablesEnd = "bar, bers, blek, chak, chik, dan, dar, das, dig, dil, din, dir, dor, dur, fang, fast, gar, gas, gen, gorn, grim, gund, had, hek, hell, hir, hor, kan, kath, khad, kor, lach, lar, ldil, ldir, leg, len, lin, mas, mnir, ndil, ndur, neg, nik, ntir, rab, rach, rain, rak, ran, rand, rath, rek, rig, rim, rin, rion, sin, sta, stir, sus, tar, thad, thel, tir, von, vor, yon, zor",
		rules = "$s$v$35m$10m$e",
	} or {
		phonemesVocals = "a, e, i, o, u, y",
		syllablesStart = "Ad, Aer, Ar, Bel, Bet, Beth, Ce'N, Cyr, Eilin, El, Em, Emel, G, Gl, Glor, Is, Isl, Iv, Lay, Lis, May, Ner, Pol, Por, Sal, Sil, Vel, Vor, X, Xan, Xer, Yv, Zub",
		syllablesMiddle = "bre, da, dhe, ga, lda, le, lra, mi, ra, ri, ria, re, se, ya",
		syllablesEnd = "ba, beth, da, kira, laith, lle, ma, mina, mira, na, nn, nne, nor, ra, rin, ssra, ta, th, tha, thra, tira, tta, vea, vena, we, wen, wyn",
		rules = "$s$v$35m$10m$e",
	})
	self.c_name:setText(namegen:generate())

	-- Random campaign
	local camp, camp_id = nil
	repeat camp, camp_id = rng.table(self.c_campaign.c_list.list)
	until not camp.locked
	self.c_campaign.c_list.sel = camp_id
	self:campaignUse(camp)

	-- Random difficulty
	local diff, diff_id = nil
	repeat diff, diff_id = rng.table(self.c_difficulty.c_list.list)
	until diff.name ~= "Tutorial" and not diff.locked
	self.c_difficulty.c_list.sel = diff_id
	self:difficultyUse(diff)

	-- Random race
	local race, race_id = nil
	repeat race, race_id = rng.table(self.all_races)
	until not race.locked
	self:raceUse(race)

	-- Random subrace
	local subrace, subrace_id = nil
	repeat subrace, subrace_id = rng.table(self.all_races[race_id].nodes)
	until not subrace.locked
	self:raceUse(subrace)

	-- Random class
	local class, class_id = nil
	repeat class, class_id = rng.table(self.all_classes)
	until not class or not class.locked
	self:classUse(class)

	-- Random subclass
	if class then
		local subclass, subclass_id = nil
		repeat subclass, subclass_id = rng.table(self.all_classes[class_id].nodes)
		until not subclass.locked
		self:classUse(subclass)
	end
end

function _M:on_focus(id, ui)
	if self.focus_ui and self.focus_ui.ui == self.c_female then self.c_desc:switchItem(self.c_female, self.birth_descriptor_def.sex.Female.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_male then self.c_desc:switchItem(self.c_male, self.birth_descriptor_def.sex.Male.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_campaign then
		local item = self.c_campaign.c_list.list[self.c_campaign.c_list.sel]
		self.c_desc:switchItem(item, item.desc)
	elseif self.focus_ui and self.focus_ui.ui == self.c_difficulty then
		local item = self.c_difficulty.c_list.list[self.c_difficulty.c_list.sel]
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:updateDesc(item)
	if item and item.desc then
		self.c_desc:switchItem(item, item.desc)
	end
end

function _M:campaignUse(item)
	if not item then return end
	if item.locked then
		self.c_campaign.c_list.sel = self.c_campaign.previous
	else
		self:setDescriptor("world", item.id)

		self:generateDifficulties()
		self:generateRaces()
		self:generateClasses()
	end
end

function _M:difficultyUse(item)
	if not item then return end
	if item.locked then
		self.c_difficulty.c_list.sel = self.c_difficulty.previous
	else
		self:setDescriptor("difficulty", item.id)

		self:generateRaces()
		self:generateClasses()
	end
end

function _M:raceUse(item, sel, v)
	if not item then return end
	if item.nodes then
		for i, item in ipairs(self.c_race.tree) do if item.shown then self.c_race:treeExpand(false, item) end end
		self.c_race:treeExpand(nil, item)
	elseif not item.locked and item.basename then
		if self.sel_race then
			self.sel_race.name = self.sel_race.basename
			self.c_race:drawItem(self.sel_race)
		end
		self:setDescriptor("race", item.pid)
		self:setDescriptor("subrace", item.id)
		self.sel_race = item
		self.sel_race.name = tstring{{"font","bold"}, {"color","LIGHT_GREEN"}, self.sel_race.basename:toString(), {"font","normal"}}
		self.c_race:drawItem(item)

		self:generateClasses()
	end
end

function _M:classUse(item, sel, v)
	if not item then return end
	if item.nodes then
		for i, item in ipairs(self.c_class.tree) do if item.shown then self.c_class:treeExpand(false, item) end end
		self.c_class:treeExpand(nil, item)
	elseif not item.locked and item.basename then
		if self.sel_class then
			self.sel_class.name = self.sel_class.basename
			self.c_class:drawItem(self.sel_class)
		end
		self:setDescriptor("class", item.pid)
		self:setDescriptor("subclass", item.id)
		self.sel_class = item
		self.sel_class.name = tstring{{"font","bold"}, {"color","LIGHT_GREEN"}, self.sel_class.basename:toString(), {"font","normal"}}
		self.c_class:drawItem(item)
	end
end

function _M:updateDescriptors()
	self.descriptors = {}
	table.insert(self.descriptors, self.birth_descriptor_def.base[self.descriptors_by_type.base])
	table.insert(self.descriptors, self.birth_descriptor_def.world[self.descriptors_by_type.world])
	table.insert(self.descriptors, self.birth_descriptor_def.difficulty[self.descriptors_by_type.difficulty])
	table.insert(self.descriptors, self.birth_descriptor_def.sex[self.descriptors_by_type.sex])
	if self.descriptors_by_type.subrace then
		table.insert(self.descriptors, self.birth_descriptor_def.race[self.descriptors_by_type.race])
		table.insert(self.descriptors, self.birth_descriptor_def.subrace[self.descriptors_by_type.subrace])
	end
	if self.descriptors_by_type.subclass then
		table.insert(self.descriptors, self.birth_descriptor_def.class[self.descriptors_by_type.class])
		table.insert(self.descriptors, self.birth_descriptor_def.subclass[self.descriptors_by_type.subclass])
	end
end

function _M:setDescriptor(key, val)
	if key then
		self.descriptors_by_type[key] = val
		print("[BIRTHER] set descriptor", key, val)
	end
	self:updateDescriptors()

	local ok = self.c_name.text:len() >= 2
	for i, o in ipairs(self.order) do
		if not self.descriptors_by_type[o] then
			ok = false
			print("Missing ", o)
			break
		end
	end
	self:toggleDisplay(self.c_ok, ok)
end

function _M:isDescriptorAllowed(d)
	self:updateDescriptors()

	local allowed = true
	local type = d.type
	print("[BIRTHER] checking allowance for ", d.name)
	for j, od in ipairs(self.descriptors) do
		if od.descriptor_choices and od.descriptor_choices[type] then
			local what = util.getval(od.descriptor_choices[type][d.name], self) or util.getval(od.descriptor_choices[type].__ALL__, self)
			if what and what == "allow" then
				allowed = true
			elseif what and (what == "never" or what == "disallow") then
				allowed = false
			elseif what and what == "forbid" then
				allowed = nil
			end
			print("[BIRTHER] test against ", od.name, "=>", what, allowed)
			if allowed == nil then break end
		end
	end

	-- Check it is allowed
	return allowed
end

function _M:getLock(d)
	if not d.locked then return false end
	local ret = d.locked()
	if ret == "hide" then return "hide" end
	return not ret
end

function _M:generateCampaigns()
	local locktext = "\n\n#GOLD#This is a locked birth option. Performing certain actions and completing certain quests will make locked campaigns, races and classes permanently available."
	local list = {}

	for i, d in ipairs(self.birth_descriptor_def.world) do
		if self:isDescriptorAllowed(d) then
			local locked = self:getLock(d)
			if locked == true then
				list[#list+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- locked --", {"font", "normal"}}:toString(), id=d.name, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				list[#list+1] = { name = tstring{d.display_name}:toString(), id=d.name, desc=desc }
			end
		end
	end

	self.all_campaigns = list
	self.default_campaign = list[1].id
end

function _M:generateDifficulties()
	local locktext = "\n\n#GOLD#This is a locked birth option. Performing certain actions and completing certain quests will make locked campaigns, races and classes permanently available."
	local list = {}

	local oldsel = nil
	if self.c_difficulty then
		oldsel = self.c_difficulty.c_list.list[self.c_difficulty.c_list.sel].id
	end

	for i, d in ipairs(self.birth_descriptor_def.difficulty) do
		if self:isDescriptorAllowed(d) then
			local locked = self:getLock(d)
			if locked == true then
				list[#list+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- locked --", {"font", "normal"}}:toString(), id=d.name, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				list[#list+1] = { name = tstring{d.display_name}:toString(), id=d.name, desc=desc }
				if oldsel == d.name then oldsel = #list end
				if d.selection_default then self.default_difficulty = d.name end
			end
		end
	end

	self.all_difficulties = list
	if self.c_difficulty then
		self.c_difficulty.c_list.list = self.all_difficulties
		self.c_difficulty.c_list:generate()
		if type(oldsel) == "number" then self.c_difficulty.c_list.sel = oldsel end
	end
end

function _M:generateRaces()
	local locktext = "\n\n#GOLD#This is a locked birth option. Performing certain actions and completing certain quests will make locked campaigns, races and classes permanently available."

	local oldtree = {}
	for i, t in ipairs(self.all_races or {}) do oldtree[t.id] = t.shown end

	local tree = {}
	local newsel = nil
	for i, d in ipairs(self.birth_descriptor_def.race) do
		if self:isDescriptorAllowed(d) then
			local nodes = {}

			for si, sd in ipairs(self.birth_descriptor_def.subrace) do
				if d.descriptor_choices.subrace[sd.name] == "allow" then
					local locked = self:getLock(sd)
					if locked == true then
						nodes[#nodes+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- locked --", {"font", "normal"}}, id=sd.name, pid=d.name, locked=true, desc=sd.locked_desc..locktext }
					elseif locked == false then
						local desc = sd.desc
						if type(desc) == "table" then desc = table.concat(sd.desc, "\n") end
						nodes[#nodes+1] = { name = sd.display_name, basename = sd.display_name, id=sd.name, pid=d.name, desc=desc }
						if self.sel_race and self.sel_race.id == sd.name then newsel = nodes[#nodes] end
					end
				end
			end

			local locked = self:getLock(d)
			if locked == true then
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- locked --", {"font", "normal"}}, id=d.name, shown = oldtree[d.name], nodes = nodes, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "LIGHT_SLATE"}, d.display_name, {"font", "normal"}}, id=d.name, shown = oldtree[d.name], nodes = nodes, desc=desc }
			end
		end
	end

	self.all_races = tree
	if self.c_race then
		self.c_race.tree = self.all_races
		self.c_race:generate()
		if newsel then self:raceUse(newsel)
		else
			self.sel_race = nil
			self:setDescriptor("race", nil)
			self:setDescriptor("subrace", nil)
		end
		if self.descriptors_by_type.difficulty == "Tutorial" then
			self:raceUse(tree[1], 1)
			self:raceUse(tree[1].nodes[1], 2)
		end
	end
end

function _M:generateClasses()
	local locktext = "\n\n#GOLD#This is a locked birth option. Performing certain actions and completing certain quests will make locked campaigns, races and classes permanently available."

	local oldtree = {}
	for i, t in ipairs(self.all_classes or {}) do oldtree[t.id] = t.shown end

	local tree = {}
	local newsel = nil
	for i, d in ipairs(self.birth_descriptor_def.class) do
		if self:isDescriptorAllowed(d) then
			local nodes = {}

			for si, sd in ipairs(self.birth_descriptor_def.subclass) do
				if d.descriptor_choices.subclass[sd.name] == "allow" then
					local locked = self:getLock(sd)
					if locked == true then
						nodes[#nodes+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- locked --", {"font", "normal"}}, id=sd.name, pid=d.name, locked=true, desc=sd.locked_desc..locktext }
					elseif locked == false then
						local desc = sd.desc
						if type(desc) == "table" then desc = table.concat(sd.desc, "\n") end
						nodes[#nodes+1] = { name = sd.display_name, basename=sd.display_name, id=sd.name, pid=d.name, desc=desc }
						if self.sel_class and self.sel_class.id == sd.name then newsel = nodes[#nodes] end
					end
				end
			end

			local locked = self:getLock(d)
			if locked == true then
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "GREY"}, "-- locked --", {"font", "normal"}}, id=d.name, shown=oldtree[d.name], nodes = nodes, locked=true, desc=d.locked_desc..locktext }
			elseif locked == false then
				local desc = d.desc
				if type(desc) == "table" then desc = table.concat(d.desc, "\n") end
				tree[#tree+1] = { name = tstring{{"font", "italic"}, {"color", "LIGHT_SLATE"}, d.display_name, {"font", "normal"}}, id=d.name, shown=oldtree[d.name], nodes = nodes, desc=desc }
			end
		end
	end

	self.all_classes = tree
	if self.c_class then
		self.c_class.tree = self.all_classes
		self.c_class:generate()
		if newsel then self:classUse(newsel)
		else
			self.sel_class = nil
			self:setDescriptor("class", nil)
			self:setDescriptor("subclass", nil)
		end
		if self.descriptors_by_type.difficulty == "Tutorial" then
			self:classUse(tree[1], 1)
			self:classUse(tree[1].nodes[1], 2)
		end
	end
end

function _M:loadPremade(pm)
	local fallback = false

	-- Load the entities directly
	if pm.module_version and pm.module_version[1] == game.__mod_info.version[1] and pm.module_version[2] == game.__mod_info.version[2] and pm.module_version[3] == game.__mod_info.version[3] then
		savefile_pipe:ignoreSaveToken(true)
		local qb = savefile_pipe:doLoad(pm.short_name, "entity", "engine.CharacterVaultSave", "character")
		savefile_pipe:ignoreSaveToken(false)

		-- Load the player directly
		if qb then
			game.party = qb
			game.player = nil
			game.party:setPlayer(1, true)
			self:atEnd("loaded")
		else
			fallback = true
		end
	else
		fallback = true
	end

	-- Fill in the descriptors and validate
	if fallback then
		self.c_name:setText(pm.short_name)
--		self.
	end
end

function _M:loadPremadeUI()
	local lss = Module:listVaultSavesForCurrent()
	local d = Dialog.new("Characters Vault", 600, 550)

	local sel = nil
	local load = Button.new{text=" Load ", fct=function() if sel then self:loadPremade(sel) game:unregisterDialog(d) end end}
	local del = Button.new{text="Delete", fct=function() end}
	local desc = TextzoneList.new{width=220, height=400}
	local list list = List.new{width=350, list=lss, height=400,
		fct=function(item)
			local oldsel, oldscroll = list.sel, list.scroll
			if sel == item then self:loadPremade(sel) game:unregisterDialog(d) end
			if sel then sel.color = nil end
			item.color = colors.simple(colors.LIGHT_GREEN)
			sel = item
			list:generate()
			list.sel, list.scroll = oldsel, oldscroll
		end,
		select=function(item) desc:switchItem(item, item.description) end
	}
	local sep = Separator.new{dir="horizontal", size=400}

	d:loadUI{
		{left=0, top=0, ui=list},
		{left=list.w, top=0, ui=sep},
		{right=0, top=0, ui=desc},

		{left=0, bottom=0, ui=load},
		{right=0, bottom=0, ui=del},
	}
	d:setupUI(true, true)
	d.key:addBind("EXIT", function() game:unregisterDialog(d) end)
	game:registerDialog(d)
end

-- Disable stuff from the base Birther
function _M:updateList() end
function _M:selectType(type) end
function _M:on_register() end
