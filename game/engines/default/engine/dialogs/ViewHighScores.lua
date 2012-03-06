-- TE4 - T-Engine 4
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
local Dialog = require "engine.ui.Dialog"
local Textzone = require "engine.ui.Textzone"
local HighScores = require "engine.HighScores"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "High Scores", game.w * 0.8, game.h * 0.8)

	game:registerHighscore()

	local text = self:generateScores()
	self.c_desc = Textzone.new{width=self.iw, height=self.ih, text=text}

	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
	}
	self:setFocus(self.c_desc)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:generateScores()
	local player = game.party:findMember{main=true}
	local campaign = player.descriptor.world
	local formatters = game.__mod_info.score_formatters[campaign]

	return HighScores.createHighScoreTable(campaign,formatters)
end
