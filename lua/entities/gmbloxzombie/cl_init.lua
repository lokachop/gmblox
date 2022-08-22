include("shared.lua")
function ENT:RemoveCSModels()
	for k, v in pairs(self.CSModels) do
		v:Remove()
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

	self.RenderObjects = {
		["head"] = {
			pos = Vector(-18.5, 0, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/head.mdl",
			mat = "gmblox/face_drool",
			col = Color(143, 175, 124),
			name = "head"
		},
		["torso"] = {
			pos = Vector(0, 0, 0),
			ang = Angle(0, 0, 90),
			model = "models/gmblox/torso.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(76, 46, 29),
			name = "torso"
		},

		["leftarm"] = {
			pos = Vector(-6, -18, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limbarm.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(143, 175, 124),
			name = "leftarm"
		},
		["rightarm"] = {
			pos = Vector(-6, 18, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limbarm.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(143, 175, 124),
			name = "rightarm"
		},

		["leftleg"] = {
			pos = Vector(12, 6, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limb.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(76, 46, 29),
			name = "leftleg"
		},
		["rightleg"] = {
			pos = Vector(12, -6, 0),
			ang = Angle(-90, 0, 0),
			model = "models/gmblox/limb.mdl",
			mat = "gmblox/robloxwhite",
			col = Color(76, 46, 29),
			name = "rightleg"
		},
	}


	self:BuildCSModels()

	self.AnimLUT = {}
	self.AnimLUT["leftarm"] = function(ent, k)
		return -180, 256
	end

	self.AnimLUT["rightarm"] = function(ent, k)
		return -180, 256
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


	self.LastGroundState = false
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
	if self.HasGibbed then
		if not self.HasRemovedCSPostGib then
			self:RemoveCSModels()
			self.HasRemovedCSPostGib = true
		end
		return
	end


	for k, v in pairs(self.CSModels) do
		if not IsValid(v) then
			self:BuildCSModels()
			break
		end

		v:CreateShadow()
	end
end


function ENT:GibOnDeath()
	if not GetConVar("gmblox_gibondeath"):GetBool() then
		return
	end

	if self.HasGibbed then
		return
	end

	for k, v in pairs(self.CSModels) do
		local prop = ents.CreateClientProp(v:GetModel())
		prop:SetPos(v:GetPos())
		prop:SetAngles(v:GetAngles())
		prop:SetColor(v:GetColor())
		prop:Spawn()

		if v:GetMaterials()[1] == "gmblox/face_background" then
			prop:SetMaterial("gmblox/face_drool")
		end

		local wait = 4
		local cv = GetConVar("gmblox_gibremovetime")

		if cv then
			wait = cv:GetInt()
		end

		timer.Simple(wait, function()
			if IsValid(prop) then
				prop:Remove()
			end
		end)
	end

	self.HasGibbed = true
end

function ENT:Think()
	if self.LastGroundState ~= self:GetGrounded() then
		if self:GetGrounded() == true then
			self.LowerArmTime = CurTime() + 0.75
		end
		self.LastGroundState = self:GetGrounded()
	end



	if (self.NextAnim or 0) > CurTime() then
		return
	end


	for k, v in pairs(self.CSModels) do
		self:AnimThink(k)
		self:Animate(k)
	end
	self.LastAnim = SysTime()

	self.NextAnim = CurTime() + ((GetConVar("gmblox_animwait"):GetInt() / 1000) * 2)

	if self:GetHealthRoblox() <= 0 then
		self:GibOnDeath()
	end
end

function ENT:OnRemove()
	self:RemoveCSModels()
end

