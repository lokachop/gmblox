local GEAR = {}
GEAR.name = "Gravity Coil" -- name of the gear
GEAR.desc = "low gravity wooo" -- optional
GEAR.icon = "gmblox/vgui/gravitycoil.png" -- optional

GEAR.model = "models/roblox_assets/gravity_coil.mdl"
GEAR.modelOffset = Vector(0, 0, -9)
GEAR.angleOffset = Angle(90, 0, 0)
GEAR.scale = Vector(1.2, 1.2, 1.2)

GEAR.material = "" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0 -- wait this many seconds before using again
GEAR.equipSound = "gmblox/gravitycoilsound.wav" -- optional

-- tr is a screentrace
GEAR.svEquip = function(ent)
	local ephys = ent:GetPhysicsObject()

	if ephys:IsValid() then
		ephys:EnableGravity(false)
	end
	ent.GravityMult = 0
end

GEAR.svUnequip = function(ent)
	local ephys = ent:GetPhysicsObject()

	if ephys:IsValid() then
		ephys:EnableGravity(true)
	end
	ent.GravityMult = 1
end

GEAR.svThinkCallback = function(ent)
		local ephys = ent:GetPhysicsObject()
		if ephys then
			ephys:ApplyForceCenter(Vector(0, 0, ephys:GetMass() * -6))
		end
end

GMBlox.DeclareGear(GEAR)