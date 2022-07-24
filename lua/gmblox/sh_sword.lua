local GEAR = {}
GEAR.name = "sword" -- name of the gear
GEAR.desc = "swording away" -- optional
GEAR.icon = "gmblox/vgui/Sword128.png" -- optional

GEAR.model = "models/props_junk/meathook001a.mdl"
GEAR.modelOffset = Vector(-2, 0, 7)
GEAR.angleOffset = Angle(90, 0, -90)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.1 -- hacky hack for doublefire
GEAR.equipSound = "gmblox/unsheath.wav" -- optional


-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	if ent.swordLunge then
		return
	end

	if (ent.framesLunge or 0) > CurTime() and (not ent.swordLunge) and (CurTime() > (ent.canNextLunge or 0)) then
		ent.swordLunge = true
		ent.swordSlashEnd = CurTime() + 1.4
	end


	if (ent.swordSlashEnd or 0) < CurTime() then
		ent.swordSlashEnd = CurTime() + 0.75
		ent.framesLunge = CurTime() + 0.25
	end
	-- do stuff
end

GEAR.clThinkCallback = function(ent)
	if (ent.swordSlashEnd or 0) > CurTime() and (not ent.swordLunge) then
		local prog = math.abs(1 - (ent.swordSlashEnd - CurTime()) / 0.75)
		ent.gearExtraAngle = Angle(0, math.sin(math.pi * prog) * 90, 0)

		ent:RebuildActiveGear()
	end

	if ent.swordLunge then
		ent.gearExtraAngle = Angle(0, 90, 0)
		ent:RebuildActiveGear()
	end


	if (CurTime() > (ent.swordSlashEnd or 0)) and ent.swordLunge then
		ent.swordLunge = false
		ent.gearExtraAngle = Angle(0, 0, 0)
		ent:RebuildActiveGear()

		ent.canNextLunge = CurTime() + 1.5
	end
end

GEAR.clFinishedCallback = function(ent)
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	if ent.swordLunge then
		return
	end

	if (ent.framesLunge or 0) > CurTime() and (not ent.swordLunge) and (CurTime() > (ent.canNextLunge or 0)) then
		ent:EmitSound("gmblox/swordlunge.wav")
		ent.swordLunge = true
		ent.swordSlashEnd = CurTime() + 0.65
		local ephys = ent:GetPhysicsObject()
		if IsValid(ephys) then
			ephys:EnableGravity(false)
			local velg = ephys:GetVelocity()
			ephys:SetVelocity(Vector(velg.x, velg.y, 0))
			ephys:ApplyForceCenter(Vector(0, 0, 450))
		end
		return
	end


	if (ent.swordSlashEnd or 0) < CurTime() then
		ent.swordSlashEnd = CurTime() + 0.75
		ent.framesLunge = CurTime() + 0.25
		ent:EmitSound("gmblox/swordslash.wav")
	end
end

GEAR.svThinkCallback = function(ent)
	if (CurTime() > (ent.swordSlashEnd or 0)) and ent.swordLunge then
		ent.swordLunge = false

		local ephys = ent:GetPhysicsObject()
		if IsValid(ephys) then
			ephys:EnableGravity(true)
		end

		ent.canNextLunge = CurTime() + 1.5
	end
end

GEAR.svUnequip = function(ent)
	local ephys = ent:GetPhysicsObject()
	if IsValid(ephys) then
		ephys:EnableGravity(true)
	end
end

GMBlox.DeclareGear(GEAR)