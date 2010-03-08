-- Quest for Trollshaws & Amon Sul
name = "Of trolls and damp caves"
desc = function(self, who)
	local desc = {}
	desc[#desc+1] = "Explore the caves below the tower of Amon Sûl and the trollshaws in search of treasure and glory!\n"
	if self:isCompleted("amon-sul") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored Amon Sûl and vanquished the Shade of Angmar.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore Amon Sûl and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	if self:isCompleted("trollshaws") then
		desc[#desc+1] = "#LIGHT_GREEN#* You have explored the Trollshaws and vanquished the Bill the Stone Troll.#WHITE#"
	else
		desc[#desc+1] = "#SLATE#* You must explore the Trollshaws and find out what lurks there and what treasures are to be gained!#WHITE#"
	end
	return table.concat(desc, "\n")
end

on_status_change = function(self, who, status, sub)
	if sub then
		if self:isCompleted("amon-sul") and self:isCompleted("trollshaws") then
			who:setQuestStatus(self.id, engine.Quest.DONE)
			who:grantQuest("starter-zones")
		end
	end
end
