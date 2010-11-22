-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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
require "engine.GameEnergyBased"
require "engine.interface.GameSound"
require "engine.interface.GameMusic"
require "engine.interface.GameTargeting"
require "engine.KeyBind"

local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local Tooltip = require "engine.Tooltip"
local MainMenu = require "mod.dialogs.MainMenu"

local Shader = require "engine.Shader"
local Zone = require "engine.Zone"
local Map = require "engine.Map"
local Level = require "engine.Level"
local FlyingText = require "engine.FlyingText"

local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

module(..., package.seeall, class.inherit(engine.GameEnergyBased, engine.interface.GameMusic, engine.interface.GameSound))

function _M:init()
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)
	engine.GameEnergyBased.init(self, engine.KeyBind.new(), 100, 100)
	self.profile_font = core.display.newFont("/data/font/VeraIt.ttf", 14)
	self.background = core.display.loadImage("/data/gfx/background/back.jpg")
	if self.background then
		self.background, self.background_w, self.background_h = self.background:glTexture()
	end

	self.tooltip = Tooltip.new(nil, 14, nil, colors.DARK_GREY, 400)

--	self.refuse_threads = true
	self.normal_key = self.key
	self.stopped = config.settings.boot_menu_background

	self:loaded()
end

function _M:loaded()
	engine.GameEnergyBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
end

function _M:run()
	self.flyers = FlyingText.new()
	self:setFlyingText(self.flyers)
	self.log = function(style, ...) end
	self.logSeen = function(e, style, ...) end
	self.logPlayer = function(e, style, ...) end

	-- Starting from here we create a new game
	self:newGame()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	-- Setup display
	self:registerDialog(MainMenu.new())

	-- Run the current music if any
	self:volumeMusic(config.settings.music.volume)
	self:playMusic("The saga begins.ogg")

	-- Get news
	if not self.news then
		self.news = {
			title = "Welcome to T-Engine and the Tales of Maj'Eyal",
			text = [[From this interface you can create new characters for the game modules you want to play.

#GOLD#"Tales of Maj'Eyal"#WHITE# is the default game module, you can also install more by selecting "Install a game module" or by going to http://te4.org/

When inside a module remember you can press Escape to bring up a menu to change keybindings, resolution and other module specific options.

Remember that in most roguelikes death is usually permanent so be careful!

Now go and have some fun!]]
		}

		self:serverNews()
		self:updateNews()
	end

--	self:installNewEngine()

	if not self.firstrunchecked then
		-- Check first time run for online profile
		self.firstrunchecked = true
		self:checkFirstTime()
	end

	if self.s_log then
		local w, h = self.s_log:getSize()
		self.mouse:registerZone(self.w - w, self.h - h, w, h, function(button)
			if button == "left" then util.browserOpenUrl(self.logged_url) end
		end, {button=true})
	end
end

function _M:newGame()
	self.player = Player.new{name=self.player_name, game_ender=true}
	Map:setViewerActor(self.player)
	self:setupDisplayMode()

	self.player:resolve()
	self.player:resolve(nil, true)
	self.player.energy.value = self.energy_to_act

	Zone:setup{npc_class="mod.class.NPC", grid_class="mod.class.Grid", }
	self:changeLevel(1, "dungeon")
end

function _M:onResolutionChange()
	local oldw, oldh = self.w, self.h
	engine.Game.onResolutionChange(self)
	print("[RESOLUTION] changed to ", self.w, self.h)
	if not self.change_res_dialog then
		self.change_res_dialog = Dialog:yesnoPopup("Resolution changed", "Accept the new resolution?", function(ret)
			self.change_res_dialog = nil
			if ret then
				util.showMainMenu(false, nil, nil, "boot", "boot", false)
			else
				self:setResolution(oldw.."x"..oldh, true)
			end
		end, "Accept", "Revert")
	end
end

function _M:setupDisplayMode()
	Map:setViewPort(0, 0, self.w, self.h, 32, 32, nil, 22, true, true)
	Map:resetTiles()
	Map.tiles.use_images = true

	-- Create the framebuffer
	self.fbo = core.display.newFBO(game.w, game.h)
	if self.fbo then
		self.fbo_shader = Shader.new("main_fbo")
		if not self.fbo_shader.shad then
			self.fbo = nil self.fbo_shader = nil
		else
			self.fbo_shader:setUniform("colorize", {1,1,1})
		end
	end
end

function _M:changeLevel(lev, zone)
	local old_lev = (self.level and not zone) and self.level.level or -1000
	if zone then
		if self.zone then
			self.zone:leaveLevel(false, lev, old_lev)
			self.zone:leave()
		end
		if type(zone) == "string" then
			self.zone = Zone.new(zone)
		else
			self.zone = zone
		end
	end
	self.zone:getLevel(self, lev, old_lev)

	if lev > old_lev then
		self.player:move(self.level.default_up.x, self.level.default_up.y, true)
	else
		self.player:move(self.level.default_down.x, self.level.default_down.y, true)
	end
	self.level:addEntity(self.player)
end

function _M:getPlayer()
	return self.player
end

function _M:updateNews()
	if self.news.link then
		self.tooltip:set("#AQUAMARINE#%s#WHITE#\n---\n%s\n---\n#LIGHT_BLUE##{underline}#%s#LAST##{normal}#", self.news.title, self.news.text, self.news.link)
	else
		self.tooltip:set("#AQUAMARINE#%s#WHITE#\n---\n%s", self.news.title, self.news.text)
	end

	if self.news.link then
		self.mouse:registerZone(5, self.tooltip.h - 30, self.tooltip.w, 30, function(button)
			if button == "left" then util.browserOpenUrl(self.news.link) end
		end, {button=true})
	end
end

function _M:tick()
	if self.stopped then return end
	if self.level then
		engine.GameEnergyBased.tick(self)
		-- Fun stuff: this can make the game realtime, although callit it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	end
	return false
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Process overlay effects
	self.level.map:processEffects()
end

function _M:display()
	-- If switching resolution, blank everything but the dialog
	if self.change_res_dialog then engine.GameEnergyBased.display(self) return end

	-- If background anim is stopped, thigns are much simplied
	if self.stopped then
		if self.background then self.background:toScreenFull(0, 0, self.w, self.h, self.background_w, self.background_h) end
		self.tooltip:display()
		self.tooltip:toScreen(5, 5)
		engine.GameEnergyBased.display(self)
		return
	end

	-- Display using Framebuffer, so that we can use shaders and all
	if self.fbo then self.fbo:use(true) end

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		-- Display the map and compute FOV for the player if needed
		if self.level.map.changed then
			self.player:playerFOV()
		end

		self.level.map:display()
	end

	-- Draw it here, inside the FBO
	self.flyers:display()

	-- Display using Framebuffer, sotaht we can use shaders and all
	if self.fbo then
		self.fbo:use(false)
		_2DNoise:bind(1, false)
		self.fbo:toScreen(
			self.level.map.display_x, self.level.map.display_y,
			self.level.map.viewport.width, self.level.map.viewport.height,
			self.fbo_shader.shad
		)
	else
--		core.display.drawQuad(0, 0, game.w, game.h, 128, 128, 128, 128)
	end

	self.tooltip:display()
	self.tooltip:toScreen(5, 5)

	local old = self.flyers
	self.flyers = nil
	engine.GameEnergyBased.display(self)
	self.flyers = old
end

--- Skip to a module directly ?
function _M:commandLineArgs(args)
	local req_mod = nil
	local req_save = nil
	local req_new = false
	for i, arg in ipairs(args) do
		if arg:find("^%-M") then
			-- Force module loading
			req_mod = arg:sub(3)
		end
		if arg:find("^%-u") then
			-- Force save loading
			req_save = arg:sub(3)
		end
		if arg:find("^%-n") then
			-- Force save loading
			req_new = true
		end
	end

	if req_mod then
		local mod = self.mod_list[req_mod]
		if mod then
			Module:instanciate(mod, req_save or "player", req_new)
		else
			print("Error: module "..req_mod.." not found!")
		end
	end
end

--- Ask if we realy want to close, if so, save the game first
function _M:onQuit()
	if self.is_quitting then return end
	self.is_quitting = Dialog:yesnoPopup("Quit", "Really exit T-Engine/ToME?", function(ok)
		self.is_quitting = false
		if ok then os.exit() end
	end, "Quit", "Continue")
end

profile_help_text = [[#LIGHT_GREEN#T-Engine4#LAST# allows you to sync your player profile with the website #LIGHT_BLUE#http://te4.org/#LAST#

This allows you to:
* Play from several computers without having to copy unlocks and achievements.
* Keep track of your modules progression, kill count, ...
* Cool statistics for each module to help sharpen your gameplay style
* Help the game developers balance and refine the game

Later on you will have an online profile page you can show to people to brag.
This is all optional, you are not forced to use this feature at all, but the developers would thank you if you did as it will
make balancing easier.
Online profile requires an internet connection, if not available it will wait and sync when it finds one.]]

function _M:checkFirstTime()
	if not profile.generic.firstrun then
		profile:checkFirstRun()
		local text = "Thanks for downloading T-Engine/ToME.\n\n"..profile_help_text
		Dialog:yesnoLongPopup("Welcome to T-Engine", text, 400, function(ret)
			if ret then
				self:registerDialog(require("mod.dialogs.Profile").new())
			end
		end, "Register now", "Maybe later")
	end
end

function _M:createProfile(loginItem)
	if self.justlogin then
		profile:performlogin(loginItem.login, loginItem.pass)
		if profile.auth then
			Dialog:simplePopup("Profile logged in!", "Your online profile is active now...", function() end )
		else
			Dialog:simplePopup("Log in rejected", "Couldn't log you...", function() end )
		end
		return
	end
	profile:newProfile(loginItem.login, loginItem.name, loginItem.pass, loginItem.email)
	if (profile.auth) then
		Dialog:simplePopup("Profile created!", "Your online profile is active now...", function() end )
	else
		Dialog:simplePopup("Profile Failed to authenticate!", "Try logging in in a few moments", function() end )
	end
end

function _M:serverNews()
	local co = coroutine.create(function()
		local th, l = profile:getNews()
		if not th or not l then return end

		local ret = l:receive(0, "final")
		while not ret do
			coroutine.yield()
			ret = l:receive(0, "final")
		end

		self.news = ret
		local f = loadstring(self.news.text)
		if f then
			local env = {}
			setfenv(f, env)
			pcall(f)
			if env.text and env.version then
				self.news.text = env.text
				print("Latest engine version available: ", env.version[4], env.version[1], env.version[2], env.version[3])
				self.latest_engine_version = env.version
				if env.link then self.news.link = env.link end
			else
				self.news = nil
			end
		end

		if self.news then
			self:updateNews()
		end
	end)
	game:registerCoroutine("getnews", co)
end
