local GEAR = {}
GEAR.name = "cheezburger" -- name of the gear
GEAR.desc = "may i have a cheezburger please" -- optional
GEAR.icon = "gmblox/vgui/cheezburger_icon.png" -- optional

GEAR.model = "models/gmblox/cheezburger.mdl"
GEAR.modelOffset = Vector(3, 0, 4)
GEAR.angleOffset = Angle(90, 0, 180)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 1 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/cheezburger_equip.wav" -- optional

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
	ent.gearExtraOffset = Vector(-8, 18.25, -8)
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
	ent:EmitSound("gmblox/cheezburger_eat.wav")
end

GMBlox.DeclareGear(GEAR)