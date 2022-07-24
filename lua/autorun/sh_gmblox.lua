-- this file declares util gmblox funcs
-- needed for easily definable gears
-- coded by lokachop @ 23/07/2022
-- contact at Lokachop#5862 or lokachop@gmail.com



GMBlox = GMBlox or {}
GMBlox.ValidGears = {}

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
    tbl.animOverrideLUT = tbl.animOverrideLUT or {}

    tbl.equipSound = tbl.equipSound or ""

    util.PrecacheModel(tbl.model)

    GMBlox.ValidGears[tbl.name] = tbl
end


-- example gear below
-- these are declared inside a lua folder called gmblox
--[[
local GEAR = {}
GEAR.name = "test gear" -- name of the gear
GEAR.desc = "this is a test gear" -- optional
GEAR.icon = "gmblox/vgui/Rocket.png" -- optional

GEAR.model = "models/props_junk/PopCan01a.mdl"
GEAR.modelOffset = Vector(0, 0, 0)
GEAR.angleOffset = Angle(0, 0, 0)

GEAR.material = "models/debug/debugwhite" -- material to paint the worldmodel, can be empty
GEAR.useCooldown = 0.1 -- wait this many seconds before using again

-- tr is a screentrace
GEAR.clCallback = function(ent, tr)
    -- do stuff
end

GEAR.svCallback = function(ent, hitpos, shootpos, shootdir)
    -- do stuff
end

GMBlox.DeclareGear(GEAR)
]]--


-- lets load all the gears now
local files = file.Find("gmblox/*.lua", "LUA")
for _, v in pairs(files) do
    if SERVER then
        AddCSLuaFile("gmblox/" .. v)
    end
    include("gmblox/" .. v)
end