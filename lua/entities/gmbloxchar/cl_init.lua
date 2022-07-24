include("shared.lua")

local function col2num(r, g, b)
	return r + bit.lshift(g, 8) + bit.lshift(b, 16)
end

local function num2col(num)
	return Color(bit.band(num, 0xFF), bit.band(bit.rshift(num, 8), 0xFF), bit.band(bit.rshift(num, 16), 0xFF))
end

net.Receive("gmblox_changecolour_sv",  function()
	local target = net.ReadEntity()

	local colhead = num2col(net.ReadUInt(24))
	local colbody = num2col(net.ReadUInt(24))

	local coleftarm = num2col(net.ReadUInt(24))
	local colrightarm = num2col(net.ReadUInt(24))

	local colleftleg = num2col(net.ReadUInt(24))
	local colrightleg = num2col(net.ReadUInt(24))

	local ro = target.RenderObjects

	ro["head"].col = colhead
	ro["torso"].col = colbody

	ro["leftleg"].col = colleftleg
	ro["rightleg"].col = colrightleg

	ro["leftarm"].col = coleftarm
	ro["rightarm"].col = colrightarm

	target:BuildCSModels()
end)


function ENT:RemoveCSModels()
	for k, v in pairs(self.CSModels) do
		v:Remove()
	end

	if IsValid(self.GearCSModel) then
		self.GearCSModel:Remove()
	end
end

function ENT:OffsetAndParentCSModel(csent, pos, ang)
	local right = self:GetRight()
	local up = self:GetUp()
	local forward = self:GetForward()

	local calcposoff = (forward * pos.x) + (right * pos.y) + (up * pos.z)

	local calcangoff = self:GetAngles()
	calcangoff:RotateAroundAxis(right, ang.p)
	calcangoff:RotateAroundAxis(up, ang.y)
	calcangoff:RotateAroundAxis(forward, ang.r)

	csent:SetPos(self:GetPos() + calcposoff)
	csent:SetAngles(calcangoff)

	csent:SetParent(self)
end

function ENT:BuildCSModels()
	self:RemoveCSModels()
	for k, v in pairs(self.RenderObjects) do
		self.CSModels[k] = ClientsideModel(v.model, RENDERGROUP_OPAQUE)
		self.CSModels[k]:SetMaterial(v.mat)
		if v.col then
			self.CSModels[k]:SetColor(v.col)
		end

		self.TargetPitches[k] = {ang = v.ang.p, speed = 128}
		self.CurrentPitches[k] = v.ang.p

		self:OffsetAndParentCSModel(self.CSModels[k], v.pos, v.ang)
	end
end

function ENT:SendSavedColour()
	local scolstr = cookie.GetString("gmblox_col")

	if not scolstr then
		return
	end

	local coltbl = util.JSONToTable(scolstr)
	if not coltbl then
		return
	end

	local colhead = coltbl.head
	local coltorso = coltbl.torso
	local coleftarm = coltbl.leftarm
	local colrightarm = coltbl.rightarm
	local colleftleg = coltbl.leftleg
	local colrightleg = coltbl.rightleg

	if not colhead or not coltorso or not coleftarm or not colrightarm or not colleftleg or not colrightleg then
		return
	end

	net.Start("gmblox_changecolour")
		net.WriteEntity(self)
		net.WriteUInt(colhead, 24)
		net.WriteUInt(coltorso, 24)
		net.WriteUInt(coleftarm, 24)
		net.WriteUInt(colrightarm, 24)
		net.WriteUInt(colleftleg, 24)
		net.WriteUInt(colrightleg, 24)
	net.SendToServer()
end


function ENT:Initialize()
	self.CSModels = {}
	self.TargetPitches = {}
	self.CurrentPitches = {}


	-- i use materials because colours break for some reason
	self.RenderObjects = {
		["head"] = {
			pos = Vector(-17.5, 0, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/head.mdl",
			mat = "gmblox/face_background",
			col = Color(255, 255, 0),
			name = "head"
		},
		["torso"] = {
			pos = Vector(0, 0, 0),
			ang = Angle(0, 0, 90),
			model = "models/gmblox/torso.mdl",
			mat = "gmblox/robloxwhite",
			col = HSVToColor(self:GetRandomColour(), 0.5, 1),
			name = "torso"
		},

		["leftarm"] = {
			pos = Vector(-6, -18, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limbarm.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(255, 255, 0),
			name = "leftarm"
		},
		["rightarm"] = {
			pos = Vector(-6, 18, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limbarm.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(255, 255, 0),
			name = "rightarm"
		},

		["leftleg"] = {
			pos = Vector(12, 6, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limb.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(75, 220, 75),
			name = "leftleg"
		},
		["rightleg"] = {
			pos = Vector(12, -6, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limb.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(75, 220, 75),
			name = "rightleg"
		},
	}


	self:BuildCSModels()

	self.AnimLUT = {}
	self.AnimLUT["leftarm"] = function(ent, k)
		if ent:GetActiveGear() ~= "" then
			return -180, 512
		end

		if not ent:GetGrounded() then
			return -270, 1024
		end
		local evel = ent:GetVelocity()
		local speed = evel:Length()

		if speed > 20 then
			return math.floor(RealTime() * 3) % 2 == 0 and (-90 - -45) or (-90 + -45), 256
		end
		return -90 - math.floor(math.sin(RealTime() * 1) * 4), 64
	end

	self.AnimLUT["rightarm"] = function(ent, k)
		if not ent:GetGrounded() then
			return -270, 1024
		end

		local evel = ent:GetVelocity()
		local speed = evel:Length()

		if speed > 20 then
			return math.floor(RealTime() * 3) % 2 == 0 and (-90 + -45) or (-90 - -45), 256
		end

		return -90 + math.floor(math.sin(RealTime() * 1) * 4), 64
	end

	self.AnimLUT["leftleg"] = function(ent, k)
		local evel = ent:GetVelocity()
		local speed = evel:Length()
		if ent:GetGrounded() then
			if speed > 20 then
				return math.floor(RealTime() * 3) % 2 == 0 and (-90 - -45) or (-90 + -45), 256
			end

			return -90 - math.floor(math.sin(RealTime() * 1) * 4), 64
		end

		return -90, 64
	end

	self.AnimLUT["rightleg"] = function(ent, k)
		local evel = ent:GetVelocity()
		local speed = evel:Length()
		if ent:GetGrounded() then
			if speed > 20 then
				return math.floor(RealTime() * 3) % 2 == 0 and (-90 + -45) or (-90 - -45), 256
			end

			return -90 + math.floor(math.sin(RealTime() * 1) * 4), 64
		end

		return -90, 64
	end



	self.GearCSModel = nil
	self.ActiveButtons = {}
	self.LastActiveGear = ""
	self.NextFires = {}
	self.NoClickZones = {}
	self.gearExtraOffset = Vector(0, 0, 0)
	self.gearExtraAngle = Angle(0, 0, 0)

	self.Inventory = {
		"rocketlauncher",
		"superball",
		"slingshot",
		"paintball",
		"bloxycola",
		"pizza",
		"cheezburger"
	}

	self.ZmMult = 0.5
	self.LastZmMult = 0.5
end

function ENT:RebuildActiveGear()
	if IsValid(self.GearCSModel) then
		self.GearCSModel:Remove()
	end

	local gear = self:GetActiveGear()
	if gear == "" then
		return
	end


	local gearData = GMBlox.ValidGears[gear]
	local mdl = gearData.model
	local offpos = gearData.modelOffset + Vector(-6, -18, 16) + self.gearExtraOffset
	local offang = gearData.angleOffset + self.gearExtraAngle
	local offmat = gearData.material

	self.GearCSModel = ClientsideModel(mdl, RENDERGROUP_OPAQUE)

	if offmat ~= "" then
		self.GearCSModel:SetMaterial(offmat)
	end

	self:OffsetAndParentCSModel(self.GearCSModel, offpos, offang)
end


function ENT:Animate(k)
	local targetPitch = self.TargetPitches[k]
	local currPitch = self.CurrentPitches[k]
	local ro = self.RenderObjects[k]

	local csModel = self.CSModels[k]
	if not IsValid(csModel) then
		return
	end

	local diffclamp = math.Clamp(targetPitch.ang - currPitch, -RealFrameTime() * targetPitch.speed, RealFrameTime() * targetPitch.speed)

	self.CurrentPitches[k] = self.CurrentPitches[k] + diffclamp



	local right = self:GetRight()
	local up = self:GetUp()
	local forward = self:GetForward()
	local calcangoff = self:GetAngles()
	calcangoff:RotateAroundAxis(right, -self.CurrentPitches[k])
	calcangoff:RotateAroundAxis(up, ro.ang.y)
	calcangoff:RotateAroundAxis(forward, ro.ang.r)

	csModel:SetAngles(calcangoff)
end

function ENT:AnimThink(k)
	local gear = self:GetActiveGear()
	local geardata = GMBlox.ValidGears[gear]

	if geardata and geardata.animOverrideLUT[k] ~= nil and self.AllowAnimOverride then
		local fine, ret, rate = pcall(geardata.animOverrideLUT[k], self, k)
		if not fine then
			print("[GMBLOX] Error in anim LUT for " .. k .. ": " .. ret)
			return
		end

		self.TargetPitches[k] = {ang = ret, speed = rate or self.TargetPitches[k].speed}
		return
	end


	if self.AnimLUT[k] then
		local fine, ret, rate = pcall(self.AnimLUT[k], self, k)
		if not fine then
			print("[GMBLOX] Error in anim LUT for " .. k .. ": " .. ret)
			return
		end

		self.TargetPitches[k] = {ang = ret, speed = rate or self.TargetPitches[k].speed}
	end
end

function ENT:Draw()
	for k, v in pairs(self.CSModels) do
		if not IsValid(v) then
			self:BuildCSModels()
			break
		end

		--v:DrawModel()
		v:CreateShadow()
	end
end

function ENT:EquipGear(name)
	local currGear = self:GetActiveGear()
	local currGearData = GMBlox.ValidGears[currGear]
	if currGearData and currGearData.clUnequip then
		local fine, err = pcall(currGearData.clUnequip, self)
		if not fine then
			print("[GMBLOX] Error in clUnequip for " .. currGear .. ": " .. err)
		end
	end


	net.Start("gmblox_equipgear")
		net.WriteString(name)
		net.WriteEntity(self)
	net.SendToServer()

	self.gearExtraOffset = Vector(0, 0, 0)
	self.gearExtraAngle = Angle(0, 0, 0)
	self:RebuildActiveGear()
end



function ENT:ReBuildGearButtons()
	if not GMBlox then
		return
	end

	self.ActiveButtons = {}

	local gearCount = #self.Inventory


	local center = ScrW() / 2
	local y = ScrH() * .9


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

			e_self.gearExtraOffset = Vector(0, 0, 0)
			e_self.gearExtraAngle = Angle(0, 0, 0)
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


local function inrange(x, y, w, h, x2, y2)
	return x <= x2 and x2 <= x + w and y <= y2 and y2 <= y + h
end

function ENT:HandleFiring()
	if LocalPlayer() ~= self:GetController() then
		return
	end

	if self:GetActiveGear() == "" then
		return
	end

	if not GMBlox then
		return
	end

	local gearName = self:GetActiveGear()
	local gearData = GMBlox.ValidGears[gearName]

	if not gearData then
		return
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		local mx, my = input.GetCursorPos()

		for k, v in pairs(self.NoClickZones) do
			if inrange(v.x, v.y, v.w, v.h, mx, my) then
				return
			end
		end


		local tr = util.TraceLine({
			start = self:GetController():GetShootPos(),
			endpos = self:GetController():GetShootPos() + (gui.ScreenToVector(mx, my) * 10000),
			filter = {self, self:GetController()},
		})


		if CurTime() > (self.NextFires[gearName] or 0) then
			local fine, ret = pcall(gearData.clCallback, self, tr)
			if not fine then
				print("[GMBLOX] Error in firing callback for " .. gearName .. ": " .. ret)
				return
			end

			if ret then
				return
			end

			timer.Simple(gearData.useCooldown - 0.2, function()
				if not IsValid(self) then
					return
				end

				pcall(gearData.clFinishedCallback, self)
			end)

			self.NextFires[gearName] = CurTime() + gearData.useCooldown
		end

		net.Start("gmblox_firegear")
			net.WriteString(gearName)
			net.WriteEntity(self)
			net.WriteVector(tr.HitPos)
		net.SendToServer()
	end
end

function ENT:HandleQuickSwitch()
	if LocalPlayer() ~= self:GetController() then
		return
	end


	local pressed = false
	for i = 1, 10 do
		local isDown = input.IsKeyDown(i)
		local idx = i - 1

		if isDown then
			pressed = true
		end

		if self.Inventory[idx] and isDown and not self.HasSwitched then
			self:EquipGear(self.Inventory[idx])
			self.HasSwitched = true
		end
	end

	if not pressed then
		self.HasSwitched = false
	end
end


function ENT:GearThink()
	local gear = self:GetActiveGear()
	if not gear then
		return
	end

	local gearData = GMBlox.ValidGears[gear]
	if not gearData or not gearData.clThinkCallback then
		return
	end

	local fine, err = pcall(gearData.clThinkCallback, self)

	if not fine then
		print("[GMBLOX] Error in gear think callback for " .. gear .. ": " .. err)
	end
end


function ENT:MakeHooks()
	hook.Add("CalcView", "GMBloxControl", function(ply, origin, ang)
		local tr = util.TraceLine({
			start = self:GetPos() + Vector(0, 0, 16),
			endpos = (self:GetPos() - (ang:Forward() * 100) * self.ZmMult) + self:GetForward() * -22,
			filter = self
		})

		local view = {
			origin = tr.HitPos + (tr.HitNormal * 2),
			angles = ang,
			fov = fov,
			drawviewer = true
		}

		return view
	end)

	local hp_bar_empty = Material("gmblox/vgui/healthbar-empty.png", "nocull ignorez alphatest")
	local hp_bar_full = Material("gmblox/vgui/healthbar-alone.png", "nocull ignorez alphatest")
	local hp_bar_overlay = Material("gmblox/vgui/health-overlay.png", "nocull ignorez alphatest")
	hook.Add("HUDPaint", "GMBloxPaintHealth", function()
		if not IsValid(self) then
			return
		end

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(hp_bar_empty)
		surface.DrawTexturedRect((ScrW() / 2) - (170 / 2), ScrH() * .975, 170, 18)

		local sz = self:GetHealthRoblox() / 100

		surface.SetMaterial(hp_bar_full)
		surface.DrawTexturedRectUV((ScrW() / 2) - (170 / 2), ScrH() * .975, 170 * sz, 18, 0, 0, sz, 1)

		surface.SetMaterial(hp_bar_overlay)
		surface.DrawTexturedRect((ScrW() / 2) - (170 / 2), ScrH() * .975, 170, 18)
	end)

	hook.Add("CreateMove", "GMBloxZoom", function(cmd)
		if not IsValid(self) then
			return
		end

		if cmd:GetMouseWheel() ~= 0 then
			self.ZmMult = self.ZmMult - cmd:GetMouseWheel() * 0.025
			if self.ZmMult < 0 then
				self.ZmMult = 0
			end
			if self.ZmMult > 4 then
				self.ZmMult = 4
			end

			net.Start("gmblox_changezoom")
				net.WriteEntity(self)
				net.WriteFloat(self.ZmMult)
			net.SendToServer()
		end
	end)
end

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
	end


	function buttonpart:DoClick()
		e_ref.colEditTarget = cref.name
		colmixer:SetColor(cref.col)
	end
end

function ENT:MakeCustomizeMenu()
	if IsValid(self.customizeMenu) then
		return
	end
	local e_ref = self

	self.customizeMenu = vgui.Create("DFrame")
	self.customizeMenu:SetSize(800, 600)
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
	colMixer:SetPos(800 - 400, 600 / 2 - 150)
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

	function self.customizeMenu:OnClose()
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

		cookie.Set("gmblox_col", util.TableToJSON(coltbl))
		e_ref:SendSavedColour()

		e_ref.NoClickZones["cusmenu"] = nil
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

	local exitButton = vgui.Create("DButton", self.frameMenu)
	exitButton:SetText("Exit")
	exitButton:DockMargin(16, 16, 16, 16)
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
	customizeButton:DockMargin(16, 16, 16, 16)
	customizeButton:Dock(BOTTOM)
	customizeButton:SetTall(64)

	function customizeButton:DoClick()
		e_ref.frameMenu:Close()
		e_ref:MakeCustomizeMenu()
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





function ENT:CallGearOnEquip()
	local gear = self:GetActiveGear()
	if not gear then
		return
	end

	local gearData = GMBlox.ValidGears[gear]

	if not gearData or not gearData.clEquip then
		return
	end

	local fine, err = pcall(gearData.clEquip, self)

	if not fine then
		print("[GMBLOX] Error in equip callback for " .. gear .. ": " .. err)
	end
end


function ENT:Think()
	for k, v in pairs(self.CSModels) do
		self:AnimThink(k)
		self:Animate(k)
	end

	if IsValid(self:GetController()) and self:GetController() == LocalPlayer() and not self.MadeHooks then
		self.MadeHooks = true
		self:MakeHooks()
		self:ReBuildGearButtons()
		self:SendSavedColour()
		self:MakeMenuButton()
	end

	if self.LastActiveGear ~= self:GetActiveGear() then
		self.LastActiveGear = self:GetActiveGear()
		self:RebuildActiveGear()
		self:CallGearOnEquip()
	end

	if LocalPlayer() == self:GetController() then
		if input.IsMouseDown(MOUSE_RIGHT) then
			gui.EnableScreenClicker(false)
		elseif self.ZmMult > 0 then
			gui.EnableScreenClicker(true)
		end
	end

	self:HandleQuickSwitch()
	self:HandleFiring()
	self:GearThink()
end


function ENT:RemoveHooks()
	hook.Remove("CalcView", "GMBloxControl")
	hook.Remove("HUDPaint", "GMBloxPaintHealth")
	hook.Remove("CreateMove", "GMBloxZoom")

	for k, v in pairs(self.ActiveButtons) do
		v:Remove()
	end

	gui.EnableScreenClicker(false)
	self.MadeHooks = false
end

net.Receive("gmblox_exit_sv", function()
	local e_ref = net.ReadEntity()
	if not IsValid(e_ref) then
		return
	end

	e_ref:RemoveHooks()
end)


function ENT:OnRemove()
	self:RemoveCSModels()

	if self.MadeHooks then
		self:RemoveHooks()
	end
end

