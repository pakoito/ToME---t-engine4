-- ToME - Tales of Maj'Eyal
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
require "engine.GameTurnBased"
require "engine.interface.GameMusic"
require "engine.interface.GameSound"
require "engine.interface.GameTargeting"
local KeyBind = require "engine.KeyBind"
local Savefile = require "engine.Savefile"
local DamageType = require "engine.DamageType"
local Zone = require "engine.Zone"
local Tiles = require "engine.Tiles"
local Map = require "engine.Map"
local Level = require "engine.Level"
local Birther = require "engine.Birther"
local Astar = require "engine.Astar"
local DirectPath = require "engine.DirectPath"
local Shader = require "engine.Shader"

local NicerTiles = require "mod.class.NicerTiles"
local GameState = require "mod.class.GameState"
local Store = require "mod.class.Store"
local Trap = require "mod.class.Trap"
local Grid = require "mod.class.Grid"
local Actor = require "mod.class.Actor"
local Party = require "mod.class.Party"
local Player = require "mod.class.Player"
local NPC = require "mod.class.NPC"

local PlayerDisplay = require "mod.class.PlayerDisplay"

local HotkeysDisplay = require "engine.HotkeysDisplay"
local ActorsSeenDisplay = require "engine.ActorsSeenDisplay"
local LogDisplay = require "engine.LogDisplay"
local LogFlasher = require "engine.LogFlasher"
local DebugConsole = require "engine.DebugConsole"
local FlyingText = require "engine.FlyingText"
local Tooltip = require "engine.Tooltip"
local Calendar = require "engine.Calendar"

local Dialog = require "engine.ui.Dialog"
local MapMenu = require "mod.dialogs.MapMenu"

module(..., package.seeall, class.inherit(engine.GameTurnBased, engine.interface.GameMusic, engine.interface.GameSound, engine.interface.GameTargeting))

-- Difficulty settings
DIFFICULTY_EASY = 1
DIFFICULTY_NORMAL = 2
DIFFICULTY_HARDCORE = 3
DIFFICULTY_NIGHTMARE = 4
DIFFICULTY_INSANE = 5

function _M:init()
	engine.GameTurnBased.init(self, engine.KeyBind.new(), 1000, 100)
	engine.interface.GameMusic.init(self)
	engine.interface.GameSound.init(self)

	-- Pause at birth
	self.paused = true

	-- Same init as when loaded from a savefile
	self:loaded()
end

function _M:run()
	self.flash = LogFlasher.new(0, 0, self.w, 20, nil, nil, nil, {255,255,255}, {0,0,0})
	self.logdisplay = LogDisplay.new(0, self.h * 0.8 + 7, self.w * 0.5 - 30, self.h * 0.2 - 7, nil, nil, nil, {255,255,255}, "/data/gfx/ui/message-log.png")
	self.player_display = PlayerDisplay.new(0, 230, 200, self.h * 0.8 - 230, {30,30,0})
	self.hotkeys_display = HotkeysDisplay.new(nil, self.w * 0.5 + 30, self.h * 0.8 + 7, self.w * 0.5 - 30, self.h * 0.2 - 7, "/data/gfx/ui/talents-list.png")
	self.npcs_display = ActorsSeenDisplay.new(nil, self.w * 0.5 + 30, self.h * 0.8 + 7, self.w * 0.5 - 30, self.h * 0.2 - 7, "/data/gfx/ui/talents-list.png")
	self.calendar = Calendar.new("/data/calendar_allied.lua", "Today is the %s %s of the %s year of the Age of Ascendancy of Maj'Eyal.\nThe time is %02d:%02d.", 122, 167)
	self.tooltip = Tooltip.new(nil, nil, {255,255,255}, {30,30,30,230})
	self.tooltip2 = Tooltip.new(nil, nil, {255,255,255}, {30,30,30,230})
	self.flyers = FlyingText.new()
	self:setFlyingText(self.flyers)
	self.minimap_bg, self.minimap_bg_w, self.minimap_bg_h = core.display.loadImage("/data/gfx/ui/minimap.png"):glTexture()
	self.nicer_tiles = NicerTiles.new()
	self:createSeparators()

	self.log = function(style, ...) if type(style) == "number" then self.logdisplay(...) self.flash(style, ...) else self.logdisplay(style, ...) self.flash(self.flash.NEUTRAL, style, ...) end end
	self.logSeen = function(e, style, ...) if e and self.level.map.seens(e.x, e.y) then self.log(style, ...) end end
	self.logPlayer = function(e, style, ...) if e == self.player or e == self.party then self.log(style, ...) end end

	self.log(self.flash.GOOD, "Welcome to #00FF00#Tales of Maj'Eyal!")

	-- List of stuff to do on tick end
	self.on_tick_end = {}

	-- Setup inputs
	self:setupCommands()
	self:setupMouse()

	-- Starting from here we create a new game
	if not self.player then self:newGame() end

	self.hotkeys_display.actor = self.player
	self.npcs_display.actor = self.player

	self:initTargeting()

	-- Ok everything is good to go, activate the game in the engine!
	self:setCurrent()

	-- Run the current music if any
	self:playMusic()

	-- Start time
	self.real_starttime = os.time()

	if self.level then self:setupDisplayMode() end
end

--- Checks if the current character is "tainted" by cheating
function _M:isTainted()
	if config.settings.cheat then return true end
	return (game.player and game.player.__cheated) and true or false
end

function _M:newGame()
	self.party = Party.new()
	local player = Player.new{name=self.player_name, game_ender=true}
	self.party:addMember(player, {
		control="full",
		type="player",
		title="Main character",
		main=true,
		orders = {follow=true, behavior=true, leash=true},
	})
	self.party:setPlayer(player)
	self:setupDisplayMode()

	-- Create the entity to store various game state things
	self.state = GameState.new{}
	local birth_done = function()
		if self.player.__allow_rod_recall then game.state:allowRodRecall(true) self.player.__allow_rod_recall = nil end

		for i = 1, 50 do
			local o = self.state:generateRandart(true)
			self.zone.object_list[#self.zone.object_list+1] = o
		end

		if config.settings.cheat then self.player.__cheated = true end

		-- Register the character online if possible
		self.player:getUUID()
	end

	-- Load for quick birth
	local save = Savefile.new(self.save_name)
	local quickbirth = save:loadQuickBirth()
	local quickhotkeys = save:loadQuickHotkeys()
	save:close()

	self.always_target = true

	local nb_unlocks, max_unlocks = self:countBirthUnlocks()

	self.creating_player = true
	local birth; birth = Birther.new("Character Creation: "..self.player.name.." ("..nb_unlocks.."/"..max_unlocks.." unlocked birth options)", self.player, {"base", "difficulty", "world", "race", "subrace", "sex", "class", "subclass" }, function()
		self.player:check("make_tile")
		self.player.make_tile = nil

		-- Save for quick birth
		local save = Savefile.new(self.save_name)
		save:saveQuickBirth(self.player.descriptor)
		save:close()

		self.player:check("before_starting_zone")
		self.player.wild_x, self.player.wild_y = self.player.default_wilderness[1], self.player.default_wilderness[2]
		self.player.last_wilderness = self.player.default_wilderness[3] or "wilderness"
		if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end
		self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, nil, self.player.starting_level_force_down)
		print("[PLAYER BIRTH] resolve...")
		self.player:resolve()
		self.player:resolve(nil, true)
		self.player.energy.value = self.energy_to_act
		Map:setViewerFaction(self.player.faction)

		self.paused = true
		print("[PLAYER BIRTH] resolved!")
		local birthend = function()
			self:registerDialog(require("engine.dialogs.ShowText").new("Welcome to ToME", "intro-"..self.player.starting_intro, {name=self.player.name}, nil, nil, function()
				self.player:resetToFull()
				self.player:registerCharacterPlayed()
				self.player:grantQuest(self.player.starting_quest)
				self.player:onBirth(birth)
				-- For quickbirth
				self.party.name = self.player.name
				self.party.__version = game.__mod_info.version
				savefile_pipe:push("", "entity", self.party)
				self.party.__version = nil
				self.creating_player = false

				birth_done()
				self.player:check("on_birth_done")
			end, true))
		end

		if self.player.no_birth_levelup then birthend()
		else self.player:playerLevelup(birthend) end
	end, quickbirth, 720, 500)

	-- Load a full player instead of a simpler quickbirthing, if possible
	birth.quickBirth = function(b)
		birth.quickBirth = nil
		if not birth.do_quickbirth then return end

		-- Ignore savefile tokens, as we load an "older" player
		savefile_pipe:ignoreSaveToken(true)
		local qb = savefile_pipe:doLoad("", "entity", nil, self.save_name)
		savefile_pipe:ignoreSaveToken(false)

		-- If we got the player, use it, otherwise quickbirth as normal
		if qb and qb.__version and qb.__version[1] == game.__mod_info.version[1] and qb.__version[2] == game.__mod_info.version[2] and qb.__version[3] == game.__mod_info.version[3] then
			-- Disable quickbirth
			birth.do_quickbirth = false
			self:unregisterDialog(b)

			-- Load the player directly
			self.party = qb
			self.player = nil
			self.party:setPlayer(1, true)
			Map:setViewerFaction(self.player.faction)
			if self.player.__game_difficulty then self:setupDifficulty(self.player.__game_difficulty) end

			-- Tell the level gen code to add all the party
			self.to_re_add_actors = {}
			for act, _ in pairs(self.party.members) do if self.player ~= act then self.to_re_add_actors[act] = true end end

			self:changeLevel(self.player.starting_level or 1, self.player.starting_zone, nil, self.player.starting_level_force_down)
			self.player:removeQuest(self.player.starting_quest)
			self.player:grantQuest(self.player.starting_quest)
			self.creating_player = false

			-- Add all items so they regen correctly
			self.player:inventoryApplyAll(function(inven, item, o) game:addEntity(o) end)

			birth_done()
			self.player:check("on_birth_done")
			if quickhotkeys then
				self.player.quickhotkeys = quickhotkeys.quickhotkeys
				self.player:sortHotkeys()
			end
		else
			-- Continue as normal
			return Birther.quickBirth(b)
		end
	end
	self:registerDialog(birth)
end

function _M:setupDifficulty(d)
	self.difficulty = d
end

function _M:loaded()
	engine.GameTurnBased.loaded(self)
	engine.interface.GameMusic.loaded(self)
	engine.interface.GameSound.loaded(self)
	Actor.projectile_class = "mod.class.Projectile"
	Zone:setup{
		npc_class="mod.class.NPC", grid_class="mod.class.Grid", object_class="mod.class.Object", trap_class="mod.class.Trap",
		on_setup = function(zone)
			-- Increases zone level for higher difficulties
			if not zone.__applied_difficulty then
				zone.__applied_difficulty = true
				if self.difficulty == self.DIFFICULTY_INSANE then
					zone.base_level_range = table.clone(zone.level_range, true)
					zone.specific_base_level.object = -10 -zone.level_range[1]
					zone.level_range[1] = zone.level_range[1] * 2 + 10
					zone.level_range[2] = zone.level_range[2] * 2 + 10
				end
			end
		end,
	}
	Map:setViewerActor(self.player)
	Map:setViewPort(216, 36, self.w - 216, math.floor(self.h * 0.80) - 36, 32, 32, nil, 22, true)
	if self.player then self.player.changed = true end
	self.key = engine.KeyBind.new()

	if self.always_target then Map:setViewerFaction(self.player.faction) end
	if self.player and config.settings.cheat then self.player.__cheated = true end
end

function _M:setupDisplayMode(reboot)
	local gfx = config.settings.tome.gfx
	self:saveSettings("tome.gfx", ('tome.gfx = {tiles=%q, size=%q}\n'):format(gfx.tiles, gfx.size))

	if reboot then
		self.change_res_dialog = true
		self:saveGame()
		util.showMainMenu(false, nil, nil, self.__mod_info.short_name, self.save_name, false)
	end

	-- Show a count for stacked objects
	Map.object_stack_count = true

	-- Select tiles
	Tiles.prefix = "/data/gfx/"
	if gfx.tiles ~= "mushroom" then
		Tiles.prefix = "/data/gfx/"..gfx.tiles.."/"
	end
	print("[DISPLAY MODE] Tileset: "..gfx.tiles)
	print("[DISPLAY MODE] Size: "..gfx.size)

	local do_bg = true

	if gfx.size == "64x64" then
		Map:setViewPort(216, 36, self.w - 216, math.floor(self.h * 0.80) - 36, 64, 64, nil, 44, do_bg)
		Map:resetTiles()
	elseif gfx.size == "32x32" then
		Map:setViewPort(216, 36, self.w - 216, math.floor(self.h * 0.80) - 36, 32, 32, nil, 22, do_bg)
		Map:resetTiles()
	elseif gfx.size == "16x16" then
		Map:setViewPort(216, 36, self.w - 216, math.floor(self.h * 0.80) - 36, 16, 16, "/data/font/FSEX300.ttf", 16, do_bg)
		Map:resetTiles()
	end

	Map.tiles.use_images = true
	if gfx.tiles == "ascii" then Map.tiles.use_images = false Map.tiles.force_back_color = {r=0, g=0, b=0, a=255} end
	if gfx.tiles == "ascii_full" then Map.tiles.use_images = false end
	if gfx.tiles == "shockbolt" then Map.tiles.nicer_tiles = true end

	if self.level then
		self.level.map:recreate()
		self:initTargeting()
		self.level.map:moveViewSurround(self.player.x, self.player.y, 8, 8)
	end
	self:setupMiniMap()

	-- Create the framebuffer
	self.fbo = core.display.newFBO(Map.viewport.width, Map.viewport.height)
	if self.fbo then
		self.fbo_shader = Shader.new("main_fbo")
		if not self.fbo_shader.shad then self.fbo = nil self.fbo_shader = nil end
	end
	if self.player then self.player:updateMainShader() end
end

function _M:initTargeting()
	engine.interface.GameTargeting.init(self)
end


function _M:setupMiniMap()
	if self.level and self.level.map then self.level.map._map:setupMiniMapGridSize(4) end
end

function _M:save()
	return class.save(self, self:defaultSavedFields{difficulty=true, to_re_add_actors=true, party=true, _chronoworlds=true}, true)
end

function _M:getSaveDescription()
	local player = self.party:findMember{main=true}

	return {
		name = player.name,
		description = ([[%s the level %d %s %s.
Difficulty: %s
Campaign: %s
Exploring level %d of %s.]]):format(
		player.name, player.level, player.descriptor.subrace, player.descriptor.subclass,
		player.descriptor.difficulty,
		player.descriptor.world,
		self.level.level, self.zone.name
		),
	}
end

function _M:getStore(def)
	return Store.stores_def[def]:clone()
end

function _M:leaveLevel(level, lev, old_lev)
	self.to_re_add_actors = self.to_re_add_actors or {}
	if level:hasEntity(self.player) then
		level.exited = level.exited or {}
		if lev > old_lev then
			level.exited.down = {x=self.player.x, y=self.player.y}
		else
			level.exited.up = {x=self.player.x, y=self.player.y}
		end
		level.last_turn = self.turn
		for act, _ in pairs(self.party.members) do
			if self.player ~= act and level:hasEntity(act) then
				level:removeEntity(act)
				self.to_re_add_actors[act] = true
			end
		end
		level:removeEntity(self.player)
	end
end

function _M:changeLevel(lev, zone, keep_old_lev, force_down)
	if not self.player.can_change_level then
		self.logPlayer(self.player, "#LIGHT_RED#You may not change level without your own body!")
		return
	end
	if zone and not self.player.can_change_zone then
		self.logPlayer(self.player, "#LIGHT_RED#You may not leave the zone with this character!")
		return
	end

	if game.player:isTalentActive(game.player.T_JUMPGATE) then
		game.player:forceUseTalent(game.player.T_JUMPGATE, {ignore_energy=true})
	end

	if game.player:isTalentActive(game.player.T_JUMPGATE_TWO) then
		game.player:forceUseTalent(game.player.T_JUMPGATE_TWO, {ignore_energy=true})
	end


	local left_zone = self.zone

	if self.zone and self.zone.on_leave then
		local nl, nz, stop = self.zone.on_leave(lev, old_lev, zone)
		if stop then return end
		if nl then lev = nl end
		if nz then zone = nz end
	end

	if self.zone and self.level then self.player:onLeaveLevel(self.zone, self.level) end

	local old_lev = (self.level and not zone) and self.level.level or -1000
	if keep_old_lev then old_lev = self.level.level end
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
		if type(self.zone.save_per_level) == "nil" then self.zone.save_per_level = config.settings.tome.save_zone_levels and true or false end
	end
	self.zone:getLevel(self, lev, old_lev)

	-- Post process walls
	self.nicer_tiles:postProcessLevelTiles(self.level)

	-- Check if we need to switch the current guardian
	self.state:zoneCheckBackupGuardian()

	-- Decay level ?
	if self.level.last_turn and self.level.data.decay and self.level.last_turn + self.level.data.decay[1] * 10 < self.turn then
		local only = self.level.data.decay.only or nil
		if not only or only.actor then
			local nb_actor, remain_actor = self.level:decay(Map.ACTOR, function(e) return not e.unique and not e.lore and not e.quest and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < self.turn * 10 end)
			if not self.level.data.decay.no_respawn then
				local gen = self.zone:getGenerator("actor", self.level)
				if gen.regenFrom then gen:regenFrom(remain_actor) end
			end
		end

		if not only or only.object then
			local nb_object, remain_object = self.level:decay(Map.OBJECT, function(e) return not e.unique and not e.lore and not e.quest and self.level.last_turn + rng.range(self.level.data.decay[1], self.level.data.decay[2]) < self.turn * 10 end)
			if not self.level.data.decay.no_respawn then
				local gen = self.zone:getGenerator("object", self.level)
				if gen.regenFrom then gen:regenFrom(remain_object) end
			end
		end
	end

	-- Move back to old wilderness position
	if self.zone.wilderness then
		self.player:move(self.player.wild_x, self.player.wild_y, true)
		self.player.last_wilderness = self.zone.short_name
	else
		local x, y
		if lev > old_lev and not force_down then
			x, y = self.level.default_up.x, self.level.default_up.y
		else
			x, y = self.level.default_down.x, self.level.default_down.y
		end
		-- Check if there is already an actor at that location, if so move it
		x = x or 1 y = y or 1
		local blocking_actor = self.level.map(x, y, engine.Map.ACTOR)
		if blocking_actor then
			local newx, newy = util.findFreeGrid(x, y, 20, true, {[Map.ACTOR]=true})
			if newx and newy then blocking_actor:move(newx, newy, true)
			else blocking_actor:teleportRandom(x, y, 200) end
		end
		self.player:move(x, y, true)
	end
	self.player.changed = true
	if self.to_re_add_actors and not self.zone.wilderness then for act, _ in pairs(self.to_re_add_actors) do
		local x, y = util.findFreeGrid(self.player.x, self.player.y, 20, true, {[Map.ACTOR]=true})
		if x then act:move(x, y, true) end
	end end

	-- Re add entities
	self.level:addEntity(self.player)
	if self.to_re_add_actors and not self.zone.wilderness then
		for act, _ in pairs(self.to_re_add_actors) do
			self.level:addEntity(act)
			act:setTarget(nil)
		end
		self.to_re_add_actors = nil
	end

	if self.zone.on_enter then
		self.zone.on_enter(lev, old_lev, zone)
	end

	self.player:onEnterLevel(self.zone, self.level)

	if self.level.data.ambient_music then
		if self.level.data.ambient_music ~= "last" then
			self:playMusic(self.level.data.ambient_music)
		end
	else
		self:stopMusic()
	end

	-- Update the minimap
	self:setupMiniMap()

	-- Tell the map to use path strings to speed up path calculations
	for uid, e in pairs(self.level.entities) do
		if e.getPathString then
			self.level.map:addPathString(e:getPathString())
		end
	end
	self.zone_name_s = nil
	self.level.map:redisplay()

	-- Level feeling
	local feeling
	if self.level.special_feeling then
		feeling = self.level.special_feeling
	else
		local lev = self.zone.base_level + self.level.level - 1
		if self.zone.level_adjust_level then lev = self.zone:level_adjust_level(self.level) end
		local diff = lev - game.player.level
		if diff >= 5 then feeling = "You feel a thrill of terror and your heart begins to pound in your chest. You feel terribly threatened upon entering this area."
		elseif diff >= 2 then feeling = "You feel mildly anxious, and walk with caution."
		elseif diff >= -2 then feeling = nil
		elseif diff >= -5 then feeling = "You feel very confident walking into this place."
		else feeling = "You stride into this area without a second thought, while stifling a yawn. You feel your time might be better spent elsewhere."
		end
	end
	if feeling then game.log("#TEAL#%s", feeling) end

	-- Autosave
	if config.settings.tome.autosave and left_zone and left_zone.short_name ~= "wilderness" and left_zone.short_name ~= self.zone.short_name then self:saveGame() end

	self.player:onEnterLevelEnd(self.zone, self.level)
end

function _M:getPlayer()
	return self.player
end

--- Clones the game world for chronomancy spells
function _M:chronoClone(name)
	local d = Dialog:simplePopup("Chronomancy", "Folding the space time structure...")
	d.__showup = nil
	core.display.forceRedraw()
	game:unregisterDialog(d)

	if name then
		self._chronoworlds = self._chronoworlds or {}
		self._chronoworlds[name] = game:cloneFull()
	else
		return game:cloneFull()
	end
end

--- Restores a chronomancy clone
function _M:chronoRestore(name, remove)
	local ngame
	if type(name) == "string" then
		ngame = self._chronoworlds[name]
		if remove then self._chronoworlds[name] = nil end
	else ngame = name end
	if not ngame then return false end

	local d = Dialog:simplePopup("Chronomancy", "Unfolding the space time structure...")
	d.__showup = nil
	core.display.forceRedraw()
	game:unregisterDialog(d)

	ngame:cloneReloaded()
	_G.game = ngame
	game:run()
	game.key:setCurrent()
	game.mouse:setCurrent()
	return true
end

--- Update the zone name, if needed
function _M:updateZoneName()
	local name
	if self.zone.display_name then
		name = self.zone.display_name()
	else
		local lev = self.level.level
		if self.level.data.reverse_level_display then lev = 1 + self.level.data.max_level - lev end
		name = ("%s (%d)"):format(self.zone.name, lev)
	end
	if self.zone_name_s and self.old_zone_name == name then return end

	self.player_display.font:setStyle("bold")
	local s = core.display.drawStringBlendedNewSurface(self.player_display.font, name, unpack(colors.simple(colors.GOLD)))
	self.player_display.font:setStyle("normal")
	self.zone_name_w, self.zone_name_h = s:getSize()
	self.zone_name_s, self.zone_name_tw, self.zone_name_th = s:glTexture()
	self.old_zone_name = name
	print("Updating zone name", name)
end

function _M:tick()
	if self.level then
		self:targetOnTick()

		engine.GameTurnBased.tick(self)
		-- Fun stuff: this can make the game realtime, although calling it in display() will make it work better
		-- (since display is on a set FPS while tick() ticks as much as possible
		-- engine.GameEnergyBased.tick(self)
	end

	-- Run tick end stuff
	if #self.on_tick_end > 0 then
		for i = 1, #self.on_tick_end do self.on_tick_end[i]() end
		self.on_tick_end = {}
	end

	if savefile_pipe.saving then self.player.changed = true end
	if self.paused and not savefile_pipe.saving then return true end
end

--- Register things to do on tick end
-- This is used for recall spells to let the tick finish before switching levels
function _M:onTickEnd(f)
	self.on_tick_end[#self.on_tick_end+1] = f
end

--- Called every game turns
-- Does nothing, you can override it
function _M:onTurn()
	if self.zone then
		if self.zone.on_turn then self.zone:on_turn() end
	end

	-- The following happens only every 10 game turns (once for every turn of 1 mod speed actors)
	if self.turn % 10 ~= 0 then return end

	-- Day/Night cycle, not worknig properly yet
--[[
	if false then
			local doTint = function (from, to, amount)
				local tint = {r = 0, g = 0, b = 0}
				tint.r = (from.r * (1 - amount) + to.r * amount)
				tint.g = (from.g * (1 - amount) + to.g * amount)
				tint.b = (from.b * (1 - amount) + to.b * amount)
				return tint
			end
			local hour, minute = game.calendar:getTimeOfDay(game.turn)
			hour = hour + (minute / 60)
			local tint = {r = 0.1, g = 0.1, b = 0.1}
			local startTint = {r = 0.1, g = 0.1, b = 0.1}
			local endTint = {r = 0.1, g = 0.1, b = 0.1}
			local lite = game.level.baseLite or 1
			if hour <= 4 then
				tint = {r = 0.1, g = 0.1, b = 0.1}
			elseif hour > 4 and hour <= 7 then
				startTint = { r = 0.1, g = 0.1, b = 0.1 }
				endTint = { r = 0.3, g = 0.3, b = 0.5 }
				tint = doTint(startTint, endTint, (hour - 4) / 3)
				lite = lite + 1
			elseif hour > 7 and hour <= 12 then
				startTint = { r = 0.3, g = 0.3, b = 0.5 }
				endTint = { r = 0.9, g = 0.9, b = 0.9 }
				tint = doTint(startTint, endTint, (hour - 7) / 5)
				lite = lite + 2
			elseif hour > 12 and hour <= 18 then
				startTint = { r = 0.9, g = 0.9, b = 0.9 }
				endTint = { r = 0.9, g = 0.9, b = 0.6 }
				tint = doTint(startTint, endTint, (hour - 12) / 6)
				lite = lite + 4
			elseif hour > 18 and hour < 24 then
				startTint = { r = 0.9, g = 0.9, b = 0.6 }
				endTint = { r = 0.1, g = 0.1, b = 0.1 }
				tint = doTint(startTint, endTint, (hour - 18) / 6)
				lite = lite + 3
			end
			game.level.map:setShown(tint.r+0.5, tint.g+0.5, tint.b+0.5, 1)
			game.level.map:setObscure(tint.r+0.3, tint.g+0.3, tint.b+0.3, 1)
--			game.player.lite = lite
	end
]]

	-- Process overlay effects
	self.level.map:processEffects()

	if not self.day_of_year or self.day_of_year ~= self.calendar:getDayOfYear(self.turn) then
		self.log(self.calendar:getTimeDate(self.turn))
		self.day_of_year = self.calendar:getDayOfYear(self.turn)
	end
end

function _M:display(nb_keyframes)
	-- If switching resolution, blank everything but the dialog
	if self.change_res_dialog then engine.GameTurnBased.display(self, nb_keyframes) return end

	-- Now the map, if any
	if self.level and self.level.map and self.level.map.finished then
		-- Display the map and compute FOV for the player if needed
		if self.level.map.changed then
			self.player:playerFOV()
		end

		-- Display using Framebuffer, so that we can use shaders and all
		if self.fbo then
			self.fbo:use(true)

			if self.level.data.background then self.level.data.background(self.level, 0, 0, nb_keyframes) end
			self.level.map:display(0, 0, nb_keyframes)
			self.target:display(0, 0)
			if self.level.data.foreground then self.level.data.foreground(self.level, 0, 0, nb_keyframes) end
			if self.level.data.weather_particle then self.state:displayWeather(self.level, self.level.data.weather_particle, nb_keyframes) end

			self.fbo:use(false)
			_2DNoise:bind(1, false)
			self.fbo:toScreen(
				self.level.map.display_x, self.level.map.display_y,
				self.level.map.viewport.width, self.level.map.viewport.height,
				self.fbo_shader.shad
			)

		-- Basic display
		else
			if self.level.data.background then self.level.data.background(self.level, self.level.map.display_x, self.level.map.display_y, nb_keyframes) end
			self.level.map:display(nil, nil, nb_keyframes)
			self.target:display()
			if self.level.data.foreground then self.level.data.foreground(self.level, self.level.map.display_x, self.level.map.display_y, nb_keyframes) end
			if self.level.data.weather_particle then self.state:displayWeather(self.level, self.level.data.weather_particle, nb_keyframes) end
		end

		if not self.zone_name_s then self:updateZoneName() end
		self.zone_name_s:toScreenFull(
			self.level.map.display_x + self.level.map.viewport.width - self.zone_name_w - 15,
			self.level.map.display_y + self.level.map.viewport.height - self.zone_name_h - 5,
			self.zone_name_w, self.zone_name_h,
			self.zone_name_tw, self.zone_name_th
		)

		-- Minimap display
		self.minimap_bg:toScreen(0, 35, 200, 200)
		self.level.map:minimapDisplay(0, 35, util.bound(self.player.x - 25, 0, self.level.map.w - 50), util.bound(self.player.y - 25, 0, self.level.map.h - 50), 50, 50, 1)
	end

	-- We display the player's interface
	self.flash:toScreen(nb_keyframe)
	self.logdisplay:toScreen()
	self.player_display:toScreen()
	if self.show_npc_list then
		self.npcs_display:toScreen()
	else
		self.hotkeys_display:toScreen()
	end
	if self.player then self.player.changed = false end

	-- UI
	self:displayUI()

	engine.GameTurnBased.display(self, nb_keyframes)

	-- Tooltip is displayed over all else, even dialogs
	self:targetDisplayTooltip(self.w, self.h)
end

--- Called when a dialog is registered to appear on screen
function _M:onRegisterDialog(d)
	-- Clean up tooltip
	self.tooltip_x, self.tooltip_y = nil, nil
	self.tooltip2_x, self.tooltip2_y = nil, nil
	if self.player then self.player:updateMainShader() end
end
function _M:onUnregisterDialog(d)
	-- Clean up tooltip
	self.tooltip_x, self.tooltip_y = nil, nil
	self.tooltip2_x, self.tooltip2_y = nil, nil
	if self.player then self.player:updateMainShader() end
end

function _M:setupCommands()
	-- Make targeting work
	self.normal_key = self.key
	self:targetSetupKey()

	-- Activate profiler keybinds
	self.key:setupProfiler()

	-- Helper function to not allow some actions on the wilderness map
	local not_wild = function(f) return function() if self.zone and not self.zone.wilderness then f() else self.logPlayer(self.player, "You cannot do that on the world map.") end end end

	-- Debug mode
	self.key:addCommands{
		[{"_a","ctrl"}] = function() if config.settings.cheat then game:registerDialog(require("mod.dialogs.debug.DebugMain").new()) end end,
		[{"_d","ctrl"}] = function() if config.settings.cheat then
			print(game.level.map(game.player.x, game.player.y, Map.TERRAIN).define_as, game.level.map(game.player.x, game.player.y, Map.TERRAIN).image)
			local add = game.level.map(game.player.x, game.player.y, Map.TERRAIN).add_displays
			if add then for i, e in ipairs(add) do print(" -", e.image) end end
		end end,
		[{"_f","ctrl"}] = function() if config.settings.cheat then
			self.nicer_tiles:handle(self.level, game.player.x, game.player.y)
			self.nicer_tiles:replaceAll(self.level)
		end end,
		[{"_g","ctrl"}] = function() if config.settings.cheat then
--			self.nicer_tiles:postProcessLevelTiles(self.level)
			local m = game.zone:makeEntityByName(game.level, "actor", "NPC_COLD_DRAKE")
			game.zone:addEntity(game.level, m, "actor", game.player.x + 1, game.player.y + 1)
		end end,
	}

	self.key:addBinds
	{
		-- Movements
		MOVE_LEFT = function() self.player:moveDir(4) end,
		MOVE_RIGHT = function() self.player:moveDir(6) end,
		MOVE_UP = function() self.player:moveDir(8) end,
		MOVE_DOWN = function() self.player:moveDir(2) end,
		MOVE_LEFT_UP = function() self.player:moveDir(7) end,
		MOVE_LEFT_DOWN = function() self.player:moveDir(1) end,
		MOVE_RIGHT_UP = function() self.player:moveDir(9) end,
		MOVE_RIGHT_DOWN = function() self.player:moveDir(3) end,
		MOVE_STAY = function() if self.player:enoughEnergy() then self.player:useEnergy() end end,

		RUN_LEFT = function() self.player:runInit(4) end,
		RUN_RIGHT = function() self.player:runInit(6) end,
		RUN_UP = function() self.player:runInit(8) end,
		RUN_DOWN = function() self.player:runInit(2) end,
		RUN_LEFT_UP = function() self.player:runInit(7) end,
		RUN_LEFT_DOWN = function() self.player:runInit(1) end,
		RUN_RIGHT_UP = function() self.player:runInit(9) end,
		RUN_RIGHT_DOWN = function() self.player:runInit(3) end,

		-- Hotkeys
		HOTKEY_1 = not_wild(function() self.player:activateHotkey(1) end),
		HOTKEY_2 = not_wild(function() self.player:activateHotkey(2) end),
		HOTKEY_3 = not_wild(function() self.player:activateHotkey(3) end),
		HOTKEY_4 = not_wild(function() self.player:activateHotkey(4) end),
		HOTKEY_5 = not_wild(function() self.player:activateHotkey(5) end),
		HOTKEY_6 = not_wild(function() self.player:activateHotkey(6) end),
		HOTKEY_7 = not_wild(function() self.player:activateHotkey(7) end),
		HOTKEY_8 = not_wild(function() self.player:activateHotkey(8) end),
		HOTKEY_9 = not_wild(function() self.player:activateHotkey(9) end),
		HOTKEY_10 = not_wild(function() self.player:activateHotkey(10) end),
		HOTKEY_11 = not_wild(function() self.player:activateHotkey(11) end),
		HOTKEY_12 = not_wild(function() self.player:activateHotkey(12) end),
		HOTKEY_SECOND_1 = not_wild(function() self.player:activateHotkey(13) end),
		HOTKEY_SECOND_2 = not_wild(function() self.player:activateHotkey(14) end),
		HOTKEY_SECOND_3 = not_wild(function() self.player:activateHotkey(15) end),
		HOTKEY_SECOND_4 = not_wild(function() self.player:activateHotkey(16) end),
		HOTKEY_SECOND_5 = not_wild(function() self.player:activateHotkey(17) end),
		HOTKEY_SECOND_6 = not_wild(function() self.player:activateHotkey(18) end),
		HOTKEY_SECOND_7 = not_wild(function() self.player:activateHotkey(19) end),
		HOTKEY_SECOND_8 = not_wild(function() self.player:activateHotkey(20) end),
		HOTKEY_SECOND_9 = not_wild(function() self.player:activateHotkey(21) end),
		HOTKEY_SECOND_10 = not_wild(function() self.player:activateHotkey(22) end),
		HOTKEY_SECOND_11 = not_wild(function() self.player:activateHotkey(23) end),
		HOTKEY_SECOND_12 = not_wild(function() self.player:activateHotkey(24) end),
		HOTKEY_THIRD_1 = not_wild(function() self.player:activateHotkey(25) end),
		HOTKEY_THIRD_2 = not_wild(function() self.player:activateHotkey(26) end),
		HOTKEY_THIRD_3 = not_wild(function() self.player:activateHotkey(27) end),
		HOTKEY_THIRD_4 = not_wild(function() self.player:activateHotkey(28) end),
		HOTKEY_THIRD_5 = not_wild(function() self.player:activateHotkey(29) end),
		HOTKEY_THIRD_6 = not_wild(function() self.player:activateHotkey(30) end),
		HOTKEY_THIRD_7 = not_wild(function() self.player:activateHotkey(31) end),
		HOTKEY_THIRD_8 = not_wild(function() self.player:activateHotkey(32) end),
		HOTKEY_THIRD_9 = not_wild(function() self.player:activateHotkey(33) end),
		HOTKEY_THIRD_10 = not_wild(function() self.player:activateHotkey(34) end),
		HOTKEY_THIRD_11 = not_wild(function() self.player:activateHotkey(35) end),
		HOTKEY_THIRD_12 = not_wild(function() self.player:activateHotkey(36) end),
		HOTKEY_PREV_PAGE = not_wild(function() self.player:prevHotkeyPage() self.log("Hotkey page %d is now displayed.", self.player.hotkey_page) end),
		HOTKEY_NEXT_PAGE = not_wild(function() self.player:nextHotkeyPage() self.log("Hotkey page %d is now displayed.", self.player.hotkey_page) end),
--		HOTKEY_HOTPAGE2 = function(sym, ctrl, shift, alt, meta, unicode, isup) self.player:setHotkeyPage(isup and 1 or 2) end,
--		HOTKEY_HOTPAGE3 = function(sym, ctrl, shift, alt, meta, unicode, isup) self.player:setHotkeyPage(isup and 1 or 3) end,

		-- Party commands
		SWITCH_PARTY_1 = not_wild(function() self.party:select(1) end),
		SWITCH_PARTY_2 = not_wild(function() self.party:select(2) end),
		SWITCH_PARTY_3 = not_wild(function() self.party:select(3) end),
		SWITCH_PARTY_4 = not_wild(function() self.party:select(4) end),
		SWITCH_PARTY_5 = not_wild(function() self.party:select(5) end),
		SWITCH_PARTY_6 = not_wild(function() self.party:select(6) end),
		SWITCH_PARTY_7 = not_wild(function() self.party:select(7) end),
		SWITCH_PARTY_8 = not_wild(function() self.party:select(8) end),
		SWITCH_PARTY = not_wild(function() self:registerDialog(require("mod.dialogs.PartySelect").new()) end),
		ORDER_PARTY_1 = not_wild(function() self.party:giveOrders(1) end),
		ORDER_PARTY_2 = not_wild(function() self.party:giveOrders(2) end),
		ORDER_PARTY_3 = not_wild(function() self.party:giveOrders(3) end),
		ORDER_PARTY_4 = not_wild(function() self.party:giveOrders(4) end),
		ORDER_PARTY_5 = not_wild(function() self.party:giveOrders(5) end),
		ORDER_PARTY_6 = not_wild(function() self.party:giveOrders(6) end),
		ORDER_PARTY_7 = not_wild(function() self.party:giveOrders(7) end),
		ORDER_PARTY_8 = not_wild(function() self.party:giveOrders(8) end),

		-- Actions
		CHANGE_LEVEL = function()
			local e = self.level.map(self.player.x, self.player.y, Map.TERRAIN)
			if self.player:enoughEnergy() and e.change_level then
				if self.player:attr("never_move") then self.log("You cannot currently leave the level.") return end

				local stop = {}
				for eff_id, p in pairs(self.player.tmp) do
					local e = self.player.tempeffect_def[eff_id]
					if e.status == "detrimental" then stop[#stop+1] = e.desc end
				end

				if e.change_zone and #stop > 0 and e.change_zone:find("^wilderness") then
					self.log("You cannot go into the wilds with the following effects: %s", table.concat(stop, ", "))
				else
					-- Do not unpause, the player is allowed first move on next level
					if e.change_level_check and e:change_level_check(game.player) then return end
					self:changeLevel(e.change_zone and e.change_level or self.level.level + e.change_level, e.change_zone, e.keep_old_lev, e.force_down)
				end
			else
				self.log("There is no way out of this level here.")
			end
		end,

		REST = function()
			self.player:restInit()
		end,

		PICKUP_FLOOR = not_wild(function()
			self.player:playerPickup()
		end),
		DROP_FLOOR = function()
			self.player:playerDrop()
		end,
		SHOW_INVENTORY = function()
			local d
			local titleupdator = self.player:getEncumberTitleUpdator("Inventory")
			d = self.player:showEquipInven(titleupdator(), nil, function(o, inven, item, button, event)
				if not o then return end
				local ud = require("mod.dialogs.UseItemDialog").new(event == "button", self.player, o, item, inven, function(_, _, _, stop)
					d.title = titleupdator()
					d:generate()
					d:generateList()
					if stop then self:unregisterDialog(d) end
				end)
				self:registerDialog(ud)
			end)
		end,
		SHOW_EQUIPMENT = "SHOW_INVENTORY",
		WEAR_ITEM = function()
			self.player:playerWear()
		end,
		TAKEOFF_ITEM = function()
			self.player:playerTakeoff()
		end,
		USE_ITEM = not_wild(function()
			self.player:playerUseItem()
		end),

		QUICK_SWITCH_WEAPON = function()
			self.player:quickSwitchWeapons()
		end,

		USE_TALENTS = not_wild(function()
			self:registerDialog(require("mod.dialogs.UseTalents").new(self.player))
		end),

		LEVELUP = function()
			self.player:playerLevelup()
		end,

		SAVE_GAME = function()
			self:saveGame()
		end,

		SHOW_QUESTS = function()
			self:registerDialog(require("engine.dialogs.ShowQuests").new(self.party:findMember{main=true}))
		end,

		SHOW_CHARACTER_SHEET = function()
			self:registerDialog(require("mod.dialogs.CharacterSheet").new(self.party:findMember{main=true}))
		end,

		-- Show time
		SHOW_TIME = function()
			self.log(self.calendar:getTimeDate(self.turn))
		end,
		-- Exit the game
		QUIT_GAME = function()
			self:onQuit()
		end,
		-- Lua console
		LUA_CONSOLE = function()
			if config.settings.cheat then
				self:registerDialog(DebugConsole.new())
			end
		end,

		-- Toggle monster list
		TOGGLE_NPC_LIST = function()
			self.show_npc_list = not self.show_npc_list
			self.player.changed = true
		end,

		HELP = "EXIT",
		EXIT = function()
			local menu menu = require("engine.dialogs.GameMenu").new{
				"resume",
				"achievements",
				{ "Show known Lore", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.ShowLore").new("Tales of Maj'Eyal Lore", self.player)) end },
				{ "Inventory", function() game:unregisterDialog(menu) self.key:triggerVirtual("SHOW_INVENTORY") end },
				{ "Character Sheet", function() game:unregisterDialog(menu) self.key:triggerVirtual("SHOW_CHARACTER_SHEET") end },
				"keybinds",
				{"Graphic Mode", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.GraphicMode").new()) end},
				{"Game Options", function() game:unregisterDialog(menu) game:registerDialog(require("mod.dialogs.GameOptions").new()) end},
				"video",
				"sound",
				"save",
				"quit"
			}
			self:registerDialog(menu)
		end,

		TACTICAL_DISPLAY = function()
			if Map.view_faction then
				self.always_target = nil
				Map:setViewerFaction(nil)
			else
				self.always_target = true
				Map:setViewerFaction(self.player.faction)
			end
		end,

		LOOK_AROUND = function()
			self.flash:empty(true)
			self.flash(self.flash.GOOD, "Looking around... (direction keys to select interesting things, shift+direction keys to move freely)")
			local co = coroutine.create(function() self.player:getTarget{type="hit", no_restrict=true, range=2000} end)
			local ok, err = coroutine.resume(co)
			if not ok and err then print(debug.traceback(co)) error(err) end
		end,
	}

	self.key:setCurrent()
end

function _M:setupMouse(reset)
	if reset then self.mouse:reset() end
	self.mouse:registerZone(Map.display_x, Map.display_y, Map.viewport.width, Map.viewport.height, function(button, mx, my, xrel, yrel, bx, by, event)
		-- Handle targeting
		if self:targetMouse(button, mx, my, xrel, yrel, event) then return end

		-- Handle Use menu
		if button == "right" and not xrel and not yrel and event == "button" then self:mouseRightClick(mx, my) return end

		-- Default left button action
		if button == "left" and not xrel and not yrel and event == "button" and self.zone and not self.zone.wilderness then if self:mouseLeftClick(mx, my) then return end end

		-- Handle the mouse movement/scrolling
		self.player:mouseHandleDefault(self.key, self.key == self.normal_key, button, mx, my, xrel, yrel, event)
	end)
	-- Scroll message log
	self.mouse:registerZone(self.logdisplay.display_x, self.logdisplay.display_y, self.w, self.h, function(button)
		if button == "wheelup" then self.logdisplay:scrollUp(1) end
		if button == "wheeldown" then self.logdisplay:scrollUp(-1) end
	end, {button=true})
	-- Use hotkeys with mouse
	self.mouse:registerZone(self.hotkeys_display.display_x, self.hotkeys_display.display_y, self.w, self.h, function(button, mx, my, xrel, yrel, bx, by, event)
		if event == "button" and button == "left" and self.zone and self.zone.wilderness then return end
		self.hotkeys_display:onMouse(button, mx, my, event == "button", function(text) self.tooltip:displayAtMap(nil, nil, self.w, self.h, text) end)
	end)
	-- Use icons
	self.mouse:registerZone(self.icons.display_x, self.icons.display_y, self.icons.w, self.icons.h, function(button, mx, my, xrel, yrel, bx, by)
		self:mouseIcon(bx, by)
		if button == "left" then self:clickIcon(bx, by) end
	end)
	-- Tooltip over the player pane
	self.mouse:registerZone(self.player_display.display_x, self.player_display.display_y, self.player_display.w, self.player_display.h, function(button, mx, my, xrel, yrel, bx, by, event)
		self.player_display.mouse:delegate(button, mx, my, xrel, yrel, bx, by, event)
	end)
	-- Move using the minimap
	self.mouse:registerZone(0, 35, 200, 200, function(button, mx, my, xrel, yrel, bx, by, event)
		if button == "left" and not xrel and not yrel and event == "button" then
			local tmx, tmy = math.floor(bx / 4), math.floor(by / 4)
			self.player:mouseMove(tmx, tmy)
		end
	end)
	if not reset then self.mouse:setCurrent() end
end

--- Left mouse click on the map
function _M:mouseLeftClick(mx, my)
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	local p = self.player
	local a = game.level.map(tmx, tmy, Map.ACTOR)
	if not a then return end
	if not p.auto_shoot_talent then return end
	local t = p:getTalentFromId(p.auto_shoot_talent)
	if not t then return end

	local target_dist = math.floor(core.fov.distance(p.x, p.y, a.x, a.y))

	if p:enoughEnergy() and p:reactionToward(a) < 0 and not p:isTalentCoolingDown(t) and p:preUseTalent(t, true, true) and target_dist <= p:getTalentRange(t) and p:canProject({type="hit"}, a.x, a.y) then
		p:useTalent(t.id, nil, nil, nil, a)
		return true
	end
end

--- Right mouse click on the map
function _M:mouseRightClick(mx, my)
	local tmx, tmy = self.level.map:getMouseTile(mx, my)
	self:registerDialog(MapMenu.new(mx, my, tmx, tmy))
end

--- Ask if we really want to close, if so, save the game first
function _M:onQuit()
	self.player:runStop("quitting")
	self.player:restStop("quitting")

	if not self.quit_dialog and not self.player.dead and not self:hasDialogUp() then
		self.quit_dialog = Dialog:yesnoPopup("Save and exit?", "Save and exit?", function(ok)
			if ok then
				local d = engine.ui.Dialog:simplePopup("Quitting...", "Quitting...", nil, true)
				d.__show_popup = false
				core.display.forceRedraw()

				-- savefile_pipe is created as a global by the engine
				self:saveGame()
				util.showMainMenu()
			end
			self.quit_dialog = nil
		end)
	end
end

--- Called when we leave the module
function _M:onDealloc()
	local time = os.time() - self.real_starttime
	print("Played ToME for "..time.." seconds")
end

--- When a save is being made, stop running/resting
function _M:onSavefilePush()
	self.player:runStop("saving")
	self.player:restStop("saving")
end

--- Requests the game to save
function _M:saveGame()
	-- savefile_pipe is created as a global by the engine
	savefile_pipe:push(self.save_name, "game", self)
	world:saveWorld()
	if not self.creating_player then game.player:saveUUID() end
	self.log("Saving game...")
end

function _M:setAllowedBuild(what, notify)
	-- Do not unlock things in easy mode
	--if self.difficulty == self.DIFFICULTY_EASY then return end

	profile.mod.allow_build = profile.mod.allow_build or {}
	if profile.mod.allow_build[what] then return end
	profile.mod.allow_build[what] = true

	profile:saveModuleProfile("allow_build", profile.mod.allow_build)

	if notify then
		self.state:checkDonation() -- They gained someting nice, they could be more receptive
		self:registerDialog(require("mod.dialogs.UnlockDialog").new(what))
	end

	return true
end

function _M:playSoundNear(who, ...)
	if who and self.level.map.seens(who.x, who.y) then
		self:playSound(...)
	end
end

--- Create a random lore object and place it
function _M:placeRandomLoreObject(define)
	if type(define) == "table" then define = rng.table(define) end
	local o = self.zone:makeEntityByName(self.level, "object", define)
	if not o then return end

	local x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
	local tries = 0
	while (self.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") or self.level.map(x, y, Map.OBJECT) or self.level.map.room_map[x][y].special) and tries < 100 do
		x, y = rng.range(0, self.level.map.w-1), rng.range(0, self.level.map.h-1)
		tries = tries + 1
	end
	if tries < 100 then
		self.zone:addEntity(self.level, o, "object", x, y)
		print("Placed lore", o.name, x, y)
		o:identify(true)
	end
end

--- Returns the current number of birth unlocks and the max
function _M:countBirthUnlocks()
	local nb = 0
	local max = 0
	local list = {
		campaign_infinite_dungeon = true,
		campaign_arena = true,

		undead_ghoul = true,
		undead_skeleton = true,
		yeek = true,

		mage = true,
		mage_tempest = true,
		mage_geomancer = true,
		mage_pyromancer = true,
		mage_cryomancer = true,

		divine_anorithil = true,
		divine_sun_paladin = true,

		wilder_wyrmic = true,
		wilder_summoner = true,

		corrupter_reaver = true,
		corrupter_corruptor = true,

		afflicted_cursed = true,
		afflicted_doomed = true,

		chronomancer_temporal_warden = true,

		psionic_mindslayer = true,
	}

	for name, _ in pairs(list) do
		max = max + 1
		if profile.mod.allow_build[name] then nb = nb + 1 end
	end
	return nb, max
end

--------------------------------------------------------------
-- UI stuff
--------------------------------------------------------------

local _sep_horiz = {core.display.loadImage("/data/gfx/ui/separator-hori.png")} _sep_horiz.tex = {_sep_horiz[1]:glTexture()}
local _sep_vert = {core.display.loadImage("/data/gfx/ui/separator-vert.png")} _sep_vert.tex = {_sep_vert[1]:glTexture()}
local _sep_top = {core.display.loadImage("/data/gfx/ui/separator-top.png")} _sep_top.tex = {_sep_top[1]:glTexture()}
local _sep_bottom = {core.display.loadImage("/data/gfx/ui/separator-bottom.png")} _sep_bottom.tex = {_sep_bottom[1]:glTexture()}
local _sep_bottoml = {core.display.loadImage("/data/gfx/ui/separator-bottom_line_end.png")} _sep_bottoml.tex = {_sep_bottoml[1]:glTexture()}
local _sep_leftl = {core.display.loadImage("/data/gfx/ui/separator-left_line_end.png")} _sep_leftl.tex = {_sep_leftl[1]:glTexture()}
local _sep_rightl = {core.display.loadImage("/data/gfx/ui/separator-right_line_end.png")} _sep_rightl.tex = {_sep_rightl[1]:glTexture()}

local _talents_icon, _talents_icon_w, _talents_icon_h = core.display.loadImage("/data/gfx/ui/talents-icon.png"):glTexture()
local _actors_icon, _actors_icon_w, _actors_icon_h = core.display.loadImage("/data/gfx/ui/actors-icon.png"):glTexture()
local _main_menu_icon, _main_menu_icon_w, _main_menu_icon_h = core.display.loadImage("/data/gfx/ui/main-menu-icon.png"):glTexture()
local _inventory_icon, _inventory_icon_w, _inventory_icon_h = core.display.loadImage("/data/gfx/ui/inventory-icon.png"):glTexture()
local _charsheet_icon, _charsheet_icon_w, _charsheet_icon_h = core.display.loadImage("/data/gfx/ui/charsheet-icon.png"):glTexture()
local _sel_icon, _sel_icon_w, _sel_icon_h = core.display.loadImage("/data/gfx/ui/icon-select.png"):glTexture()

function _M:displayUI()
	local middle = self.w * 0.5
	local bottom = self.h * 0.8
	local bottom_h = self.h * 0.2
	local icon_x = middle - (_talents_icon_w) / 2
	local icon_x2 = middle + (_talents_icon_w) / 2
	local mid_min = icon_x - (_sep_vert[2])
	local mid_max = icon_x2

	-- Icons
	local x, y = icon_x, bottom + _sep_horiz[3] / 2
	_talents_icon:toScreenFull(x, y, _talents_icon_w, _talents_icon_h, _talents_icon_w, _talents_icon_h)
	if not self.show_npc_list then _sel_icon:toScreenFull(x, y, _sel_icon_w, _sel_icon_h, _sel_icon_w, _sel_icon_h) end
	y = y + _talents_icon_h
	_actors_icon:toScreenFull(x, y, _actors_icon_w, _actors_icon_h, _actors_icon_w, _actors_icon_h)
	if self.show_npc_list then _sel_icon:toScreenFull(x, y, _sel_icon_w, _sel_icon_h, _sel_icon_w, _sel_icon_h) end
	y = y + _talents_icon_h
	_inventory_icon:toScreenFull(x, y, _inventory_icon_w, _inventory_icon_h, _inventory_icon_w, _inventory_icon_h) y = y + _inventory_icon_h
	_charsheet_icon:toScreenFull(x, y, _charsheet_icon_w, _charsheet_icon_h, _charsheet_icon_w, _charsheet_icon_h) y = y + _charsheet_icon_h
	_main_menu_icon:toScreenFull(x, y, _main_menu_icon_w, _main_menu_icon_h, _main_menu_icon_w, _main_menu_icon_h) y = y + _main_menu_icon_h

	-- Separators
	_sep_horiz.tex[1]:toScreenFull(0, 20, self.w, _sep_horiz[3], _sep_horiz.tex[2], _sep_horiz.tex[3])
	_sep_horiz.tex[1]:toScreenFull(0, bottom - _sep_horiz[3] / 2, self.w, _sep_horiz[3], _sep_horiz.tex[2], _sep_horiz.tex[3])

	_sep_vert.tex[1]:toScreenFull(mid_min, bottom, _sep_vert[2], bottom_h, _sep_vert.tex[2], _sep_vert.tex[3])
	_sep_vert.tex[1]:toScreenFull(mid_max, bottom, _sep_vert[2], bottom_h, _sep_vert.tex[2], _sep_vert.tex[3])

	_sep_vert.tex[1]:toScreenFull(200, 20, _sep_vert[2], bottom - 20, _sep_vert.tex[2], _sep_vert.tex[3])

	-- Ornaments
	_sep_top.tex[1]:toScreenFull(mid_min - (-_sep_vert[2] + _sep_top[2]) / 2, bottom - 14, _sep_top[2], _sep_top[3], _sep_top.tex[2], _sep_top.tex[3])
	_sep_top.tex[1]:toScreenFull(mid_max - (-_sep_vert[2] + _sep_top[2]) / 2, bottom - 14, _sep_top[2], _sep_top[3], _sep_top.tex[2], _sep_top.tex[3])
	_sep_bottoml.tex[1]:toScreenFull(mid_min - (-_sep_vert[2] + _sep_bottoml[2]) / 2, self.h - _sep_bottoml[3], _sep_bottoml[2], _sep_bottoml[3], _sep_bottoml.tex[2], _sep_bottoml.tex[3])
	_sep_bottoml.tex[1]:toScreenFull(mid_max - (-_sep_vert[2] + _sep_bottoml[2]) / 2, self.h - _sep_bottoml[3], _sep_bottoml[2], _sep_bottoml[3], _sep_bottoml.tex[2], _sep_bottoml.tex[3])

	_sep_leftl.tex[1]:toScreenFull(0, 20 - _sep_leftl[3] / 2 + 7, _sep_leftl[2], _sep_leftl[3], _sep_leftl.tex[2], _sep_leftl.tex[3])
	_sep_leftl.tex[1]:toScreenFull(0, bottom - _sep_leftl[3] / 2, _sep_leftl[2], _sep_leftl[3], _sep_leftl.tex[2], _sep_leftl.tex[3])

	_sep_rightl.tex[1]:toScreenFull(self.w - _sep_rightl[2], 20 - _sep_rightl[3] / 2 + 7, _sep_rightl[2], _sep_rightl[3], _sep_rightl.tex[2], _sep_rightl.tex[3])
	_sep_rightl.tex[1]:toScreenFull(self.w - _sep_rightl[2], bottom - _sep_rightl[3] / 2, _sep_rightl[2], _sep_rightl[3], _sep_rightl.tex[2], _sep_rightl.tex[3])

	_sep_top.tex[1]:toScreenFull(200 - (_sep_top[2] - _sep_vert[2]) / 2, 20 - 7, _sep_top[2], _sep_top[3], _sep_top.tex[2], _sep_top.tex[3])
	_sep_bottom.tex[1]:toScreenFull(200 - (_sep_bottom[2] - _sep_vert[2]) / 2, bottom - 25, _sep_bottom[2], _sep_bottom[3], _sep_bottom.tex[2], _sep_bottom.tex[3])

end

function _M:createSeparators()
	local middle = self.w * 0.5
	local bottom = self.h * 0.8
	local bottom_h = self.h * 0.2
	self.icons = {
		display_x = middle - (_talents_icon_w) / 2,
		display_y = bottom + _sep_horiz[3] / 2,
		w = _talents_icon_w,
		h = 5*_talents_icon_h
	}
end

function _M:clickIcon(bx, by)
	if by < _talents_icon_h then
		self.show_npc_list = false
		self.player.changed = true
	elseif by < 2*_talents_icon_h then
		self.show_npc_list = true
		self.player.changed = true
	elseif by < 3*_talents_icon_h then
		self.key:triggerVirtual("SHOW_INVENTORY")
	elseif by < 4*_talents_icon_h then
		self.key:triggerVirtual("SHOW_CHARACTER_SHEET")
	elseif by < 5*_talents_icon_h then
		self.key:triggerVirtual("EXIT")
	end
end

function _M:mouseIcon(bx, by)
	if by < _talents_icon_h then
		self.tooltip:displayAtMap(nil, nil, self.w, self.h, "Display talents")
	elseif by < 2*_talents_icon_h then
		self.tooltip:displayAtMap(nil, nil, self.w, self.h, "Display creatures")
	elseif by < 3*_talents_icon_h then
		self.tooltip:displayAtMap(nil, nil, self.w, self.h, "Inventory")
	elseif by < 4*_talents_icon_h then
		self.tooltip:displayAtMap(nil, nil, self.w, self.h, "Character Sheet")
	elseif by < 5*_talents_icon_h then
		self.tooltip:displayAtMap(nil, nil, self.w, self.h, "Main menu")
	end
end
