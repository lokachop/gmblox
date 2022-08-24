-- this file declares util gmblox funcs
-- needed for easily definable gears
-- coded by lokachop @ 23/07/2022
-- contact at Lokachop#5862 or lokachop@gmail.com



GMBlox = GMBlox or {}


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
GMBlox.ValidGears = {}
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

GMBlox.ValidFaces = {}
function GMBlox.DeclareFace(name, mat, mat_ui)
	GMBlox.ValidFaces[name] = mat
end

GMBlox.ValidHats = {}
function GMBlox.DeclareHat(name, model, posoff, angoff, scl)
	GMBlox.ValidHats[name] = {
		model = model,
		posOffset = posoff,
		angleOffset = angoff,
		name = name,
		scale = scl
	}
end

GMBlox.ValidShirts = {}
function GMBlox.DeclareShirt(name, mat)
	GMBlox.ValidShirts[name] = mat
end

GMBlox.ValidTShirts = {}
function GMBlox.DeclareTShirt(name, mat)
	GMBlox.ValidTShirts[name] = mat
end


GMBlox.ValidPants = {}
function GMBlox.DeclarePants(name, mat)
	GMBlox.ValidPants[name] = mat
end

GMBlox.DeclareShirt("Battle Shirt of Awesomeness", "gmblox/shirt/awesomeness.png")
GMBlox.DeclareShirt("Stanford Shirt", "gmblox/shirt/stanford.png")
GMBlox.DeclareShirt("White Plaid Shirt", "gmblox/shirt/whiteplaid.png")
GMBlox.DeclareShirt("I <3 Chicken", "gmblox/shirt/chickenshirt.png")
GMBlox.DeclareShirt("Epic Shirt", "gmblox/shirt/epic_shirt.png")
GMBlox.DeclareShirt("Guest Shirt", "gmblox/shirt/guest_shirt.png")
GMBlox.DeclareShirt("Summertime Hoodie", "gmblox/shirt/summertime_hoodie.png")
GMBlox.DeclareShirt("Spaceman Suit", "gmblox/shirt/spaceman_suit.png")
GMBlox.DeclareShirt("Mad Murderer Hoodie", "gmblox/shirt/mad_murderer_hoodie.png")
GMBlox.DeclareShirt("Racing Jacket", "gmblox/shirt/racing_helmet_jacket.png")
GMBlox.DeclareShirt("Knight Shirt", "gmblox/shirt/knight_shirt.png")



GMBlox.DeclarePants("Battle Pants of Awesomeness", "gmblox/shirt/awesomeness.png")
GMBlox.DeclarePants("Jeans", "gmblox/shirt/jeans.png")
GMBlox.DeclarePants("Grey Wizard Robes", "gmblox/shirt/grey_wizard_robes.png")
GMBlox.DeclarePants("Toxic Pants", "gmblox/shirt/toxicpants.png")
GMBlox.DeclarePants("Mad Murderer Pants", "gmblox/shirt/mad_murderer_pants.png")
GMBlox.DeclarePants("Telamons Swim Trunks", "gmblox/shirt/telamons_swim_trunks.png")
GMBlox.DeclarePants("Classic Wizard Robes", "gmblox/shirt/classic_wizard.png")
GMBlox.DeclarePants("Golden Robe Of Pwnage", "gmblox/shirt/golden_robe.png")
GMBlox.DeclarePants("Racing Pants", "gmblox/shirt/racing_helmet_pants.png")
GMBlox.DeclarePants("Spaceman Pants", "gmblox/shirt/spaceman_pants.png")
GMBlox.DeclarePants("Knight Pants", "gmblox/shirt/knight_pants.png")


GMBlox.DeclareTShirt("Bloxxer", "gmblox/tshirt/bloxxer.png")
GMBlox.DeclareTShirt("Suit", "gmblox/tshirt/suit.png")
GMBlox.DeclareTShirt("Vest", "gmblox/tshirt/vest.png")
GMBlox.DeclareTShirt("Got Root?", "gmblox/tshirt/root.png")
GMBlox.DeclareTShirt("Lottery Ticket", "gmblox/tshirt/lottery.png")
GMBlox.DeclareTShirt("Wrench", "gmblox/tshirt/wrench.png")
GMBlox.DeclareTShirt("Pirate", "gmblox/tshirt/pirate.png")
GMBlox.DeclareTShirt("Coyote", "gmblox/tshirt/coyote.png")
GMBlox.DeclareTShirt("Im With Stupid", "gmblox/tshirt/im_with_stupid.png")
GMBlox.DeclareTShirt("2006 Logo", "gmblox/tshirt/2006_logo.png")
GMBlox.DeclareTShirt("OH NOES", "gmblox/tshirt/noes.png")


-- declare og faces
GMBlox.DeclareFace("normal", "gmblox/face/smile.png")
GMBlox.DeclareFace(":3", "gmblox/face/colonthree.png")
GMBlox.DeclareFace("drool", "gmblox/face/drool.png")
GMBlox.DeclareFace("manface", "gmblox/face/man.png")
GMBlox.DeclareFace("palface", "gmblox/face/pal.png")
GMBlox.DeclareFace("stare", "gmblox/face/stare.png")

-- new update, new faces :D
GMBlox.DeclareFace(":D", "gmblox/face/d.png")
GMBlox.DeclareFace("sad", "gmblox/face/sad.png")
GMBlox.DeclareFace("retro smiley", "gmblox/face/retrosmiley.png")
GMBlox.DeclareFace("XD", "gmblox/face/xd.png")
GMBlox.DeclareFace("fearless", "gmblox/face/fearless.png")
GMBlox.DeclareFace("finn mccool", "gmblox/face/finn.png")


GMBlox.DeclareHat("HL2 Lamp Shade", "models/props_c17/lampShade001a.mdl", Vector(-3, 0, 0), Angle(0, 0, 0))
GMBlox.DeclareHat("HL2 Cone", "models/props_junk/TrafficCone001a.mdl", Vector(-14.4, 0, 0), Angle(0, 0, 0))
GMBlox.DeclareHat("HL2 Pot", "models/props_interiors/pot02a.mdl", Vector(-0, 6.9, -6.9), Angle(180, 0, 45), Vector(1.75, 1.75, 1.75))
GMBlox.DeclareHat("HL2 Tophat", "models/player/items/humans/top_hat.mdl", Vector(8.65, 0, 0), Angle(0, 0, 0), Vector(1.5, 1.75, 1.75))

-- from roblox
GMBlox.DeclareHat("Astronaut Helmet", "models/roblox_assets/astronaut_helmet.mdl", Vector(2.4, 0, 0), Angle(0, 0, 180), Vector(1.25, 1.25, 1.25))
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