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

setStatusAll{no_teleport=true, no_vaulted=true}

defineTile(',', "GRASS")
defineTile(';', "GRASS_DARK1")
defineTile('~', "DEEP_WATER")
defineTile('%', "POISON_DEEP_WATER")

defineTile('$', "GRASS_DARK1", {random_filter={add_levels=25, type="money"}})
defineTile('*', "GRASS", {random_filter={add_levels=25, type="gem"}})
defineTile('&', "TREE_DARK", {random_filter={add_levels=15, subtype="amulet", tome_mod="vault"}})

defineTile('^', "GRASS_DARK1", nil, nil, {random_filter={add_levels=15, name="poison vine"}})
defineTile('+', "GRASS", nil, nil, {random_filter={add_levels=15, name="poison vine"}})

defineTile('#', "GRASS_DARK1", nil, {random_filter={add_levels=30, subtype="plants", never_move=1}})

rotates = {"default", "90", "180", "270", "flipx", "flipy"}

return {
[[,,,^,;,,,^;,,;++,,+,]],
[[,#,,,,;;;,,;,;#,,,;,]],
[[~~,,#,,#;;;;,;*;;,,;]],
[[,;~$,,+,*#,,,#;+#,,,]],
[[;,,#~,#,$,^,,^,$,,,;]],
[[,#*,+~+,$,,#,;,#^,,#]],
[[,,;,$~,;;%%*,+,;,;,,]],
[[;,#,^~;,+,#%%;;;^#,;]],
[[;,*,,;~~~%%,%%%,,;,;]],
[[,#,^,;%#%~%%%#%,#;+,]],
[[,,,%,;$%%$~$%,%,;$,#]],
[[;+$%%%;#%,~,%^,%$#,,]],
[[;,#%%;#%%%~%%%%,%,,^]],
[[,,$%;%;%#+&~~~#;%,,,]],
[[^$,%%%,%%+%%%%~%,+,;]],
[[,,%%#%%%*%$%~$~;%,,,]],
[[,%#,#$;#;#%~%~%%%$#;]],
[[;,%$,$,$^*%,~%,#+,#,]],
[[,#,,^,+$,#,%;;%;,;,;]],
[[,;;,,#,,,^,++,,,;;,,]],
}
