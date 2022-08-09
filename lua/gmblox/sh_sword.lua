local GEAR = {}
GEAR.name = "sword" -- name of the gear
GEAR.desc = "swording away" -- optional
GEAR.icon = "gmblox/vgui/Sword128.png" -- optional

GEAR.model = "models/gmblox/sword.mdl"
GEAR.modelOffset = Vector(-17, 0, 2)
GEAR.angleOffset = Angle(0, -90, 90)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.5
GEAR.useCooldownDoubleFire = 1.3
GEAR.equipSound = "gmblox/unsheath.wav" -- optional

GEAR.animOverrideLUT = {}
GEAR.animOverrideLUT["rightarm"] = function(ent, k)
	if ent:GetGearState() == 2 then
		return -180, 512
	end


	local state = ent:GetGearState() == 1
	local tang = state and -90 or -180
	local tspeed = state and 512 or 2048

	return tang, tspeed
end

GEAR.animOverrideLUT["leftarm"] = function(ent, k)
	if ent:GetGearState() == 2 then
		return -90, 512
	end
end

GEAR.animOverrideLUT["leftleg"] = function(ent, k)
	if ent:GetGearState() == 2 then
		return -135, 512
	end
end

GEAR.animOverrideLUT["rightleg"] = function(ent, k)
	if ent:GetGearState() == 2 then
		return -45, 512
	end
end



-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
end

GEAR.clThinkCallback = function(ent)
end

GEAR.clFinishedCallback = function(ent)
end

GEAR.clUnequip = function(ent)
	ent.AllowAnimOverride = false
end

GEAR.clEquip = function(ent)
	ent.AllowAnimOverride = true
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	if ent:GetGearState() == 0 then
		ent:EmitSound("gmblox/swordslash.wav")
		ent:SetGearState(1)
		ent.StartSword = CurTime()

		ent.SwordHBPos = Vector(16, 0, 8)
		ent.SwordHBSize = 14
	end
end

GEAR.svFinishedCallback = function(ent)
	if ent:GetGearState() == 1 then
		ent:SetGearState(0)
		ent:SetGearAngle(Angle(0, 0, 0))
		ent:SetGearOffset(Vector(0, 0, 0))
		ent.StartSword = nil
		ent.SwordHBPos = nil
		ent.SwordHBSize = nil
	end
end

local function DoDmg(ent)
	local sz = ent.SwordHBSize or 12
	local posoff = ent:LocalToWorld(ent.SwordHBPos or Vector(0, 0, 0))


	local padd = ent:GetUp() * 16 + ent:GetRight() * 16 + ent:GetForward() * -8

	local tr = util.TraceHull({
		start = posoff,
		endpos = posoff + padd,
		filter = ent,
		mins = Vector(-sz, -sz, -sz),
		maxs = Vector(sz, sz, sz),
	})

	if tr.Hit and IsValid(tr.Entity) then
		tr.Entity:TakeDamage(30, ent:GetController(), ent)
	end
end

GEAR.svThinkCallback = function(ent)
	if ent:GetGearState() == 1 and (ent.NextAnimTimeSword or 0) < CurTime() then
		if not ent.StartSword then
			return
		end

		local t = (CurTime() - ent.StartSword) / GEAR.useCooldown

		local tcalc = math.Clamp(t * 3, 0, 1)

		local lang = LerpAngle(tcalc, Angle(0, 0, 0), Angle(0, -90, 0))
		local lpos = LerpVector(tcalc, Vector(0, 0, 0), Vector(35, 0, -2))

		ent:SetGearAngle(lang)
		ent:SetGearOffset(lpos)

		ent.NextAnimTimeSword = CurTime() + 0.066
	end




	-- do damage now

	if (ent.NextSwordDamageCheck or 0) > CurTime() then
		return
	end

	DoDmg(ent)
	ent.NextSwordDamageCheck = CurTime() + 0.1
end

GEAR.svDoubleFire = function(ent)
	if (ent.NextSwordLunge or 0) > CurTime() then
		return true -- cancel firing
	end


	ent:EmitSound("gmblox/swordlunge.wav")
	ent:SetGearState(2)

	ent:SetGearAngle(Angle(0, -90, 0))
	ent:SetGearOffset(Vector(17.5, 0, 20))


	local ephys = ent:GetPhysicsObject()
	if IsValid(ephys) then
		local evel = ephys:GetVelocity()

		ephys:SetVelocity(Vector(evel.x, evel.y, 64))
		ephys:EnableGravity(false)
	end

	ent.SwordHBPos = Vector(0, 0, 16)
	ent.SwordHBSize = 16
end

GEAR.svDoubleFireFinished = function(ent)
	ent:SetGearState(0)

	ent:SetGearAngle(Angle(0, 0, 0))
	ent:SetGearOffset(Vector(0, 0, 0))

	local ephys = ent:GetPhysicsObject()
	if IsValid(ephys) then
		ephys:EnableGravity(true)
	end

	ent.NextSwordLunge = CurTime() + 1.5
	ent.SwordHBPos = nil
	ent.SwordHBSize = nil
end


GEAR.svUnequip = function(ent)
	local ephys = ent:GetPhysicsObject()
	if IsValid(ephys) then
		ephys:EnableGravity(true)
	end

	ent.SwordHBPos = nil
	ent.SwordHBSize = nil
end

GEAR.svEquip = function(ent)
end

GMBlox.DeclareGear(GEAR)