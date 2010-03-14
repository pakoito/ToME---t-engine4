require "engine.class"

--- Handles music in the game
module(..., package.seeall, class.make)

--- Initializes running
-- We check the direction sides to know if we are in a tunnel, along a wall or in open space.
function _M:init()
	self.current_music = nil
	self.loaded_musics = {}
end

function _M:loaded()
	self.loaded_musics = self.loaded_musics or {}
end

function _M:playMusic(name)
	name = name or self.current_music
	local m = self.loaded_musics[name]
	if not m then
		self.loaded_musics[name] = core.sound.newMusic("/data/music/"..name)
		m = self.loaded_musics[name]
	end
	if not m then return end
	if self.current_music then
		self:stopMusic()
	end
	m:play()
	self.current_music = name
end

function _M:stopMusic()
	if not self.loaded_musics[self.current_music] then return end
	self.loaded_musics[self.current_music]:stop()
end
