AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("sv_physics.lua")

util.PrecacheModel("models/gmblox/head.mdl")
util.PrecacheModel("models/gmblox/torso.mdl")
util.PrecacheModel("models/gmblox/limb.mdl")

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube05x05x025.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetDragCoefficient(0)
		phys:SetMass(150)
	end

	self:SetStanding(true)
	self.targetAng = Angle(90, 0, 0)
	self.WalkSpeedMult = 1
	self.JumpPowerMult = 1

	self:SetHealthRoblox(100)

	self.NearestPlayer = nil
end

function ENT:RefreshFilterTables()
	self.targetFilter = {}
	local entc = ents.GetAll()
	for k, v in pairs(entc) do
		if v:IsPlayer() then
			self.targetFilter[#self.targetFilter + 1] = v
		end

		if v:GetClass() == "gmbloxchar" then
			self.targetFilter[#self.targetFilter + 1] = v
		end

		if v:GetClass() == "gmbloxzombie" then
			self.targetFilter[#self.targetFilter + 1] = v
		end
	end


	self.targetFilterDamage = {}

	local filt = ents.GetAll()
	for k, v in pairs(filt) do
		if not v:IsPlayer() and v:GetClass() ~= "gmbloxchar" then
			self.targetFilterDamage[#self.targetFilterDamage + 1] = v
		end
	end

end



function ENT:RefindNearestPlayer()
	self.NearestPlayer = nil
	local ents_near = ents.FindInSphere(self:GetPos(), 2048)
	local last_closest = math.huge

	for k, v in pairs(ents_near) do
		if v:IsValid() and v:IsPlayer() and (v:Health() > 0) and v:GetPos():DistToSqr(self:GetPos()) < last_closest then
			last_closest = v:GetPos():DistToSqr(self:GetPos())
			self.NearestPlayer = v
		end
	end
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

function ENT:DieIfNeeded()
	if (self:GetHealthRoblox() <= 0 and not self.HasFallen) then
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


function ENT:DamageIfNear()
	if (self.NextDmg or 0) > CurTime() then
		return
	end

	if not self.targetFilterDamage then
		return
	end


	local tr = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos(),
		mins = Vector(-20, -20, -26),
		maxs = Vector(20, 20, 26),
		filter = self.targetFilterDamage,
	})

	if not tr.Hit then
		return
	end

	if not IsValid(tr.Entity) then
		return
	end

	if tr.Entity:IsPlayer() or tr.Entity:GetClass() == "gmbloxchar" then
		tr.Entity:TakeDamage(10, self, self:GetClass())
	end

	self.NextDmg = CurTime() + 0.6

end

function ENT:Think()
	if (self.NextFind or 0) < CurTime() then
		self:RefindNearestPlayer()
		self.NextFind = CurTime() + 6
	end

	if (self.nextTargetFilterRefresh or 0) < CurTime() then
		self:RefreshFilterTables()
		self.nextTargetFilterRefresh = CurTime() + 24
	end


	self:FallOverCheck()
	local tr
	if self:GetStanding() then
		tr = self:Stand()
	end

	self:ZombieChase(tr)
	self:DamageIfNear()
	self:DieIfNeeded()

	self:NextThink(CurTime() + 0.035)
	return true
end

-- horrid hax to fix https://github.com/Facepunch/garrysmod-issues/issues/861
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:OnRemove()
	self:StopSound("gmblox/bfsl-minifigfoots1.wav")
end

function ENT:OnTakeDamage(dmginfo)
	self:SetHealthRoblox(self:GetHealthRoblox() - (dmginfo:GetDamage()))
end