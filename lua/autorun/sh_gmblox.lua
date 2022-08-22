-- this file declares util gmblox funcs
-- needed for easily definable gears
-- coded by lokachop @ 23/07/2022
-- contact at Lokachop#5862 or lokachop@gmail.com



GMBlox = GMBlox or {}
GMBlox.ValidGears = {}
GMBlox.ValidFaces = {}
GMBlox.ValidHats = {}
GMBlox.DefaultInventory = GMBlox.DefaultInventory or {
	"rocketlauncher",
	"superball",
	"slingshot",
	"paintball",
	"bloxycola",
	"pizza",
	"cheezburger"
}

GMBlox.IsAllowedLUT = GMBlox.IsAllowedLUT or {}

function GMBlox.RebuildIsAllowedLUT()
	GMBlox.IsAllowedLUT = {}

	for k, v in pairs(GMBlox.DefaultInventory) do
		GMBlox.IsAllowedLUT[v] = true
	end
end
GMBlox.RebuildIsAllowedLUT()



-- creates a valid gear from a table
function GMBlox.DeclareGear(tbl)
	tbl.name = tbl.name or "Gear"
	tbl.desc = tbl.desc or "No description"
	tbl.model = tbl.model or "models/props_junk/popcan01a.mdl"
	tbl.material = tbl.material or ""
	tbl.icon = (tbl.icon and tbl.icon ~= "") and tbl.icon or "gmblox/vgui/lua.png"

	tbl.useCooldown = tbl.useCooldown or 0.5
	tbl.useCooldownDoubleFire = tbl.useCooldownDoubleFire or 0.5
	tbl.clCallback = tbl.clCallback or function() end
	tbl.svCallback = tbl.svCallback or function() end
	tbl.clFinishedCallback = tbl.clFinishedCallback or function() end
	tbl.svFinishedCallback = tbl.svFinishedCallback or function() end
	tbl.animOverrideLUT = tbl.animOverrideLUT or {}

	tbl.equipSound = tbl.equipSound or ""

	util.PrecacheModel(tbl.model)

	GMBlox.ValidGears[tbl.name] = tbl
end

function GMBlox.DeclareFace(name, mat, mat_ui)
	GMBlox.ValidFaces[name] = {
		mat = mat,
		matui = mat_ui
	}
end

function GMBlox.DeclareHat(name, model, posoff, angoff, scl)
	GMBlox.ValidHats[name] = {
		model = model,
		posOffset = posoff,
		angleOffset = angoff,
		name = name,
		scale = scl
	}
end



-- declare og faces
GMBlox.DeclareFace("normal", "gmblox/face_background", "gmblox/vgui/smile-background.png")
GMBlox.DeclareFace(":3", "gmblox/colonthreebackground", "gmblox/vgui/colonthree-background.png")
GMBlox.DeclareFace("drool", "gmblox/face_drool", "gmblox/vgui/face_drool.png")
GMBlox.DeclareFace("manface", "gmblox/face_man", "gmblox/vgui/face_man.png")
GMBlox.DeclareFace("palface", "gmblox/face_pal", "gmblox/vgui/face_pal.png")
GMBlox.DeclareFace("stare", "gmblox/face_stare", "gmblox/vgui/face_stare.png")

-- new update, new faces :D
GMBlox.DeclareFace(":D", "gmblox/face_d", "gmblox/vgui/face_d.png")
GMBlox.DeclareFace("sad", "gmblox/face_sad", "gmblox/vgui/face_sad.png")
GMBlox.DeclareFace("retro smiley", "gmblox/face_retrosmiley", "gmblox/vgui/face_retrosmiley.png")
GMBlox.DeclareFace("XD", "gmblox/face_xd", "gmblox/vgui/face_xd.png")
GMBlox.DeclareFace("fearless", "gmblox/face_fearless", "gmblox/vgui/face_fearless.png")
GMBlox.DeclareFace("finn mccool", "gmblox/face_finn", "gmblox/vgui/face_finn.png")


GMBlox.DeclareHat("Lamp Shade", "models/props_c17/lampShade001a.mdl", Vector(-3, 0, 0), Angle(0, 0, 0))
GMBlox.DeclareHat("Cone", "models/props_junk/TrafficCone001a.mdl", Vector(-14.4, 0, 0), Angle(0, 0, 0))
GMBlox.DeclareHat("Pot", "models/props_interiors/pot02a.mdl", Vector(-0, 6.9, -6.9), Angle(180, 0, 45), Vector(1.75, 1.75, 1.75))
GMBlox.DeclareHat("Tophat", "models/player/items/humans/top_hat.mdl", Vector(8.65, 0, 0), Angle(0, 0, 0), Vector(1.5, 1.75, 1.75))

-- from roblox
GMBlox.DeclareHat("Astronaut Helmet", "models/roblox_assets/astronaut_helmet.mdl", Vector(3.6, 0, 0), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))
GMBlox.DeclareHat("BC Hardhat", "models/roblox_assets/builders_club_hard_hat.mdl", Vector(-2.75, 0, 1), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))
GMBlox.DeclareHat("Doge", "models/roblox_assets/doge.mdl", Vector(5, 0, 3), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))
GMBlox.DeclareHat("Bloxxer Cap", "models/roblox_assets/bloxxer_cap.mdl", Vector(1, 0, 0), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))
GMBlox.DeclareHat("Kitty Ears", "models/roblox_assets/kitty_ears.mdl", Vector(-2, 0, 0), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))
GMBlox.DeclareHat("Shaggy", "models/roblox_assets/shaggy.mdl", Vector(3.25, -1, -1), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))

-- lets load all the gears now
local files = file.Find("gmblox/*.lua", "LUA")
for _, v in pairs(files) do
	if SERVER then
		AddCSLuaFile("gmblox/" .. v)
	end
	include("gmblox/" .. v)
end