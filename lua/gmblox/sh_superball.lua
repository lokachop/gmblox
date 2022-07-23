local GEAR = {}
GEAR.name = "superball" -- name of the gear
GEAR.desc = "super balls" -- optional
GEAR.icon = "gmblox/vgui/Superball.png" -- optional

GEAR.model = "models/hunter/misc/sphere025x025.mdl"
GEAR.modelOffset = Vector(0, 0, 4)
GEAR.angleOffset = Angle(0, 0, 0)

GEAR.material = "models/xqm/rails/gumball_1" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 3 -- wait this many seconds before using again
GEAR.equipSound = "" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	local bounceBall = ents.Create("prop_physics")
	bounceBall:SetModel("models/XQM/Rails/gumball_1.mdl")
	bounceBall:SetColor(Color(255, 0, 0, 255))
	bounceBall:Spawn()

	bounceBall:SetPos(shootpos)

	bounceBall:PhysicsInitSphere(16, "metal_bouncy")
	local bounceBall_phys = bounceBall:GetPhysicsObject()
	if not IsValid(bounceBall_phys) then
		bounceBall:Remove()
		return
	end
	bounceBall_phys:Wake()
	bounceBall_phys:ApplyForceCenter(shootdir * -1024)
	print("hey")


	bounceBall:AddCallback("PhysicsCollide", function(enthit, data)
		if not IsValid(bounceBall) then
			return
		end

		bounceBall:EmitSound("gmblox/superball.wav")

		if not IsValid(data.HitEntity) then
			return
		end

		if data.HitEntity:GetClass() == "gmbloxchar" and data.HitSpeed:Length() > 60 then
			data.HitEntity:TakeDamage(40)
		end
	end)

	timer.Simple(5, function()
		if not IsValid(bounceBall) then
			return
		end
		bounceBall:Remove()
	end)

	ent:EmitSound("gmblox/superball.wav")
end

GMBlox.DeclareGear(GEAR)