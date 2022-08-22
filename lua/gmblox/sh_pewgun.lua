local GEAR = {}
GEAR.name = "xls laser gun" -- name of the gear
GEAR.desc = "pew pew" -- optional
GEAR.icon = "gmblox/vgui/lasergun.png" -- optional

GEAR.model = "models/roblox_assets/xls_mark_ii_pulse_laser_pistol.mdl"
GEAR.modelOffset = Vector(-8, 0, 7)
GEAR.angleOffset = Angle(180, 0, 180)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.3 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/lasergun_equip.wav" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	local laserBall = ents.Create("prop_physics")
	laserBall:SetModel("models/hunter/misc/sphere025x025.mdl")
	laserBall:Spawn()
	laserBall:SetPos(shootpos)
	laserBall:SetGravity(0)
	laserBall:SetColor(HSVToColor(110, 1, 1))

	local laserBall_phys = laserBall:GetPhysicsObject()
	if not IsValid(laserBall_phys) then
		laserBall:Remove()
		return
	end
	laserBall_phys:SetMass(1)
	laserBall_phys:Wake()
	laserBall_phys:ApplyForceCenter(shootdir * -512 * 2)
	laserBall_phys:EnableGravity(false)
	laserBall_phys:SetDragCoefficient(0)
	laserBall_phys:SetBuoyancyRatio(0)



	laserBall:AddCallback("PhysicsCollide", function(enthit, data)
		if not IsValid(laserBall) then
			return
		end

		local hent = data.HitEntity

		if IsValid(hent) and data.HitSpeed:Length() > 60 and IsValid(ent) and not laserBall.HasHit then
			hent:TakeDamage(15, ent:GetController())
		end

		laserBall.HasHit = true
		laserBall:Remove()
	end)

	timer.Simple(5, function()
		if not IsValid(laserBall) then
			return
		end
		laserBall:Remove()
	end)

	ent:EmitSound("gmblox/lasergun_pew.wav")
end

GMBlox.DeclareGear(GEAR)