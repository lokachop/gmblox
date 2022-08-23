local GEAR = {}
GEAR.name = "bloxycola" -- name of the gear
GEAR.desc = "bloxyyyy" -- optional
GEAR.icon = "gmblox/vgui/bloxy.png" -- optional

GEAR.model = "models/gmblox/bloxy.mdl"
GEAR.modelOffset = Vector(-0.15, 0, 4)
GEAR.angleOffset = Angle(90, 0, 180)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 4 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/bloxy_equip.wav" -- optional

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
	ent:SetGearOffset(Vector(-6, -18.25, -8))
	ent:SetGearAngle(Angle(-45, 0, 0))


	ent:EmitSound("gmblox/bloxy_drink.wav")
end

GEAR.svFinishedCallback = function(ent)
	ent:SetGearOffset(Vector(0, 0, 0))
	ent:SetGearAngle(Angle(0, 0, 0))

	local currHP = ent:GetHealthRoblox()
	ent:SetHealthRoblox(math.Clamp(currHP + 25, 0, 100))
end



GMBlox.DeclareGear(GEAR)