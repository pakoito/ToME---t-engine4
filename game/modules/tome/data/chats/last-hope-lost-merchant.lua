-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local q = game.player:hasQuest("lost-merchant")
if q and q:isStatus(q.COMPLETED, "saved") then

local p = game:getPlayer(true)

newChat{ id="welcome",
	text = [[Ah, my #{italic}#good#{normal}# friend @playername@!
Thanks to you I made it safely to this great city! I am planning to open my most excellent boutique soon, but since I am in your debt, perhaps I could open early for you if you are in need of rare goods.]]
..((p:knowTalent(p.T_TRAP_MASTERY) and not p:knowTalent(p.T_FLASH_BANG_TRAP)) and "\nDuring our escape I found the plans for a #YELLOW#Flash Bang Trap#LAST#, you would not happen to be interested by any chance?" or "")
..((game.state:isAdvanced() and "\nOh my friend, good news! As I told you I can now request a truly #{italic}#unique#{normal}# object to be crafted just for you. For a truly unique price..." or "\nI eventually plan to arrange a truly unique service for the most discerning of customers. If you come back later when I'm fully set up I shall be able to order for you something quite marvellous. For a perfectly #{italic}#suitable#{normal}# price, of course.")),
	answers = {
		{"Yes please, let me see your wares.", action=function(npc, player)
			npc.store:loadup(game.level, game.zone)
			npc.store:interact(player)
		end},
		{"What about the unique object?", cond=function(npc, player) return game.state:isAdvanced() end, jump="unique1"},
		{"Flash Bang Trap ? Sounds useful.", cond=function(npc, player) return p:knowTalent(p.T_TRAP_MASTERY) and not p:knowTalent(p.T_FLASH_BANG_TRAP) end, jump="trap"},
		{"Sorry, I have to go!"},
	}
}

newChat{ id="trap",
	text = [[You know, I have asked here and there and it happens to be a very rare thing this contraption...
But since you have saved me, I'm willing to part from it for only 3000 gold pieces, a real bargain!]],
	answers = {
		{"Expensive, but I will take it.", cond=function(npc, player) return player.money >= 3000 end, jump="traplearn"},
		{"..."},
	}
}

newChat{ id="traplearn",
	text = [[Nice doing business with you my friend. There you go!]],
	answers = {
		{"Thanks.", action=function(npc, player)
			p:learnTalent(p.T_FLASH_BANG_TRAP, 1, nil, {no_unlearn=true})
			p:incMoney(-3000)
			game.log("#LIGHT_GREEN#You learn the schematic, you can now create flash bang traps!")
		end},
	}
}

newChat{ id="unique1",
	text = [[I normally offer this service only for a truly deserved price, but for you my friend I am willing to offer a 20% discount - #{italic}#only#{normal}# 4000 gold to make an utterly unique item of your choice.  What do you say?]],
	answers = {
		{"Why, 'tis a paltry sum - take my order, man, and be quick about it!", cond=function(npc, player) return player.money >= 10000 end, jump="make"},
		{"Yes, please!", cond=function(npc, player) return player.money >= 4000 end, jump="make"},
		{"HOW MUCH?! Please, excuse me, I- I need some fresh air...", cond=function(npc, player) return player.money < 500 end},
		{"Not now, thank you."},
	}
}

local maker_list = function()
	local mainbases = {
		armours = {
			"elven-silk robe",
			"drakeskin leather armour",
			"voratun mail armour",
			"voratun plate armour",
			"elven-silk cloak",
			"drakeskin leather gloves",
			"voratun gauntlets",
			"elven-silk wizard hat",
			"drakeskin leather cap",
			"voratun helm",
			"pair of drakeskin leather boots",
			"pair of voratun boots",
			"drakeskin leather belt",
			"voratun shield",
		},
		weapons = {
			"voratun battleaxe",
			"voratun greatmaul",
			"voratun greatsword",
			"voratun waraxe",
			"voratun mace",
			"voratun longsword",
			"voratun dagger",
			"living mindstar",
			"quiver of dragonbone arrows",
			"dragonbone longbow",
			"drakeskin leather sling",
			"dragonbone staff",
			"pouch of voratun shots",
		},
		misc = {
			"voratun ring",
			"voratun amulet",
			"dwarven lantern",
			"voratun pickaxe",
			{"dragonbone wand", "dragonbone wand"},
			{"dragonbone totem", "dragonbone totem"},
			{"voratun torque", "voratun torque"},
		},
	}
	local l = {{"I've changed my mind.", jump = "welcome"}}
	for kind, bases in pairs(mainbases) do
		l[#l+1] = {kind:capitalize(), action=function(npc, player)
			local l = {{"I've changed my mind.", jump = "welcome"}}
			newChat{ id="makereal",
				text = [[Which kind of item would you like ?]],
				answers = l,
			}

			for i, name in ipairs(bases) do
				local dname = nil
				if type(name) == "table" then name, dname = name[1], name[2] end
				local not_ps, force_themes
				not_ps = game.state:attrPowers(player) -- make sure randart is compatible with player
				if not_ps.arcane then force_themes = {'antimagic'} end
				
				local o, ok
				local tries = 100
				repeat
					o = game.zone:makeEntity(game.level, "object", {name=name, ignore_material_restriction=true, no_tome_drops=true, ego_filter={keep_egos=true, ego_chance=-1000}}, nil, true)
					if o then ok = true end
					if o and o.power_source and player:attr("forbid_arcane") and o.power_source.arcane then ok = false o = nil end
					tries = tries - 1
				until ok or tries < 0
				if o then
					if not dname then dname = o:getName{force_id=true, do_color=true, no_count=true}
					else dname = "#B4B4B4#"..o:getDisplayString()..dname.."#LAST#" end
					l[#l+1] = {dname, action=function(npc, player)
						local art, ok
						local nb = 0
						repeat
							art = game.state:generateRandart{base=o, lev=70, egos=4, force_themes=force_themes, forbid_power_source=not_ps}
							if art then ok = true end
							if art and art.power_source and player:attr("forbid_arcane") and art.power_source.arcane then ok = false end
							nb = nb + 1
							if nb == 40 then break end
						until ok
						if art and nb < 40 then
							art:identify(true)
							player:addObject(player.INVEN_INVEN, art)
							player:incMoney(-4000)
							-- clear chrono worlds and their various effects
							if game._chronoworlds then
								game.log("#CRIMSON#Your timetravel has no effect on pre-determined outcomes such as this.")
								game._chronoworlds = nil
							end
							if not config.settings.cheat then game:saveGame() end

							newChat{ id="naming",
								text = "Do you want to name your item?\n"..tostring(art:getTextualDesc()),
								answers = {
									{"Yes, please.", action=function(npc, player)
										local d = require("engine.dialogs.GetText").new("Name your item", "Name", 2, 40, function(txt)
											art.name = txt:removeColorCodes():gsub("#", " ")
											game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true})
										end, function() game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true}) end)
										game:registerDialog(d)
									end},
									{"No thanks.", action=function() game.log("#LIGHT_BLUE#The merchant carefully hands you: %s", art:getName{do_color=true}) end},
								},
							}
							return "naming"
						else
							newChat{ id="oups",
								text = "Oh I am sorry, it seems we could not make the item your require.",
								answers = {
									{"Oh, let's try something else then.", jump="make"},
									{"Oh well, maybe later then."},
								},
							}
							return "oups"
						end
					end}
				end
			end

			return "makereal"
		end}
	end
	return l
end

newChat{ id="make",
	text = [[Which kind of item would you like ?]],
	answers = maker_list(),
}

else

newChat{ id="welcome",
	text = [[*This store does not appear to be open yet*]],
	answers = {
		{"[leave]"},
	}
}

end

return "welcome"
