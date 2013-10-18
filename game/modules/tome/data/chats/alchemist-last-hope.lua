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
local alchemist_num = 4
local other_alchemist_nums = {1, 2, 3}
local q = game.player:hasQuest("brotherhood-of-alchemists")
local final_reward = "TAINT_TELEPATHY"
local e = {
	{
	short_name = "brawn",
	name = "elixir of brawn",
	id = "ELIXIR_BRAWN",
	start = "brawn_start",
	almost = "brawn_almost_done",
	full = "elixir_of_brawn",
	full_2 = "elixir_of_stoneskin",
	full_3 = "elixir_of_foundations",
	poached = "brawn_poached",
	},
	{
	short_name = "stoneskin",
	name = "elixir of stoneskin",
	id = "ELIXIR_STONESKIN",
	start = "stoneskin_start",
	almost = "stoneskin_almost_done",
	full = "elixir_of_stoneskin",
	full_2 = "elixir_of_brawn",
	full_3 = "elixir_of_foundations",
	poached = "stoneskin_poached",
	},
	{
	short_name = "foundations",
	name = "elixir of foundations",
	id = "ELIXIR_FOUNDATIONS",
	start = "foundations_start",
	almost = "foundations_almost_done",
	full = "elixir_of_foundations",
	full_2 = "elixir_of_brawn",
	full_3 = "elixir_of_stoneskin",
	poached = "foundations_poached",
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
		return ([[Damn it all. You're too late. %s has already finished. But I suppose you did your best, so I'll take these and keep my end of the bargian.]]):format(other_alch)
	else
		return ([[Great work! And you're still in one piece, I see. Always nice. I feel the same way after safely brewing up a particularly tricky mixture. I've near blown my face clean off several times. Oh, while you were gone a little bird told me that %s has managed to create a %s. Don't let him finish before me!]]):format(other_alch, other_elixir)
	end
end

if not q or (q and not q:isCompleted(e[1].start) and not q:isCompleted(e[2].start) and not q:isCompleted(e[3].start)) then

-- Here's the dialog that pops up if the player has never worked for this alchemist before:
newChat{ id="welcome",
	text = [[#LIGHT_GREEN#*A dwarf in stained, battered mail armor opens the door.*#WHITE#
Say, you interested in dismembering stuff and getting paid?]],
	answers = {
		{"Always.", jump="ominous"},
		{"[leave]"},
	}
}

newChat{ id="ominous",
	text = [[By the corpses of the gods, I love adventurers. Was about to become one myself when it suddenly hit me. And by "it" I mean "my wife." Har!]],
	answers = {
		{"What do you propose?", jump="proposal"},
	}
}

newChat{ id="proposal",
	text = [[I propose that I give you a list of monster parts to fetch, then you go and fetch them, then I make some blindingly amazing brews with said monster parts, then I get accepted into the Brotherhood of Alchemists.]],
	answers = {
		{"Sounds like a plan.", jump="help"},
	}
}

newChat{ id="help",
	text = [[I make excellent plans. And brews, which the Brotherhood will no doubt make me call 'elixirs' once I'm in. And I'll obey, because they have ways of getting what they want. Now, where were we?]],
	answers = {
		{"Aiding you with getting into some Brotherhood. What's in it for me?", jump="competition"},
	}
}

newChat{ id="competition",
	text = [[Oh, easy. You get a swig of each brew, of course. They'll put hair on your chest, and possibly your eyelids and fingernails. And, if your aid proves the deciding factor, then I've got a real treat for you: perhaps the last Taint of Telepathy left in Maj'Eyal.]],
	answers = {
		{"I accept.", jump="choice", action = function(npc, player) player:grantQuest("brotherhood-of-alchemists") end,},
		{"I cannot aid you at this time."},
	}
}

newChat{ id="choice",
	text = [[One last thing. There's a few other fellows angling for the same slot in the Brotherhood that I am. They're not going to be sitting on their hands while we're at work here, so best move quick-like. Now, which of these do you want to help me with first: the Brew of Brawn, the Brew of Stoneskin, or the Brew of Foundations? Or Elixirs, rather. Not Brews. Best get in the habit now, I suppose.]],
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

if npc.errand_given then
newChat{ id="list",
	text = [[Right, here's the list. Oh, one more thing. Got me some fellas already out hunting for this stuff, and I'll not play favorites. One of them brings me those ingredients before you do, and you're out of luck. Hurry back.]],
	answers = {
		{"I'll be off."},
	}
}
else
newChat{ id="list",
	text = [[Right, here's the list. Oh, one more thing. Got me some fellas already out hunting for this stuff, and I'll not play favorites. One of them brings me those ingredients before you do, and you're out of luck. Hurry back.

Oh, and one other last thing... if you have the time for another errand, though I've got no reward on this one.]],
	answers = {
		{"Well, I'll see if I can help.", jump="errand", action=function(npc, player) npc.errand_given = true end},
		{"I'm here for profit, not errands - I have the list and will work on it; sort your own sidejobs out.", action=function(npc, player) npc.errand_given = true end},
	}
}
end

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
	text = [[#LIGHT_GREEN#*The mailed dwarf opens his door.*#WHITE#
Aha, my favorite adventurer.]],
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
	text = [[#LIGHT_GREEN#*He gleefully claps you on the shoulder.*#WHITE#
Ha ha! This is the last one! Stire and Marus and that damned hermit can suck on my beard! And so can my wife! YES, I KNOW YOU CAN HEAR ME. Good work, friend. Let's have them.]],
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
	text = [[Give me an hour or so to make with the alchemy. Don't go anywhere.]],
	answers = {
		{"[Wait]", jump="complete3"},

	}
}

--Final Elixir:
newChat{ id="totally-complete2",
	text = [[I'd invite you inside while you wait, but the she-dwarf's in there, and I've grown fond of you.]],
	answers = {
		{"[Wait]", jump="totally-complete3"},

	}
}

--Not final elixir:
newChat{ id="complete3",
	text = [[#LIGHT_GREEN#*The dwarf finally returns with a vial.*#WHITE#
Tastes like Urh'Rok's own piss, but it gets the job done.]],
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
	text = [[#LIGHT_GREEN#*The dwarf finally returns with a vial and a small pouch.*#WHITE#
I put a bit of the good stuff in this one, though it won't do you any favors tomorrow morning. And careful with that Taint of Telepathy, especially if the wife answers the door the next time you knock. Har!]],
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
	text = [[Bless you adventurers. Which will it be?]],
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

if npc.errand_given then
newChat{ id="list",
	text = [[Here's a list of the creature bits I need. Good luck with the murdering!]],
	answers = {
		{"I'll be off."},
	}
}
else
newChat{ id="list",
	text = [[Here's a list of the creature bits I need. Good luck with the murdering!

Oh, and one other last thing... if you have the time for another errand, though I've got no reward on this one.]],
	answers = {
		{"Well, I'll see if I can help.", jump="errand", action=function(npc, player) npc.errand_given = true end},
		{"I'm here for profit, not errands - I have the list and will work on it; sort your own sidejobs out.", action=function(npc, player) npc.errand_given = true end},
	}
}
end

-- If the elixir got made while you were out:
newChat{ id="poached",
	text = [[Er, it seems that while you were out, somebody else managed to bring me the ingredients. I've got no reward for you! Sorry about that, but when time is of the essence, 'first come, first served' is the only sensible policy.]],
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

newChat{ id="errand",
	text = [[Well, it's like this, one of my wife's friends has gone missing. A young alchemist in training, called Celia. Thing is, her husband died recently, and the grief done drove her mad. She used to go out to his grave every day, until one day she didn't come back. Personally I don't think she was able to live without him; the two were inseparable. If you get a chance on your travels, could you pass by the mausoleum to the east and check... well, you get the idea.

It's strange what death can do to people, how it can take over their minds. Sometimes they forget it's the living that matter... See she gets a proper burial - treated respectfully, eh?]],
	answers = {
		{"I'll do what I can.", action=function(npc, player)
			game:onLevelLoad("wilderness-1", function(zone, level)
				local g = game.zone:makeEntityByName(level, "terrain", "LAST_HOPE_GRAVEYARD")
				local spot = level:pickSpot{type="zone-pop", subtype="last-hope-graveyard"}
				game.zone:addEntity(level, g, "terrain", spot.x, spot.y)
				game.nicer_tiles:updateAround(game.level, spot.x, spot.y)
				game.state:locationRevealAround(spot.x, spot.y)
			end)
			game.log("He points out the location of the graveyard on your map.")
			player:grantQuest("grave-necromancer")
		end},
	}
}

return "welcome"
