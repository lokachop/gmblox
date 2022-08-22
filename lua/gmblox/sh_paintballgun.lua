local GEAR = {}
GEAR.name = "paintball" -- name of the gear
GEAR.desc = "paintballing" -- optional
GEAR.icon = "gmblox/vgui/PaintballIcon.png" -- optional

GEAR.model = "models/gmblox/paintball_gun.mdl"
GEAR.modelOffset = Vector(-7, 2, 6)
GEAR.angleOffset = Angle(90, 0, -90)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.75 -- wait this many seconds before using again
GEAR.equipSound = "" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	-- do stuff
end


local function makePaintGibs(col, pos)
	for i = 1, 3 do
		local pGib = ents.Create("prop_physics")
		pGib:SetModel("models/hunter/plates/plate025x025.mdl")
		pGib:SetColor(HSVToColor(col, 1, 1))
		pGib:SetPos(pos)
		pGib:Spawn()

		local pGibPhys = pGib:GetPhysicsObject()
		if IsValid(pGibPhys) then
			pGibPhys:ApplyForceCenter(VectorRand(-100, 100))
			pGibPhys:SetMass(1)
		end

		pGib:SetCollisionGroup(COLLISION_GROUP_DEBRIS)


		timer.Simple(2, function()
			if not IsValid(pGib) then
				return
			end
			pGib:Remove()
		end)

	end

end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	local paintBall = ents.Create("prop_physics")
	paintBall:SetModel("models/hunter/misc/sphere025x025.mdl")
	paintBall:Spawn()
	paintBall:SetPos(shootpos)
	paintBall:SetGravity(0)
	paintBall.HSVCol = math.random(0, 360)
	paintBall:SetColor(HSVToColor(paintBall.HSVCol, 1, 1))

	local paintBall_phys = paintBall:GetPhysicsObject()
	if not IsValid(paintBall_phys) then
		paintBall:Remove()
		return
	end
	paintBall_phys:SetMass(1)
	paintBall_phys:Wake()
	paintBall_phys:ApplyForceCenter(shootdir * -512 * 2)
	paintBall_phys:EnableGravity(false)
	paintBall_phys:SetDragCoefficient(0)
	paintBall_phys:SetBuoyancyRatio(0)



	paintBall:AddCallback("PhysicsCollide", function(enthit, data)
		if not IsValid(paintBall) then
			return
		end

		local hent = data.HitEntity

		if IsValid(hent) and data.HitSpeed:Length() > 60 and IsValid(ent) then
			hent:TakeDamage(20, ent:GetController())
		end

		if CPPI and IsValid(hent) and not hent:CPPICanTool() then
			return
		end

		if IsValid(hent) and hent:GetClass() == "prop_physics" then
			hent:SetColor(HSVToColor(paintBall.HSVCol, 1, 1))
		end

		if not paintBall.HasGibbed then
			makePaintGibs(paintBall.HSVCol, paintBall:GetPos())
			paintBall.HasGibbed = true
		end

		paintBall:Remove()
	end)

	timer.Simple(5, function()
		if not IsValid(paintBall) then
			return
		end
		paintBall:Remove()
	end)

	ent:EmitSound("gmblox/paintball.wav")
end

GMBlox.DeclareGear(GEAR)