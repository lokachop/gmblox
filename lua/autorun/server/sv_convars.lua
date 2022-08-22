GMBlox = GMBlox or {}

function GMBlox.GetAllowedGearsFromFile()
    local allowed = file.Read("gmblox_allowed_gears.txt", "DATA")
    local alltbl = allowed and util.JSONToTable(allowed)
    if not alltbl then
        alltbl = {}
        for k, v in pairs(GMBlox.ValidGears) do
            alltbl[k] = true
        end
    end

    for k, v in pairs(alltbl) do
        if not GMBlox.ValidGears[k] then
            alltbl[k] = nil
        end
    end

    for k, v in pairs(GMBlox.ValidGears) do
        if alltbl[k] == nil then
            alltbl[k] = true
        end
    end

    return alltbl
end


function GMBlox.RebuildDefaultInventory()
    local alltbl = GMBlox.GetAllowedGearsFromFile()

    GMBlox.DefaultInventory = {}
    for k, v in pairs(alltbl) do
        if v == true then
            GMBlox.DefaultInventory[#GMBlox.DefaultInventory + 1] = k
        end
    end
    GMBlox.RebuildIsAllowedLUT()
end


function GMBlox.AddGearToSave(name)
    local alltbl = GMBlox.GetAllowedGearsFromFile()

    alltbl[name] = true
    file.Write("gmblox_allowed_gears.txt", util.TableToJSON(alltbl))

    GMBlox.RebuildDefaultInventory()
end

function GMBlox.RemoveGearFromSave(name)
    local alltbl = GMBlox.GetAllowedGearsFromFile()

    if alltbl[name] == true then
        alltbl[name] = false
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