hook.Add("AddToolMenuCategories", "GMBloxCategories", function()
	spawnmenu.AddToolCategory("Options", "GMBlox", "GMBlox")
end)

hook.Add("PopulateToolMenu", "GMBloxPopulate", function()
	spawnmenu.AddToolMenuOption("Options", "GMBlox", "GMBlox_Config", "GMBlox options", "", "", function(dform)
		dform:ClearControls()
		dform:CheckBox("Draw Scoreboard", "gmblox_drawscoreboard")

		dform:Help("GMBlox, by lokachop")
	end)
end)

CreateClientConVar("gmblox_drawscoreboard", 1, true, false, "Toggles rendering the scoreboard while on a GMBlox character", 0, 1)