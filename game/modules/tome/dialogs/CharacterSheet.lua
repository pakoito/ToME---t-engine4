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
require "mod.class.interface.TooltipsData"
local Dialog = require "engine.ui.Dialog"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"
local Tab = require "engine.ui.Tab"
local SurfaceZone = require "engine.ui.SurfaceZone"
local Separator = require "engine.ui.Separator"
local Stats = require "engine.interface.ActorStats"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog, mod.class.interface.TooltipsData))

cs_player_dup = nil

function _M:init(actor)
	if _M.cs_player_dup and _M.cs_player_dup.name ~= actor.name then _M.cs_player_dup = nil end

	self.actor = actor
	Dialog.init(self, "Character Sheet: "..self.actor.name, math.max(game.w * 0.7, 950), 500)

	self.font = core.display.newFont("/data/font/DroidSansMono.ttf", 12)
	self.font_h = self.font:lineSkip()

	self.c_general = Tab.new{title="General", default=true, fct=function() end, on_change=function(s) if s then self:switchTo("general") end end}
	self.c_attack = Tab.new{title="Attack", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("attack") end end}
	self.c_defence = Tab.new{title="Defense", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("defence") end end}
	self.c_talents = Tab.new{title="Talents", default=false, fct=function() end, on_change=function(s) if s then self:switchTo("talents") end end}

	local tw, th = self.font_bold:size(self.title)

	self.vs = Separator.new{dir="vertical", size=self.iw}

	self.c_tut = Textzone.new{width=self.iw * 0.6, auto_height=true, no_color_bleed=true, font = self.font, text=[[
Values #00FF00#in brackets ( )#LAST# shows changes made from last character sheet checking.
Keyboard: #00FF00#'d'#LAST# to save character dump. #00FF00#TAB key#LAST# to switch between tabs.
Mouse: Hover over stat for info
]]}

	game.total_playtime = (game.total_playtime or 0) + (os.time() - (game.last_update or game.real_starttime))
	game.last_update = os.time()

	local playtime = ""
	local days = math.floor(game.total_playtime/86400)
	local hours = math.floor(game.total_playtime/3600) % 24
	local minutes = math.floor(game.total_playtime/60) % 60
	local seconds = game.total_playtime % 60

	if days > 0 then
		playtime = ("%i day%s %i hour%s %i minute%s %s second%s"):format(days, days > 1 and "s" or "", hours, hours > 1 and "s" or "", minutes, minutes > 1 and "s" or "", seconds, seconds > 1 and "s" or "")
	elseif hours > 0 then
		playtime = ("%i hour%s %i minute%s %s second%s"):format(hours, hours > 1 and "s" or "", minutes, minutes > 1 and "s" or "", seconds, seconds > 1 and "s" or "")
	elseif minutes > 0 then
		playtime = ("%i minute%s %s second%s"):format(minutes, minutes > 1 and "s" or "", seconds, seconds > 1 and "s" or "")
	else
		playtime = ("%s second%s"):format(seconds, seconds > 1 and "s" or "")
	end

	self.c_playtime = Textzone.new{width=self.iw * 0.4, auto_height=true, no_color_bleed=true, font = self.font, text=("#GOLD#Days adventuring / current month:#LAST# %d / %s\n#GOLD#Time playing:#LAST# %s"):format(game.turn / game.calendar.DAY, game.calendar:getMonthName(game.calendar:getDayOfYear(game.turn)), playtime)}

	self.c_desc = SurfaceZone.new{width=self.iw, height=self.ih - self.c_general.h - self.vs.h - self.c_tut.h,alpha=0}

	self.hoffset = 17 + math.max(self.c_tut.h, self.c_playtime.h) + self.vs.h + self.c_general.h

	self:loadUI{
		{left=0, top=0, ui=self.c_tut},
		{left=self.iw * 0.6, top=0, ui=self.c_playtime},
		{left=15, top=self.c_tut.h, ui=self.c_general},
		{left=15+self.c_general.w, top=self.c_tut.h, ui=self.c_attack},
		{left=15+self.c_general.w+self.c_attack.w, top=self.c_tut.h, ui=self.c_defence},
		{left=15+self.c_general.w+self.c_attack.w+self.c_defence.w, top=self.c_tut.h, ui=self.c_talents},
		{left=0, top=self.c_tut.h + self.c_general.h, ui=self.vs},

		{left=0, top=self.c_tut.h + self.c_general.h + 5 + self.vs.h, ui=self.c_desc},
	}
	self:setFocus(self.c_general)
	self:setupUI()

	self:switchTo("general")

	self:updateKeys()
end

function _M:innerDisplay(x, y, nb_keyframes)
	self.actor:toScreen(nil, x + self.iw - 128, y + 6, 128, 128)
end

function _M:switchTo(kind)
	self:drawDialog(kind, _M.cs_player_dup)
	if kind == "general" then self.c_attack.selected = false self.c_defence.selected = false self.c_talents.selected = false
	elseif kind == "attack" then self.c_general.selected = false self.c_defence.selected = false self.c_talents.selected = false
	elseif kind == "defence" then self.c_attack.selected = false self.c_general.selected = false self.c_talents.selected = false
	elseif kind == "talents" then self.c_attack.selected = false self.c_general.selected = false self.c_defence.selected = false
	end
	self:updateKeys()
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:updateKeys()
	self.key:addCommands{
	_TAB = function() self:tabTabs() end,
	__TEXTINPUT = function(c)
		if c == 'd' or c == 'D' then
			self:dump()
		end
	end,
	}

	self.key:addBinds{
		EXIT = function() _M.cs_player_dup = game.player:clone() game:unregisterDialog(self) end,
	}
end

function _M:tabTabs()
	if self.c_general.selected == true then self.c_attack:select()
	elseif self.c_attack.selected == true then self.c_defence:select()
	elseif 	self.c_defence.selected == true then self.c_talents:select()
	elseif self.c_talents.selected == true then self.c_general:select()
	end
end

function _M:mouseZones(t, no_new)
	-- Offset the x and y with the window position and window title
	if not t.norestrict then
		for i, z in ipairs(t) do
			if not z.norestrict then
				z.x = z.x + self.display_x + 5
				z.y = z.y + self.display_y + 20 + 3
			end
		end
	end

	if not no_new then self.mouse = engine.Mouse.new() end
	self.mouse:registerZones(t)
end

function _M:mouseTooltip(text, _, _, _, w, h, x, y)
	self:mouseZones({
		{ x=x, y=y+self.hoffset, w=w, h=h, fct=function(button) game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text) end},
	}, true)
end

function _M:mouseLink(link, text, _, _, _, w, h, x, y)
	self:mouseZones({
		{ x=x, y=y + self.hoffset, w=w, h=h, fct=function(button)
			game.tooltip_x, game.tooltip_y = 1, 1; game:tooltipDisplayAtMap(game.w, game.h, text)
			if button == "left" then
				util.browserOpenUrl(link)
			end
		end},
	}, true)
end

function _M:drawDialog(kind, actor_to_compare)
	--actor_to_compare = actor_to_compare or {}
	self.mouse:reset()

	self:setupUI()

	local player = self.actor
	local s = self.c_desc.s

	s:erase(0,0,0,0)

	local h = 0
	local w = 0

	local text = ""

	if player.__te4_uuid and profile.auth and profile.auth.drupid then
		local path = "http://te4.org/characters/"..profile.auth.drupid.."/tome/"..player.__te4_uuid
		local LinkTxt = "Online URL: #LIGHT_BLUE##{underline}#"..path.."#{normal}#"
		local Link_w, Link_h = self.font:size(LinkTxt)
		h = self.c_desc.h - Link_h
		w = (self.c_desc.w - Link_w) * 0.5
		self:mouseLink(path, "You can find your character sheet online", s:drawColorStringBlended(self.font, LinkTxt, w, h, 255, 255, 255, true))
	end

	local compare_fields = function(item1, item2, field, outformat, diffoutformat, mod, isinversed, nobracets, ...)
		mod = mod or 1
		isinversed = isinversed or false
		local ret = tstring{}
		local added = 0
		local add = false
		local value
		if type(field) == "function" then
			value = field(item1, ...)
		else
			value = item1[field]
		end
		ret:add(outformat:format((value or 0) * mod))

		if value then
			add = true
		end

		local value2
		if item2 then
			if type(field) == "function" then
				value2 = field(item2, ...)
			else
				value2 = item2[field]
			end
		end

		if value and value2 and value2 ~= value then
			if added == 0 and not nobracets then
				ret:add(" (")
			elseif added > 1 then
				ret:add(" / ")
			end
			added = added + 1
			add = true

			if isinversed then
				ret:add(value2 < value and {"color","RED"} or {"color","LIGHT_GREEN"}, diffoutformat:format(((value or 0) - value2) * mod), {"color", "LAST"})
			else
				ret:add(value2 > value and {"color","RED"} or {"color","LIGHT_GREEN"}, diffoutformat:format(((value or 0) - value2) * mod), {"color", "LAST"})
			end
		end
		if added > 0 and not nobracets then
			ret:add(")")
		end
		if add then
			return ret:toString()
		end
		return nil
	end

	local compare_table_fields = function(item1, item2, field, outformat, text, kfunct, mod, isinversed)
		mod = mod or 1
		isinversed = isinversed or false
		local ret = tstring{}
		local added = 0
		local add = false
		ret:add(text)
		local tab = {}
		if item1[field] then
			for k, v in pairs(item1[field]) do
				tab[k] = {}
				tab[k][1] = v
			end
		end
		if item2[field] then
			for k, v in pairs(item2[field]) do
				tab[k] = tab[k] or {}
				tab[k][2] = v
			end
		end
		local count1 = 0
		for k, v in pairs(tab) do
			local count = 0
			if isinversed then
				ret:add(("%s"):format((count1 > 0) and " / " or ""), (v[1] or 0) > 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			else
				ret:add(("%s"):format((count1 > 0) and " / " or ""), (v[1] or 0) < 0 and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0)), {"color","LAST"})
			end
			count1 = count1 + 1
			if v[1] then
				add = true
			end
			for kk, vv in pairs(v) do
				if kk > 1 and (v[1] or 0) ~= vv then
					if count == 0 then
						ret:add("(")
					elseif count > 0 then
						ret:add(" / ")
					end
					if isinversed then
						ret:add((v[1] or 0) > vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
					else
						ret:add((v[1] or 0) < vv and {"color","RED"} or {"color","LIGHT_GREEN"}, outformat:format((v[1] or 0) - vv), {"color","LAST"})
					end
					add = true
					count = count + 1
				end
			end
			if count > 0 then
				ret:add(")")
			end
			ret:add(kfunct(k))
		end

		if add then
			return ret:toString()
		end
		return nil
	end

	if kind == "general" then
		local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
		h = 0
		w = 0
		s:drawStringBlended(self.font, "Sex  : "..((player.descriptor and player.descriptor.sex) or (player.female and "Female" or "Male")), w, h, 0, 200, 255, true) h = h + self.font_h
		s:drawStringBlended(self.font, (player.descriptor and "Race : " or "Type : ")..((player.descriptor and player.descriptor.subrace) or player.type:capitalize()), w, h, 0, 200, 255, true) h = h + self.font_h
		s:drawStringBlended(self.font, (player.descriptor and "Class: " or "Stype: ")..((player.descriptor and player.descriptor.subclass) or player.subtype:capitalize()), w, h, 0, 200, 255, true) h = h + self.font_h
		s:drawStringBlended(self.font, "Size : "..(player:TextSizeCategory():capitalize()), w, h, 0, 200, 255, true) h = h + self.font_h

		h = h + self.font_h
		if player:attr("forbid_arcane") then
			s:drawColorStringBlended(self.font, "#ORCHID#Zigur follower", w, h, 255, 255, 255, true) h = h + self.font_h
		end

		h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_LEVEL, s:drawColorStringBlended(self.font,  "Level: #00ff00#"..player.level, w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_LEVEL, s:drawColorStringBlended(self.font, ("Exp  : #00ff00#%2d%%"):format(100 * cur_exp / max_exp), w, h, 255, 255, 255, true)) h = h + self.font_h
		self:mouseTooltip(self.TOOLTIP_GOLD, s:drawColorStringBlended(self.font, ("Gold : #00ff00#%0.2f"):format(player.money), w, h, 255, 255, 255, true)) h = h + self.font_h

		h = h + self.font_h

		text = compare_fields(player, actor_to_compare, "max_life", "%d", "%+.0f")
		if player.life < 0 then self:mouseTooltip(self.TOOLTIP_LIFE, s:drawColorStringBlended(self.font, ("#c00000#Life: #00ff00#???/%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		else self:mouseTooltip(self.TOOLTIP_LIFE, s:drawColorStringBlended(self.font, ("#c00000#Life: #00ff00#%d/%s"):format(player.life, text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end

		if player:knowTalent(player.T_STAMINA_POOL) then
			text = compare_fields(player, actor_to_compare, "max_stamina", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_STAMINA, s:drawColorStringBlended(self.font, ("#ffcc80#Stamina: #00ff00#%d/%s"):format(player:getStamina(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_MANA_POOL) then
			text = compare_fields(player, actor_to_compare, "max_mana", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_MANA, s:drawColorStringBlended(self.font, ("#7fffd4#Mana: #00ff00#%d/%s"):format(player:getMana(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_POSITIVE_POOL) then
			text = compare_fields(player, actor_to_compare, "max_positive", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_POSITIVE, s:drawColorStringBlended(self.font, ("#7fffd4#Positive: #00ff00#%d/%s"):format(player:getPositive(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_NEGATIVE_POOL) then
			text = compare_fields(player, actor_to_compare, "max_negative", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_NEGATIVE, s:drawColorStringBlended(self.font, ("#7fffd4#Negative: #00ff00#%d/%s"):format(player:getNegative(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_VIM_POOL) then
			text = compare_fields(player, actor_to_compare, "max_vim", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_VIM, s:drawColorStringBlended(self.font, ("#904010#Vim: #00ff00#%d/%s"):format(player:getVim(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_HATE_POOL) then
			self:mouseTooltip(self.TOOLTIP_HATE, s:drawColorStringBlended(self.font, ("#F53CBE#Hate: #00ff00#%d/%d"):format(player:getHate(), player.max_hate), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_PARADOX_POOL) then
			text = compare_fields(player, actor_to_compare, function(actor) local _, chance = actor:paradoxFailChance() return chance end, "%d%%", "%+.1f%%", 1, true)
			self:mouseTooltip(self.TOOLTIP_PARADOX, s:drawColorStringBlended(self.font, ("#LIGHT_STEEL_BLUE#Paradox: #00ff00#%d(fail: %s)"):format(player:getParadox(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_PSI_POOL) then
			text = compare_fields(player, actor_to_compare, "max_psi", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_PSI, s:drawColorStringBlended(self.font, ("#7fffd4#Psi: #00ff00#%d/%s"):format(player:getPsi(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:getMaxFeedback() > 0 then
			text = compare_fields(player, actor_to_compare, "psionic_feedback_max", "%d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_FEEDBACK, s:drawColorStringBlended(self.font, ("#7fffd4#Feedback: #00ff00#%d/%s"):format(player:getFeedback(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
			text = compare_fields(player, actor_to_compare, function(actor) local _, chance = actor:equilibriumChance() return 100 - chance end, "%d%%", "%+.1f%%", 1, true)
			self:mouseTooltip(self.TOOLTIP_EQUILIBRIUM, s:drawColorStringBlended(self.font, ("#00ff74#Equi: #00ff00#%d(fail: %s)"):format(player:getEquilibrium(), text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end

		h = 0
		w = self.w * 0.25

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Speeds:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, "global_speed", "%.2f%%", "%+.2f%%",100)
		self:mouseTooltip(self.TOOLTIP_SPEED_GLOBAL,   s:drawColorStringBlended(self.font, ("Global speed  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor) return (1/actor:combatMovementSpeed()-1) end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_SPEED_MOVEMENT, s:drawColorStringBlended(self.font, ("Movement speed: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor) return actor.combat_spellspeed - 1 end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_SPEED_SPELL,    s:drawColorStringBlended(self.font, ("Spell speed   : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor) return actor.combat_physspeed - 1 end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_SPEED_ATTACK,   s:drawColorStringBlended(self.font, ("Attack speed  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor) return actor.combat_mindspeed - 1 end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_SPEED_MENTAL,   s:drawColorStringBlended(self.font, ("Mental speed  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		h = h + self.font_h
		if player.died_times then
			text = compare_fields(player, actor_to_compare, function(actor) return #actor.died_times end, "%3d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_LIVES,       s:drawColorStringBlended(self.font, ("Times died     : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		if player.easy_mode_lifes then
			text = compare_fields(player, actor_to_compare, "easy_mode_lifes", "%3d", "%+.0f")
			self:mouseTooltip(self.TOOLTIP_LIVES, s:drawColorStringBlended(self.font,   ("Lives left     : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, function(actor) return util.bound((actor.healing_factor or 1), 0, 2.5) end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_HEALING_MOD, s:drawColorStringBlended(self.font, ("Healing mod.   : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, "life_regen", "%.2f", "%+.2f")
		self:mouseTooltip(self.TOOLTIP_LIFE_REGEN,  s:drawColorStringBlended(self.font, ("Life regen     : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor) return actor.life_regen * util.bound((actor.healing_factor or 1), 0, 2.5) end, "%.2f", "%+.2f")
		self:mouseTooltip(self.TOOLTIP_LIFE_REGEN,  s:drawColorStringBlended(self.font, ("(with heal mod): #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h

		h = h + self.font_h
		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Vision:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, "lite", "%d", "%+.0f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_LITE,  s:drawColorStringBlended(self.font, ("Light radius   : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, "sight", "%d", "%+.0f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_SIGHT,  s:drawColorStringBlended(self.font, ("Vision range   : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, function(actor) return (actor:attr("infravision") or actor:attr("heightened_senses")) and math.max((actor.heightened_senses or 0), (actor.infravision or 0)) end, "%d", "%+.0f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_INFRA,  s:drawColorStringBlended(self.font, ("Infravision    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, function(who) return who:attr("stealth") and who.stealth + (who:attr("inc_stealth") or 0) end, "%.1f", "%+.1f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_STEALTH,  s:drawColorStringBlended(self.font, ("Stealth        : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, "see_stealth", "%.1f", "%+.1f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_SEE_STEALTH,  s:drawColorStringBlended(self.font, ("See stealth    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, "invisible", "%.1f", "%+.1f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_INVISIBLE,  s:drawColorStringBlended(self.font, ("Invisibility   : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		text = compare_fields(player, actor_to_compare, "see_invisible", "%.1f", "%+.1f")
		if text then
			self:mouseTooltip(self.TOOLTIP_VISION_SEE_INVISIBLE,  s:drawColorStringBlended(self.font, ("See invisible  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end

		local any_esp = false
		local esps_compare = {}
		if actor_to_compare and actor_to_compare.esp_all then
			esps_compare["All"] = {}
			esps_compare["All"][1] = v
			any_esp = true
		end
		if player.esp_all then
			esps_compare["All"] = esps_compare["All"] or {}
			esps_compare["All"][2] = v
			any_esp = true
		end
		for type, v in pairs(actor_to_compare and (actor_to_compare.esp or {}) or {}) do
			if v ~= 0 then
				esps_compare[type] = {}
				esps_compare[type][1] = v
				any_esp = true
			end
		end
		for type, v in pairs(player.esp or {}) do
			if v ~= 0 then
				esps_compare[type] = esps_compare[type] or {}
				esps_compare[type][2] = v
				any_esp = true
			end
		end
		if any_esp then
			text = compare_fields(player, actor_to_compare, "esp_range", "%d", "%+.0f")
			if text then
				self:mouseTooltip(self.TOOLTIP_ESP_RANGE,  s:drawColorStringBlended(self.font, ("Telepathy range: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end

		-- player.forbid_arcane
		-- player.exp_mod
		-- player.can_breath[]

		h = 0
		w = self.w * 0.5

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Stats:        base/current", w, h, 255, 255, 255, true) h = h + self.font_h

		local print_stat = function(stat, name, tooltip)
			local StatVal = player:getStat(stat, nil, nil, true)
			local StatTxt = ""
			text = compare_fields(player, actor_to_compare, function(actor) return actor:getStat(stat, nil, nil, true) end, "", "%+.0f", 1, false, true)
			local text2 = compare_fields(player, actor_to_compare, function(actor) return actor:getStat(stat) end, "", "%+.0f", 1, false, true)

			local text3 = ("(%s / %s)"):format(text~="" and text or "0", text2~="" and text2 or "0")
			if text3 == "(0 / 0)" then
				text3 = ""
			end

--			if StatVal > player:getStat(stat) then
--				StatTxt = ("%s: #ff0000#%3d / %d#LAST#%s"):format(name, player:getStat(stat, nil, nil, true), player:getStat(stat), text3)
--			else
				StatTxt = ("%s: #00ff00#%3d / %d#LAST#%s"):format(name, player:getStat(stat, nil, nil, true), player:getStat(stat), text3)
--			end

			self:mouseTooltip(tooltip, s:drawColorStringBlended(self.font, StatTxt, w, h, 255, 255, 255, true)) h = h + self.font_h
		end

		print_stat(self.actor.STAT_STR, ("%-12s"):format(Stats.stats_def[self.actor.STAT_STR].name:capitalize()), self.TOOLTIP_STR)
		print_stat(self.actor.STAT_DEX, ("%-12s"):format(Stats.stats_def[self.actor.STAT_DEX].name:capitalize()), self.TOOLTIP_DEX)
		print_stat(self.actor.STAT_MAG, ("%-12s"):format(Stats.stats_def[self.actor.STAT_MAG].name:capitalize()), self.TOOLTIP_MAG)
		print_stat(self.actor.STAT_WIL, ("%-12s"):format(Stats.stats_def[self.actor.STAT_WIL].name:capitalize()), self.TOOLTIP_WIL)
		print_stat(self.actor.STAT_CUN, ("%-12s"):format(Stats.stats_def[self.actor.STAT_CUN].name:capitalize()), self.TOOLTIP_CUN)
		print_stat(self.actor.STAT_CON, ("%-12s"):format(Stats.stats_def[self.actor.STAT_CON].name:capitalize()), self.TOOLTIP_CON)
		h = h + self.font_h

		local nb_inscriptions = 0
		for i = 1, player.max_inscriptions do if player.inscriptions[i] then nb_inscriptions = nb_inscriptions + 1 end end
		self:mouseTooltip(self.TOOLTIP_INSCRIPTIONS, s:drawColorStringBlended(self.font, ("#AQUAMARINE#Inscriptions (%d/%d)"):format(nb_inscriptions, player.max_inscriptions), w, h, 255, 255, 255, true)) h = h + self.font_h
		for i = 1, player.max_inscriptions do if player.inscriptions[i] then
			local t = player:getTalentFromId("T_"..player.inscriptions[i])
			local desc = player:getTalentFullDescription(t)
			self:mouseTooltip("#GOLD##{bold}#"..t.name.."#{normal}##WHITE#\n"..tostring(desc), s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(t.name), w, h, 255, 255, 255, true)) h = h + self.font_h
		end end

		if any_esp then
			h = h + self.font_h
			self:mouseTooltip(self.TOOLTIP_ESP,  s:drawColorStringBlended(self.font, ("Telepathy of: "), w, h, 255, 255, 255, true)) h = h + self.font_h
			if not esps_compare["All"] then
				for type, v in pairs(esps_compare) do
					self:mouseTooltip(self.TOOLTIP_ESP,  s:drawColorStringBlended(self.font, ("%s%s "):format(v[2] and (v[1] and "#GOLD#" or "#00ff00#") or "#ff0000#", type:capitalize()), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			else
				self:mouseTooltip(self.TOOLTIP_ESP_ALL,  s:drawColorStringBlended(self.font, ("%sAll "):format(esps_compare["All"][1] and "#GOLD#" or "#00ff00#"), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end

		h = 0
		w = self.w * 0.77
		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Current effects:", w, h, 255, 255, 255, true) h = h + self.font_h
		for tid, act in pairs(player.sustain_talents) do
			if act then
				local t = player:getTalentFromId(tid)
				local desc = "#GOLD##{bold}#"..t.name.."#{normal}##WHITE#\n"..tostring(player:getTalentFullDescription(t))
				self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(player:getTalentFromId(tid).name), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end
		for eff_id, p in pairs(player.tmp) do
			local e = player.tempeffect_def[eff_id]
			local desc = e.long_desc(player, p)
			if e.status == "detrimental" then
				self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_RED#%s"):format(e.desc), w, h, 255, 255, 255, true)) h = h + self.font_h
			else
				self:mouseTooltip(desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(e.desc), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end
	elseif kind=="attack" then
		h = 0
		w = 0

		local mainhand = player:getInven(player.INVEN_MAINHAND)
		if mainhand and (#mainhand > 0) then
			local WeaponTxt = "#LIGHT_BLUE#Main Hand"
			if player:hasTwoHandedWeapon() then
				WeaponTxt = WeaponTxt.."(2-handed)"
			end
			WeaponTxt = WeaponTxt..":"

			for i, o in ipairs(player:getInven(player.INVEN_MAINHAND)) do
				local mean, dam = o.combat, o.combat
				if o.archery and mean then
					dam = (player:getInven("QUIVER") and player:getInven("QUIVER")[1] and player:getInven("QUIVER")[1].combat)
				end
				if mean and dam then
					s:drawColorStringBlended(self.font, WeaponTxt, w, h, 255, 255, 255, true) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return math.floor(actor:combatAttack(...)) end, "%3d", "%+.0f", 1, false, false, mean)
					dur_text = ("%d"):format(math.floor(player:combatAttack(o.combat)/5))
					self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatDamage(...) end, "%3d", "%+.0f", 1, false, false, dam)
					self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage      : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatAPR(...) end, "%3d", "%+.0f", 1, false, false, dam)
					self:mouseTooltip(self.TOOLTIP_COMBAT_APR,    s:drawColorStringBlended(self.font, ("APR         : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatCrit(...) end, "%3d%%", "%+.0f%%", 1, false, false, dam)
					self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT,   s:drawColorStringBlended(self.font, ("Crit. chance: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSpeed(...) end, "%.2f%%", "%+.2f%%", 100, true, false, mean)
					self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED,  s:drawColorStringBlended(self.font, ("Speed       : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
				if mean and mean.range then
					self:mouseTooltip(self.TOOLTIP_COMBAT_RANGE, s:drawColorStringBlended(self.font, ("Range (Main Hand): #00ff00#%3d"):format(mean.range), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		-- Handle bare-handed combat
		else
			s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Unarmed:", w, h, 255, 255, 255, true) h = h + self.font_h
			local mean, dam = player.combat, player.combat
			if mean and dam then
				text = compare_fields(player, actor_to_compare, function(actor, ...) return math.floor(actor:combatAttack(...)) end, "%3d", "%+.0f", 1, false, false, mean)
				dur_text = ("%d"):format(math.floor(player:combatAttack(player.combat)/5))
				self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
				text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatDamage(...) end, "%3d", "%+.0f", 1, false, false, dam)
				self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage      : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
				text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatAPR(...) end, "%3d", "%+.0f", 1, false, false, dam)
				self:mouseTooltip(self.TOOLTIP_COMBAT_APR,    s:drawColorStringBlended(self.font, ("APR         : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
				text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatCrit(...) end, "%3d%%", "%+.0f%%", 1, false, false, dam)
				self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT,   s:drawColorStringBlended(self.font, ("Crit. chance: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
				text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSpeed(...) end, "%.2f%%", "%+.2f%%", 100, false, false, mean)
				self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED,  s:drawColorStringBlended(self.font, ("Speed       : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
			if mean and mean.range then
				self:mouseTooltip(self.TOOLTIP_COMBAT_RANGE, s:drawColorStringBlended(self.font, ("Range (Main Hand): #00ff00#%3d"):format(mean.range), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end

		h = h + self.font_h
		-- All weapons in off hands
		-- Offhand attacks are with a damage penalty, that can be reduced by talents
		if player:getInven(player.INVEN_OFFHAND) then
			for i, o in ipairs(player:getInven(player.INVEN_OFFHAND)) do
				local offmult = player:getOffHandMult(o.combat)
				local mean, dam = o.combat, o.combat
				if o.archery and mean then
					dam = (player:getInven("QUIVER") and player:getInven("QUIVER")[1] and player:getInven("QUIVER")[1].combat)
				end
				if mean and dam then
					s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Off Hand:", w, h, 255, 255, 255, true) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return math.floor(actor:combatAttack(...)) end, "%3d", "%+.0f", 1, false, false, mean)
					dur_text = ("%d"):format(math.floor(player:combatAttack(o.combat)/5))
					self:mouseTooltip(self.TOOLTIP_COMBAT_ATTACK, s:drawColorStringBlended(self.font, ("Accuracy    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatDamage(...) end, "%3d", "%+.0f", offmult, false, false, dam)
					self:mouseTooltip(self.TOOLTIP_COMBAT_DAMAGE, s:drawColorStringBlended(self.font, ("Damage      : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatAPR(...) end, "%3d", "%+.0f", 1, false, false, dam)
					self:mouseTooltip(self.TOOLTIP_COMBAT_APR,    s:drawColorStringBlended(self.font, ("APR         : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatCrit(...) end, "%3d%%", "%+.0f%%", 1, false, false, dam)
					self:mouseTooltip(self.TOOLTIP_COMBAT_CRIT,   s:drawColorStringBlended(self.font, ("Crit. chance: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
					text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSpeed(...) end, "%.2f%%", "%+.2f%%", 100, false, false, mean)
					self:mouseTooltip(self.TOOLTIP_COMBAT_SPEED,  s:drawColorStringBlended(self.font, ("Speed       : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
				if mean and mean.range then self:mouseTooltip(self.TOOLTIP_COMBAT_RANGE, s:drawColorStringBlended(self.font, ("Range (Off Hand): #00ff00#%3d"):format(mean.range), w, h, 255, 255, 255, true)) h = h + self.font_h end
			end
		end

		-- player.combat_physcrit
		-- player.combat_mindcrit

		h = 0
		w = self.w * 0.25

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Magical:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSpellpower() end, "%3d", "%+.0f")
		dur_text = ("%d"):format(math.floor(player:combatSpellpower()/5))
		self:mouseTooltip(self.TOOLTIP_SPELL_POWER, s:drawColorStringBlended(self.font, ("Spellpower  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSpellCrit() end, "%d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_SPELL_CRIT, s:drawColorStringBlended(self.font,  ("Crit. chance: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatSpellSpeed() end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_SPELL_SPEED, s:drawColorStringBlended(self.font, ("Spell speed : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return (1 - (actor.spell_cooldown_reduction or 0)) * 100 end, "%3d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_SPELL_COOLDOWN  , s:drawColorStringBlended(self.font,   ("Spell cooldown: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		h = h + self.font_h
		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Mental:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatMindpower() end, "%3d", "%+.0f")
		dur_text = ("%d"):format(math.floor(player:combatMindpower()/5))
		self:mouseTooltip(self.TOOLTIP_MINDPOWER, s:drawColorStringBlended(self.font, ("Mindpower: #00ff00#%s"):format(text, dur_text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatMindCrit() end, "%d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_MIND_CRIT, s:drawColorStringBlended(self.font,  ("Crit. chance: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatMindSpeed() end, "%.2f%%", "%+.2f%%", 100)
		self:mouseTooltip(self.TOOLTIP_MIND_SPEED, s:drawColorStringBlended(self.font, ("Mind speed : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h

		h = 0
		w = self.w * 0.5

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Damage mods.:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return 150 + (actor.combat_critical_power or 0) end, "%3d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_INC_CRIT_POWER  , s:drawColorStringBlended(self.font,   ("Critical mult.: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h

		if player.inc_damage.all then
			text = compare_fields(player, actor_to_compare, function(actor, ...) return actor.inc_damage and actor.inc_damage.all or 0 end, "%3d%%", "%+.0f%%")
			self:mouseTooltip(self.TOOLTIP_INC_DAMAGE_ALL, s:drawColorStringBlended(self.font, ("All damage    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end

		local inc_damages = {}
		for i, t in ipairs(DamageType.dam_def) do
			if player.inc_damage[DamageType[t.type]] and player.inc_damage[DamageType[t.type]] ~= 0 then
				inc_damages[t] = inc_damages[t] or {}
				inc_damages[t][1] = player.inc_damage[DamageType[t.type]]
			end
			if actor_to_compare and actor_to_compare.inc_damage[DamageType[t.type]] and actor_to_compare.inc_damage[DamageType[t.type]] ~= 0 then
				inc_damages[t] = inc_damages[t] or {}
				inc_damages[t][2] = actor_to_compare.inc_damage[DamageType[t.type]]
			end
		end

		for i, ts in pairs(inc_damages) do
			if ts[1] then
				if ts[2] and ts[2] ~= ts[1] then
					self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("%s%-20s: #00ff00#%+d%%%s(%+.0f%%)"):format((i.text_color or "#WHITE#"), i.name:capitalize().."#LAST# damage", ts[1] + (player.inc_damage.all or 0), ts[2] > ts[1] and "#ff0000#" or "#00ff00#", ts[1] - ts[2] ), w, h, 255, 255, 255, true)) h = h + self.font_h
				else
					self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("%s%-20s: #00ff00#%+d%%"):format((i.text_color or "#WHITE#"), i.name:capitalize().."#LAST# damage", ts[1] + (player.inc_damage.all or 0)), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			else
				if ts[2] then
					self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("%s%-20s: #00ff00#%+d%%(%+.0f%%)"):format((i.text_color or "#WHITE#"), i.name:capitalize().."#LAST# damage", (player.inc_damage.all or 0),-ts[2] ), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		end

		local inc_damage_actor_types = {}
		if player.inc_damage_actor_type then
			for i, t in pairs(player.inc_damage_actor_type) do
				if player.inc_damage_actor_type[i] and player.inc_damage_actor_type[i] ~= 0 then
					inc_damage_actor_types[i] = inc_damage_actor_types[i] or {}
					inc_damage_actor_types[i][1] = player.inc_damage_actor_type[i]
				end
			end
		end
		if actor_to_compare and actor_to_compare.inc_damage_actor_type then
			for i, t in pairs(actor_to_compare.inc_damage_actor_type) do
				if actor_to_compare.inc_damage_actor_type[i] and actor_to_compare.inc_damage_actor_type[i] ~= 0 then
					inc_damage_actor_types[i] = inc_damage_actor_types[i] or {}
					inc_damage_actor_types[i][2] = actor_to_compare.inc_damage_actor_type[i]
				end
			end
		end
		for i, ts in pairs(inc_damage_actor_types) do
			if ts[1] then
				if ts[2] and ts[2] ~= ts[1] then
					self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("#ORANGE#%-20s: #00ff00#%+d%%%s(%+.0f%%)"):format(i:capitalize().."#LAST# damage", ts[1], ts[2] > ts[1] and "#ff0000#" or "#00ff00#", ts[1] - ts[2] ), w, h, 255, 255, 255, true)) h = h + self.font_h
				else
					self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("#ORANGE#%-20s: #00ff00#%+d%%"):format(i:capitalize().."#LAST# damage", ts[1]), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			else
				if ts[2] then
					self:mouseTooltip(self.TOOLTIP_INC_DAMAGE, s:drawColorStringBlended(self.font, ("#ORANGE#%-20s: #00ff00#%+d%%(%+.0f%%)"):format(i:capitalize().."#LAST# damage", 0,-ts[2] ), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		end

		h = 0
		w = self.w * 0.75

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Damage penetration.:", w, h, 255, 255, 255, true) h = h + self.font_h

		if player.resists_pen.all then
			text = compare_fields(player, actor_to_compare, function(actor, ...) return actor.resists_pen and actor.resists_pen.all or 0 end, "%3d%%", "%+.0f%%")
			self:mouseTooltip(self.TOOLTIP_RESISTS_PEN_ALL, s:drawColorStringBlended(self.font, ("All damage    : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end

		local resists_pens = {}
		for i, t in ipairs(DamageType.dam_def) do
			if player.resists_pen[DamageType[t.type]] and player.resists_pen[DamageType[t.type]] ~= 0 then
				resists_pens[t] = resists_pens[t] or {}
				resists_pens[t][1] = player.resists_pen[DamageType[t.type]]
			end
			if actor_to_compare and actor_to_compare.resists_pen[DamageType[t.type]] and actor_to_compare.resists_pen[DamageType[t.type]] ~= 0 then
				resists_pens[t] = resists_pens[t] or {}
				resists_pens[t][2] = actor_to_compare.resists_pen[DamageType[t.type]]
			end
		end

		for i, ts in pairs(resists_pens) do
			if ts[1] then
				if ts[2] and ts[2] ~= ts[1] then
					self:mouseTooltip(self.TOOLTIP_RESISTS_PEN, s:drawColorStringBlended(self.font, ("%s%-20s: #00ff00#%+d%%%s(%+.0f%%)"):format((i.text_color or "#WHITE#"), i.name:capitalize().."#LAST# damage", ts[1] + (player.resists_pen.all or 0), ts[2] > ts[1] and "#ff0000#" or "#00ff00#", ts[1] - ts[2] ), w, h, 255, 255, 255, true)) h = h + self.font_h
				else
					self:mouseTooltip(self.TOOLTIP_RESISTS_PEN, s:drawColorStringBlended(self.font, ("%s%-20s: #00ff00#%+d%%"):format((i.text_color or "#WHITE#"), i.name:capitalize().."#LAST# damage", ts[1] + (player.resists_pen.all or 0)), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			else
				if ts[2] then
					self:mouseTooltip(self.TOOLTIP_RESISTS_PEN, s:drawColorStringBlended(self.font, ("%s%-20s: #00ff00#%+d%%(%+.0f%%)"):format((i.text_color or "#WHITE#"), i.name:capitalize().."#LAST# damage", (player.resists_pen.all or 0),-ts[2] ), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		end

	elseif kind=="defence" then
		h = 0
		w = 0

		local ArmorTxt = "#LIGHT_BLUE#"
		if player:hasHeavyArmor() then
			ArmorTxt = ArmorTxt.."Heavy armor"
		elseif player:hasMassiveArmor() then
			ArmorTxt = ArmorTxt.."Massive armor"
		else
			ArmorTxt = ArmorTxt.."Light armor"
		end

		ArmorTxt = ArmorTxt..":"

		s:drawColorStringBlended(self.font, ArmorTxt, w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatFatigue() end, "%3d%%", "%+.0f%%", 1, true)
		self:mouseTooltip(self.TOOLTIP_FATIGUE, s:drawColorStringBlended(self.font,           ("Fatigue         : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatArmorHardiness() end, "%3d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_ARMOR_HARDINESS,   s:drawColorStringBlended(self.font, ("Armor Hardiness : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatArmor() end, "%3d", "%+.0f")
		self:mouseTooltip(self.TOOLTIP_ARMOR,   s:drawColorStringBlended(self.font,           ("Armor           : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatDefense(true) end, "%3d", "%+.0f")
		self:mouseTooltip(self.TOOLTIP_DEFENSE, s:drawColorStringBlended(self.font,           ("Defense         : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatDefenseRanged(true) end, "%3d", "%+.0f")
		self:mouseTooltip(self.TOOLTIP_RDEFENSE,s:drawColorStringBlended(self.font,           ("Ranged Defense  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return actor:combatCritReduction()  end, "%d%%", "%+.0f%%")
		self:mouseTooltip(self.TOOLTIP_CRIT_REDUCTION,s:drawColorStringBlended(self.font,           ("Crit. Reduction  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h

		h = h + self.font_h
		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Saves:", w, h, 255, 255, 255, true) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return math.floor(actor:combatPhysicalResist(true)) end, "%3d", "%+.0f")
		dur_text = ("%d"):format(math.floor(player:combatPhysicalResist(true)/5))
		self:mouseTooltip(self.TOOLTIP_PHYS_SAVE,   s:drawColorStringBlended(self.font, ("Physical: #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return math.floor(actor:combatSpellResist(true)) end, "%3d", "%+.0f")
		dur_text = ("%d"):format(math.floor(player:combatSpellResist(true)/5))
		self:mouseTooltip(self.TOOLTIP_SPELL_SAVE,  s:drawColorStringBlended(self.font, ("Spell   : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h
		text = compare_fields(player, actor_to_compare, function(actor, ...) return math.floor(actor:combatMentalResist(true)) end, "%3d", "%+.0f")
		dur_text = ("%d"):format(math.floor(player:combatMentalResist(true)/5))
		self:mouseTooltip(self.TOOLTIP_MENTAL_SAVE, s:drawColorStringBlended(self.font, ("Mental  : #00ff00#%s"):format(text), w, h, 255, 255, 255, true)) h = h + self.font_h

		h = 0
		w = self.w * 0.25

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Resistances base / cap:", w, h, 255, 255, 255, true) h = h + self.font_h

		local resists = {}
		for i, t in ipairs(DamageType.dam_def) do
			if player.resists[DamageType[t.type]] and player.resists[DamageType[t.type]] ~= 0 then
				resists[t] = resists[t] or {}
				resists[t][1] = player:combatGetResist(DamageType[t.type])
			end
			if actor_to_compare and actor_to_compare.resists[DamageType[t.type]] and actor_to_compare.resists[DamageType[t.type]] ~= 0 then
				resists[t] = resists[t] or {}
				resists[t][2] = actor_to_compare:combatGetResist(DamageType[t.type])
			end
		end

		if player.resists.all then
			text = compare_fields(player, actor_to_compare, function(actor, ...) return actor.resists.all end, "", "%+.0f%%", 1, false, true)
			local res_cap = compare_fields(player, actor_to_compare, function(actor, ...) return actor.resists_cap.all or 0 end, "", "%+.0f%%",  1, false, true)
			local res_text = ("(%s / %s)"):format(text ~= "" and text or "0", res_cap ~= "" and res_cap or "0")
			if res_text == "(0 / 0)" then
				res_text = ""
			end
			self:mouseTooltip(self.TOOLTIP_RESIST_ALL, s:drawColorStringBlended(self.font, ("%-10s: #00ff00#%3d%% / %d%%%s"):format("All", player.resists.all, player.resists_cap.all or 0, res_text), w, h, 255, 255, 255, true)) h = h + self.font_h
		end
		for i, t in ipairs(DamageType.dam_def) do
			if player.resists[DamageType[t.type]] and player.resists[DamageType[t.type]] ~= 0 then
				self:mouseTooltip(self.TOOLTIP_RESIST, s:drawColorStringBlended(self.font, ("%s%-10s#LAST#: #00ff00#%3d%% / %d%%"):format((t.text_color or "#WHITE#"), t.name:capitalize(), player:combatGetResist(DamageType[t.type]), (player.resists_cap[DamageType[t.type]] or 0) + (player.resists_cap.all or 0)), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end
		if player.resists_actor_type then
			for i, t in pairs(player.resists_actor_type) do
				if t and t ~= 0 then
					self:mouseTooltip(self.TOOLTIP_RESIST, s:drawColorStringBlended(self.font, ("#ORANGE#%-10s#LAST#: #00ff00#%3d%% / %d%%"):format(i:capitalize(), t, player.resists_cap_actor_type or 100), w, h, 255, 255, 255, true)) h = h + self.font_h
				end
			end
		end

		h = 0
		w = self.w * 0.52

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Effect resistances:", w, h, 255, 255, 255, true) h = h + self.font_h


		immune_type = "poison_immune" immune_name =    "Poison     " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "disease_immune" immune_name =   "Disease    " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "cut_immune" immune_name =       "Bleed      " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "confusion_immune" immune_name = "Confusion  " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "blind_immune" immune_name =     "Blind      " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "silence_immune" immune_name =   "Silence    " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "disarm_immune" immune_name =    "Disarm     " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "pin_immune" immune_name =       "Pinning    " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "stun_immune" immune_name =      "Stun/Freeze" if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "sleep_immune" immune_name =     "Sleep      " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "fear_immune" immune_name =      "Fear       " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "knockback_immune" immune_name = "Knockback  " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "stone_immune" immune_name =     "Stoning    " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "instakill_immune" immune_name = "Instadeath " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end
		immune_type = "teleport_immune" immune_name =  "Teleport   " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end

		immune_type = "negative_status_effect_immune" immune_name =	"All        " if player:attr(immune_type) then text = compare_fields(player, actor_to_compare, function(actor, ...) return util.bound((actor:attr(...) or 0) * 100, 0, 100) end, "%3d%%", "%+.0f%%", 1, false, false, immune_type) self:mouseTooltip(self.TOOLTIP_SPECIFIC_IMMUNE, s:drawColorStringBlended(self.font, ("%s: #00ff00#%s"):format(immune_name, text), w, h, 255, 255, 255, true)) h = h + self.font_h end

		h = 0
		w = self.w * 0.75

		s:drawColorStringBlended(self.font, "#LIGHT_BLUE#Damage when hit:", w, h, 255, 255, 255, true) h = h + self.font_h

		for i, t in ipairs(DamageType.dam_def) do
			if player.on_melee_hit[DamageType[t.type]] and player.on_melee_hit[DamageType[t.type]] ~= 0 then
				self:mouseTooltip(self.TOOLTIP_ON_HIT_DAMAGE, s:drawColorStringBlended(self.font, ("%s%-10s#LAST#: #00ff00#%.2f"):format((t.text_color or "#WHITE#"), t.name:capitalize(), player.on_melee_hit[DamageType[t.type]]), w, h, 255, 255, 255, true)) h = h + self.font_h
			end
		end

		--player.combat_mentalresist

	elseif kind=="talents" then
		h = 0
		w = 0

		local list = {}
		for j, t in pairs(player.talents_def) do
			if player:knowTalent(t.id) and not t.hide then
				local lvl = player:getTalentLevelRaw(t)
				list[#list+1] = {
					name = ("%s (%d)"):format(t.name, lvl),
					desc = player:getTalentFullDescription(t):toString(),
				}
			end
		end

		table.sort(list, function(a,b) return a.name < b.name end)

		for i, t in ipairs(list) do
			self:mouseTooltip(t.desc, s:drawColorStringBlended(self.font, ("#LIGHT_GREEN#%s"):format(t.name), w, h, 255, 255, 255, true)) h = h + self.font_h

			if h + self.font_h >= self.c_desc.h then h = 0 w = w + self.c_desc.w / 6 end
		end
	end

	self.c_desc:generate()
	self.changed = false
end

function _M:dump()
	local player = self.actor

	fs.mkdir("/character-dumps")
	local file = "/character-dumps/"..(player.name:gsub("[^a-zA-Z0-9_-.]", "_")).."-"..os.date("%Y%m%d-%H%M%S")..".txt"
	local fff = fs.open(file, "w")
	local labelwidth = 17
	local nl = function(s) s = s or "" fff:write(s:removeColorCodes()) fff:write("\n") end
	local nnl = function(s) s = s or "" fff:write(s:removeColorCodes()) end
	--prepare label and value
	local makelabel = function(s,r) while s:len() < labelwidth do s = s.." " end return ("%s: %s"):format(s, r) end

	local cur_exp, max_exp = player.exp, player:getExpChart(player.level+1)
	nl("  [ToME4 @ www.te4.org Character Dump]")
	nl()

	nnl(("%-32s"):format(makelabel("Sex", (player.descriptor and player.descriptor.sex) or (player.female and "Female" or "Male"))))
	nl(("STR:  %d"):format(player:getStr()))

	nnl(("%-32s"):format(makelabel("Race", (player.descriptor and player.descriptor.subrace) or player.type:capitalize())))
	nl(("DEX:  %d"):format(player:getDex()))

	nnl(("%-32s"):format(makelabel("Class", (player.descriptor and player.descriptor.subclass) or player.subtype:capitalize())))
	nl(("MAG:  %d"):format(player:getMag()))

	nnl(("%-32s"):format(makelabel("Level", ("%d"):format(player.level))))
	nl(("WIL:  %d"):format(player:getWil()))

	nnl(("%-32s"):format(makelabel("Exp", ("%d%%"):format(100 * cur_exp / max_exp))))
	nl(("CUN:  %d"):format(player:getCun()))

	nnl(("%-32s"):format(makelabel("Gold", ("%.2f"):format(player.money))))
	nl(("CON:  %d"):format(player:getCon()))

	 -- All weapons in main hands
	local strings = {}
	for i = 1, 6 do strings[i]="" end
	if player:getInven(player.INVEN_MAINHAND) then
		for i, o in ipairs(player:getInven(player.INVEN_MAINHAND)) do
			local mean, dam = o.combat, o.combat
			if o.archery and mean then
				dam = (player:getInven("QUIVER")[1] and player:getInven("QUIVER")[1].combat)
			end
			if mean and dam then
				strings[1] = ("Accuracy(Main Hand): %3d"):format(player:combatAttack(mean))
				strings[2] = ("Damage  (Main Hand): %3d"):format(player:combatDamage(dam))
				strings[3] = ("APR     (Main Hand): %3d"):format(player:combatAPR(dam))
				strings[4] = ("Crit    (Main Hand): %3d%%"):format(player:combatCrit(dam))
				strings[5] = ("Speed   (Main Hand): %0.2f"):format(player:combatSpeed(mean))
			end
			if mean and mean.range then strings[6] = ("Range (Main Hand): %3d"):format(mean.range) end
		end
	end
	--Unarmed??
	if player:isUnarmed() then
		local mean, dam = player.combat, player.combat
		if mean and dam then
			strings[1] = ("Accuracy(Unarmed): %3d"):format(player:combatAttack(mean))
			strings[2] = ("Damage  (Unarmed): %3d"):format(player:combatDamage(dam))
			strings[3] = ("APR     (Unarmed): %3d"):format(player:combatAPR(dam))
			strings[4] = ("Crit    (Unarmed): %3d%%"):format(player:combatCrit(dam))
			strings[5] = ("Speed   (Unarmed): %0.2f"):format(player:combatSpeed(mean))
		end
		if mean and mean.range then strings[6] = ("Range (Unarmed): %3d"):format(mean.range) end
	end

	local enc, max = player:getEncumbrance(), player:getMaxEncumbrance()

	nl()
	nnl(("%-32s"):format(strings[1]))
	nnl(("%-32s"):format(makelabel("Life", ("    %d/%d"):format(player.life, player.max_life))))
	nl(makelabel("Encumbrance", enc .. "/" .. max))

	nnl(("%-32s"):format(strings[2]))
	if player:knowTalent(player.T_STAMINA_POOL) then
		nnl(("%-32s"):format(makelabel("Stamina", ("    %d/%d"):format(player:getStamina(), player.max_stamina))))
	else
		 nnl(("%-32s"):format(" "))
	end
	nl(makelabel("Difficulty", (player.descriptor and player.descriptor.difficulty) or "???"))
	nl(makelabel("Permadeath", (player.descriptor and player.descriptor.permadeath) or "???"))

	nnl(("%-32s"):format(strings[3]))
	if player:knowTalent(player.T_MANA_POOL) then
		nl(makelabel("Mana", ("    %d/%d"):format(player:getMana(), player.max_mana)))
	else
		nl()
	end
	nnl(("%-32s"):format(strings[4]))
	if player:knowTalent(player.T_POSITIVE_POOL) then
		nl(makelabel("Positive", ("    %d/%d"):format(player:getPositive(), player.max_positive)))
	else
		nl()
	end
	nnl(("%-32s"):format(strings[5]))
	if player:knowTalent(player.T_NEGATIVE_POOL) then
		nl(makelabel("Negative", ("    %d/%d"):format(player:getNegative(), player.max_negative)))
	else
		nl()
	end
	nnl(("%-32s"):format(strings[6]))
	if player:knowTalent(player.T_VIM_POOL) then
		nl(makelabel("Vim", ("    %d/%d"):format(player:getVim(), player.max_vim)))
	else
		nl()
	end
	nnl(("%-32s"):format(""))
	if player:knowTalent(player.T_EQUILIBRIUM_POOL) then
		nl((makelabel("Equilibrium", ("    %d"):format(player:getEquilibrium()))))
	else
		nl()
	end
	nnl(("%-32s"):format(""))
	if player:knowTalent(player.T_PARADOX_POOL) then
		nl((makelabel("Paradox", ("    %d"):format(player:getParadox()))))
	else
		nl()
	end

	-- All weapons in off hands
	-- Offhand attacks are with a damage penalty, that can be reduced by talents
	if player:getInven(player.INVEN_OFFHAND) then
		for i, o in ipairs(player:getInven(player.INVEN_OFFHAND)) do
			local offmult = player:getOffHandMult(o.combat)
			local mean, dam = o.combat, o.combat
			if o.archery and mean then
				dam = (player:getInven("QUIVER")[1] and player:getInven("QUIVER")[1].combat)
			end
			if mean and dam then
				nl()
				nl(("Accuracy(Off Hand): %3d"):format(player:combatAttack(mean)))
				nl(("Damage  (Off Hand): %3d"):format(player:combatDamage(dam) * offmult))
				nl(("APR     (Off Hand): %3d"):format(player:combatAPR(dam)))
				nl(("Crit    (Off Hand): %3d%%"):format(player:combatCrit(dam)))
				nl(("Speed   (Off Hand): %0.2f"):format(player:combatSpeed(mean)))
			end
			if mean and mean.range then strings[6] = ("Range (Off Hand): %3d"):format(mean.range) end
		end
	end

	nl()
	nnl(("%-32s"):format(makelabel("Fatigue", player:combatFatigue() .. "%")))
	nl(makelabel("Spellpower", player:combatSpellpower() ..""))
	nnl(("%-32s"):format(makelabel("Armor", player:combatArmor() .. "")))
	nl(makelabel("Spell Crit", player:combatSpellCrit() .."%"))
	nnl(("%-32s"):format(makelabel("Armor Hardiness", player:combatArmorHardiness() .. "%")))
	nl(makelabel("Spell Speed", player:combatSpellSpeed() ..""))
	nnl(("%-32s"):format(makelabel("Defense", player:combatDefense(true) .. "")))
	nl()
	nnl(("%-32s"):format(makelabel("Ranged Defense", player:combatDefenseRanged(true) .. "")))

	nl()
	if player.inc_damage.all then nl(makelabel("All damage", player.inc_damage.all.."%")) end
	for i, t in ipairs(DamageType.dam_def) do
		if player.inc_damage[DamageType[t.type]] and player.inc_damage[DamageType[t.type]] ~= 0 then
			nl(makelabel(t.name:capitalize().." damage", (player.inc_damage[DamageType[t.type]] + (player.inc_damage.all or 0)).."%"))
		end
	end

	nl()
	nl(makelabel("Physical Save",player:combatPhysicalResist(true) ..""))
	nl(makelabel("Spell Save",player:combatSpellResist(true) ..""))
	nl(makelabel("Mental Save",player:combatMentalResist(true) ..""))

	nl()
	if player.resists.all then nl(("All Resists: %3d%%"):format(player.resists.all, player.resists_cap.all or 0)) end
	for i, t in ipairs(DamageType.dam_def) do
		if player.resists[DamageType[t.type]] and player.resists[DamageType[t.type]] ~= 0 then
			nl(("%s Resist(cap): %3d%%(%3d%%)"):format(t.name:capitalize(), player:combatGetResist(DamageType[t.type]), (player.resists_cap[DamageType[t.type]] or 0) + (player.resists_cap.all or 0)))
		end
	end

	immune_type = "poison_immune" immune_name = "Poison Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "disease_immune" immune_name = "Disease Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "cut_immune" immune_name = "Bleed Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "confusion_immune" immune_name = "Confusion Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "blind_immune" immune_name = "Blind Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "silence_immune" immune_name = "Silence Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "disarm_immune" immune_name = "Disarm Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "pin_immune" immune_name = "Pinning Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "stun_immune" immune_name = "Stun Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "sleep_immune" immune_name = "Sleep Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "fear_immune" immune_name = "Fear Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "knockback_immune" immune_name = "Knockback Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "stone_immune" immune_name = "Stoning Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "instakill_immune" immune_name = "Instadeath Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end
	immune_type = "teleport_immune" immune_name = "Teleport Resistance" if player:attr(immune_type) then nl(("%s: %3d%%"):format(immune_name, util.bound(player:attr(immune_type) * 100, 0, 100))) end

	nl()
	local most_kill, most_kill_max = "none", 0
	local total_kill = 0
	for name, nb in pairs(player.all_kills or {}) do
		if nb > most_kill_max then most_kill_max = nb most_kill = name end
		total_kill = total_kill + nb
	end
	nl(("Number of NPC killed: %s"):format(total_kill))
	nl(("Most killed NPC: %s (%d)"):format(most_kill, most_kill_max))

	if player.winner then
		nl()
		nl("  [Winner!]")
		nl()
		for i, line in ipairs(player.winner_text) do
			nl(("%s"):format(line:removeColorCodes()))
		end
	end

	-- Talents
	nl()
	nl("  [Talents Chart]")
	nl()
	for i, tt in ipairs(player.talents_types_def) do
		 local ttknown = player:knowTalentType(tt.type)
		if not (player.talents_types[tt.type] == nil) and ttknown then
			local cat = tt.type:gsub("/.*", "")
			local catname = ("%s / %s"):format(cat:capitalize(), tt.name:capitalize())
			nl((" - %-35s(mastery %.02f)"):format(catname, player:getTalentTypeMastery(tt.type)))

			-- Find all talents of this school
			if (ttknown) then
				for j, t in ipairs(tt.talents) do
					if not t.hide then
						local typename = "class"
						if t.generic then typename = "generic" end
						local skillname = ("    %s (%s)"):format(t.name, typename)
						nl(("%-37s %d/%d"):format(skillname, player:getTalentLevelRaw(t.id), t.points))
					end
				end
			end
		end
	end

	-- Inscriptions
	local nb_inscriptions = 0
	for i = 1, player.max_inscriptions do if player.inscriptions[i] then nb_inscriptions = nb_inscriptions + 1 end end
	nl()
	nl(("  [Inscriptions (%d/%d)]"):format(nb_inscriptions, player.max_inscriptions))
	nl()
	for i = 1, player.max_inscriptions do if player.inscriptions[i] then
		local t = player:getTalentFromId("T_"..player.inscriptions[i])
		local desc = player:getTalentFullDescription(t)
		nl(("%s"):format(t.name))
	end end

	 -- Current Effects

	 nl()
	 nl("  [Current Effects]")
	 nl()

	for tid, act in pairs(player.sustain_talents) do
		if act then nl("- "..player:getTalentFromId(tid).name)	end
	end
	for eff_id, p in pairs(player.tmp) do
		local e = player.tempeffect_def[eff_id]
		if e.status == "detrimental" then
			 nl("+ "..e.desc)
		else
			 nl("- "..e.desc)
		end
	end

	-- Quests, Active and Completed

	local first = true
	for id, q in pairs(game.party.quests or {}) do
		if q:isEnded() then
			if first then
					nl()
					nl("  [Completed Quests]")
					nl()
					first=false
			end
			nl(" -- ".. q.name)
			nl(q:desc(game.party):gsub("#.-#", "   "))
		end
	end

	 first=true
	for id, q in pairs(game.party.quests or {}) do
		if not q:isEnded() then
			if first then
					first=false
					nl()
					nl("  [Active Quests]")
					nl()
				end
			nl(" -- ".. q.name)
			nl(q:desc(game.party):gsub("#.-#", "   "))
		end
	end


	--All Equipment
	nl()
	nl("  [Character Equipment]")
	nl()
	local index = 0
	for inven_id =  1, #player.inven_def do
		if player.inven[inven_id] and player.inven_def[inven_id].is_worn then
			nl((" %s"):format(player.inven_def[inven_id].name))

			for item, o in ipairs(player.inven[inven_id]) do
				if not self.filter or self.filter(o) then
					local char = string.char(string.byte('a') + index)
					nl(("%s) %s"):format(char, o:getName{force_id=true}))
					nl(("   %s"):format(tostring(o:getTextualDesc())))
					if o.droppedBy then
						nl(("   Dropped by %s"):format(o.droppedBy))
					end
					index = index + 1
				end
			end
		end
	end

	nl()
	nl("  [Player Achievements]")
	nl()
	local achs = {}
	for id, data in pairs(player.achievements or {}) do
		local a = world:getAchievementFromId(id)
		achs[#achs+1] = {id=id, data=data, name=a.name}
	end
	table.sort(achs, function(a, b) return a.name < b.name end)
	for i, d in ipairs(achs) do
		local a = world:getAchievementFromId(d.id)
		nl(("'%s' was achieved for %s At %s"):format(a.name, a.desc, d.data.when))
	end

	nl()
	nl("  [Character Inventory]")
	nl()
	for item, o in ipairs(player:getInven("INVEN")) do
		if not self.filter or self.filter(o) then
			local char = string.char(string.byte('a') + item - 1)
			nl(("%s) %s"):format(char, o:getName{force_id=true}))
			nl(("   %s"):format(tostring(o:getTextualDesc())))
			if o.droppedBy then
				nl(("   Dropped by %s"):format(o.droppedBy))
			end
		end
	end

	nl()
	nl("  [Last Messages]")
	nl()

	nl(table.concat(game.uiset.logdisplay:getLines(40), "\n"):removeColorCodes())

	fff:close()

	Dialog:simplePopup("Character dump complete", "File: "..fs.getRealPath(file))
end
