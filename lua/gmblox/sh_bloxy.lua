local GEAR = {}
GEAR.name = "bloxycola" -- name of the gear
GEAR.desc = "bloxyyyy" -- optional
GEAR.icon = "gmblox/vgui/bloxy.png" -- optional

GEAR.model = "models/gmblox/bloxy.mdl"
GEAR.modelOffset = Vector(-2, 0, 4)
GEAR.angleOffset = Angle(90, 0, 180)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 4 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/bloxy_equip.wav" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	ent.gearExtraOffset = Vector(-4, 17.5, -8)
	ent.gearExtraAngle = Angle(-45, 0, 0)

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
	ent:EmitSound("gmblox/bloxy_drink.wav")
end

GMBlox.DeclareGear(GEAR)