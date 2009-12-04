-- Convert unicode keys to other unicode keys depending on locale
-- This allows to support the number bar "hotkeys" without too much trouble
if locale == "frFR" then
	return {
		[_AMPERSAND] =	_1,
		[_WORLD_73] =	_2,
		[_QUOTEDBL] =	_3,
		[_QUOTE] =	_4,
		[_LEFTPAREN] =	_5,
		[_MINUS] =	_6,
		[_WORLD_72] =	_7,
		[_UNDERSCORE] =	_8,
		[_WORLD_71] =	_9,
		[_WORLD_64] =	_0,
--		[_RIGHTPAREN] =	_),
--		[_EQUALS] =	_=,
	}
else
	-- Default to no convertion
	return {}
end
