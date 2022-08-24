AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_gear.lua")
AddCSLuaFile("cl_ui.lua")
AddCSLuaFile("cl_menu.lua")
AddCSLuaFile("cl_net.lua")
AddCSLuaFile("cl_shiftlock.lua")
AddCSLuaFile("cl_loadout.lua")
AddCSLuaFile("cl_shirts_n_pants.lua")

include("shared.lua")
include("sv_physics.lua")
include("sv_net.lua")

util.PrecacheModel("models/gmblox/head.mdl")
util.PrecacheModel("models/gmblox/torso.mdl")
util.PrecacheModel("models/gmblox/limb.mdl")
util.PrecacheModel("models/gmblox/limb_left.mdl")
util.PrecacheModel("models/gmblox/limb_right.mdl")

util.PrecacheModel("models/gmblox/limbarm.mdl")
util.PrecacheModel("models/gmblox/limbarm_left.mdl")
util.PrecacheModel("models/gmblox/limbarm_right.mdl")

function ENT:UnControl()
	if not IsValid(self:GetController()) then
		return
	end

	if self.PreFlagNoTarget then
		self:AddFlags(FL_NOTARGET)
	end

	if self.PreFlagAimTarget then
		self:AddFlags(FL_AIMTARGET)
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
	self.WalkSpeedMult = 1
	self.JumpPowerMult = 1
	self.GravityMult = 1

	self:SetHealthRoblox(100)

	self:AddEFlags(EFL_DONTBLOCKLOS)

	self:SetUseType(SIMPLE_USE)
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
	local tr
	if self:GetStanding() then
		tr = self:Stand()
	end

	self:DieIfNeeded()
	self:PlayerHandleMovement(tr)
	self:ThinkGear()


	if IsValid(self:GetController()) then
		self:GetController():SetPos(self:GetPos() + self:GetForward() * -12)
	end

	if IsValid(self:GetController()) then
		self:NextThink(CurTime() + 0.025)
	else
		self:NextThink(CurTime() + 0.075)
	end
	return true
end

-- horrid hax to fix https://github.com/Facepunch/garrysmod-issues/issues/861
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end


function ENT:BeginControl(ply)
	if IsValid(self:GetController()) then
		return
	end

	self:SetController(ply)

	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(self)
	ply:Flashlight(false)
	ply:AllowFlashlight(false)
	ply:StripWeapons()

	self.PreFlagNoTarget = ply:GetFlags(FL_NOTARGET)
	self.PreFlagAimTarget = ply:GetFlags(FL_AIMTARGET)

	ply:RemoveFlags(FL_NOTARGET)
	ply:RemoveFlags(FL_AIMTARGET)
end

function ENT:Use(ply, caller)
	if ply:GetInfoNum("gmblox_loadoutprompt", 1) == 0 then
		self:BeginControl(ply)
		return
	end

	if not self.HasLoadout then
		net.Start("gmblox_promptloadout")
			net.WriteEntity(self)
		net.Send(ply)
		return
	end

	self:BeginControl(ply)
end

function ENT:OnRemove()
	self:UnControl()
	self:StopSound("gmblox/bfsl-minifigfoots1.wav")
end

function ENT:OnTakeDamage(dmginfo)
	self:SetHealthRoblox(self:GetHealthRoblox() - (dmginfo:GetDamage()))
end