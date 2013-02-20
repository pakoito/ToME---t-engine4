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

local art_list = mod.class.Object:loadList("/data/general/objects/brotherhood-artifacts.lua")
local alchemist_num = 1
local other_alchemist_nums = {2, 3, 4}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "LIFEBINDING_EMERALD"
local e = {
	{
	short_name = "fox",
	name = "elixir of the fox",
	id = "ELIXIR_FOX",
	start = "fox_start",
	almost = "fox_almost_done",
	full = "elixir_of_the_fox",
	full_2 = "elixir_of_avoidance",
	full_3 = "elixir_of_precision",
	poached = "fox_poached",
	},
	{
	short_name = "avoidance",
	name = "elixir of avoidance",
	id = "ELIXIR_AVOIDANCE",
	start = "avoidance_start",
	almost = "avoidance_almost_done",
	full = "elixir_of_avoidance",
	full_2 = "elixir_of_the_fox",
	full_3 = "elixir_of_precision",
	poached = "avoidance_poached",
	},
	{
	short_name = "precision",
	name = "elixir of precision",
	id = "ELIXIR_PRECISION",
	start = "precision_start",
	almost = "precision_almost_done",
	full = "elixir_of_precision",
	full_2 = "elixir_of_the_fox",
	full_3 = "elixir_of_avoidance",
	poached = "precision_poached",
	},
}

--cond function for turning in non-final elixirs
--checks that player has quest and elixir ingredients, hasn't completed it yet, has started that elixir, and hasn't completed both other elixirs since that would make this the last one:
local function turn_in(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) and not q:isCompleted(e[n].full) --make sure we haven't finished the quest already
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and not (q:isCompleted(e[n].full_2) and q:isCompleted(e[n].full_3)) --make sure we haven't already finished both the other elixirs, since that would make this the final one which requires a special dialog.
end

--cond function for turning in final elixir with index n
--checks that player has quest and elixir ingredients, hasn't completed it yet, has started that elixir, and both the other elixirs are done
local function turn_in_final(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) and not q:isCompleted(e[n].full) --make sure we haven't finished the quest already
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and (q:isCompleted(e[n].full_2) and q:isCompleted(e[n].full_3)) --make sure the other two elixirs are made, thus making this the final turn-in
end

--cond function for turning in poached (completed by somebody besides you) elixirs
--checks that the player has the quest and elixir ingredients, hasn't turned it in, the task is complete anyway, the task has actually been started, and that it's been poached
local function turn_in_poached(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and not q:isCompleted(e[n].almost) --make sure we haven't turned it in already
	and q:isCompleted(e[n].full) --make sure that, even though we haven't turned it in, the elixir has been made for this alchemist
	and q:isCompleted(e[n].start) --make sure we've been given the task to make this elixir
	and q:isCompleted(e[n].poached)  --make sure this task has been poached
end

local function more_aid(npc, player)
	return not (q:isCompleted(e[1].full) and q:isCompleted(e[2].full) and q:isCompleted(e[3].full)) --make sure all the elixirs aren't already made
	--Next, for each of the three elixirs, make sure it's not the case that we're still working on it
	and not (q:isCompleted(e[1].start) and not q:isCompleted(e[1].full))
	and not (q:isCompleted(e[2].start) and not q:isCompleted(e[2].full))
	and not (q:isCompleted(e[3].start) and not q:isCompleted(e[3].full))
end

local function give_bits(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name) -- make sure we have the quest and the elixir's ingredients
	and q:isCompleted(e[n].start) --make sure we've started the task
	and not q:isCompleted(e[n].full) --... but not finished
end

local function empty_handed(npc, player, n) -- n is the index of the elixir we're checking on
	return q and q:check_ingredients(player, e[n].short_name, n) -- make sure we have the quest and the elixir's ingredients
	and q:isCompleted(e[n].start) --make sure we've started the task
	and not q:isCompleted(e[n].almost) --make sure we've not turned the stuff in before...
	and q:isCompleted(e[n].full)  --... and yet the elixir is already made (poached!)
end

--Make the alchemist's reaction to your turn-in vary depending on whether he lost.
local function alchemist_reaction_complete(npc, player, lose, other_alch, other_elixir)
	if lose == true then
		return ([[Pfaugh. You're too late. %s has already finished. But I suppose it doesn't do any harm to take these and give you your undeserved reward.]]):format(other_alch)
	else
		return ([[Ah, excellent. Hand them over, if you please. You should know that in your overlong absence, %s has managed to create a %s. I'll be most put out if he steals my rightful spot.]]):format(other_alch, other_elixir)
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A human robed in immaculate white satin opens the door and eyes you appraisingly.*#WHITE#
Ah, an adventurer. I was just thinking that I needed a new one.]],
	answers = {
		{"That sounds promising. And ominous.", jump="ominous"},
		{"[leave]"},
	}
}

newChat{ id="ominous",
	text = [[Indeed, it is both promising and ominous. I can reward you handsomely for your efforts, but they will lead you into deadly peril to which, I assume, the previous three fellows who went off on my errand never to return can attest.]],
	answers = {
		{"What do you propose?", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[Good adventurer, I am an alchemist, and quite a good one. This year, for the first time, the great Brotherhood of Alchemists has invited my application to their number. I'll not try your patience with the details of the application process, but suffice to say that it is grueling. Fortunately, a mere three tasks now stand between me and acceptance.]],
	answers = {
		{"How can I help?", jump="help"},
	}
}

newChat{ id="help",
	text = [[I require ingredients for three potent mixtures. Obviously, since I seek your aid, none of them is to be found by simply strolling to the local herbalist's. No, they will need to be forcibly parted from their owners who will, just as obviously, put up a fight. I've yet to encounter a naga who would be persuaded to hand over his tongue! Ha! Oh, I am droll at times.]],
	answers = {
		{"I specialize in separating vital body parts from monsters. What do you offer in return?", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[Why, I will let you share in the fruits of my labors! Each of the three mixtures I shall produce in a quantity sufficient to create three doses: one for me, one for the Brotherhood and their confounded trial... and one for you. I must tell you that time is of the essence. I am not the only one who the Brotherhood invited this year, yet they will accept only one applicant-- the first to complete their trials. I know of at least three others laboring furiously to take my rightful place. Should your aid see me through, then I will reward you beyond even the remarkable elixirs. I've an ancient Lifebinding Emerald that grants great powers of health and healing when used properly. What say you?]],
	answers = {
		{"I accept.", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"I cannot aid you at this time."},
	}
}

newChat{ id="choice",
	text = [[Excellent. Now then, I've three elixirs I'm working on. I'll burden you with only one at a time, since I've learned the hard way about the hazards of overloading an adventurer's brain. Here are your options: the elixir of the fox, which makes you as nimble and cunning as a fox; the elixir of avoidance, which sharpens your natural inclinations to get out of the way of incoming harm; or the elixir of precision, which grants intuitive understanding of an enemy's most sensitive spots. Which would you like to aid me with?]],
	answers = {
		{"The "..e[1].name..".", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[1].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"The "..e[2].name..".", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[2].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"The "..e[3].name..".", jump="list",
			cond = function(npc, player) return not game.player:hasQuest("brotherhood-of-alchemists"):isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].start)
				game.player:hasQuest("brotherhood-of-alchemists"):update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[3].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[leave]"},
	}
}

newChat{ id="list",
	text = [[Here's a list of the ingredients I'm missing. Please attempt to not lose your life in their pursuit. I'll be most put out if I must wait another year. Oh, and I suppose I should tell you that I've already a handful of adventurers out scouring the unpleasant places of the world for these ingredients. Dally and one of them shall claim the prize while you're out.]],
	answers = {
		{"I'll be off."},
	}
}

-- Quest is complete; nobody answers the door
elseif q and q:isStatus(q.DONE) then
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The door is locked and nobody responds to your knocks*#WHITE#]],
	answers = {
		{"[Leave]"},
	}
}


else -- Here's the dialog that pops up if the player *has* worked with this alchemist before (either done quests or is in the middle of one):

local other_alch, other_elixir, player_loses, alch_picked, e_picked = q:competition(player, other_alchemist_nums)

newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*The alchemist opens his door.*#WHITE#
Ah, you again.]],
	answers = {
		-- If not the final elixir:
		{"I've returned with the ingredients for the "..e[1].name..".", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 1) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{"I've returned with the ingredients for the "..e[2].name..".", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 2) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},
		{"I've returned with the ingredients for the "..e[3].name..".", jump="complete",
			cond = function(npc, player) return turn_in(npc, player, 3) end,
			action = function(npc, player)
				q:on_turnin(player, alch_picked, e_picked, false)
			end,
		},

		-- If the final elixir:
		{"I've returned with the ingredients for the "..e[1].name..".", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 1) end,
		},
		{"I've returned with the ingredients for the "..e[2].name..".", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 2) end,
		},
		{"I've returned with the ingredients for the "..e[3].name..".", jump="totally-complete",
			cond = function(npc, player) return turn_in_final(npc, player, 3) end,
		},

		-- If the elixir got made while you were out:
		{"I've returned with the ingredients for the "..e[1].name..".", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 1) end,
		},
		{"I've returned with the ingredients for the "..e[2].name..".", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 2) end,
		},
		{"I've returned with the ingredients for the "..e[3].name..".", jump="poached",
			cond = function(npc, player) return turn_in_poached(npc, player, 3) end,
		},

		--Don't let player work on multiple elixirs for the same alchemist.
		--See comments in more_aid function above for all the gory detail
		{"I've come to offer more aid.", jump="choice",
			cond = function(npc, player) return more_aid(npc, player) end,
		},
		{"[leave]"},
	}
}

--Not final elixir:
newChat{ id="complete",
	text = alchemist_reaction_complete(npc, player, player_loses, other_alch, other_elixir),
	answers = {
		{"[Give him the monster bits.]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 1) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:remove_ingredients(player, e[1].short_name, 1)
			end
		},
		{"[Give him the monster bits.]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 2) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:remove_ingredients(player, e[2].short_name, 2)
			end
		},
		{"[Give him the monster bits.]", jump="complete2",
			cond = function(npc, player) return give_bits(npc, player, 3) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:remove_ingredients(player, e[3].short_name, 3)
			end
		},
--		{"Sorry, it seems I lack some stuff. I will be back."},
	}
}

--Final elixir:
newChat{ id="totally-complete",
	text = [[#LIGHT_GREEN#*The alchemist grins and motions impatiently for the ingredients.*#WHITE#
Wonderful, absolutely wonderful! The final step! Here, let me have those!]],
	answers = {
		{"[Give him the monster bits]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 1) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:remove_ingredients(player, e[1].short_name, 1)
			end
		},
		{"[Give him the monster bits]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 2) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:remove_ingredients(player, e[2].short_name, 2)
			end
		},
		{"[Give him the monster bits]", jump="totally-complete2",
			cond = function(npc, player) return give_bits(npc, player, 3) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:remove_ingredients(player, e[3].short_name, 3)
			end
		},
		--{"Sorry, it seems I lack some stuff. I will be back."},
	}
}

--Not final elixir:
newChat{ id="complete2",
	text = [[Wait here while I perform my art. I'll have your reward within the hour.]],
	answers = {
		{"[Wait]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[A final wait for you, my good adventurer, and then I shall return with both your rewards! Haha, complete at last!]],
	answers = {
		{"[Wait]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*The alchemist finally returns and hands you a small vial of fine glass.*#WHITE#
Enjoy your reward.]],
	answers = {
		{"Thank you. I'll be off.",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:update_needed_ingredients(player)
			end
		},
		{"Thank you. I'll be off.",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:update_needed_ingredients(player)
			end
		},
		{"Thank you. I'll be off.",
			cond = function(npc, player) return q and q:isCompleted(e[3].almost) and not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].full)
				q:reward(player, e[3].id)
				q:update_needed_ingredients(player)
			end
		},
	}
}

--Final elixir:
newChat{ id="totally-complete3",
	text = [[#LIGHT_GREEN#*The alchemist finally returns with a vial and a green gem.*#WHITE#
Enjoy the fruits of your labors, adventurer. I know I will. To show my appreciation, I shall name my firstborn after... er, what was your name, then? Haha, I jest. Oh, I do go on when I'm giddy. Fare you well.]],
	answers = {
		{"Thank you. I'll be off.",
			cond = function(npc, player) return q and q:isCompleted(e[1].almost) and not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].full)
				q:reward(player, e[1].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)

			end
		},
		{"Thank you. I'll be off.",
			cond = function(npc, player) return q and q:isCompleted(e[2].almost) and not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].full)
				q:reward(player, e[2].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
			end
		},
		{"Thank you. I'll be off.",
			cond = function(npc, player) return q and q:isCompleted(e[3].almost) and not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].full)
				q:reward(player, e[3].id)
				q:reward(player, final_reward)
				q:update_needed_ingredients(player)
				q:winner_is(player, alchemist_num)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.DONE)
			end
		},
	}
}

newChat{ id="choice",
	text = [[Excellent. With which would you like to aid me?]],
	answers = {
		{"The "..e[1].name..".", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[1].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[1].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"The "..e[2].name..".", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[2].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[2].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"The "..e[3].name..".", jump="list",
			cond = function(npc, player) return not q:isCompleted(e[3].full) end,
			action = function(npc, player)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].start)
				q:update_needed_ingredients(player)
			end,
			on_select=function(npc, player)
				local o = art_list[e[3].id]
				o:identify(true)
				game.tooltip_x, game.tooltip_y = 1, 1
				game:tooltipDisplayAtMap(game.w, game.h, tostring(o:getDesc()))
			end,
		},
		{"[leave]"},
	}
}

newChat{ id="list",
	text = [[Here's a list of the ingredients I'm missing. Please attempt to not lose your life in their pursuit. I'll be most put out if I must wait another year.]],
	answers = {
		{"I'll be off."},
	}
}

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[Terribly sorry, but I've already made the elixir without your aid. I've no reward to give you, and no reason to do so if I did.]],
	answers = {
		{"Hrmph.",
			cond = function(npc, player) return empty_handed(npc, player, 1) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[1].short_name, 1)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[1].almost)
				q:update_needed_ingredients(player)
			end,
		},
		{"Hrmph.",
			cond = function(npc, player) return empty_handed(npc, player, 2) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[2].short_name, 2)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[2].almost)
				q:update_needed_ingredients(player)
			end,
		},
		{"Hrmph.",
			cond = function(npc, player) return empty_handed(npc, player, 3) end,
			action = function(npc, player)
				q:remove_ingredients(player, e[3].short_name, 3)
				player:setQuestStatus("brotherhood-of-alchemists", engine.Quest.COMPLETED, e[3].almost)
				q:update_needed_ingredients(player)
			end,
		},
	}
}

end

return "welcome"
