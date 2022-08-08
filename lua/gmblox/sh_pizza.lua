local GEAR = {}
GEAR.name = "pizza" -- name of the gear
GEAR.desc = "pizza!" -- optional
GEAR.icon = "gmblox/vgui/pizzaicon_sz.png" -- optional

GEAR.model = "models/gmblox/robloxpizza.mdl"
GEAR.modelOffset = Vector(-2, 0, 7)
GEAR.angleOffset = Angle(90, 0, 0)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 1.5 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/pizza_equip.wav" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	ent:RebuildActiveGear()
	-- do stuff
end

GEAR.clFinishedCallback = function(ent)
	ent:RebuildActiveGear()
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	ent:SetGearOffset(Vector(-6, -18.25, -12))
	ent:SetGearAngle(Angle(0, 0, 180))

	ent:EmitSound("gmblox/pizza_eat.wav")
end

GEAR.svFinishedCallback = function(ent)
	ent:SetGearOffset(Vector(0, 0, 0))
	ent:SetGearAngle(Angle(0, 0, 0))
end

GMBlox.DeclareGear(GEAR)