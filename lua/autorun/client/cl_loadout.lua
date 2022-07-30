GMBlox = GMBlox or {}

net.Receive("gmblox_change_is_allowed_cl", function()
    local json = net.ReadString()
    if not json then
        return
    end

    local alltbl = util.JSONToTable(json)

    GMBlox.DefaultInventory = {}
    for k, v in ipairs(alltbl) do
        GMBlox.DefaultInventory[#GMBlox.DefaultInventory + 1] = v
    end
    GMBlox.RebuildIsAllowedLUT()

    if not GMBlox.CheckList then
        return
    end

    for k, v in pairs(GMBlox.ValidGears) do
        if GMBlox.CheckList[v.name] then
            GMBlox.CheckList[v.name]:SetChecked(GMBlox.IsAllowedLUT[v.name] or false)
        end
    end
end)


hook.Add("InitPostEntity", "GMBloxRequestGear", function()
    net.Start("gmblox_request_allowed_gear")
    net.SendToServer()
end)