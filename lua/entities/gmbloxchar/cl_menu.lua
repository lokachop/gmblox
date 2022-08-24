local function col2num(r, g, b)
	return r + bit.lshift(g, 8) + bit.lshift(b, 16)
end

local uvPartLUT = {
	["torso"] = {
		x = 231,
		y = 74,
		w = 128,
		h = 128
	},
	["leftarm"] = {
		x = 217,
		y = 355,
		w = 64,
		h = 128
	},
	["rightarm"] = {
		x = 308,
		y = 355,
		w = 64,
		h = 128
	},
	["leftleg"] = {
		x = 217,
		y = 355,
		w = 64,
		h = 128
	},
	["rightleg"] = {
		x = 308,
		y = 355,
		w = 64,
		h = 128
	}
}

local applyLUTShirt = {
	["torso"] = true,
	["leftarm"] = true,
	["rightarm"] = true,
}

local applyLUTPants = {
	["torso"] = true,
	["leftleg"] = true,
	["rightleg"] = true,
}

function ENT:BodyPartButton(x, y, w, h, cref, colmixer)
	local buttonpart = vgui.Create("DButton", self.customizeMenu)
	buttonpart:SetPos(x, y)
	buttonpart:SetSize(w, h)
	buttonpart:SetText("")

	local e_ref = self
	function buttonpart:Paint(w2, h2)
		local opt = e_ref.colEditTarget == cref.name and 0 or 255
		surface.SetDrawColor(255, opt, opt)
		surface.DrawRect(0, 0, w2, h2)

		surface.SetDrawColor(cref.col.r, cref.col.g, cref.col.b)
		surface.DrawRect(2, 2, w2 - 4, h2 - 4)


		if cref.name == "head" then
			if not self.matFaces then
				self.matFaces = {}
			end

			if not self.matFaces[e_ref.ActiveFace] then
				self.matFaces[e_ref.ActiveFace] = Material(e_ref.Faces[e_ref.ActiveFace], "nocull ignorez")
			end
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.matFaces[e_ref.ActiveFace])
			surface.DrawTexturedRect(2, 2, w2 - 4, h2 - 4)
			return
		end

		if applyLUTPants[cref.name] then
			local uvDat = uvPartLUT[cref.name]
			if not uvDat then
				return
			end

			if e_ref.ActivePants ~= "none" and GMBlox.ValidPants[e_ref.ActivePants] ~= nil then
				local mat = Material(GMBlox.ValidPants[e_ref.ActivePants], "ignorez nocull smooth")
				local szRatW = mat:Width() / 585
				local szRatH = mat:Height() / 559

				local u0 = (uvDat.x * szRatW) / (585 * szRatW)
				local v0 = (uvDat.y * szRatH) / (559 * szRatH)

				local u1 = ((uvDat.x + uvDat.w) * szRatW) / (585 * szRatW)
				local v1 = ((uvDat.y + uvDat.h) * szRatH) / (559 * szRatH)

				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(mat)
				surface.DrawTexturedRectUV(2, 2, w2 - 4, h2 - 4, u0, v0, u1, v1)
			end
		end

		if applyLUTShirt[cref.name] then
			local uvDat = uvPartLUT[cref.name]
			if not uvDat then
				return
			end

			if e_ref.ActiveShirt ~= "none" and GMBlox.ValidShirts[e_ref.ActiveShirt] ~= nil then
				local mat = Material(GMBlox.ValidShirts[e_ref.ActiveShirt], "ignorez nocull smooth")
				local szRatW = mat:Width() / 585
				local szRatH = mat:Height() / 559

				local u0 = (uvDat.x * szRatW) / (585 * szRatW)
				local v0 = (uvDat.y * szRatH) / (559 * szRatH)

				local u1 = ((uvDat.x + uvDat.w) * szRatW) / (585 * szRatW)
				local v1 = ((uvDat.y + uvDat.h) * szRatH) / (559 * szRatH)

				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(mat)
				surface.DrawTexturedRectUV(2, 2, w2 - 4, h2 - 4, u0, v0, u1, v1)
			end
		end


		if cref.name == "torso" then
			if e_ref.ActiveTShirt == "none" then
				return
			end

			if GMBlox.ValidTShirts[e_ref.ActiveTShirt] == nil then
				return
			end
			local mat = Material(GMBlox.ValidTShirts[e_ref.ActiveTShirt], "ignorez nocull smooth")
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(2, 2, w2 - 4, h2 - 4)
		end
	end


	function buttonpart:DoClick()
		e_ref.colEditTarget = cref.name
		colmixer:SetColor(cref.col)
	end
end

function ENT:MakeComboSelect(x, y, var, choices)
	local cSelect = vgui.Create("DComboBox", self.customizeMenu)
	cSelect:SetPos(x, y)
	cSelect:SetSize(150, 20)
	cSelect:SetValue(self[var])

	for k, v in pairs(choices) do
		cSelect:AddChoice(k)
	end

	local e_ref = self
	function cSelect:OnSelect(index, value, data)
		if not IsValid(e_ref) then
			return
		end
		e_ref[var] = value
	end
	return cSelect
end




function ENT:MakeCustomizeMenu()
	if IsValid(self.customizeMenu) then
		return
	end
	local e_ref = self

	self.customizeMenu = vgui.Create("DFrame")
	self.customizeMenu:SetSize(900, 600)
	self.customizeMenu:Center()
	self.customizeMenu:SetTitle("GMBlox Customization")
	self.customizeMenu:SetDraggable(false)
	self.customizeMenu:MakePopup()

	self.colEditTarget = "head"

	self.NoClickZones["cusmenu"] = {
		x = self.customizeMenu:GetX(),
		y = self.customizeMenu:GetY(),
		w = self.customizeMenu:GetWide(),
		h = self.customizeMenu:GetTall(),
	}


	local colMixer = vgui.Create("DColorMixer", self.customizeMenu)
	colMixer:SetPos(900 - 400, 600 / 2 - 150)
	colMixer:SetSize(400, 300)
	colMixer:SetColor(e_ref.RenderObjects[e_ref.colEditTarget].col)

	function colMixer:ValueChanged(newcol)
		if not IsValid(e_ref) then
			return
		end
		if not e_ref.colEditTarget then
			return
		end

		if not e_ref.RenderObjects[e_ref.colEditTarget] then
			return
		end

		e_ref.RenderObjects[e_ref.colEditTarget].col = Color(newcol.r, newcol.g, newcol.b)
	end

	local offx = 50
	local offy = 0
	self:BodyPartButton(offx + 100, offy + 50, 100, 100, self.RenderObjects["head"], colMixer)
	self:BodyPartButton(offx + 75, offy + 150, 150, 200, self.RenderObjects["torso"], colMixer)

	self:BodyPartButton(offx + 0, offy + 150, 75, 200, self.RenderObjects["leftarm"], colMixer)
	self:BodyPartButton(offx + 75 + 150, offy + 150, 75, 200, self.RenderObjects["rightarm"], colMixer)

	self:BodyPartButton(offx + 75, offy + 350, 75, 200, self.RenderObjects["leftleg"], colMixer)
	self:BodyPartButton(offx + 75 + 75, offy + 350, 75, 200, self.RenderObjects["rightleg"], colMixer)





	self:MakeComboSelect(offx + 200, offy + 100 - 10, "ActiveFace", GMBlox.ValidFaces)
	local ctemp = self:MakeComboSelect(offx + 200, offy + 120 - 10, "ActiveHat", GMBlox.ValidHats)
	ctemp:AddChoice("None")

	ctemp = self:MakeComboSelect(offx + 300, offy + 220 - 10, "ActiveShirt", GMBlox.ValidShirts)
	ctemp:AddChoice("none")

	ctemp = self:MakeComboSelect(offx + 300, offy + 240 - 10, "ActiveTShirt", GMBlox.ValidTShirts)
	ctemp:AddChoice("none")

	ctemp = self:MakeComboSelect(offx + 300, offy + 260 - 10, "ActivePants", GMBlox.ValidPants)
	ctemp:AddChoice("none")



	function self.customizeMenu:OnClose()
		if not IsValid(e_ref) then
			return
		end

		local chead = e_ref.RenderObjects["head"].col
		local ctorso = e_ref.RenderObjects["torso"].col

		local cleftarm = e_ref.RenderObjects["leftarm"].col
		local crightarm = e_ref.RenderObjects["rightarm"].col

		local cleftleg = e_ref.RenderObjects["leftleg"].col
		local crightleg = e_ref.RenderObjects["rightleg"].col

		local coltbl = {
			head = col2num(chead.r, chead.g, chead.b),
			torso = col2num(ctorso.r, ctorso.g, ctorso.b),

			leftarm = col2num(cleftarm.r, cleftarm.g, cleftarm.b),
			rightarm = col2num(crightarm.r, crightarm.g, crightarm.b),

			leftleg = col2num(cleftleg.r, cleftleg.g, cleftleg.b),
			rightleg = col2num(crightleg.r, crightleg.g, crightleg.b),
		}

		local proptbl = {
			hat = e_ref.ActiveHat,
			face = e_ref.ActiveFace,
			shirt = e_ref.ActiveShirt,
			pants = e_ref.ActivePants,
			tshirt = e_ref.ActiveTShirt
		}

		cookie.Set("gmblox_col", util.TableToJSON(coltbl))
		cookie.Set("gmblox_prop", util.TableToJSON(proptbl))
		e_ref:SendSavedAppearance()

		e_ref.NoClickZones["cusmenu"] = nil
	end
end

local crCount = 0
local function makeCreditAndReason(parent, name, reason, link)
	crCount = crCount + 1

	local panelBase = vgui.Create(link and "DButton" or "DPanel", parent)

	panelBase.bcol = crCount % 2 == 0 and Color(148, 148, 148) or Color(128, 128, 128)
	panelBase.hcol = crCount % 2 == 0 and Color(148, 148, 188) or Color(128, 128, 168)

	function panelBase:Paint(w, h)
		local ccalc = (self.hovered or false) and self.hcol or self.bcol

		surface.SetDrawColor(ccalc)
		surface.DrawRect(0, 0, w, h)
	end
	panelBase:Dock(TOP)

	if link then
		panelBase:SetText("")
		function panelBase:DoClick()
			gui.OpenURL(link)
		end

		function panelBase:OnCursorEntered()
			self.hovered = true
			self:SetCursor("hand")
		end

		function panelBase:OnCursorExited()
			self.hovered = false
			self:SetCursor("arrow")
		end
	end

	local dm = 4
	local textName = vgui.Create("DLabel", panelBase)
	textName:SetText(name)
	textName:SetTextColor(Color(255, 255, 255))
	textName:SizeToContents()
	textName:DockMargin(dm, 0, dm, 0)
	textName:Dock(LEFT)

	local textReason = vgui.Create("DLabel", panelBase)
	textReason:SetText(reason)
	textReason:SetTextColor(Color(255, 255, 255))
	textReason:SizeToContents()
	textReason:DockMargin(dm, 0, dm, 0)
	textReason:Dock(RIGHT)

	return panelBase
end


function ENT:MakeCreditsMenu()
	if IsValid(self.creditsMenu) then
		return
	end

	self.creditsMenu = vgui.Create("DFrame")
	self.creditsMenu:SetSize(800 * .35, 600 * .5)
	self.creditsMenu:Center()
	self.creditsMenu:SetTitle("GMBlox Credits")
	self.creditsMenu:SetDraggable(false)
	self.creditsMenu:MakePopup()

	self.NoClickZones["credits"] = {
		x = self.creditsMenu:GetX(),
		y = self.creditsMenu:GetY(),
		w = self.creditsMenu:GetWide(),
		h = self.creditsMenu:GetTall(),
	}

	makeCreditAndReason(self.creditsMenu, "opiper", "Bugtesting, awesome friend", "https://steamcommunity.com/profiles/76561198885421847/")
	makeCreditAndReason(self.creditsMenu, "sweepy", "Bugtesting, awesome friend", "https://steamcommunity.com/profiles/76561198277636412")
	makeCreditAndReason(self.creditsMenu, "Swedish Swede", "Bugtesting, awesome friend", "https://steamcommunity.com/profiles/76561198260232820")
	makeCreditAndReason(self.creditsMenu, "Lord_Arcness", "Bugtesting, awesome friend", "https://steamcommunity.com/profiles/76561198118355002")
	makeCreditAndReason(self.creditsMenu, "MISTER BONES", "Bugtesting, awesome friend", "https://steamcommunity.com/profiles/76561198056452663")
	makeCreditAndReason(self.creditsMenu, "Hybird", "Help with sounds, textures, gears and fixes", "https://steamcommunity.com/profiles/76561199160976480")
	makeCreditAndReason(self.creditsMenu, "ToxicOrSomething", "Bugtesting, models and textures", "https://steamcommunity.com/profiles/76561198048575789")
	makeCreditAndReason(self.creditsMenu, "ROBLOX", "Original Game", "https://www.roblox.com/")
	makeCreditAndReason(self.creditsMenu, "GMPublisher", "Used for publishing to the workshop", "https://github.com/WilliamVenner/gmpublisher")
	makeCreditAndReason(self.creditsMenu, "Rbx2Source", "Used to convert roblox assets to source", "https://github.com/MaximumADHD/Rbx2Source")

	--https://steamcommunity.com/id/you_suck_balls/

	-- and most importantly
	makeCreditAndReason(self.creditsMenu, LocalPlayer():GetName(), "Downloading and using the addon", "https://steamcommunity.com/profiles/" .. LocalPlayer():SteamID64())


	local e_ref = self
	function self.creditsMenu:OnClose()
		e_ref.NoClickZones["credits"] = nil
	end

end

function ENT:MakeMenu()
	if IsValid(self.frameMenu) then
		return
	end

	local e_ref = self

	self.frameMenu = vgui.Create("DFrame")
	self.frameMenu:SetSize(800 * .25, 600 * .5)
	self.frameMenu:Center()
	self.frameMenu:SetTitle("GMBlox")
	self.frameMenu:MakePopup()
	self.frameMenu:SetDraggable(false)

	self.NoClickZones["menu"] = {
		x = self.frameMenu:GetX(),
		y = self.frameMenu:GetY(),
		w = self.frameMenu:GetWide(),
		h = self.frameMenu:GetTall(),
	}

	local dm = 12
	local exitButton = vgui.Create("DButton", self.frameMenu)
	exitButton:SetText("Exit")
	exitButton:DockMargin(dm, dm, dm, dm)
	exitButton:Dock(BOTTOM)
	exitButton:SetTall(64)

	function exitButton:DoClick()
		e_ref.frameMenu:Close()
		net.Start("gmblox_exit")
			net.WriteEntity(e_ref)
		net.SendToServer()
	end

	local customizeButton = vgui.Create("DButton", self.frameMenu)
	customizeButton:SetText("Customize")
	customizeButton:DockMargin(dm, dm, dm, dm)
	customizeButton:Dock(BOTTOM)
	customizeButton:SetTall(64)

	function customizeButton:DoClick()
		e_ref.frameMenu:Close()
		e_ref:MakeCustomizeMenu()
	end


	local creditsButton = vgui.Create("DButton", self.frameMenu)
	creditsButton:SetText("Credits")
	creditsButton:DockMargin(dm, dm, dm, dm)
	creditsButton:Dock(BOTTOM)
	creditsButton:SetTall(64)

	function creditsButton:DoClick()
		e_ref.frameMenu:Close()
		e_ref:MakeCreditsMenu()
	end


	function self.frameMenu:OnClose()
		e_ref.NoClickZones["menu"] = nil
	end
end

function ENT:MakeMenuButton()
	local buttonMn = vgui.Create("DButton")
	self.ActiveButtons["menu"] = buttonMn
	buttonMn:SetSize(60, 51)
	buttonMn:SetPos(0, ScrH() - 51)
	buttonMn:SetText("")
	buttonMn.hovered = false

	self.NoClickZones["menubtton"] = {
		x = buttonMn:GetX(),
		y = buttonMn:GetY(),
		w = buttonMn:GetWide(),
		h = buttonMn:GetTall(),
	}


	local t_buttonMn = Material("gmblox/vgui/SettingsButton.png", "nocull ignorez")
	local t_buttonMn_h = Material("gmblox/vgui/SettingsButton_dn.png", "nocull ignorez")
	function buttonMn:Paint(w, h)
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(buttonMn.hovered and t_buttonMn_h or t_buttonMn)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	function buttonMn:OnCursorEntered()
		self.hovered = true
	end

	function buttonMn:OnCursorExited()
		self.hovered = false
	end

	local e_ref = self
	function buttonMn:DoClick()
		if not IsValid(e_ref) then
			return
		end
		e_ref:MakeMenu()
	end
end
