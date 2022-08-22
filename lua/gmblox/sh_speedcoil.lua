local GEAR = {}
GEAR.name = "Speed Coil" -- name of the gear
GEAR.desc = "vrooom" -- optional
GEAR.icon = "gmblox/vgui/speedcoil.png" -- optional

GEAR.model = "models/roblox_assets/speed_coil.mdl"
GEAR.modelOffset = Vector(0, 0, -9)
GEAR.angleOffset = Angle(90, 0, 0)
GEAR.scale = Vector(1.2, 1.2, 1.2)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/speedcoilsound.wav" -- optional

-- tr is a screentrace
GEAR.svEquip = function(ent)
	ent.WalkSpeedMult = 2
end

GEAR.svUnequip = function(ent)
	ent.WalkSpeedMult = 1
end

GMBlox.DeclareGear(GEAR)