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
	ent.gearExtraOffset = Vector(-6, 17.5, -12)
	ent.gearExtraAngle = Angle(0, 0, 180)

	ent:RebuildActiveGear()
	-- do stuff
end

GEAR.clFinishedCallback = function(ent)
	ent.gearExtraOffset = Vector(0, 0, 0)
	ent.gearExtraAngle = Angle(0, 0, 0)

	ent:RebuildActiveGear()
	-- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	ent:EmitSound("gmblox/pizza_eat.wav")
end

GMBlox.DeclareGear(GEAR)