local GEAR = {}
GEAR.name = "slingshot" -- name of the gear
GEAR.desc = "shoot these slings" -- optional
GEAR.icon = "gmblox/vgui/Slingshot.png" -- optional

GEAR.model = "models/weapons/w_suitcase_passenger.mdl"
GEAR.modelOffset = Vector(0, 0, 4)
GEAR.angleOffset = Angle(0, 0, 0)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.45 -- wait this many seconds before using again
GEAR.equipSound = "" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	local slingshotBall = ents.Create("prop_physics")
	slingshotBall:SetModel("models/hunter/misc/sphere025x025.mdl")
	slingshotBall:Spawn()
	slingshotBall:SetPos(shootpos)

	local slingshotBall_phys = slingshotBall:GetPhysicsObject()
	if not IsValid(slingshotBall_phys) then
		slingshotBall:Remove()
		return
	end
	slingshotBall_phys:SetMass(1)
	slingshotBall_phys:Wake()
	slingshotBall_phys:ApplyForceCenter(shootdir * -512 * 2)

	slingshotBall:AddCallback("PhysicsCollide", function(enthit, data)
		if not IsValid(slingshotBall) then
			return
		end

		if not IsValid(data.HitEntity) then
			return
		end

		if data.HitEntity:GetClass() == "gmbloxchar" and data.HitSpeed:Length() > 60 then
			data.HitEntity:TakeDamage(10)
		end
	end)

	timer.Simple(5, function()
		if not IsValid(slingshotBall) then
			return
		end
		slingshotBall:Remove()
	end)

	ent:EmitSound("gmblox/Rubberband.wav")
end

GMBlox.DeclareGear(GEAR)
