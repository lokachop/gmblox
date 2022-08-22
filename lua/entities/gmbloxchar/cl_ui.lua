
function ENT:ReBuildGearButtons()
	if not GMBlox then
		return
	end

	self.ActiveButtons = {}

	local gearCount = #self.Inventory


	local center = ScrW() / 2
	local y = (ScrH() - 64) - (18 * 2)


	local gearNum = 0
	for k, v in pairs(self.Inventory) do
		local gearData = GMBlox.ValidGears[v]
		if not gearData then
			continue
		end

		gearNum = gearNum + 1
		local gNCopy = gearNum

		local button = vgui.Create("DButton")
		button:SetText("")
		button:SetSize(64, 64)
		button:SetPos(center - (64 * (gearCount / 2)) + (64 * (k - 1)), y)

		local c_mat = Material(gearData.icon, "nocull ignorez alphatest")
		local e_self = self
		function button:Paint(w, h)
			surface.SetDrawColor(64, 64, 64, 255)

			if v == e_self:GetActiveGear() then
				surface.SetDrawColor(255, 0, 0, 255)
			end
			surface.DrawRect(0, 0, w, h)

			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(2, 2, w - 4, h - 4)

			surface.SetDrawColor(255, 255, 255)
			surface.SetMaterial(c_mat)
			surface.DrawTexturedRect(0, 0, w, h)

			draw.SimpleText(gNCopy, "DermaLarge", 0, 0, Color(255, 255, 255), TEXT_ALIGN_TOP, TEXT_ALIGN_LEFT)
		end

		function button:DoClick()
			e_self:EquipGear(v)
			e_self:RebuildActiveGear()
		end


		self.NoClickZones[#self.NoClickZones + 1] = {
			x = center - (64 * (gearCount / 2)) + (64 * (k - 1)),
			y = y,
			w = 64,
			h = 64
		}
		self.ActiveButtons[v] = button
	end
end



local f_icon = Material("gmblox/vgui/PlayerlistFriendIcon.png", "nocull ignorez smooth mips")
function ENT:RenderScoreboard()
	if not GetConVar("gmblox_drawscoreboard") then
		return
	end

	if not GetConVar("gmblox_drawscoreboard"):GetBool() then
		return
	end


	surface.SetDrawColor(0, 0, 0, 128)

	local sw = 384
	local sh = 32
	surface.DrawRect(ScrW() - sw * 1.05, sh * 0.95, sw, sh)

	draw.SimpleText("Kills", "DermaLarge", ScrW() - sw * .4, sh * .95, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText("Deaths", "DermaLarge", ScrW() - sw * .1, sh * .95, Color(255, 255, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

	local curr_y = sh + sh * 0.95
	for k, v in pairs(team.GetAllTeams()) do
		surface.SetDrawColor(v.Color.r, v.Color.g, v.Color.b, 96)
		surface.DrawRect(ScrW() - sw * 1.05, curr_y, sw, 24)

		local bar_y = curr_y
		draw.SimpleText(v.Name, "GMBlox_Trebuchet18", ScrW() - sw * 1.05, curr_y + 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		curr_y = curr_y + 24

		local plys = team.GetPlayers(k)
		local hasPly = false
		local teamFrags = 0
		local teamDeaths = 0
		for k2, v2 in pairs(plys) do
			local grmod = k2 % 2 == 0 and 96 or 0
			surface.SetDrawColor(grmod, grmod, grmod, 128)
			surface.DrawRect(ScrW() - sw * 1.05, curr_y, sw, 24)

			local off_add = 0
			local friendStatus = v2:GetFriendStatus()
			if friendStatus == "friend" then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(f_icon)

				surface.DrawTexturedRect(ScrW() - sw * 1.05, curr_y, 24, 24)
				off_add = 24
			end

			draw.SimpleText(v2:GetName(), "GMBlox_Trebuchet18", (ScrW() - sw * 1.05) + off_add, curr_y + 2, Color(v.Color.r, v.Color.g, v.Color.b), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

			local kills = v2:Frags()
			teamFrags = teamFrags + kills
			draw.SimpleText(kills, "GMBlox_Trebuchet18", ScrW() - sw * .475, curr_y + 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

			local deaths = v2:Deaths()
			teamDeaths = teamDeaths + deaths
			draw.SimpleText(deaths, "GMBlox_Trebuchet18", ScrW() - sw * .2, curr_y + 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)


			hasPly = true
			curr_y = curr_y + 24
		end


		draw.SimpleText(teamFrags, "GMBlox_Trebuchet18Bold", ScrW() - sw * .475, bar_y + 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(teamDeaths, "GMBlox_Trebuchet18Bold", ScrW() - sw * .2, bar_y + 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		if not hasPly then
			surface.SetDrawColor(0, 0, 0, 128)
			surface.DrawRect(ScrW() - sw * 1.05, curr_y, sw, 24)
			curr_y = curr_y + 24
		end
	end
end
