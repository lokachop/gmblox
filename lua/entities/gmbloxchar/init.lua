AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.PrecacheModel("models/gmblox/head.mdl")
util.PrecacheModel("models/gmblox/torso.mdl")
util.PrecacheModel("models/gmblox/limb.mdl")

util.AddNetworkString("gmblox_equipgear")
util.AddNetworkString("gmblox_firegear")
util.AddNetworkString("gmblox_changezoom")

util.AddNetworkString("gmblox_changecolour")
util.AddNetworkString("gmblox_changecolour_sv")

util.AddNetworkString("gmblox_exit")
util.AddNetworkString("gmblox_exit_sv")

util.AddNetworkString("gmblox_changehat")
util.AddNetworkString("gmblox_changehat_sv")

net.Receive("gmblox_changehat", function(len, ply)
	if (ply.nextCustomizeHat or 0) > CurTime() then
		return
	end

	ply.nextCustomizeHat = CurTime() + 1

	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local hat = net.ReadString()

	if not hat then
		return
	end

	local face = net.ReadString()

	if not face then
		return
	end


	net.Start("gmblox_changehat_sv")
		net.WriteEntity(target)
		net.WriteString(hat)
		net.WriteString(face)
	net.Broadcast()
end)



function ENT:UnControl()
	if not IsValid(self:GetController()) then
		return
	end

	self:GetController():UnSpectate()
	self:GetController():AllowFlashlight(true)

	local found = false
	if IsValid(self:GetController()) then
		self:GetController():Spawn()


		-- find a safe spot to spawn at
		-- this allows players to clip through thin walls, although you can do the same with chairs
		for i = 1, 32 do
			local pos = self:GetPos() + Vector(math.random(-64, 64), math.random(-64, 64), 0)


			local tr = util.TraceHull({
				start = pos,
				endpos = pos,
				mins = Vector(-16, -16, 0),
				maxs = Vector(16, 16, 71)
			})

			if not tr.Hit then
				self:GetController():SetPos(pos)
				found = true
				break
			end
		end

		-- no spot found, PANIC!
		if not found then
			self:GetController():SetPos(self:GetPos())
		end
	end

	self:SetController(nil)
end


net.Receive("gmblox_exit", function(len, ply)
	if (ply.nextExitGMBlox or 0) > CurTime() then
		return
	end

	ply.nextExitGMBlox = CurTime() + 1

	local target = net.ReadEntity()

	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	target:UnControl()

	net.Start("gmblox_exit_sv")
		net.WriteEntity(target)
	net.Send(ply)
end)

net.Receive("gmblox_changecolour", function(len, ply)
	if (ply.NextChangeColour or 0) > CurTime() then
		return
	end

	ply.NextChangeColour = CurTime() + 1

	local target = net.ReadEntity()

	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local colhead = net.ReadUInt(24)
	local coltorso = net.ReadUInt(24)
	local colleftarm = net.ReadUInt(24)
	local colrightarm = net.ReadUInt(24)
	local colleftleg = net.ReadUInt(24)
	local colrightleg = net.ReadUInt(24)

	if not colhead or not coltorso or not colleftarm or not colrightarm or not colleftleg or not colrightleg then
		return
	end

	net.Start("gmblox_changecolour_sv")
		net.WriteEntity(target)
		net.WriteUInt(colhead, 24)
		net.WriteUInt(coltorso, 24)
		net.WriteUInt(colleftarm, 24)
		net.WriteUInt(colrightarm, 24)
		net.WriteUInt(colleftleg, 24)
		net.WriteUInt(colrightleg, 24)
	net.Broadcast()
end)


net.Receive("gmblox_equipgear", function(len, ply)
	if (ply.NextGearChange or 0) > CurTime() then
		return
	end
	ply.NextGearChange = CurTime() + 0.05

	local gear = net.ReadString()
	if gear == nil then
		return
	end


	if #gear > 64 then
		return
	end

	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local gearData = GMBlox.ValidGears[gear]
	if not gearData then
		return
	end

	local currgear = target:GetActiveGear()
	if currgear and GMBlox.ValidGears[currgear] and GMBlox.ValidGears[currgear].svUnequip then
		pcall(GMBlox.ValidGears[currgear].svUnequip, target)
	end

	if gear == target:GetActiveGear() then
		target:SetActiveGear("")
		return
	end

	target:SetGearOffset(Vector(0, 0, 0))
	target:SetGearAngle(Angle(0, 0, 0))

	target:SetActiveGear(gear)

	if gearData.equipSound then
		ply:EmitSound(gearData.equipSound)
	end

	if gearData.svEquip then
		local fine, err = pcall(gearData.svEquip, target)
		if not fine then
			print("Error in gear \"" .. gear .. "\" equip: " .. err)
		end
	end
end)


net.Receive("gmblox_firegear", function(len, ply)
	local gear = net.ReadString()
	if gear == nil then
		return
	end

	if #gear > 64 then
		return
	end

	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	if gear ~= target:GetActiveGear() then
		return
	end

	if target:GetHealthRoblox() <= 0 then
		return
	end

	if not GMBlox then
		return
	end

	local gearData = GMBlox.ValidGears[gear]

	if not gearData then
		return
	end

	if CurTime() < (target.NextFires[gear] or 0) then
		return
	end

	local pos = net.ReadVector()
	if not pos then
		return
	end

	local diff = (target:GetPos() - pos)
	local diff_norm = diff:GetNormalized()
	local shootpos = (target:GetPos() + -diff_norm * 48)


	local fine, ret = pcall(gearData.svCallback, target, pos, shootpos, diff_norm)

	if not fine then
		print("[GMBlox] Error in callback for gear \"" .. gear .. "\": " .. ret)
		return
	end

	if ret then
		return
	end

	timer.Simple(gearData.useCooldown, function()
		local fine2, err = pcall(gearData.svFinishedCallback, target)
		if not fine2 then
			print("[GMBlox] Error in callback for gear \"" .. gear .. "\": " .. err)
		end
	end)

	target.NextFires[gear] = CurTime() + gearData.useCooldown
end)

-- no ratelimit!
-- people change zoom VERY fast
net.Receive("gmblox_changezoom", function(len, ply)
	local target = net.ReadEntity()
	if not IsValid(target) then
		return
	end

	if target:GetClass() ~= "gmbloxchar" then
		return
	end

	if not IsValid(target:GetController()) then
		return
	end

	if target:GetController() ~= ply then
		return
	end

	local zoom = net.ReadFloat()
	if zoom == nil then
		return
	end

	target.InternZoom = zoom
end)

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetDragCoefficient(0)
		phys:SetMass(500)
	end

	self:SetStanding(true)
	self.targetAng = Angle(90, 0, 0)
	self.NextFires = {}
	self.InternZoom = 1

	self:SetHealthRoblox(100)
	self:SetRandomColour(math.random(0, 360))
end

function ENT:SpawnFunction(ply, tr, classname)
	if not tr.Hit then
		return
	end


	local ent = ents.Create(classname)
	ent:SetPos(tr.HitPos + tr.HitNormal * 16)
	ent:SetAngles(Angle(90, 0, 0))
	ent:Spawn()

	local ephys = ent:GetPhysicsObject()
	if IsValid(ephys) then
		ephys:Wake()
	end

	return ent
end

-- code by wireteam, edited by lokachop
-- https://github.com/wiremod/wire/blob/3221e99978b6dbab94afa5db6940988eec63c089/lua/entities/gmod_wire_expression2/core/entity.lua
function ApplyAngForce(ent, angForce)
	if angForce[1] == 0 and angForce[2] == 0 and angForce[3] == 0 then
		return
	end

	local phys = ent:GetPhysicsObject()

	-- assign vectors
	local up = ent:GetUp()
	local left = ent:GetRight() * -1
	local forward = ent:GetForward()

	-- apply pitch force
	if angForce[1] ~= 0 then
		local pitch = up * (angForce[1] * 0.5)
		phys:ApplyForceOffset( forward, pitch )
		phys:ApplyForceOffset( forward * -1, pitch * -1 )
	end

	-- apply yaw force
	if angForce[2] ~= 0 then
		local yaw = forward * (angForce[2] * 0.5)
		phys:ApplyForceOffset( left, yaw )
		phys:ApplyForceOffset( left * -1, yaw * -1 )
	end

	-- apply roll force
	if angForce[3] ~= 0 then
		local roll = left * (angForce[3] * 0.5)
		phys:ApplyForceOffset( up, roll )
		phys:ApplyForceOffset( up * -1, roll * -1 )
	end
end

function ENT:Stand()
	-- there's probably a much better way to do all of this but i horribly suck at vector math and this works
	-- if anyone knows a better method, please commit!

	local targetAng = self.targetAng
	local phys = self:GetPhysicsObject()

	local reachAng = self:WorldToLocalAngles(targetAng) * 200
	local angVel = self:GetLocalAngularVelocity() * 200

	local inertia = phys:GetInertia()
	local delta = (reachAng - angVel)
	local calc2 = Angle(delta.p * inertia.y, delta.y * inertia.z, delta.r * inertia.x)
	local fv = Vector(calc2.p, calc2.y, calc2.r)

	if IsValid(phys) then
		ApplyAngForce(self, fv * 2)
	end

	phys:AddAngleVelocity(-phys:GetAngleVelocity() / 2)

	-- now we need to actually stand
	local suspLen = 36.5
	local suspDamp = 1024
	local suspStr = 80400

	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0, 0, suspLen),
		filter = self,
	})

	if not tr.Hit then
		self:SetGrounded(false)
		return
	end
	self:SetGrounded(true)

	local invdist = math.abs(tr.Fraction - 1) * (suspLen / 5)
	local force = suspStr * invdist + (suspDamp * (-self:GetVelocity().z))

	phys:ApplyForceCenter(Vector(0, 0, force / 2))

	-- lets slow down now
	local vel = phys:GetVelocity()
	phys:ApplyForceCenter(-vel * 64)
end

function ENT:PlayerHandleMovement()
	if not self:GetStanding() then
		return
	end

	local ply = self:GetController()
	if not IsValid(ply) then
		return
	end

	local phys = self:GetPhysicsObject()
	if not IsValid(phys) then
		return
	end

	local forwardDir = ply:EyeAngles():Forward()
	local rightDir = ply:EyeAngles():Right()

	forwardDir.z = 0
	forwardDir:Normalize()

	rightDir.z = 0
	rightDir:Normalize()


	local totalVel = Vector(0, 0, 0)
	local moved = false
	if ply:KeyDown(IN_FORWARD) then
		totalVel = totalVel + forwardDir
		moved = true
	end
	if ply:KeyDown(IN_BACK) then
		totalVel = totalVel - forwardDir
		moved = true
	end

	if ply:KeyDown(IN_MOVERIGHT) then
		totalVel = totalVel + rightDir
		moved = true
	end
	if ply:KeyDown(IN_MOVELEFT) then
		totalVel = totalVel - rightDir
		moved = true
	end

	totalVel:Normalize()


	if moved then
		if not self.HasWalkSound then
			self:EmitSound("gmblox/bfsl-minifigfoots1.wav")
			self.HasWalkSound = true
		end

		if self.InternZoom > 0 then
			local vang = totalVel:Angle()
			self.targetAng = Angle(90, vang.y, 0)
		end
	elseif self.HasWalkSound then
		self:StopSound("gmblox/bfsl-minifigfoots1.wav")
		self.HasWalkSound = false
	end

	if self.InternZoom <= 0 then
		local fwang = ply:EyeAngles():Forward()
		fwang.z = 0
		fwang:Normalize()
		self.targetAng = Angle(90, fwang:Angle().y, 0)
	end


	local airVel = self:GetVelocity()
	airVel.z = 0

	local vcalc = totalVel * 120
	phys:SetVelocity(Vector(vcalc.x, vcalc.y, phys:GetVelocity().z))


	if self.HasJumped and self:GetGrounded() then
		self.NextJump = CurTime() + 0.1
		self.HasJumped = false
	end

	if ply:KeyDown(IN_JUMP) and self:GetGrounded() and CurTime() > (self.NextJump or 0) and (not self.HasJumped) then
		if math.random(0, 1) == 1 then
			self:EmitSound("gmblox/button.wav")
			timer.Simple(math.Rand(0.05, 0.20), function()
				if not IsValid(self) then
					return
				end

				self:StopSound("gmblox/button.wav")
			end)
		end


		phys:ApplyForceCenter(Vector(0, 0, 110000))
		self.NextJump = CurTime() + 0.25
		self.HasJumped = true
		self:EmitSound("gmblox/jump.wav")
	end
end


function ENT:FallOverCheck()
	local ang = self:GetAngles()
	local diff = 30 -- 30 deg before falling over
	if ang.p > (90 + diff) or ang.p < (90 - diff) and self:GetStanding() and (CurTime() > (self.CanFallAgain or 0)) then
		self:SetStanding(false)
		self:SetGrounded(true)
		self:EmitSound("gmblox/splat.wav")
		timer.Simple(4, function()
			if not IsValid(self) then
				return
			end

			self.CanFallAgain = CurTime() + 1
			self:SetStanding(true)
			self:EmitSound("gmblox/hit.wav")
		end)
	end
end


function ENT:DieIfNeeded()
	if (self:GetHealthRoblox() <= 0 and not self.HasFallen) or (IsValid(self:GetController()) and self:GetController():Health() <= 0 and not self.HasFallen) then
		self.HasFallen = true
		self:EmitSound("gmblox/Died.wav")
		self:SetStanding(false)

		timer.Simple(2, function()
			if not IsValid(self) then
				return
			end

			self:Remove()
		end)
	end
end


function ENT:ThinkGear()
	local gear = self:GetActiveGear()
	if not gear then
		return
	end

	local gearData = GMBlox.ValidGears[gear]

	if not gearData or not gearData.svThinkCallback then
		return
	end

	local fine, err = pcall(gearData.svThinkCallback, self)
	if not fine then
		print("[GMBlox] Error in svThinkCallback for gear " .. gear .. ": " .. err)
	end
end


function ENT:Think()
	self:FallOverCheck()
	if self:GetStanding() then
		self:Stand()
	end

	self:DieIfNeeded()
	self:PlayerHandleMovement()
	self:ThinkGear()

	self:NextThink(CurTime() + 0.025)
	return true
end

-- horrid hax to fix https://github.com/Facepunch/garrysmod-issues/issues/861
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:Use(ply, caller)
	if not IsValid(self:GetController()) then
		self:SetController(ply)

		ply:Spectate(OBS_MODE_CHASE)
		ply:SpectateEntity(self)
		ply:Flashlight(false)
		ply:AllowFlashlight(false)
		ply:StripWeapons()
	end
end

function ENT:OnRemove()
	self:UnControl()
	self:StopSound("gmblox/bfsl-minifigfoots1.wav")
end

function ENT:OnTakeDamage(dmginfo)
	self:SetHealthRoblox(self:GetHealthRoblox() - (dmginfo:GetDamage()))
end