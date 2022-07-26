local GEAR = {}
GEAR.name = "rocketlauncher" -- name of the gear
GEAR.desc = "A rocketlauncher" -- optional
GEAR.icon = "gmblox/vgui/Rocket.png" -- optional

GEAR.model = "models/gmblox/rocketlauncher.mdl"
GEAR.modelOffset = Vector(-7.5, 0, -5)
GEAR.angleOffset = Angle(180, 0, 90)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 4 -- wait this many seconds before using again
GEAR.equipSound = "" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	local rocketProp = ents.Create("prop_physics")
	rocketProp:SetModel("models/hunter/blocks/cube025x075x025.mdl")
	rocketProp:SetColor(Color(64, 128, 255, 255))
	rocketProp:Spawn()
	if not IsValid(rocketProp) then
		return
	end

	rocketProp:SetPos(shootpos)

	local p_diff_ang = shootdir:Angle()
	rocketProp:SetAngles(p_diff_ang + Angle(90, 0, 90))
	rocketProp:EmitSound("gmblox/rocket_whoosh.wav")

	local rocketPhys = rocketProp:GetPhysicsObject()
	if not IsValid(rocketPhys) then
		rocketProp:Remove()
		return
	end
	rocketPhys:SetMass(500)
	rocketPhys:EnableGravity(false)
	rocketPhys:ApplyForceCenter(-shootdir * (1280 * 200))
	rocketPhys:SetDragCoefficient(0)
	rocketPhys:SetBuoyancyRatio(0)

	rocketProp:AddCallback("PhysicsCollide", function()
		if rocketProp.HasExploded or false then
			return
		end

		if not IsValid(ent) then
			rocketProp:Remove()
			return
		end

		if not IsValid(ent:GetController()) then
			rocketProp:Remove()
			return
		end

		util.BlastDamage(rocketProp, ent:GetController(), rocketProp:GetPos(), 160, 90)

		local effectdata = EffectData()
		EffectData():SetOrigin(rocketProp:GetPos())
		util.Effect("Explosion", effectdata, true, true)
		rocketProp.HasExploded = true

		rocketProp:StopSound("gmblox/rocket_whoosh.wav")
		rocketProp:Remove()
	end)

	timer.Simple(20, function()
		if not IsValid(rocketProp) then
			return
		end

		rocketProp:StopSound("gmblox/rocket_whoosh.wav")
		rocketProp:Remove()
	end)

	-- do stuff
end

GMBlox.DeclareGear(GEAR)