include("shared.lua")

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
		},
		["torso"] = {
			pos = Vector(0, 0, 0),
			ang = Angle(0, 0, 90),
			model = "models/gmblox/torso.mdl",
			mat = "gmblox/robloxwhite",
			col = HSVToColor(self:GetRandomColour(), 0.5, 1),
		},

		["leftarm"] = {
			pos = Vector(-6, -18, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limbarm.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(255, 255, 0),
		},
		["rightarm"] = {
			pos = Vector(-6, 18, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limbarm.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(255, 255, 0),
		},

		["leftleg"] = {
			pos = Vector(12, 6, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limb.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(75, 220, 75),
		},
		["rightleg"] = {
			pos = Vector(12, -6, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limb.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(75, 220, 75),
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

	local diff = targetPitch.ang - currPitch
	local diffclamp = math.Clamp(diff, -RealFrameTime() * targetPitch.speed, RealFrameTime() * targetPitch.speed)

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
			net.Start("gmblox_equipgear")
				net.WriteString(v)
				net.WriteEntity(e_self)
			net.SendToServer()

			e_self.gearExtraOffset = Vector(0, 0, 0)
			e_self.gearExtraAngle = Angle(0, 0, 0)
		end


		self.NoClickZones[#self.NoClickZones + 1] = {
			x = center - (64 * (gearCount / 2)) + (64 * (k - 1)),
			y = y,
			w = 64,
			h = 64
		}
		self.ActiveButtons[k] = button
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
			net.Start("gmblox_equipgear")
				net.WriteString(self.Inventory[idx])
				net.WriteEntity(self)
			net.SendToServer()

			self.gearExtraOffset = Vector(0, 0, 0)
			self.gearExtraAngle = Angle(0, 0, 0)
			self.HasSwitched = true
		end
	end

	if not pressed then
		self.HasSwitched = false
	end
end


function ENT:Think()
	for k, v in pairs(self.CSModels) do
		self:AnimThink(k)
		self:Animate(k)
	end

	if IsValid(self:GetController()) and self:GetController() == LocalPlayer() and not self.MadeHooks then
		self.MadeHooks = true
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



		self:ReBuildGearButtons()
	end

	if self.LastActiveGear ~= self:GetActiveGear() then
		self.LastActiveGear = self:GetActiveGear()
		self:RebuildActiveGear()
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
end

function ENT:OnRemove()
	self:RemoveCSModels()

	if self.MadeHooks then
		hook.Remove("CalcView", "GMBloxControl")
		hook.Remove("HUDPaint", "GMBloxPaintHealth")
		hook.Remove("CreateMove", "GMBloxZoom")

		for k, v in pairs(self.ActiveButtons) do
			v:Remove()
		end

		gui.EnableScreenClicker(false)
	end
end

