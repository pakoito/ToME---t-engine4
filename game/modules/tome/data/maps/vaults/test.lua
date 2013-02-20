-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

-- This is simply and example of how to use levers, not a real ingame vault

defineTile('.', "FLOOR")
defineTile('=', "FLOOR", nil, nil, nil, {foobar=true})
defineTile('&', "GENERIC_LEVER", nil, nil, nil, {lever=1, lever_kind="foo", lever_radius=10, lever_block="foobar"})
defineTile('+', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_action=3, lever_action_value=0, lever_action_kind="foo"})
defineTile('5', "GENERIC_LEVER_DOOR", nil, nil, nil, {lever_toggle=true, lever_action_kind="foo"})
defineTile('6', "HARDWALL", nil, nil, nil, {on_block_change="FLOOR", on_block_change_msg="Ahah it opens!"})
defineTile('"', "FLOOR", nil, nil, nil, {lever_action_value=0, lever_action_only_once=true, lever_action_kind="foo", lever_action_custom=function(i, j, who, val, old)
	if val == 3 then
		game.level.map:particleEmitter(i, j, 5, "ball_fire", {radius=5})
		return true
	end
end})

return {
[[...........]],
[[...+.6.....]],
[[..=====....]],
[[........"..]],
[[..&.&.&....]],
[[...........]],
[[....+5.....]],
[[...........]],
}
