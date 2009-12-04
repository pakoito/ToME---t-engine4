require "engine.class"
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorTemporaryEffects"
require "engine.interface.ActorLife"
require "engine.interface.ActorLevel"
require "engine.interface.ActorStats"
require "engine.interface.ActorTalents"
require "engine.interface.ActorResource"
require "engine.interface.BloodyDeath"
require "mod.class.interface.Combat"

module(..., package.seeall, class.inherit(
	-- a ToME actor is a complex beast it uses may inetrfaces
	engine.Actor,
	engine.interface.ActorTemporaryEffects,
	engine.interface.ActorLife,
	engine.interface.ActorLevel,
	engine.interface.ActorStats,
	engine.interface.ActorTalents,
	engine.interface.ActorResource,
	engine.interface.BloodyDeath,
	mod.class.interface.Combat
))

function _M:init(t)
	engine.Actor.init(self, t)
	engine.interface.ActorTemporaryEffects.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorLevel.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorTalents.init(self, t)
	engine.interface.ActorResource.init(self, t)

	self.unused_stats = self.unused_stats or 0
	self.unused_talents =  self.unused_talents or 0
	self.unused_talents_types = self.unused_talents_types or 0
end

function _M:act()
	-- Cooldown talents
	self:cooldownTalents()
	-- Regen resources
	self:regenLife()
	self:regenResources()
end

function _M:move(x, y, force)
	local moved = false
	if force or self:enoughEnergy() then
		moved = engine.Actor.move(self, game.level.map, x, y, force)
		if not force and moved then self:useEnergy() end
	end
	return moved
end

function _M:tooltip()
	return ("%s\n#00ffff#Level: %d\nExp: %d/%d\n#ff0000#HP: %d"):format(self.name, self.level, self.exp, self:getExpChart(self.level+1) or "---", self.life)
end

function _M:die(src)
	-- Gives the killer some exp for the kill
	if src then
		src:gainExp(self:worthExp())
	end
	-- Do we get a blooooooody death ?
	if rng.percent(33) then self:bloodyDeath() end
	return true
end

function _M:levelup()
	self.unused_stats = self.unused_stats + 3
	self.unused_talents = self.unused_talents + 1
	if self.level % 5 == 0 then
		self.unused_talents_types = self.unused_talents_types + 1
	end

	-- Gain life and resources
	self.max_life = self.max_life + 10
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_I) and 1 or 0)
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_II) and 1 or 0)
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_III) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_I) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_II) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_III) and 1 or 0)

	self:incMaxMana(10)
	self:incMaxStamina(10)
	-- Healp up on new level
	self.life = self.max_life
	self.mana = self.max_mana
	self.stamina = self.max_stamina

	-- Auto levelup ?
	if self.autolevel then
		engine.Autolevel:autoLevel(self)
	end
end

--- Notifies a change of stat value
function _M:onStatChange(stat, v)
	if stat == self.STAT_CON then
		self.max_life = self.max_life + 5 * v
	elseif stat == self.STAT_WIL then
		self:incMaxMana(5 * v)
		self:incMaxStamina(5 * v)
	end
end

function _M:attack(target)
	self:bumpInto(target)
end

--- Tries to get a target from the user
function _M:getTarget()
	return self.target.x, self.target.y
end

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab)
	if not self:enoughEnergy() then return end
	if ab.mana and self:getMana() < ab.mana then
		game.logPlayer(self, "You do not have enough mana to cast %s.", ab.name)
		return
	end
	if ab.stamina and self:getStamina() < ab.stamina then
		game.logPlayer(self, "You do not have enough stamina to use %s.", ab.name)
		return
	end

	if ab.message then
		game.logSeen(self, "%s", self:useTalentMessage(ab))
	elseif ab.type[1]:find("^spell/") then
		game.logSeen(self, "%s casts %s.", self.name:capitalize(), ab.name)
	else
		game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
	end
	return true
end

--- Called before a talent is used
-- Check if it must use a turn, mana, stamina, ...
-- @param ab the talent (not the id, the table)
-- @param ret the return of the talent action
-- @return true to continue, false to stop
function _M:postUseTalent(ab, ret)
	if ret == nil then return end
	self:useEnergy()

	if ab.mana then
		self:incMana(-ab.mana)
	end
	if ab.stamina then
		self:incStamina(-ab.stamina)
	end

	return true
end
