include("shared.lua")
include("cl_gear.lua")
include("cl_ui.lua")
include("cl_menu.lua")
include("cl_net.lua")

surface.CreateFont("GMBlox_Trebuchet18Bold", {
	font = "Trebuchet MS",
	size = 18,
	weight = 800,
	antialias = false,
	additive = false,
})

surface.CreateFont("GMBlox_Trebuchet18", {
	font = "Trebuchet MS",
	size = 18,
	weight = 600,
	antialias = false,
	additive = false,
})

function ENT:RemoveCSModels()
	for k, v in pairs(self.CSModels) do
		v:Remove()
	end

	if IsValid(self.GearCSModel) then
		self.GearCSModel:Remove()
	end

	if IsValid(self.HatCSModel) then
		self.HatCSModel:Remove()
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

	self:RebuildActiveGear()
	self:RebuildActiveHat()
end

function ENT:Initialize()
	self.CSModels = {}
	self.TargetPitches = {}
	self.CurrentPitches = {}

	self.Faces = GMBlox.ValidFaces or {
		["normal"] = {
			mat = "gmblox/face_background",
			matui = "gmblox/vgui/smile-background.png",
		},
		[":3"] = {
			mat = "gmblox/colonthreebackground",
			matui = "gmblox/vgui/colonthree-background.png",
		},
		["drool"] = {
			mat = "gmblox/face_drool",
			matui = "gmblox/vgui/face_drool.png",
		},
	}


	self.Hats = GMBlox.ValidHats or {}

	self.ActiveHat = "None"
	self.ActiveFace = "normal"

	self.RenderObjects = {
		["head"] = {
			pos = Vector(-17.5, 0, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/head.mdl",
			mat = self.Faces[self.ActiveFace].mat,
			col = Color(255, 255, 0),
			name = "head"
		},
		["torso"] = {
			pos = Vector(0, 0, 0),
			ang = Angle(0, 0, 90),
			model = "models/gmblox/torso.mdl",
			mat = "gmblox/robloxwhite",
			col = HSVToColor(230, 0.5, 1),
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
		if not ent:GetGrounded() or (self.LowerArmTime > CurTime()) then
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
		if ent:GetActiveGear() ~= "" then
			return -180, 512
		end

		if not ent:GetGrounded() or (self.LowerArmTime > CurTime())  then
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
	self.HatCSModel = nil


	self.ActiveButtons = {}
	self.LastActiveGear = ""
	self.NextFires = {}
	self.NoClickZones = {}
	self.LastGearOffset = Vector(0, 0, 0)
	self.LastGearAngle = Angle(0, 0, 0)
	self.LastGroundState = false
	self.LowerArmTime = 0

	self.Inventory = GMBlox.DefaultInventory or {
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

function ENT:RebuildActiveHat()
	if IsValid(self.HatCSModel) then
		self.HatCSModel:Remove()
	end

	local hat = self.ActiveHat
	if hat == "" then
		return
	end

	if hat == "None" then
		return
	end


	local hatinf = GMBlox.ValidHats[hat]

	if not hatinf then
		return
	end

	self.HatCSModel = ClientsideModel(hatinf.model, RENDERGROUP_OPAQUE)
	local offpos = hatinf.posOffset + Vector(-24, 0, 0)
	local offang = hatinf.angleOffset + Angle(90, 0, 0)

	if hatinf.scale then
		local mat = Matrix()
		mat:Scale(hatinf.scale)
		self.HatCSModel:EnableMatrix("RenderMultiply", mat)
	end

	self:OffsetAndParentCSModel(self.HatCSModel, offpos, offang)
end


function ENT:Animate(k)
	local targetPitch = self.TargetPitches[k]
	local currPitch = self.CurrentPitches[k]
	local ro = self.RenderObjects[k]

	local csModel = self.CSModels[k]
	if not IsValid(csModel) then
		return
	end

	local t_diff = SysTime() - (self.LastAnim or 0)

	local diffclamp = math.Clamp(targetPitch.ang - currPitch, -(RealFrameTime() + t_diff) * targetPitch.speed, (RealFrameTime() + t_diff) * targetPitch.speed)

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

		if fine and ret and rate then
			self.TargetPitches[k] = {ang = ret, speed = rate or self.TargetPitches[k].speed}
			return
		end
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

		v:CreateShadow()
	end

	if IsValid(self.GearCSModel) then
		self.GearCSModel:CreateShadow()
	end

	if IsValid(self.HatCSModel) then
		self.HatCSModel:CreateShadow()
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

		self:RenderScoreboard()
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


function ENT:Think()
	if self.LastGroundState ~= self:GetGrounded() then
		if self:GetGrounded() == true then
			self.LowerArmTime = CurTime() + 0.75
		end
		self.LastGroundState = self:GetGrounded()
	end



	if (self.NextAnimTime or 0) < CurTime() then
		for k, v in pairs(self.CSModels) do
			self:AnimThink(k)
			self:Animate(k)
		end
		self.LastAnim = SysTime()
		self.NextAnimTime = CurTime() + (GetConVar("gmblox_animwait"):GetInt() / 1000)
	end


	if not self.MadeHooks and IsValid(self:GetController()) and self:GetController() == LocalPlayer() then
		self.MadeHooks = true
		self:MakeHooks()
		self:ReBuildGearButtons()
		self:SendSavedAppearance()
		self:MakeMenuButton()
	end

	if self.LastActiveGear ~= self:GetActiveGear() then
		self.LastActiveGear = self:GetActiveGear()
		self:RebuildActiveGear()
		self:CallGearOnEquip()
	end

	if LocalPlayer() == self:GetController() then
		if input.IsMouseDown(MOUSE_RIGHT) then
			if not (self.HasSavedPos or false) then
				RememberCursorPosition()
				self.HasSavedPos = true
			end
			gui.EnableScreenClicker(false)
		elseif self.ZmMult > 0 then
			if self.HasSavedPos then
				RestoreCursorPosition()
				self.HasSavedPos = false
			end

			gui.EnableScreenClicker(true)
		end
	end

	if not IsValid(self:GetController()) then
		self.NoClickZones = {}
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

