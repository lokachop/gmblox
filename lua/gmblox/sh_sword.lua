local GEAR = {}
GEAR.name = "sword" -- name of the gear
GEAR.desc = "swording away" -- optional
GEAR.icon = "gmblox/vgui/Sword128.png" -- optional

GEAR.model = "models/gmblox/sword.mdl"
GEAR.modelOffset = Vector(-17, 0, 2)
GEAR.angleOffset = Angle(0, -90, 90)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.75 -- hacky hack for doublefire
GEAR.equipSound = "gmblox/unsheath.wav" -- optional

GEAR.animOverrideLUT = {}
GEAR.animOverrideLUT["leftarm"] = function(ent, k)
	return -90, 1024
end

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
end

GEAR.clThinkCallback = function(ent)
end

GEAR.clFinishedCallback = function(ent)
end

GEAR.clUnequip = function(ent)
	ent.AllowAnimOverride = false
end

GEAR.clEquip = function(ent)
	ent.AllowAnimOverride = true
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
	ent:EmitSound("gmblox/swordslash.wav")
end

GEAR.svThinkCallback = function(ent)
end

GEAR.svUnequip = function(ent)
end

GEAR.svEquip = function(ent)
end

GMBlox.DeclareGear(GEAR)