hook.Add("AddToolMenuCategories", "GMBloxCategories", function()
	spawnmenu.AddToolCategory("Options", "GMBlox", "GMBlox")
end)

hook.Add("PopulateToolMenu", "GMBloxPopulate", function()
	spawnmenu.AddToolMenuOption("Options", "GMBlox", "GMBlox_Config", "GMBlox options", "", "", function(dform)
		dform:ClearControls()
		dform:CheckBox("Draw Scoreboard", "gmblox_drawscoreboard")

		dform:Help("GMBlox, by lokachop")
	end)


	spawnmenu.AddToolMenuOption("Options", "GMBlox", "GMBlox_ConfigServer", "GMBlox server options", "", "", function(dform)
		dform:ClearControls()
		dform:Help("Default gear list")
		for k, v in pairs(GMBlox.ValidGears) do
			local check = dform:CheckBox(v.name, "gmblox_gear_" .. v.name .. "_is_default")

			function check:OnChange()
				net.Start("gmblox_convarchanged_isdefault")
				net.SendToServer()
			end
		end

		dform:Help("GMBlox, by lokachop")
	end)
end)

if CLIENT then
	CreateClientConVar("gmblox_drawscoreboard", 1, true, false, "Toggles rendering the scoreboard while on a GMBlox character", 0, 1)
end

for k, v in pairs(GMBlox.ValidGears) do
	CreateConVar("gmblox_gear_" .. v.name .. "_is_default", 1, bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED), "Toggles whether or not the " .. v.name .. " gear is given on spawn", 0, 1)
end