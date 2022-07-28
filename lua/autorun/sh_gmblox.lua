-- this file declares util gmblox funcs
-- needed for easily definable gears
-- coded by lokachop @ 23/07/2022
-- contact at Lokachop#5862 or lokachop@gmail.com



GMBlox = GMBlox or {}
GMBlox.ValidGears = {}
GMBlox.DefaultInventory = {
    "rocketlauncher",
    "superball",
    "slingshot",
    "paintball",
    "bloxycola",
    "pizza",
    "cheezburger"
}

GMBlox.IsAllowedLUT = {}

function GMBlox.RebuildIsAllowedLUT()
    GMBlox.IsAllowedLUT = {}
    for k, v in pairs(GMBlox.DefaultInventory) do
        GMBlox.IsAllowedLUT[v] = true
    end
end

function GMBlox.RebuildDefaultInventory()
    GMBlox.DefaultInventory = {}
    for k, v in pairs(GMBlox.ValidGears) do
        local isallowed = GetConVar("gmblox_gear_" .. v.name .. "_is_default"):GetBool()

        if isallowed then
            GMBlox.DefaultInventory[#GMBlox.DefaultInventory + 1] = v.name
        end
    end

    GMBlox.RebuildIsAllowedLUT()
end

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


GMBlox.RebuildDefaultInventory()


if SERVER then
    util.AddNetworkString("gmblox_convarchanged_isdefault")
    util.AddNetworkString("gmblox_convarchanged_isdefault_cl")

    net.Receive("gmblox_convarchanged_isdefault", function(len, ply)
        if (ply.NextConvarChanged or 0) > CurTime() then
            return
        end

        ply.NextConvarChanged = CurTime() + 0.1

        if not ply:IsSuperAdmin() then
            return
        end

        GMBlox.RebuildDefaultInventory()
        net.Start("gmblox_convarchanged_isdefault_cl")
        net.Broadcast()
    end)

end

if CLIENT then
    net.Receive("gmblox_convarchanged_isdefault_cl", function()
        GMBlox.RebuildDefaultInventory()
    end)
end