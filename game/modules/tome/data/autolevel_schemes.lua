local Autolevel = require "engine.Autolevel"

local function learnStats(self, statorder)
	local i = 1
	while self.unused_stats > 0 do
		self:incStat(statorder[i], 1)
		i = util.boundWrap(i + 1, 1, #statorder)
		self.unused_stats = self.unused_stats - 1
	end
end

Autolevel:registerScheme{ name = "warrior", levelup = function(self)
	learnStats(self, { self.STAT_STR, self.STAT_STR, self.STAT_DEX })
end}

Autolevel:registerScheme{ name = "ghoul", levelup = function(self)
	learnStats(self, { self.STAT_STR, self.STAT_CON })
end}

Autolevel:registerScheme{ name = "tank", levelup = function(self)
	learnStats(self, { self.STAT_STR, self.STAT_CON, self.STAT_CON })
end}

Autolevel:registerScheme{ name = "rogue", levelup = function(self)
	learnStats(self, { self.STAT_DEX, self.STAT_CUN, self.STAT_CUN })
end}

Autolevel:registerScheme{ name = "archer", levelup = function(self)
	learnStats(self, { self.STAT_DEX, self.STAT_DEX, self.STAT_CUN })
end}

Autolevel:registerScheme{ name = "slinger", levelup = function(self)
	learnStats(self, { self.STAT_DEX, self.STAT_DEX, self.STAT_STR })
end}

Autolevel:registerScheme{ name = "caster", levelup = function(self)
	learnStats(self, { self.STAT_MAG, self.STAT_MAG, self.STAT_WIL })
end}

Autolevel:registerScheme{ name = "warriormage", levelup = function(self)
	if self.level % 2 == 0 then
		learnStats(self, { self.STAT_MAG, self.STAT_MAG, self.STAT_WIL })
	else
		learnStats(self, { self.STAT_STR, self.STAT_STR, self.STAT_DEX })
	end
end}

Autolevel:registerScheme{ name = "snake", levelup = function(self)
	if self.level % 2 == 0 then
		learnStats(self, { self.STAT_CUN, self.STAT_DEX, self.STAT_CON })
	else
		learnStats(self, { self.STAT_CUN, self.STAT_DEX, self.STAT_STR })
	end
end}
