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
	-- 2 STR for 1 DEX
	learnStats(self, { self.STAT_STR, self.STAT_STR, self.STAT_DEX })
end}

Autolevel:registerScheme{ name = "caster", levelup = function(self)
	-- 2 MAG for 1 WIL
	learnStats(self, { self.STAT_MAG, self.STAT_MAG, self.STAT_WIL })
end}
