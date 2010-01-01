require "engine.class"
require "engine.Actor"
require "engine.Autolevel"
require "engine.interface.ActorInventory"
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
	engine.interface.ActorInventory,
	engine.interface.ActorTemporaryEffects,
	engine.interface.ActorLife,
	engine.interface.ActorLevel,
	engine.interface.ActorStats,
	engine.interface.ActorTalents,
	engine.interface.ActorResource,
	engine.interface.BloodyDeath,
	mod.class.interface.Combat
))

function _M:init(t, no_default)
	-- Define some basic combat stats
	self.combat_def = 0
	self.combat_armor = 0
	self.combat_atk = 0
	self.combat_apr = 0
	self.combat_dam = 0
	self.combat_physcrit = 0
	self.combat_physspeed = 0
	self.combat_spellspeed = 0
	self.combat_spellcrit = 0
	self.combat_spellpower = 0

	self.combat_physresist = 0
	self.combat_spellresist = 0

	self.fatigue = 0

	self.unused_stats = self.unused_stats or 0
	self.unused_talents =  self.unused_talents or 0
	self.unused_talents_types = self.unused_talents_types or 0

	t.life_rating = t.life_rating or 10
	t.mana_rating = t.mana_rating or 10
	t.stamina_rating = t.stamina_rating or 10

	-- Resistances
	t.resists = t.resists or {}

	-- Default regen
	t.mana_regen = t.mana_regen or 0.5
	t.stamina_regen = t.stamina_renge or 0.5
	t.life_regen = t.life_regen or 0.1

	-- Default melee barehanded damage
	self.combat = { dam=1, atk=1, apr=0, dammod={str=1} }

	engine.Actor.init(self, t, no_default)
	engine.interface.ActorInventory.init(self, t)
	engine.interface.ActorTemporaryEffects.init(self, t)
	engine.interface.ActorLife.init(self, t)
	engine.interface.ActorStats.init(self, t)
	engine.interface.ActorTalents.init(self, t)
	engine.interface.ActorResource.init(self, t)
	engine.interface.ActorLevel.init(self, t)
end

function _M:act()
	if not engine.Actor.act(self) then return end

	-- Cooldown talents
	self:cooldownTalents()
	-- Regen resources
	self:regenLife()
	self:regenResources()
	-- Compute timed effects
	self:timedEffects()

	-- Still enough energy to act ?
	if self.energy.value < game.energy_to_act then return false end

	return true
end

function _M:move(x, y, force)
	local moved = false
	if force or self:enoughEnergy() then
		-- Should we prob travel through walls ?
		if not force and self:attr("prob_travel") and game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) then
			moved = self:probabilityTravel(x, y)
		else
			moved = engine.Actor.move(self, x, y, force)
		end
		if not force and moved and not self.did_energy then self:useEnergy() end
	end
	self.did_energy = nil
	return moved
end

function _M:probabilityTravel(x, y)
	local dirx, diry = x - self.x, y - self.y
	local tx, ty = x, y
	while game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move", self) do
		tx = tx + dirx
		ty = ty + diry
	end
	if game.level.map:isBound(x, y) then
		return engine.Actor.move(self, tx, ty, false)
	end
	return true
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

	-- Drop stuff
	for inven_id, inven in pairs(self.inven) do
		for i, o in ipairs(inven) do
			if not o.no_drop then
				game.level.map:addObject(self.x, self.y, o)
			end
		end
	end
	self.inven = {}

	return true
end

function _M:levelup()
	self.unused_stats = self.unused_stats + 3
	self.unused_talents = self.unused_talents + 1
	if self.level % 5 == 0 then
		self.unused_talents_types = self.unused_talents_types + 1
	end

	-- Gain life and resources
	local rating = self.life_rating
	if not self.fixed_rating then
		rating = rng.range(math.floor(self.life_rating * 0.5), math.floor(self.life_rating * 1.5))
	end
	self.max_life = self.max_life + rating
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_I) and 1 or 0)
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_II) and 1 or 0)
		+ (self:knowTalent(self.T_IMPROVED_HEALTH_III) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_I) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_II) and 1 or 0)
		- (self:knowTalent(self.T_DECREASED_HEALTH_III) and 1 or 0)

	self:incMaxMana(self.mana_rating)
	self:incMaxStamina(self.stamina_rating)
	-- Healp up on new level
	self.life = self.max_life
	self.mana = self.max_mana
	self.stamina = self.max_stamina

	-- Auto levelup ?
	if self.autolevel then
		engine.Autolevel:autoLevel(self)
	end
end

function _M:updateBonus()
	engine.Actor.updateBonus(self)
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

--- Called before a talent is used
-- Check the actor can cast it
-- @param ab the talent (not the id, the table)
-- @return true to continue, false to stop
function _M:preUseTalent(ab, silent)
	if not self:enoughEnergy() then print("fail energy") return false end

	if ab.mode == "sustained" then
		if ab.sustain_mana and self.max_mana < ab.sustain_mana then
			game.logPlayer(self, "You do not have enough mana to cast %s.", ab.name)
			return false
		end
		if ab.sustain_stamina and self.max_stamina < ab.sustain_stamina then
			game.logPlayer(self, "You do not have enough stamina to use %s.", ab.name)
			return false
		end
	else
		if ab.mana and self:getMana() < ab.mana * (100 + self.fatigue) / 100 then
			game.logPlayer(self, "You do not have enough mana to cast %s.", ab.name)
			return false
		end
		if ab.stamina and self:getStamina() < ab.stamina * (100 + self.fatigue) / 100 then
			game.logPlayer(self, "You do not have enough stamina to use %s.", ab.name)
			return false
		end
	end

	if not silent then
		if ab.message then
			game.logSeen(self, "%s", self:useTalentMessage(ab))
		elseif ab.mode == "sustained" and not self:isTalentActive(ab.id) then
			game.logSeen(self, "%s activates %s.", self.name:capitalize(), ab.name)
		elseif ab.mode == "sustained" and self:isTalentActive(ab.id) then
			game.logSeen(self, "%s deactivates %s.", self.name:capitalize(), ab.name)
		elseif ab.type[1]:find("^spell/") then
			game.logSeen(self, "%s casts %s.", self.name:capitalize(), ab.name)
		else
			game.logSeen(self, "%s uses %s.", self.name:capitalize(), ab.name)
		end
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

	if ab.type[1]:find("^spell/") then
		self:useEnergy(game.energy_to_act * self:combatSpellSpeed())
	elseif ab.type[1]:find("^physical/") then
		self:useEnergy(game.energy_to_act * self:combatSpeed())
	else
		self:useEnergy()
	end

	if ab.mode == "sustained" then
		if not self:isTalentActive(ab.id) then
			if ab.sustain_mana then
				self.max_mana = self.max_mana - ab.sustain_mana
			end
			if ab.sustain_stamina then
				self.max_stamina = self.max_stamina - ab.sustain_stamina
			end
		else
			if ab.sustain_mana then
				self.max_mana = self.max_mana + ab.sustain_mana
			end
			if ab.sustain_stamina then
				self.max_stamina = self.max_stamina + ab.sustain_stamina
			end
		end
	else
		if ab.mana then
			self:incMana(-ab.mana * (100 + self.fatigue) / 100)
		end
		if ab.stamina then
			self:incStamina(-ab.stamina * (100 + self.fatigue) / 100)
		end
	end

	return true
end

--- Can the actor see the target actor
-- This does not check LOS or such, only the actual ability to see it.<br/>
-- Check for telepathy, invisibility, stealth, ...
function _M:canSee(actor)
	-- Check for invisibility. This is a "simple" checkHit between invisible and see_invisible attrs
	if actor:attr("invisible") then
		-- Special case, 0 see invisible, can NEVER see invisible things
		if not self:attr("see_invisible") then return false, 0 end
		local hit, chance = self:checkHit(self:attr("see_invisible"), actor:attr("invisible"), 0, 100)
		if not hit then
			return false, chance
		end
	end
	return true, 100
end

--- Can the target be applied some effects
-- @param what a string describing what is being tried
function _M:canBe(what)
	if what == "stun" and self:attr("stun_immune") then return false end
	if what == "knockback" and self:attr("knockback_immune") then return false end
	return true
end
