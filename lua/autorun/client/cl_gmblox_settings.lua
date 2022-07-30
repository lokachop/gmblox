if CLIENT then
	CreateClientConVar("gmblox_drawscoreboard", 1, true, false, "Toggles rendering the scoreboard while on a GMBlox character", 0, 1)
end

GMBlox = GMBlox or {}
GMBlox.CheckList = GMBlox.CheckList or {}

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
			local cb = vgui.Create("DCheckBoxLabel")
			cb:SetText(v.name)
			cb:SetTextColor(Color(0, 0, 0))
			cb:SetValue(GMBlox.IsAllowedLUT[v.name])

			GMBlox.CheckList[v.name] = cb

			function cb:OnChange(val)
				if not LocalPlayer():IsSuperAdmin() then
					self:SetChecked(GMBlox.IsAllowedLUT[v.name])
					return
				end

				net.Start("gmblox_change_is_allowed")
					net.WriteString(v.name)
					net.WriteBool(tobool(val))
				net.SendToServer()
			end

			dform:AddItem(cb)
		end

		dform:Help("GMBlox, by lokachop")
	end)
end)
