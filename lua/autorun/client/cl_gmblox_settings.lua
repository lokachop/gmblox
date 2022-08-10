if CLIENT then
	CreateClientConVar("gmblox_drawscoreboard", 1, true, false, "Toggles rendering the scoreboard while on a GMBlox character", 0, 1)
	CreateClientConVar("gmblox_gibondeath", 0, true, false, "Toggles seeing people gib upon dying or not", 0, 1)
	CreateClientConVar("gmblox_animwait", 33, true, false, "Animation wait time in milliseconds, lower can make anims less laggy at cost of performance", 0, 500)
	CreateClientConVar("gmblox_defaultloadout", "none", true, false, "Default loadout to have selected")
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
		dform:CheckBox("Gib upon death", "gmblox_gibondeath")
		local formc = dform:NumSlider("Animation Wait (ms)", "gmblox_animwait", 0, 500, 0)
		formc:SetValue(GetConVar("gmblox_animwait"):GetFloat())


		local combo = dform:ComboBox("Default loadout", "gmblox_defaultloadout")
		combo:SetValue("none")

		for k, v in pairs(file.Find("gmblox/gearpresets/*.txt", "DATA")) do
			local nameNoExt = string.sub(v, 1, -5)

			combo:AddChoice(nameNoExt)
		end
		combo:AddChoice("none")

		dform:Help("GMBlox, by Lokachop")
	end)


	spawnmenu.AddToolMenuOption("Options", "GMBlox", "GMBlox_ConfigServer", "GMBlox server options", "", "", function(dform)
		dform:ClearControls()
		dform:Help("Allowed gear list")
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

		dform:Help("GMBlox, by Lokachop")
	end)
end)
