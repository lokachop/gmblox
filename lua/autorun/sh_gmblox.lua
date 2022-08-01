-- this file declares util gmblox funcs
-- needed for easily definable gears
-- coded by lokachop @ 23/07/2022
-- contact at Lokachop#5862 or lokachop@gmail.com



GMBlox = GMBlox or {}
GMBlox.ValidGears = {}
GMBlox.ValidFaces = {}
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
    tbl.icon = tbl.icon or "gmblox/vgui/lua.png"

    tbl.useCooldown = tbl.useCooldown or 0.5
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

-- declare og faces

GMBlox.DeclareFace("normal", "gmblox/face_background", "gmblox/vgui/smile-background.png")
GMBlox.DeclareFace(":3", "gmblox/colonthreebackground", "gmblox/vgui/colonthree-background.png")
GMBlox.DeclareFace("drool", "gmblox/face_drool", "gmblox/vgui/face_drool.png")

-- lets load all the gears now
local files = file.Find("gmblox/*.lua", "LUA")
for _, v in pairs(files) do
    if SERVER then
        AddCSLuaFile("gmblox/" .. v)
    end
    include("gmblox/" .. v)
end