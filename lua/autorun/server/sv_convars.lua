GMBlox = GMBlox or {}

function GMBlox.RebuildDefaultInventory()
    local allowed = file.Read("gmblox_allowed_gears.txt", "DATA")
    if not allowed then
        allowed = [[{"1":"rocketlauncher","2":"superball","3":"slingshot","4":"paintball","5":"bloxycola","6":"pizza","7":"cheezburger","superball":true,"paintball":true,"bloxycola":true,"cheezburger":true,"rocketlauncher":true,"pizza":true,"slingshot":true}]]
    end

    local alltbl = util.JSONToTable(allowed)
    if not alltbl then
        alltbl = {}
    end

    GMBlox.DefaultInventory = {}
    for k, v in pairs(alltbl) do
        GMBlox.DefaultInventory[#GMBlox.DefaultInventory + 1] = k
    end
    GMBlox.RebuildIsAllowedLUT()
end


function GMBlox.AddGearToSave(name)
    local allowed = file.Read("gmblox_allowed_gears.txt", "DATA")
    if not allowed then
        allowed = allowed = [[{"1":"rocketlauncher","2":"superball","3":"slingshot","4":"paintball","5":"bloxycola","6":"pizza","7":"cheezburger","superball":true,"paintball":true,"bloxycola":true,"cheezburger":true,"rocketlauncher":true,"pizza":true,"slingshot":true}]]
    end

    local alltbl = util.JSONToTable(allowed)
    if not alltbl then
        alltbl = {}
    end

    alltbl[name] = true
    file.Write("gmblox_allowed_gears.txt", util.TableToJSON(alltbl))

    GMBlox.RebuildDefaultInventory()
end

function GMBlox.RemoveGearFromSave(name)
    local allowed = file.Read("gmblox_allowed_gears.txt", "DATA")
    if not allowed then
        allowed = allowed = [[{"1":"rocketlauncher","2":"superball","3":"slingshot","4":"paintball","5":"bloxycola","6":"pizza","7":"cheezburger","superball":true,"paintball":true,"bloxycola":true,"cheezburger":true,"rocketlauncher":true,"pizza":true,"slingshot":true}]]
    end

    local alltbl = util.JSONToTable(allowed)
    if not alltbl then
        alltbl = {}
    end

    if alltbl[name] then
        alltbl[name] = nil
        file.Write("gmblox_allowed_gears.txt", util.TableToJSON(alltbl))
    end

    GMBlox.RebuildDefaultInventory()
end

function GMBlox.BroadcastAllowedGear()
    local str = util.TableToJSON(GMBlox.DefaultInventory, false)

    net.Start("gmblox_change_is_allowed_cl")
        net.WriteString(str)
    net.Broadcast()
end




util.AddNetworkString("gmblox_change_is_allowed")
util.AddNetworkString("gmblox_change_is_allowed_cl")
util.AddNetworkString("gmblox_request_allowed_gear")

net.Receive("gmblox_request_allowed_gear", function(len, ply)
    if (ply.NextRequestGear or 0) > CurTime() then
        return
    end
    ply.NextRequestGear = CurTime() + 2


    local str = util.TableToJSON(GMBlox.DefaultInventory, false)
    net.Start("gmblox_change_is_allowed_cl")
        net.WriteString(str)
    net.Send(ply)
end)

net.Receive("gmblox_change_is_allowed", function(len, ply)
    if not ply:IsSuperAdmin() then
        return
    end

    local gearName = net.ReadString()

    if not gearName then
        return
    end

    if not GMBlox.ValidGears[gearName] then
        return
    end

    local state = net.ReadBool()

    if state then
        GMBlox.AddGearToSave(gearName)
    else
        GMBlox.RemoveGearFromSave(gearName)
    end

    GMBlox.BroadcastAllowedGear()
end)


GMBlox.RebuildDefaultInventory()
GMBlox.BroadcastAllowedGear()