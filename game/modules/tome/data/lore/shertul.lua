-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

--------------------------------------------------------------------------
-- Sher'Tul
--------------------------------------------------------------------------

newLore{
	id = "shertul-fortress-1",
	category = "sher'tul",
	name = "first mural painting", always_pop = true,
	image = "shertul_fortress_lore1.png",
	lore = function() return [[You see here a mural showing a dark and tortured world. Large, god-like figures with powerful auras fight each other, and the earth is torn beneath their feet.
There is some text underneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Sho ch'zun Eyal mor donuth, ik ranaheli donoth trun ze.'#{normal}#]] or [[#{italic}#'In the beginning the world was dark, and the petty gods fought over their broken lands.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-2",
	category = "sher'tul",
	name = "second mural painting", always_pop = true,
	image = "shertul_fortress_lore2.png",
	lore = function() return [[In this picture a huge god with glowing eyes towers above the land, and in his right hand he holds high the sun. The other gods are running from him, wincing from the light.
There is some text underneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Fa AMAKTHEL tabak, ik koru bazan tro yu, ik ranaheli tobol don schek ruun. Ik blana dem Soli as banafel ik goriz uf Eyal ik blod, "Tro fasa goru domus asam, ik goru domit tro Eyal."'#{normal}#]] or [[#{italic}#'But AMAKTHEL came, and his might surpassed all else, and the petty gods fled before his glory. And he made the Sun from his breath and held it above the world and said, "All that this light touches shall be mine, and this light shall touch all the world.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-3",
	category = "sher'tul",
	name = "third mural painting", always_pop = true,
	image = "shertul_fortress_lore3.png",
	lore = function() return [[This picture shows the huge god holding some smaller figures in his hands and pointing out at the lands beyond. You imagine these figures must be the Sher'Tul.
There is some text beneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Ik AMAKTHEL cosio SHER'TUL, ik baladath peris furko masa bren doth benna zi, ik blod is "Fen makel ath goru domus ik denz tro ala fron."'#{normal}#]] or [[#{italic}#'And AMAKTHEL made the SHER'TUL, and gave unto us the powers to achieve all that we set our will to, and said to us "Go forth to where the light touches and take all for your own."'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-4",
	category = "sher'tul",
	name = "fourth mural painting", always_pop = true,
	image = "shertul_fortress_lore4.png",
	lore = function() return [[You see a mural showing a huge metropolis made of crystal, with small islands of stone floating in the air behind it. In the foreground is sitting a Sher'Tul, with a hand stretched up to the sky.
There is some text beneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Batialatoth ro Eyal, ik rinsi akan fronseth sumit kurameth ik linnet pora gasios aeren. Ach nen beswar goreg.'#{normal}#]] or [[#{italic}#'We conquered the world, and built for ourselves towering cities of crystal and fortresses that travelled the skies. But some were not content...'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-5",
	category = "sher'tul",
	name = "fifth mural painting", always_pop = true,
	image = "shertul_fortress_lore5.png",
	lore = function() return [[This mural shows nine Sher'Tul standing side by side, each holding aloft a dark weapon. Your eyes are drawn to a runed staff held by the red-robed figure in the centre. It seems familiar somehow...
There is some text beneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Zubadon koref noch hesen, ik dorudon koref noch pasor. Cosief maro dondreth karatu - Ranaduzil - ik jein belsan ovrienis.'#{normal}#]] or [[#{italic}#'Of pride we accepted no equals, and of greed we accepted no servitude. We made for ourselves terrible weapons - the Godslayers - and nine were chosen to wield them.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-6",
	category = "sher'tul",
	name = "sixth mural painting", always_pop = true,
	image = "shertul_fortress_lore6.png",
	lore = function() return [[You see images of epic battles, with Sher'Tul warriors fighting and slaying god-like figures over ten times their size.
There is some text underneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Ranaheli meth dondruil ik duzin, ik leisif konru as neremin. Eyal matath bre sun. Ach unu rana soriton...'#{normal}#]] or [[#{italic}#'The petty gods were hunted down and slain, and their spirits rent to nothing. The land became our own. But one god remained...'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-7",
	category = "sher'tul",
	name = "seventh mural painting", always_pop = true,
	image = "shertul_fortress_lore7.png",
	lore = function() return [[You see the red-robed Sher'Tul striking the huge god with the dark, runed staff. Bodies litter the floor around them, and the golden throne behind is bathed in blood. The light in the god's eyes seems faded.
There is some text underneath ]]..(not game.player:attr("speaks_shertul") and [[which you do not understand: #{italic}#'Trobazan AMAKTHEL konruata as va aurin leas, ik mab peli zort akan hun, penetar dondeberoth.'#{normal}#]] or [[#{italic}#'The almighty AMAKTHEL was assaulted on his golden throne, and though many died before his feet, he was finally felled.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-8",
	category = "sher'tul",
	name = "eighth mural painting", always_pop = true,
	image = "shertul_fortress_lore8.png",
	lore = function() return [[The large mural shows the great god spread on the ground, with the dark staff held against his chest. Sher'Tul surround him, some hacking off his limbs, cutting out his tongue, and binding him with chains. A burst of light flares up from where a tall Sher'Tul warrior is gouging his eye with a black-bladed halberd. In the background a Sher'Tul mage beckons to a huge chasm in the ground.
The text beneath says simply ]]..(not game.player:attr("speaks_shertul") and [[#{italic}#'Meas Abar.'#{normal}#]] or [[#{italic}#'The Great Sin.'#{normal}#]])
	end,
}

newLore{
	id = "shertul-fortress-9",
	category = "sher'tul",
	name = "ninth mural painting", always_pop = true,
	image = "shertul_fortress_lore9.png",
	lore = function() return [[This final mural has been ruined, with deep scores and scratches etched across its surface. All you can see of the original appears to be flames.]] end,
}

newLore{
	id = "shertul-fortress-takeoff",
	category = "sher'tul",
	name = "Yiilkgur raising toward the sky", always_pop = true,
	image = "fortress_takeoff.png",
	lore = [[Yiilkgur, the Sher'Tul Fortress is re-activated and raises from the depths of Nur toward the sky.]],
}

newLore{
	id = "shertul-fortress-caldizar",
	category = "sher'tul",
	name = "a living Sher'Tul?!", always_pop = true,
	image = "inside_caldizar_fortress.png",
	lore = [[You somehow got teleported to an other Sher'Tul Fortress, in a very alien location. There you saw a living Sher'Tul.]],
}

newLore{
	id = "first-farportal",
	category = "sher'tul",
	name = "lost farportal", always_pop = true,
	image = "farportal_entering.png",
	lore = function() return game.player.name..[[ boldly entering a Sher'Tul farportal.]] end,
}
